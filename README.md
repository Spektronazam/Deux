# Deux - The Successor Debugging Suite

![Deux Logo](/logo.png)

**Deux** is a complete rewrite and spiritual successor to New Dex — the most powerful debugging suite for Roblox. Built on the UNC/sUNC standard with zero Synapse-specific code, it runs on any modern executor.

## Install

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Spektronazam/Deux/feat/successor-rewrite/out.lua"))()
```

## Features

| Category | Feature | Status |
|----------|---------|--------|
| **Core** | UNC/sUNC environment abstraction | ✅ |
| **Core** | Cloneref hardening + gethui-first parenting | ✅ |
| **Core** | Persistent JSON settings (versioned, per-place) | ✅ |
| **Core** | Theme engine (Dark / Darker / Light + custom JSON) | ✅ |
| **Core** | Central keybind system (rebindable, no conflicts) | ✅ |
| **Core** | Toast notification system | ✅ |
| **Core** | Pub/sub state store (selection bus, events) | ✅ |
| **Explorer** | Click-to-select (3D parts + GUI objects) | ✅ |
| **Explorer** | Bookmarks / starred instances (per-place) | ✅ |
| **Explorer** | Advanced search (`class:` `name:` `tag:` `prop:` `nil:` `service:`) | ✅ |
| **Explorer** | Multi-select (Ctrl+Click, Shift+Click) | ✅ |
| **Explorer** | Nil instances tab | ✅ |
| **Explorer** | Deferred-event-safe batch updates | ✅ |
| **Explorer** | Full right-click context menu | ✅ |
| **Properties** | Tag Editor (CollectionService) | ✅ |
| **Properties** | Attribute CRUD (all types, rename, delete) | ✅ |
| **Properties** | Copy value as Lua / display / JSON | ✅ |
| **Properties** | Multi-instance editing with conflict detection | ✅ |
| **Properties** | Signal connections viewer (getconnections) | ✅ |
| **Properties** | Property search & category collapse | ✅ |
| **Properties** | Property change history (undo) | ✅ |
| **Script Editor** | Luau lexer with RichText syntax highlighting | ✅ |
| **Script Editor** | Tabbed interface | ✅ |
| **Script Editor** | Find / Replace (regex) | ✅ |
| **Script Editor** | Run buffer (F5, sandboxed) | ✅ |
| **Script Editor** | Decompile with timing + re-decompile + bytecode | ✅ |
| **Script Editor** | Status bar (line/col/total/modified) | ✅ |
| **Terminal** | 18 built-in commands | ✅ |
| **Terminal** | Tab-complete (commands + instance paths) | ✅ |
| **Terminal** | Command history (up/down, persisted) | ✅ |
| **Terminal** | Plugin-extensible command registry | ✅ |
| **Remote Spy** | Universal hook engine (metamethod + function + GC) | ✅ |
| **Remote Spy** | Default preset (FireServer/InvokeServer/__namecall) | ✅ |
| **Remote Spy** | Filter expressions (sandboxed Lua predicates) | ✅ |
| **Remote Spy** | Replay / Copy as Script | ✅ |
| **Remote Spy** | Save/load hook profiles | ✅ |
| **Save Instance** | Wraps saveinstance with options UI | ✅ |
| **Save Instance** | Scope: whole game / selection / nil | ✅ |
| **Save Instance** | Save as Model (subtree, rbxmx) | ✅ |
| **Data Inspector** | GC Explorer (filter by type/source/name/upvalue) | ✅ |
| **Data Inspector** | Function detail (env, consts, upvals, decompile) | ✅ |
| **Data Inspector** | Reference explorer (find all holders) | ✅ |
| **Data Inspector** | Constant-signature builder | ✅ |
| **Data Inspector** | Thread browser | ✅ |
| **Network Spy** | Inbound RemoteEvent/Function listener | ✅ |
| **Network Spy** | HTTP spy (RequestAsync, HttpGet) | ✅ |
| **Network Spy** | WebSocket monitor | ✅ |
| **API Reference** | Searchable class/member/enum docs | ✅ |
| **API Reference** | RMD descriptions, tags, security levels | ✅ |
| **Plugin System** | Plugin loader with sandboxed Dex API | ✅ |
| **Plugin System** | Manifest (plugin.json), manager UI | ✅ |
| **Plugin System** | Hot-reload on file change | ✅ |
| **Workspace Tools** | Freecam (WASD+QE+RMB) | ✅ |
| **Workspace Tools** | Noclip | ✅ |
| **Workspace Tools** | Selection highlight (Highlight instance) | ✅ |
| **Workspace Tools** | Quick toggles (Anchor, Transparent, Reset) | ✅ |
| **Workspace Tools** | Animation viewer | ✅ |
| **Console** | Captures print/warn/error + LogService | ✅ |
| **Console** | Filter by level, text search | ✅ |
| **Console** | Copy all / copy selection | ✅ |

## Architecture

```
Deux/
├── core/                   # Core systems (loaded first)
│   ├── Env.lua            # UNC/sUNC abstraction + capability detection
│   ├── Settings.lua       # Persistent JSON settings engine
│   ├── Theme.lua          # Theme engine (3 presets + custom)
│   ├── Keybinds.lua       # Central keybind registry
│   ├── Notifications.lua  # Toast notification system
│   └── Store.lua          # Pub/sub state store
├── modules/               # App modules
│   ├── Lib.lua            # UI primitives (Window, Signal, ScrollBar, etc.)
│   ├── Explorer.lua       # Instance tree explorer
│   ├── Properties.lua     # Property editor + tags + attributes
│   ├── ScriptEditor.lua   # Code editor with Luau highlighting
│   ├── Terminal.lua        # Command palette / terminal
│   ├── RemoteSpy.lua      # Universal hook/debug engine
│   ├── SaveInstance.lua   # Save place/model UI
│   ├── DataInspector.lua  # GC/function/reference explorer
│   ├── NetworkSpy.lua     # Inbound + HTTP + WebSocket viewer
│   ├── APIReference.lua   # Interactive API docs
│   ├── PluginAPI.lua      # Plugin system + manager
│   ├── WorkspaceTools.lua # Camera, highlight, toggles
│   └── Console.lua        # Output capture console
├── plugins/               # User plugins (loaded at runtime)
│   └── samples/           # Example plugins
├── main.lua               # Entry point + boot orchestrator
├── build.py               # Build system (bundle + hash + manifest)
├── VERSION                # Version string
└── out.lua                # Built output (single file)
```

## Building

```bash
python3 build.py              # Standard build -> out.lua
python3 build.py --minify     # + out.min.lua (stripped comments/whitespace)
python3 build.py --watch      # Rebuild on file changes
```

## Executor Compatibility

Deux runs on any executor supporting the UNC/sUNC standard. At boot it probes for capabilities and gracefully disables features that require missing APIs.

**Minimum requirements:** `readfile`, `writefile`, `makefolder`, `cloneref`, `gethui`

**Full features require:** `hookfunction`, `hookmetamethod`, `getgc`, `getreg`, `getconnections`, `decompile`, `saveinstance`, `getscriptbytecode`, `getthreads`, `request`, `WebSocket`

Run `version` in the Terminal to see your executor's compatibility score.

## Keybinds (Defaults)

| Key | Action |
|-----|--------|
| `RCtrl+D` | Toggle Deux menu |
| `Alt+Click` | Click-to-select (3D/GUI) |
| `Ctrl+C` | Copy instance path |
| `Ctrl+B` | Toggle bookmark |
| `Delete` | Delete selected |
| `F5` | Run script buffer |
| `Ctrl+D` | Re-decompile |
| `Ctrl+F` | Find in script |
| `Ctrl+S` | Save script |
| `Ctrl+W` | Close tab |
| `Ctrl+Z` | Undo property change |

All keybinds are rebindable via Settings.

## Plugin Development

Place plugins in `deux/plugins/<name>/`:

```
deux/plugins/my-plugin/
├── plugin.json    # {name, version, author, permissions}
└── init.lua       # Entry point
```

```lua
-- init.lua
Dex.Terminal.AddCommand({
    Name = "hello",
    Description = "Say hello",
    Run = function(args)
        Dex.Notify("Hello from plugin!", "Success")
    end
})

Dex.Explorer.AddRightClick("My Action", function(instance)
    print("Clicked on", instance.Name)
end)
```

## Credits

- **Moon / LorekeeperZinnia** — Original New Dex architecture, Lib module, and UI system
- **iris** — Successor co-conspirator and feature inspiration
- **Spektronazam** — Deux successor rewrite (v2.0.0)
- **UNC Community** — Unified Naming Convention standard

## License

MIT — See [LICENSE](LICENSE)
