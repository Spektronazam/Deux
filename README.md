# Deux

![Deux Logo](/logo.png)

Successor to New Dex. Same idea, same shape: an in-game Explorer / Properties /
Script Editor with a few extra tools sitting next to them. Built against UNC /
sUNC, no Synapse-specific calls.

## Install

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Spektronazam/Deux/master/out.lua"))()
```

There's also a stripped build (~10% smaller, same behaviour):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Spektronazam/Deux/master/out.min.lua"))()
```

## Layout

```
core/        env, settings, theme, keybinds, notifications, store
modules/     Lib (UI primitives) + the apps you click in the menu
main.lua     boot orchestrator
build.py     bundles everything into out.lua / out.min.lua
plugins/     drop-in user plugins (loaded at runtime from deux/plugins/)
```

Everything except `Lib` is loaded the same way: each module returns
`{InitDeps, InitAfterMain, Main}`, `main.lua` walks the list, threads the deps
through, and lights it all up in one shot.

## Building

```bash
python3 build.py            # out.lua
python3 build.py --minify   # + out.min.lua
python3 build.py --watch    # rebuild on change
python3 build.py --check    # verify on-disk hashes vs ModuleHashs.dat
```

## Executor compatibility

Anything that ships UNC works. At boot, `core/Env` probes for every API and
flips capability flags; modules that need a missing one just sit out instead
of crashing. The bare minimum is filesystem (`readfile`/`writefile`/`makefolder`),
`cloneref`, and `gethui`. Run `version` in the Terminal to see your score.

Things that *really* want to be there for the full experience:
`hookfunction`, `hookmetamethod`, `getgc`, `getreg`, `getconnections`,
`decompile`, `getscriptbytecode`, `saveinstance`, `request`, `WebSocket`.

## Default keybinds

| Key | Action |
|-----|--------|
| `RCtrl+D` | toggle the menu |
| `Alt+Click` | click-to-select (3D and GUI) |
| `Ctrl+C` | copy instance path |
| `Ctrl+B` | toggle bookmark |
| `Delete` | delete selected |
| `F5` | run buffer |
| `Ctrl+D` | re-decompile |
| `Ctrl+F` | find |
| `Ctrl+S` | save script |
| `Ctrl+W` | close tab |
| `Ctrl+Z` | undo property change |

All of them are rebindable in Settings.

## Plugins

Drop a folder into `deux/plugins/<name>/`:

```
deux/plugins/my-plugin/
  plugin.json
  init.lua
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

The sandbox is the `Dex.*` table; anything not on it isn't reachable.

## Credits

Original New Dex by Moon / LorekeeperZinnia. The Lib module here is largely
descended from theirs.

iris helped shape the successor plan.

Rewrite + extra modules by Spektronazam.

UNC / sUNC standard by the executor community.

## License

MIT. See [LICENSE](LICENSE).
