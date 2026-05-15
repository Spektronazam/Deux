#!/usr/bin/env python3
"""
Deux Build System
=================
Bundles core/ and modules/ into a single out.lua with:
- Deterministic module ordering
- SHA-256 hash generation (ModuleHashs.dat)
- Optional minification (--minify)
- Release manifest (manifest.json)
- Version + git commit embedding (runtime-readable as _G.DeuxBuild)
- --check mode (verify on-disk modules against ModuleHashs.dat)
- --watch mode (poll-based, rebuild on change)

Usage:
    python build.py              # Standard build
    python build.py --minify     # + minified out.min.lua
    python build.py --watch      # Watch mode (rebuild on change)
    python build.py --check      # Verify hashes match without building
    python build.py --version X  # Override version string
"""

import os
import sys
import json
import hashlib
import time
import subprocess
from pathlib import Path

# --- Configuration -----------------------------------------------------------

ROOT = Path(__file__).parent
CORE_DIR = ROOT / "core"
MODULES_DIR = ROOT / "modules"
MAIN_FILE = ROOT / "main.lua"
OUTPUT_FILE = ROOT / "out.lua"
OUTPUT_MIN_FILE = ROOT / "out.min.lua"
HASH_FILE = ROOT / "ModuleHashs.dat"
MANIFEST_FILE = ROOT / "manifest.json"
VERSION_FILE = ROOT / "VERSION"

# Order matters: core modules loaded first, then Lib (foundation), then app modules
CORE_ORDER = [
    "Env",
    "Settings",
    "Theme",
    "Keybinds",
    "Notifications",
    "Store",
]

MODULE_ORDER = [
    "Lib",
    "Explorer",
    "Properties",
    "ScriptEditor",
    "Terminal",
    "RemoteSpy",
    "SaveInstance",
    "DataInspector",
    "NetworkSpy",
    "APIReference",
    "PluginAPI",
    "WorkspaceTools",
    "Console",
]


# --- Helpers -----------------------------------------------------------------

def read_file(path: Path) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write_file(path: Path, content: str):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def sha256(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


def get_version(override=None) -> str:
    if override:
        return override
    if VERSION_FILE.exists():
        return read_file(VERSION_FILE).strip()
    try:
        result = subprocess.run(
            ["git", "describe", "--tags", "--always"],
            capture_output=True, text=True, cwd=ROOT, check=False,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except Exception:
        pass
    return "2.0.0"


def get_git_commit() -> str:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            capture_output=True, text=True, cwd=ROOT, check=False,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except Exception:
        pass
    return "unknown"


def lua_escape(s: str) -> str:
    """Escape a string for safe inclusion inside Lua double-quoted literals."""
    return (s.replace("\\", "\\\\")
             .replace('"', '\\"')
             .replace("\n", "\\n")
             .replace("\r", "\\r"))


# --- Minifier ----------------------------------------------------------------
# Strips comments and trailing whitespace while correctly skipping string and
# long-bracket spans. The previous implementation could mangle `--` and `]]`
# that appeared inside string literals.

def minify_lua(source: str) -> str:
    out = []
    i = 0
    n = len(source)

    while i < n:
        c = source[i]
        nxt = source[i + 1] if i + 1 < n else ""

        # Long bracket open: [[, [=[, [==[, ...
        if c == "[" and (nxt == "[" or nxt == "="):
            j = i + 1
            level = 0
            while j < n and source[j] == "=":
                level += 1
                j += 1
            if j < n and source[j] == "[":
                close = "]" + ("=" * level) + "]"
                end = source.find(close, j + 1)
                if end == -1:
                    out.append(source[i:])
                    break
                out.append(source[i:end + len(close)])
                i = end + len(close)
                continue

        # Comment
        if c == "-" and nxt == "-":
            # Long comment?
            k = i + 2
            if k < n and source[k] == "[":
                kk = k + 1
                level = 0
                while kk < n and source[kk] == "=":
                    level += 1
                    kk += 1
                if kk < n and source[kk] == "[":
                    close = "]" + ("=" * level) + "]"
                    end = source.find(close, kk + 1)
                    if end == -1:
                        break  # malformed, drop the rest
                    i = end + len(close)
                    continue
            # Line comment - skip to end of line
            while i < n and source[i] != "\n":
                i += 1
            continue

        # String literal
        if c == '"' or c == "'":
            quote = c
            out.append(c)
            i += 1
            while i < n:
                ch = source[i]
                if ch == "\\" and i + 1 < n:
                    out.append(source[i:i + 2])
                    i += 2
                    continue
                out.append(ch)
                i += 1
                if ch == quote:
                    break
                if ch == "\n":
                    break
            continue

        out.append(c)
        i += 1

    # Now collapse trailing whitespace and empty lines.
    text = "".join(out)
    lines = []
    for line in text.split("\n"):
        stripped = line.rstrip()
        if stripped.strip():
            lines.append(stripped)
    return "\n".join(lines)


# --- Build core --------------------------------------------------------------

def collect_modules() -> dict:
    """Return {name: source} for every core+app module."""
    result = {}
    for name in CORE_ORDER:
        path = CORE_DIR / f"{name}.lua"
        if path.exists():
            result[name] = read_file(path)
        else:
            print(f"  WARNING: Core module not found: {path}")
    for name in MODULE_ORDER:
        path = MODULES_DIR / f"{name}.lua"
        if path.exists():
            result[name] = read_file(path)
        else:
            print(f"  WARNING: Module not found: {path}")
    return result


def build_runtime_meta(version: str, commit: str, modules_hashes: dict) -> str:
    """Lua snippet that exposes _G.DeuxBuild for runtime introspection."""
    items = [f'    {{Name = "{name}", SHA256 = "{h}"}}'
             for name, h in sorted(modules_hashes.items())]
    credits = [
        "Moon/LorekeeperZinnia (New Dex original)",
        "iris (successor co-conspirator)",
        "Spektronazam (Deux rewrite)",
        "UNC Community",
    ]
    cred_lua = ", ".join(f'"{lua_escape(c)}"' for c in credits)
    return (
        "do\n"
        "  -- Auto-generated by build.py - do not edit\n"
        "  local prev = rawget(_G, \"DeuxBuild\")\n"
        "  if not prev then\n"
        "    _G.DeuxBuild = {\n"
        f'      Version    = "{lua_escape(version)}",\n'
        f'      Commit     = "{lua_escape(commit)}",\n'
        f'      BuildTime  = "{lua_escape(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))}",\n'
        f"      Credits    = {{{cred_lua}}},\n"
        "      Modules    = {\n"
        + ",\n".join(items) + "\n"
        "      },\n"
        "    }\n"
        "  end\n"
        "end\n"
    )


def build(minify=False, version_override=None) -> bool:
    version = get_version(version_override)
    commit = get_git_commit()
    print(f"[Deux Build] Version: {version}")
    print(f"[Deux Build] Commit:  {commit}")
    print(f"[Deux Build] Minify:  {minify}")

    sources = collect_modules()
    hashs = {name: sha256(src) for name, src in sources.items()}

    parts = []
    parts.append(f"-- Deux v{version} ({commit}) | Built {time.strftime('%Y-%m-%d %H:%M:%S')} UTC")
    parts.append("-- https://github.com/Spektronazam/Deux")
    parts.append("-- Credits: Moon/LorekeeperZinnia, iris, Spektronazam, UNC Community")
    parts.append("")
    parts.append(build_runtime_meta(version, commit, hashs))
    parts.append("local EmbeddedModules = {}")
    parts.append("")

    print(f"[Deux Build] Embedding {len(CORE_ORDER)} core modules...")
    for name in CORE_ORDER:
        if name not in sources:
            continue
        src = sources[name]
        parts.append(f'EmbeddedModules["{name}"] = function()')
        parts.append(src)
        parts.append("end")
        parts.append("")
        print(f"  + {name} ({len(src)} bytes)")

    print(f"[Deux Build] Embedding {len(MODULE_ORDER)} app modules...")
    for name in MODULE_ORDER:
        if name not in sources:
            continue
        src = sources[name]
        parts.append(f'EmbeddedModules["{name}"] = function()')
        parts.append(src)
        parts.append("end")
        parts.append("")
        print(f"  + {name} ({len(src)} bytes)")

    print("[Deux Build] Appending main.lua...")
    parts.append(read_file(MAIN_FILE))

    full_source = "\n".join(parts)

    write_file(OUTPUT_FILE, full_source)
    print(f"[Deux Build] Written: {OUTPUT_FILE} ({len(full_source):,} bytes)")

    minified_size = None
    if minify:
        minified = minify_lua(full_source)
        write_file(OUTPUT_MIN_FILE, minified)
        minified_size = len(minified)
        ratio = (1 - minified_size / max(len(full_source), 1)) * 100
        print(f"[Deux Build] Written: {OUTPUT_MIN_FILE} ({minified_size:,} bytes, {ratio:.1f}% smaller)")

    hash_lines = [f"{name}:{h}" for name, h in sorted(hashs.items())]
    write_file(HASH_FILE, "\n".join(hash_lines) + "\n")
    print(f"[Deux Build] Written: {HASH_FILE}")

    manifest = {
        "name": "Deux",
        "version": version,
        "commit": commit,
        "build_time": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "modules": list(CORE_ORDER) + list(MODULE_ORDER),
        "core_count": len(CORE_ORDER),
        "module_count": len(MODULE_ORDER),
        "total_size": len(full_source),
        "minified_size": minified_size,
        "sha256": sha256(full_source),
        "hashs": hashs,
    }
    write_file(MANIFEST_FILE, json.dumps(manifest, indent=2) + "\n")
    print(f"[Deux Build] Written: {MANIFEST_FILE}")

    print(f"\n[Deux Build] Done! Total: {len(full_source):,} bytes across {len(hashs)} modules.")
    return True


# --- Check mode --------------------------------------------------------------

def check() -> bool:
    """Compare on-disk modules against ModuleHashs.dat. Exit non-zero on drift."""
    if not HASH_FILE.exists():
        print(f"[Deux Check] {HASH_FILE} not present. Run a build first.")
        return False

    expected = {}
    for line in read_file(HASH_FILE).splitlines():
        line = line.strip()
        if not line:
            continue
        if ":" not in line:
            continue
        name, h = line.split(":", 1)
        expected[name.strip()] = h.strip()

    actual = {name: sha256(src) for name, src in collect_modules().items()}

    drifted, missing, extra = [], [], []
    for name, h in expected.items():
        if name not in actual:
            missing.append(name)
        elif actual[name] != h:
            drifted.append(name)
    for name in actual:
        if name not in expected:
            extra.append(name)

    if not (drifted or missing or extra):
        print(f"[Deux Check] OK - {len(actual)} modules match {HASH_FILE.name}.")
        return True

    if drifted:
        print(f"[Deux Check] DRIFT ({len(drifted)}): {', '.join(drifted)}")
    if missing:
        print(f"[Deux Check] MISSING ({len(missing)}): {', '.join(missing)}")
    if extra:
        print(f"[Deux Check] EXTRA ({len(extra)}): {', '.join(extra)}")
    return False


# --- Watch mode --------------------------------------------------------------

def watch():
    print("[Deux Build] Watch mode active. Press Ctrl+C to stop.")
    last_mtime = 0.0

    try:
        while True:
            current_mtime = 0.0
            paths = (list(CORE_DIR.glob("*.lua"))
                     + list(MODULES_DIR.glob("*.lua"))
                     + [MAIN_FILE])
            for path in paths:
                if path.exists():
                    mt = path.stat().st_mtime
                    if mt > current_mtime:
                        current_mtime = mt

            if current_mtime > last_mtime:
                if last_mtime > 0:
                    print("\n[Deux Build] Change detected, rebuilding...")
                build()
                last_mtime = current_mtime

            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[Deux Build] Watch stopped.")


# --- CLI ---------------------------------------------------------------------

if __name__ == "__main__":
    args = sys.argv[1:]

    do_minify = "--minify" in args
    do_watch = "--watch" in args
    do_check = "--check" in args

    version_override = None
    if "--version" in args:
        idx = args.index("--version")
        if idx + 1 < len(args):
            version_override = args[idx + 1]

    if do_check:
        ok = check()
        sys.exit(0 if ok else 1)

    if do_watch:
        watch()
    else:
        ok = build(minify=do_minify, version_override=version_override)
        sys.exit(0 if ok else 1)
