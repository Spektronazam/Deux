#!/usr/bin/env python3
"""
Deux Build System
=================
Bundles core/ and modules/ into a single out.lua with:
- Deterministic module ordering
- SHA-256 hash generation (ModuleHashs.dat)
- Optional minification (--minify)
- Release manifest (manifest.json)
- Version embedding from VERSION file or git tag

Usage:
    python build.py              # Standard build
    python build.py --minify     # Minified build
    python build.py --watch      # Watch mode (rebuild on change)
    python build.py --version X  # Override version string
"""

import os
import sys
import json
import hashlib
import time
import re
from pathlib import Path

# ─── Configuration ────────────────────────────────────────────────────────────

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

# ─── Helpers ──────────────────────────────────────────────────────────────────

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
    # Try git tag
    try:
        import subprocess
        result = subprocess.run(
            ["git", "describe", "--tags", "--always"],
            capture_output=True, text=True, cwd=ROOT
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except Exception:
        pass
    return "2.0.0"


def minify_lua(source: str) -> str:
    """Basic Lua minifier: strip comments, collapse whitespace, remove empty lines."""
    lines = source.split("\n")
    result = []
    in_block_comment = False

    for line in lines:
        # Handle block comments
        if in_block_comment:
            end_idx = line.find("]]")
            if end_idx != -1:
                in_block_comment = False
                line = line[end_idx + 2:]
            else:
                continue

        # Check for block comment start
        bc_start = line.find("--[[")
        if bc_start != -1:
            before = line[:bc_start]
            after = line[bc_start + 4:]
            bc_end = after.find("]]")
            if bc_end != -1:
                line = before + after[bc_end + 2:]
            else:
                in_block_comment = True
                line = before

        # Strip single-line comments (but not inside strings - simplified)
        comment_idx = line.find("--")
        if comment_idx != -1:
            # Simple check: not inside a string
            pre = line[:comment_idx]
            if pre.count('"') % 2 == 0 and pre.count("'") % 2 == 0:
                line = pre

        # Strip trailing whitespace
        line = line.rstrip()

        # Skip empty lines
        if line.strip():
            result.append(line)

    return "\n".join(result)


# ─── Build ────────────────────────────────────────────────────────────────────

def build(minify=False, version_override=None):
    version = get_version(version_override)
    print(f"[Deux Build] Version: {version}")
    print(f"[Deux Build] Minify: {minify}")

    hashs = {}
    parts = []

    # Header
    parts.append(f'-- Deux v{version} | Built {time.strftime("%Y-%m-%d %H:%M:%S")}')
    parts.append(f'-- https://github.com/Spektronazam/Deux')
    parts.append("")

    # Embedded modules container
    parts.append("local EmbeddedModules = {}")
    parts.append("")

    # Core modules
    print(f"[Deux Build] Embedding {len(CORE_ORDER)} core modules...")
    for name in CORE_ORDER:
        path = CORE_DIR / f"{name}.lua"
        if not path.exists():
            print(f"  WARNING: Core module not found: {path}")
            continue
        source = read_file(path)
        hashs[name] = sha256(source)
        # Wrap as a function that returns the module
        parts.append(f'EmbeddedModules["{name}"] = function()')
        parts.append(source)
        parts.append("end")
        parts.append("")
        print(f"  + {name} ({len(source)} bytes)")

    # App modules
    print(f"[Deux Build] Embedding {len(MODULE_ORDER)} app modules...")
    for name in MODULE_ORDER:
        path = MODULES_DIR / f"{name}.lua"
        if not path.exists():
            print(f"  WARNING: Module not found: {path}")
            continue
        source = read_file(path)
        hashs[name] = sha256(source)
        parts.append(f'EmbeddedModules["{name}"] = function()')
        parts.append(source)
        parts.append("end")
        parts.append("")
        print(f"  + {name} ({len(source)} bytes)")

    # Main loader
    print(f"[Deux Build] Appending main.lua...")
    main_source = read_file(MAIN_FILE)
    parts.append(main_source)

    # Join
    full_source = "\n".join(parts)

    # Write output
    write_file(OUTPUT_FILE, full_source)
    print(f"[Deux Build] Written: {OUTPUT_FILE} ({len(full_source)} bytes)")

    # Minified version
    if minify:
        minified = minify_lua(full_source)
        write_file(OUTPUT_MIN_FILE, minified)
        print(f"[Deux Build] Written: {OUTPUT_MIN_FILE} ({len(minified)} bytes, {100 - int(len(minified)/len(full_source)*100)}% smaller)")

    # Hash file
    hash_lines = []
    for name, h in sorted(hashs.items()):
        hash_lines.append(f"{name}:{h}")
    write_file(HASH_FILE, "\n".join(hash_lines))
    print(f"[Deux Build] Written: {HASH_FILE}")

    # Manifest
    manifest = {
        "name": "Deux",
        "version": version,
        "build_time": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "modules": list(CORE_ORDER) + list(MODULE_ORDER),
        "core_count": len(CORE_ORDER),
        "module_count": len(MODULE_ORDER),
        "total_size": len(full_source),
        "minified_size": len(minified) if minify else None,
        "sha256": sha256(full_source),
        "hashs": hashs,
    }
    write_file(MANIFEST_FILE, json.dumps(manifest, indent=2))
    print(f"[Deux Build] Written: {MANIFEST_FILE}")

    print(f"\n[Deux Build] Done! Total: {len(full_source):,} bytes across {len(hashs)} modules.")
    return True


# ─── Watch Mode ───────────────────────────────────────────────────────────────

def watch():
    """Rebuild on file changes (poll-based)."""
    print("[Deux Build] Watch mode active. Press Ctrl+C to stop.")
    last_mtime = 0

    while True:
        current_mtime = 0
        for path in list(CORE_DIR.glob("*.lua")) + list(MODULES_DIR.glob("*.lua")) + [MAIN_FILE]:
            if path.exists():
                mt = path.stat().st_mtime
                if mt > current_mtime:
                    current_mtime = mt

        if current_mtime > last_mtime:
            if last_mtime > 0:
                print(f"\n[Deux Build] Change detected, rebuilding...")
            build()
            last_mtime = current_mtime

        time.sleep(1)


# ─── CLI ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    args = sys.argv[1:]

    do_minify = "--minify" in args
    do_watch = "--watch" in args
    version_override = None

    if "--version" in args:
        idx = args.index("--version")
        if idx + 1 < len(args):
            version_override = args[idx + 1]

    if do_watch:
        watch()
    else:
        success = build(minify=do_minify, version_override=version_override)
        sys.exit(0 if success else 1)
