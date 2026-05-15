--[[
	Deux Core :: Env
	UNC/sUNC Environment Abstraction & Capability Detection
	
	Provides a unified interface to executor functions following the
	Unified Naming Convention (UNC) standard. Falls back to legacy
	aliases when UNC names are unavailable.
	
	Usage:
		local Env = require("core/Env") -- loaded by main bundler
		if Env.Capabilities.Decompile then
			local src = Env.decompile(script)
		end
]]

local Env = {}
Env.Capabilities = {}
Env.ExecutorName = "Unknown"
Env.ExecutorVersion = ""
Env.MissingAPIs = {}

-- Utility: safe global resolve
local function resolveGlobal(...)
	for _, name in ipairs({...}) do
		local val = getfenv(0)[name] or _G[name] or shared[name]
		if val ~= nil then return val end
	end
	return nil
end

-- Utility: resolve from a table path (e.g. "debug.getupvalues")
local function resolveChain(chain)
	local parts = string.split(chain, ".")
	local current = getfenv(0)[parts[1]] or _G[parts[1]]
	if not current then return nil end
	for i = 2, #parts do
		current = current[parts[i]]
		if not current then return nil end
	end
	return current
end

-- Utility: register an env function with UNC-first fallback
local function register(envName, ...)
	local func = resolveGlobal(...)
	if func then
		Env[envName] = func
	else
		Env.MissingAPIs[#Env.MissingAPIs + 1] = envName
	end
	return func ~= nil
end

local function registerChain(envName, ...)
	for _, chain in ipairs({...}) do
		local func = resolveChain(chain)
		if func then
			Env[envName] = func
			return true
		end
	end
	Env.MissingAPIs[#Env.MissingAPIs + 1] = envName
	return false
end

------------------------------------------------------------------------
-- IDENTIFICATION
------------------------------------------------------------------------
local identifyFn = resolveGlobal("identifyexecutor", "getexecutorname", "get_executor_name")
if identifyFn then
	local s, name, ver = pcall(identifyFn)
	if s then
		Env.ExecutorName = name or "Unknown"
		Env.ExecutorVersion = ver or ""
	end
end

------------------------------------------------------------------------
-- FILESYSTEM (UNC Standard)
------------------------------------------------------------------------
register("readfile", "readfile")
register("writefile", "writefile")
register("appendfile", "appendfile")
register("makefolder", "makefolder", "mkdir")
register("listfiles", "listfiles", "list_files")
register("isfile", "isfile", "is_file")
register("isfolder", "isfolder", "is_folder")
register("delfile", "delfile", "del_file", "deletefile")
register("delfolder", "delfolder", "del_folder", "deletefolder")
register("loadfile", "dofile") -- not the same semantics but closest fallback

Env.Capabilities.Filesystem = (Env.readfile ~= nil and Env.writefile ~= nil and Env.makefolder ~= nil)

------------------------------------------------------------------------
-- CLOSURES & HOOKING (UNC Standard)
------------------------------------------------------------------------
register("hookfunction", "hookfunction", "hookfunc", "replaceclosure", "detour_function")
register("hookmetamethod", "hookmetamethod", "hook_metamethod")
register("newcclosure", "newcclosure", "new_cclosure")
register("iscclosure", "iscclosure", "is_c_closure")
register("islclosure", "islclosure", "is_l_closure")
register("clonefunction", "clonefunction", "clone_function")
register("getnamecallmethod", "getnamecallmethod", "get_namecall_method")
register("setnamecallmethod", "setnamecallmethod", "set_namecall_method")

Env.Capabilities.Hooking = (Env.hookfunction ~= nil or Env.hookmetamethod ~= nil)

------------------------------------------------------------------------
-- DEBUG (UNC Standard)
------------------------------------------------------------------------
registerChain("getupvalues", "debug.getupvalues", "getupvalues", "getupvals")
registerChain("setupvalue", "debug.setupvalue", "setupvalue", "setupval")
registerChain("getupvalue", "debug.getupvalue", "getupvalue", "getupval")
registerChain("getconstants", "debug.getconstants", "getconstants", "getconsts")
registerChain("setconstant", "debug.setconstant", "setconstant", "setconst")
registerChain("getconstant", "debug.getconstant", "getconstant", "getconst")
registerChain("getinfo", "debug.getinfo", "getinfo")
registerChain("getstack", "debug.getstack", "getstack")
registerChain("setstack", "debug.setstack", "setstack")
registerChain("getprotos", "debug.getprotos", "getprotos")
registerChain("getproto", "debug.getproto", "getproto")

Env.Capabilities.Debug = (Env.getupvalues ~= nil and Env.getconstants ~= nil)

------------------------------------------------------------------------
-- METATABLE (UNC Standard)
------------------------------------------------------------------------
register("getrawmetatable", "getrawmetatable", "get_raw_metatable")
register("setrawmetatable", "setrawmetatable", "set_raw_metatable")
register("setreadonly", "setreadonly", "set_readonly", "make_readonly")
register("isreadonly", "isreadonly", "is_readonly")

Env.Capabilities.Metatable = (Env.getrawmetatable ~= nil)

------------------------------------------------------------------------
-- INSTANCES & REFERENCES (UNC Standard)
------------------------------------------------------------------------
register("cloneref", "cloneref", "clone_ref")
register("gethui", "gethui", "get_hidden_ui")
register("protectgui", "protectgui", "protect_gui")
register("getnilinstances", "getnilinstances", "get_nil_instances")
register("getinstances", "getinstances", "get_instances")
register("fireclickdetector", "fireclickdetector", "fire_click_detector")
register("fireproximityprompt", "fireproximityprompt", "fire_proximity_prompt")
register("firetouchinterest", "firetouchinterest", "fire_touch_interest")
register("firesignal", "firesignal", "fire_signal")
register("getconnections", "getconnections", "get_connections")
register("getcallbackvalue", "getcallbackvalue", "get_callback_value")
register("sethiddenproperty", "sethiddenproperty", "set_hidden_property", "set_hidden_prop")
register("gethiddenproperty", "gethiddenproperty", "get_hidden_property", "get_hidden_prop")

Env.Capabilities.Instances = (Env.cloneref ~= nil)
Env.Capabilities.Connections = (Env.getconnections ~= nil)

------------------------------------------------------------------------
-- SCRIPTS (UNC Standard)
------------------------------------------------------------------------
register("decompile", "decompile", "decompile_script")
register("getscriptbytecode", "getscriptbytecode", "get_script_bytecode", "dumpstring")
register("getscripthash", "getscripthash", "get_script_hash")
register("getscriptclosure", "getscriptclosure", "get_script_closure", "getscriptfunction")
register("getscripts", "getscripts", "get_scripts")
register("getrunningscripts", "getrunningscripts", "get_running_scripts")
register("getloadedmodules", "getloadedmodules", "get_loaded_modules")
register("getscriptfromthread", "getscriptfromthread", "get_script_from_thread")

Env.Capabilities.Decompile = (Env.decompile ~= nil)
Env.Capabilities.ScriptBytecode = (Env.getscriptbytecode ~= nil)

------------------------------------------------------------------------
-- GC / REGISTRY (UNC Standard)
------------------------------------------------------------------------
register("getgc", "getgc", "get_gc_objects")
register("getreg", "getreg", "get_registry")
register("getthreads", "getthreads", "get_threads")
register("getthreadidentity", "getthreadidentity", "getidentity", "get_thread_identity", "getthreadcontext")
register("setthreadidentity", "setthreadidentity", "setidentity", "set_thread_identity", "setthreadcontext")

Env.Capabilities.GC = (Env.getgc ~= nil)
Env.Capabilities.Registry = (Env.getreg ~= nil)

------------------------------------------------------------------------
-- NETWORK / HTTP (UNC Standard)
------------------------------------------------------------------------
register("request", "request", "http_request", "httpRequest")
register("setclipboard", "setclipboard", "set_clipboard", "toclipboard")
register("getexecutorname", "identifyexecutor", "getexecutorname")

-- WebSocket
local wsClass = resolveGlobal("WebSocket", "websocket")
if wsClass and wsClass.connect then
	Env.WebSocket = wsClass
	Env.Capabilities.WebSocket = true
else
	Env.Capabilities.WebSocket = false
end

Env.Capabilities.HTTP = (Env.request ~= nil)
Env.Capabilities.Clipboard = (Env.setclipboard ~= nil)

------------------------------------------------------------------------
-- CRYPTO (UNC Standard)
------------------------------------------------------------------------
local cryptLib = resolveGlobal("crypt")
if cryptLib then
	Env.crypt = cryptLib
	Env.Capabilities.Crypt = true
else
	Env.Capabilities.Crypt = false
end

------------------------------------------------------------------------
-- DRAWING (UNC Standard)
------------------------------------------------------------------------
local drawingClass = resolveGlobal("Drawing")
if drawingClass then
	Env.Drawing = drawingClass
	Env.Capabilities.Drawing = true
else
	Env.Capabilities.Drawing = false
end
register("cleardrawcache", "cleardrawcache", "clear_draw_cache")

------------------------------------------------------------------------
-- SAVE INSTANCE
------------------------------------------------------------------------
register("saveinstance", "saveinstance", "save_instance")
Env.Capabilities.SaveInstance = (Env.saveinstance ~= nil)

------------------------------------------------------------------------
-- MISC (UNC Standard)
------------------------------------------------------------------------
register("getcustomasset", "getcustomasset", "getsynasset", "get_custom_asset")
register("queue_on_teleport", "queue_on_teleport", "queueonteleport")
register("checkcaller", "checkcaller", "check_caller")
register("isexecutorclosure", "isexecutorclosure", "is_executor_closure", "checkclosure")
register("lz4compress", "lz4compress")
register("lz4decompress", "lz4decompress")
register("messagebox", "messagebox", "message_box")
register("rconsoleprinт", "rconsoleprint", "rconsoleprinт")
register("rconsoleinfo", "rconsoleinfo")
register("rconsolewarn", "rconsolewarn")
register("rconsoleerr", "rconsoleerr")
register("rconsoleclear", "rconsoleclear")
register("rconsoleclose", "rconsoleclose")
register("rconsolecreate", "rconsolecreate")

------------------------------------------------------------------------
-- SAFE SERVICE ACCESS (cloneref-wrapped)
------------------------------------------------------------------------
local game = game
local cloneref = Env.cloneref

Env.getService = function(serviceName)
	local s, serv = pcall(game.GetService, game, serviceName)
	if not s then return nil end
	if cloneref then
		return cloneref(serv)
	end
	return serv
end

------------------------------------------------------------------------
-- SAFE GUI PARENTING
------------------------------------------------------------------------
Env.getGuiParent = function()
	-- Priority: gethui > CoreGui (elevated) > PlayerGui
	if Env.gethui then
		local s, hui = pcall(Env.gethui)
		if s and hui then return hui end
	end
	
	local s = pcall(function() return game:GetService("CoreGui"):GetFullName() end)
	if s then
		local cg = Env.getService("CoreGui")
		return cg
	end
	
	local Players = Env.getService("Players")
	if Players then
		local lp = Players.LocalPlayer
		if lp then
			local pg = lp:FindFirstChildOfClass("PlayerGui")
			if pg then return pg end
		end
	end
	
	return nil
end

------------------------------------------------------------------------
-- GUI PROTECTION
------------------------------------------------------------------------
Env.protectGui = function(gui)
	if Env.protectgui then
		pcall(Env.protectgui, gui)
	end
end

------------------------------------------------------------------------
-- CAPABILITY SUMMARY
------------------------------------------------------------------------
Env.getCapabilitySummary = function()
	local summary = {}
	for name, val in pairs(Env.Capabilities) do
		summary[#summary + 1] = name .. ": " .. (val and "YES" or "NO")
	end
	table.sort(summary)
	return table.concat(summary, "\n")
end

Env.getMissingAPIs = function()
	return Env.MissingAPIs
end

------------------------------------------------------------------------
-- sUNC TEST (optional, behind debug flag)
------------------------------------------------------------------------
Env.runCompatibilityTest = function()
	local results = {}
	local total, passed = 0, 0
	
	local tests = {
		{"readfile", Env.readfile},
		{"writefile", Env.writefile},
		{"makefolder", Env.makefolder},
		{"listfiles", Env.listfiles},
		{"isfile", Env.isfile},
		{"isfolder", Env.isfolder},
		{"cloneref", Env.cloneref},
		{"gethui", Env.gethui},
		{"getconnections", Env.getconnections},
		{"hookfunction", Env.hookfunction},
		{"hookmetamethod", Env.hookmetamethod},
		{"newcclosure", Env.newcclosure},
		{"decompile", Env.decompile},
		{"getscriptbytecode", Env.getscriptbytecode},
		{"getgc", Env.getgc},
		{"getreg", Env.getreg},
		{"getrawmetatable", Env.getrawmetatable},
		{"setreadonly", Env.setreadonly},
		{"request", Env.request},
		{"setclipboard", Env.setclipboard},
		{"getcustomasset", Env.getcustomasset},
		{"queue_on_teleport", Env.queue_on_teleport},
		{"getthreadidentity", Env.getthreadidentity},
		{"setthreadidentity", Env.setthreadidentity},
		{"getnilinstances", Env.getnilinstances},
		{"getloadedmodules", Env.getloadedmodules},
		{"firesignal", Env.firesignal},
		{"saveinstance", Env.saveinstance},
		{"checkcaller", Env.checkcaller},
	}
	
	for _, test in ipairs(tests) do
		total = total + 1
		local name, fn = test[1], test[2]
		local has = fn ~= nil
		if has then passed = passed + 1 end
		results[#results + 1] = {Name = name, Available = has}
	end
	
	return {
		Results = results,
		Total = total,
		Passed = passed,
		Score = math.floor((passed / total) * 100),
		Executor = Env.ExecutorName .. " " .. Env.ExecutorVersion
	}
end

return Env
