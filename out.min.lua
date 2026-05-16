do
  local prev = rawget(_G, "DeuxBuild")
  if not prev then
    _G.DeuxBuild = {
      Version    = "2.0.0",
      Commit     = "9fc1b9e",
      BuildTime  = "2026-05-16T05:13:21Z",
      Credits    = {"Moon/LorekeeperZinnia (New Dex original)", "iris (successor co-conspirator)", "Spektronazam (Deux rewrite)", "UNC Community"},
      Modules    = {
    {Name = "APIReference", SHA256 = "4288a2ed8c7962241024f1e95bf6991817a3a49d20f3e29ab8e0b1ae2800d221"},
    {Name = "Console", SHA256 = "c0ae9c734e260106e027129e225ced74e4058da8c6bacd1ee4a99ded9f2d38d2"},
    {Name = "DataInspector", SHA256 = "b3bcd852249da777897bfebef73745f202c36ea3912ef822a662f9156bd6d050"},
    {Name = "Env", SHA256 = "655d14d8118c242e815bc44725f74924e63d50c2ea304b1c939faf697385055f"},
    {Name = "Explorer", SHA256 = "971896151e49c97e501417bf58ae4e08f5cc51b30f6964d7e6587a23b90105cd"},
    {Name = "Keybinds", SHA256 = "90dcae39b20dc9dad53ae686379281955d82381b4da83e86029494258233e1e6"},
    {Name = "Lib", SHA256 = "40dc9d45b5384ce10279d2ccbc3ae7b5baca2d24279e8a8967c524b84f2664a7"},
    {Name = "NetworkSpy", SHA256 = "dde397c936f15b9b37a1d3fe7be762ac099abc302737e1ccbfff7c5520a89b43"},
    {Name = "Notifications", SHA256 = "85fbc0f9a498debf7cdfa2c5b9d22e3a54be85610290e34039366ad3262242fd"},
    {Name = "PluginAPI", SHA256 = "edc0fee6c975c11981df74da99423bae7fb6c396a5ed357c0fc6f3bc986aeb16"},
    {Name = "Properties", SHA256 = "fa0885fd5afdf27ded3549a304ae32f8fadc9896f3f80d5d43b0148e873a7fae"},
    {Name = "RemoteSpy", SHA256 = "7f26f732e8e92b5432c4d678052b46f569512fb232aebbe0a50c877ddfa01a3b"},
    {Name = "SaveInstance", SHA256 = "ed5842e6b2c10d49c99b683ed105639e8f1d18f3e9a0cbdd5b9af1f05eb53029"},
    {Name = "ScriptEditor", SHA256 = "32c18b60b8e482d2e38ae6dcd5450ebd82df3e2be1a0146d780acaefba5084ff"},
    {Name = "Settings", SHA256 = "0734d3c944bf5fdf372fd300a2cea62b16d1d31018553ad4bd9265f8b51e0cd6"},
    {Name = "Store", SHA256 = "3ac813ffe966dd16ab3b186412f5485074115a95322c3df0ce72f4ec2e9cc522"},
    {Name = "Terminal", SHA256 = "8696dacf3d5ff8951030d8aee79e390df86922b83f75d008ba8a58bca284f6d5"},
    {Name = "Theme", SHA256 = "d5a9ffdcf12be1994bd1cfe785a76210b19b9d6ca3bfd73d4a06867535cbba08"},
    {Name = "ThemePicker", SHA256 = "6fc96700071d05ab5fc0a45ab606ddc908ab2d018682cad021c3a87425b89dec"},
    {Name = "WorkspaceTools", SHA256 = "87968a461d6241ecb5636cb36a5ae7dddae2f36324ecfd4aedddc83507d032a0"}
      },
    }
  end
end
local EmbeddedModules = {}
EmbeddedModules["Env"] = function()
local Env = {}
Env.Capabilities = {}
Env.ExecutorName = "Unknown"
Env.ExecutorVersion = ""
Env.MissingAPIs = {}
local function resolveGlobal(...)
	for _, name in ipairs({...}) do
		local val = getfenv(0)[name] or _G[name] or shared[name]
		if val ~= nil then return val end
	end
	return nil
end
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
local identifyFn = resolveGlobal("identifyexecutor", "getexecutorname", "get_executor_name")
if identifyFn then
	local s, name, ver = pcall(identifyFn)
	if s then
		Env.ExecutorName = name or "Unknown"
		Env.ExecutorVersion = ver or ""
	end
end
register("readfile", "readfile")
register("writefile", "writefile")
register("appendfile", "appendfile")
register("makefolder", "makefolder", "mkdir")
register("listfiles", "listfiles", "list_files")
register("isfile", "isfile", "is_file")
register("isfolder", "isfolder", "is_folder")
register("delfile", "delfile", "del_file", "deletefile")
register("delfolder", "delfolder", "del_folder", "deletefolder")
register("loadfile", "dofile")
Env.Capabilities.Filesystem = (Env.readfile ~= nil and Env.writefile ~= nil and Env.makefolder ~= nil)
register("hookfunction", "hookfunction", "hookfunc", "replaceclosure", "detour_function")
register("hookmetamethod", "hookmetamethod", "hook_metamethod")
register("newcclosure", "newcclosure", "new_cclosure")
register("iscclosure", "iscclosure", "is_c_closure")
register("islclosure", "islclosure", "is_l_closure")
register("clonefunction", "clonefunction", "clone_function")
register("getnamecallmethod", "getnamecallmethod", "get_namecall_method")
register("setnamecallmethod", "setnamecallmethod", "set_namecall_method")
Env.Capabilities.Hooking = (Env.hookfunction ~= nil or Env.hookmetamethod ~= nil)
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
register("getrawmetatable", "getrawmetatable", "get_raw_metatable")
register("setrawmetatable", "setrawmetatable", "set_raw_metatable")
register("setreadonly", "setreadonly", "set_readonly", "make_readonly")
register("isreadonly", "isreadonly", "is_readonly")
Env.Capabilities.Metatable = (Env.getrawmetatable ~= nil)
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
register("getgc", "getgc", "get_gc_objects")
register("getreg", "getreg", "get_registry")
register("getthreads", "getthreads", "get_threads")
register("getthreadidentity", "getthreadidentity", "getidentity", "get_thread_identity", "getthreadcontext")
register("setthreadidentity", "setthreadidentity", "setidentity", "set_thread_identity", "setthreadcontext")
Env.Capabilities.GC = (Env.getgc ~= nil)
Env.Capabilities.Registry = (Env.getreg ~= nil)
register("request", "request", "http_request", "httpRequest")
register("setclipboard", "setclipboard", "set_clipboard", "toclipboard")
register("getexecutorname", "identifyexecutor", "getexecutorname")
local wsClass = resolveGlobal("WebSocket", "websocket")
if wsClass and wsClass.connect then
	Env.WebSocket = wsClass
	Env.Capabilities.WebSocket = true
else
	Env.Capabilities.WebSocket = false
end
Env.Capabilities.HTTP = (Env.request ~= nil)
Env.Capabilities.Clipboard = (Env.setclipboard ~= nil)
local cryptLib = resolveGlobal("crypt")
if cryptLib then
	Env.crypt = cryptLib
	Env.Capabilities.Crypt = true
else
	Env.Capabilities.Crypt = false
end
local drawingClass = resolveGlobal("Drawing")
if drawingClass then
	Env.Drawing = drawingClass
	Env.Capabilities.Drawing = true
else
	Env.Capabilities.Drawing = false
end
register("cleardrawcache", "cleardrawcache", "clear_draw_cache")
register("saveinstance", "saveinstance", "save_instance")
Env.Capabilities.SaveInstance = (Env.saveinstance ~= nil)
register("getcustomasset", "getcustomasset", "getsynasset", "get_custom_asset")
register("queue_on_teleport", "queue_on_teleport", "queueonteleport")
register("checkcaller", "checkcaller", "check_caller")
register("isexecutorclosure", "isexecutorclosure", "is_executor_closure", "checkclosure")
register("lz4compress", "lz4compress")
register("lz4decompress", "lz4decompress")
register("messagebox", "messagebox", "message_box")
register("rconsoleprint", "rconsoleprint", "rconsole_print", "consoleprint")
register("rconsoleinfo", "rconsoleinfo")
register("rconsolewarn", "rconsolewarn")
register("rconsoleerr", "rconsoleerr")
register("rconsoleclear", "rconsoleclear")
register("rconsoleclose", "rconsoleclose")
register("rconsolecreate", "rconsolecreate")
register("getrenv", "getrenv", "get_renv")
register("getsenv", "getsenv", "get_senv")
register("getgenv", "getgenv", "get_genv")
register("getfunctions", "getfunctions", "get_functions")
register("getallthreads", "getallthreads", "get_all_threads")
register("compareinstances", "compareinstances", "compare_instances")
register("isscriptable", "isscriptable", "is_scriptable")
register("setscriptable", "setscriptable", "set_scriptable")
do
	local ws = resolveGlobal("WebSocket")
	if ws and (ws.connect or ws.Connect) then
		Env.WebSocket = ws
		Env.Capabilities.WebSocket = true
	else
		Env.MissingAPIs[#Env.MissingAPIs + 1] = "WebSocket"
		Env.Capabilities.WebSocket = false
	end
end
registerChain("crypt_hash",     "crypt.hash",     "crypto.hash")
registerChain("crypt_base64encode", "crypt.base64encode", "crypto.base64encode", "base64encode", "base64_encode")
registerChain("crypt_base64decode", "crypt.base64decode", "crypto.base64decode", "base64decode", "base64_decode")
Env.Capabilities.Crypt = (Env.crypt_base64encode ~= nil and Env.crypt_base64decode ~= nil)
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
Env.getGuiParent = function()
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
Env.protectGui = function(gui)
	if Env.protectgui then
		pcall(Env.protectgui, gui)
	end
end
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
		{"getrenv", Env.getrenv},
		{"getsenv", Env.getsenv},
		{"getgenv", Env.getgenv},
		{"compareinstances", Env.compareinstances},
		{"setscriptable", Env.setscriptable},
		{"WebSocket", Env.WebSocket},
		{"firetouchinterest", Env.firetouchinterest},
		{"fireproximityprompt", Env.fireproximityprompt},
		{"fireclickdetector", Env.fireclickdetector},
		{"crypt_base64encode", Env.crypt_base64encode},
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
end
EmbeddedModules["Settings"] = function()
local Settings = {}
local SCHEMA_VERSION = 2
local FILE_PATH = "deux/settings.json"
local PLACE_FILE_PATH
local Env
local HttpService
local currentData = {}
local subscribers = {}
local globalSubscribers = {}
Settings.Defaults = {
	_SchemaVersion = SCHEMA_VERSION,
	General = {
		AutoUpdate = true,
		AutoUpdateChannel = "stable",
		StealthMode = false,
		ShowSplash = true,
		DebugMode = false,
	},
	Explorer = {
		Sorting = true,
		TeleportToOffset = {0, 0, 0},
		ClickToRename = true,
		ClickToSelect3D = true,
		ClickToSelectGUI = true,
		AutoUpdateSearch = true,
		AutoUpdateMode = 0,
		PartSelectionBox = true,
		GuiSelectionBox = true,
		CopyPathUseGetChildren = true,
		ShowNilInstances = true,
		BookmarksEnabled = true,
		MaxSearchResults = 500,
	},
	Properties = {
		MaxConflictCheck = 50,
		ShowDeprecated = false,
		ShowHidden = false,
		ClearOnFocus = false,
		LoadstringInput = true,
		NumberRounding = 3,
		ShowAttributes = true,
		MaxAttributes = 100,
		ShowTags = true,
		ShowConnections = true,
		ScaleType = 1,
		CopyFormat = "lua",
	},
	ScriptEditor = {
		FontSize = 14,
		Font = "Code",
		TabSize = 4,
		UseSpaces = false,
		WordWrap = false,
		ShowLineNumbers = true,
		ShowMinimap = false,
		AutoDecompile = true,
		HighlightCurrentLine = true,
	},
	Terminal = {
		FontSize = 13,
		MaxHistory = 200,
		MaxOutput = 5000,
		ShowTimestamps = true,
	},
	RemoteSpy = {
		Enabled = false,
		LogFireServer = true,
		LogInvokeServer = true,
		LogBindables = false,
		LogInbound = false,
		MaxLogs = 2000,
		AutoScroll = true,
		FilterExpression = "",
	},
	SaveInstance = {
		IncludeScriptSource = true,
		OptimizeMeshes = false,
		ScrubPlayerData = true,
		DefaultScope = "game",
	},
	DataInspector = {
		MaxGCResults = 1000,
		ShowFunctions = true,
		ShowTables = true,
		ShowThreads = true,
		AutoRefresh = false,
	},
	NetworkSpy = {
		LogHTTP = false,
		LogWebSocket = false,
		MaxLogs = 1000,
	},
	WorkspaceTools = {
		FreecamSpeed = 1,
		FreecamFOV = 70,
		HighlightColor = {0, 120, 255},
		HighlightTransparency = 0.5,
	},
	Console = {
		CaptureLogService = true,
		MaxLines = 3000,
		ShowTimestamps = true,
		FilterLevel = "all",
	},
	Plugins = {
		Enabled = true,
		AutoLoad = true,
		TrustedPlugins = {},
	},
}
local function deepCopy(t)
	if type(t) ~= "table" then return t end
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = deepCopy(v)
	end
	return copy
end
local function deepMerge(base, override)
	local result = deepCopy(base)
	if type(override) ~= "table" then return result end
	for k, v in pairs(override) do
		if type(v) == "table" and type(result[k]) == "table" and not v[1] then
			result[k] = deepMerge(result[k], v)
		else
			result[k] = deepCopy(v)
		end
	end
	return result
end
local function getNestedValue(tbl, path)
	local parts = string.split(path, ".")
	local current = tbl
	for _, part in ipairs(parts) do
		if type(current) ~= "table" then return nil end
		current = current[part]
	end
	return current
end
local function setNestedValue(tbl, path, value)
	local parts = string.split(path, ".")
	local current = tbl
	for i = 1, #parts - 1 do
		if type(current[parts[i]]) ~= "table" then
			current[parts[i]] = {}
		end
		current = current[parts[i]]
	end
	local lastKey = parts[#parts]
	local oldVal = current[lastKey]
	current[lastKey] = value
	return oldVal
end
local migrations = {}
migrations[1] = function(data)
	local migrated = deepCopy(Settings.Defaults)
	if data.Explorer then
		for k, v in pairs(data.Explorer) do
			if k ~= "_Recurse" and migrated.Explorer[k] ~= nil then
				migrated.Explorer[k] = v
			end
		end
	end
	if data.Properties then
		for k, v in pairs(data.Properties) do
			if k ~= "_Recurse" and migrated.Properties[k] ~= nil then
				migrated.Properties[k] = v
			end
		end
	end
	if data.Theme then
		migrated._LegacyTheme = data.Theme
	end
	migrated._SchemaVersion = 2
	return migrated
end
local function migrate(data)
	local version = data._SchemaVersion or 1
	while version < SCHEMA_VERSION do
		local migrator = migrations[version]
		if migrator then
			data = migrator(data)
		end
		version = version + 1
	end
	data._SchemaVersion = SCHEMA_VERSION
	return data
end
local function notifyChange(path, newVal, oldVal)
	for pattern, callbacks in pairs(subscribers) do
		if string.find(path, pattern, 1, true) == 1 then
			for _, cb in ipairs(callbacks) do
				task.spawn(cb, path, newVal, oldVal)
			end
		end
	end
	for _, cb in ipairs(globalSubscribers) do
		task.spawn(cb, path, newVal, oldVal)
	end
end
function Settings.Init(envRef, serviceTable)
	Env = envRef
	HttpService = serviceTable.HttpService or game:GetService("HttpService")
	local placeId = game.PlaceId
	if placeId and placeId ~= 0 then
		PLACE_FILE_PATH = "deux/settings_" .. tostring(placeId) .. ".json"
	end
	if Env.Capabilities.Filesystem then
		pcall(Env.makefolder, "deux")
		pcall(Env.makefolder, "deux/saved")
		pcall(Env.makefolder, "deux/plugins")
		pcall(Env.makefolder, "deux/themes")
		pcall(Env.makefolder, "deux/hooks")
		pcall(Env.makefolder, "deux/saved/scripts")
		pcall(Env.makefolder, "deux/saved/places")
		pcall(Env.makefolder, "deux/saved/bookmarks")
	end
	Settings.Load()
end
function Settings.Load()
	currentData = deepCopy(Settings.Defaults)
	if not Env or not Env.Capabilities.Filesystem then return end
	local s, raw = pcall(Env.readfile, FILE_PATH)
	if s and raw and raw ~= "" then
		local s2, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
		if s2 and type(decoded) == "table" then
			decoded = migrate(decoded)
			currentData = deepMerge(Settings.Defaults, decoded)
		end
	end
	if PLACE_FILE_PATH then
		local s3, placeRaw = pcall(Env.readfile, PLACE_FILE_PATH)
		if s3 and placeRaw and placeRaw ~= "" then
			local s4, placeData = pcall(HttpService.JSONDecode, HttpService, placeRaw)
			if s4 and type(placeData) == "table" then
				currentData = deepMerge(currentData, placeData)
			end
		end
	end
	currentData._SchemaVersion = SCHEMA_VERSION
end
function Settings.Save()
	if not Env or not Env.Capabilities.Filesystem then return false end
	local s, encoded = pcall(HttpService.JSONEncode, HttpService, currentData)
	if not s then return false end
	local s2 = pcall(Env.writefile, FILE_PATH, encoded)
	return s2
end
function Settings.SavePlaceOverrides(overrides)
	if not Env or not Env.Capabilities.Filesystem or not PLACE_FILE_PATH then return false end
	local s, encoded = pcall(HttpService.JSONEncode, HttpService, overrides)
	if not s then return false end
	local s2 = pcall(Env.writefile, PLACE_FILE_PATH, encoded)
	return s2
end
function Settings.Get(path)
	return getNestedValue(currentData, path)
end
function Settings.Set(path, value, noSave)
	local oldVal = getNestedValue(currentData, path)
	if oldVal == value then return end
	setNestedValue(currentData, path, value)
	notifyChange(path, value, oldVal)
	if not noSave then
		Settings.Save()
	end
end
function Settings.SetBatch(changes)
	for path, value in pairs(changes) do
		local oldVal = getNestedValue(currentData, path)
		if oldVal ~= value then
			setNestedValue(currentData, path, value)
			notifyChange(path, value, oldVal)
		end
	end
	Settings.Save()
end
function Settings.Reset(category)
	if category then
		local defaultCat = Settings.Defaults[category]
		if defaultCat then
			local oldCat = currentData[category]
			currentData[category] = deepCopy(defaultCat)
			notifyChange(category, currentData[category], oldCat)
		end
	else
		local old = currentData
		currentData = deepCopy(Settings.Defaults)
		notifyChange("", currentData, old)
	end
	Settings.Save()
end
function Settings.Subscribe(pathPrefix, callback)
	if not subscribers[pathPrefix] then
		subscribers[pathPrefix] = {}
	end
	table.insert(subscribers[pathPrefix], callback)
	return function()
		local list = subscribers[pathPrefix]
		if list then
			local idx = table.find(list, callback)
			if idx then table.remove(list, idx) end
		end
	end
end
function Settings.SubscribeAll(callback)
	table.insert(globalSubscribers, callback)
	return function()
		local idx = table.find(globalSubscribers, callback)
		if idx then table.remove(globalSubscribers, idx) end
	end
end
function Settings.GetAll()
	return currentData
end
function Settings.GetDefaults()
	return Settings.Defaults
end
function Settings.Export()
	if not HttpService then return nil end
	local s, json = pcall(HttpService.JSONEncode, HttpService, currentData)
	return s and json or nil
end
function Settings.Import(jsonStr)
	if not HttpService then return false end
	local s, decoded = pcall(HttpService.JSONDecode, HttpService, jsonStr)
	if not s or type(decoded) ~= "table" then return false end
	decoded = migrate(decoded)
	local old = currentData
	currentData = deepMerge(Settings.Defaults, decoded)
	notifyChange("", currentData, old)
	Settings.Save()
	return true
end
function Settings.GetSchemaVersion()
	return SCHEMA_VERSION
end
return Settings
end
EmbeddedModules["Theme"] = function()
local Theme = {}
local Env, Settings, HttpService, Lighting
local currentTheme = {}
local subscribers = {}
local globalSubscribers = {}
local currentPresetName = "Dark"
local currentFontName = "Gotham"
local rgb = Color3.fromRGB
local function colorToTable(c)
	return {math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)}
end
local function tableToColor(t)
	if type(t) == "table" and #t >= 3 then
		return rgb(t[1], t[2], t[3])
	end
	return rgb(255, 255, 255)
end
Theme.Presets = {
	Dark = {
		Name = "Dark",
		Main1 = rgb(52, 52, 52),
		Main2 = rgb(45, 45, 45),
		Main3 = rgb(38, 38, 38),
		Outline1 = rgb(33, 33, 33),
		Outline2 = rgb(55, 55, 55),
		Outline3 = rgb(30, 30, 30),
		TextBox = rgb(38, 38, 38),
		Menu = rgb(32, 32, 32),
		ListSelection = rgb(11, 90, 175),
		Button = rgb(60, 60, 60),
		ButtonHover = rgb(68, 68, 68),
		ButtonPress = rgb(40, 40, 40),
		Highlight = rgb(75, 75, 75),
		Text = rgb(255, 255, 255),
		TextDim = rgb(180, 180, 180),
		PlaceholderText = rgb(100, 100, 100),
		Important = rgb(255, 80, 80),
		Success = rgb(80, 200, 120),
		Warning = rgb(255, 200, 50),
		Accent = rgb(0, 120, 215),
		ScrollBar = rgb(80, 80, 80),
		ScrollBarHover = rgb(100, 100, 100),
		Separator = rgb(40, 40, 40),
		TabActive = rgb(60, 60, 60),
		TabInactive = rgb(38, 38, 38),
		Notification = rgb(45, 45, 45),
		NotificationBorder = rgb(70, 70, 70),
		Syntax = {
			Text = rgb(204, 204, 204),
			Background = rgb(36, 36, 36),
			Selection = rgb(255, 255, 255),
			SelectionBack = rgb(11, 90, 175),
			Operator = rgb(204, 204, 204),
			Number = rgb(255, 198, 0),
			String = rgb(173, 241, 149),
			Comment = rgb(102, 102, 102),
			Keyword = rgb(248, 109, 124),
			Error = rgb(255, 60, 60),
			FindBackground = rgb(141, 118, 0),
			MatchingWord = rgb(85, 85, 85),
			BuiltIn = rgb(132, 214, 247),
			CurrentLine = rgb(45, 50, 65),
			LocalMethod = rgb(253, 251, 172),
			LocalProperty = rgb(97, 161, 241),
			Nil = rgb(255, 198, 0),
			Bool = rgb(255, 198, 0),
			Function = rgb(248, 109, 124),
			Local = rgb(248, 109, 124),
			Self = rgb(248, 109, 124),
			FunctionName = rgb(253, 251, 172),
			Bracket = rgb(204, 204, 204),
			TypeAnnotation = rgb(78, 201, 176),
		},
	},
	Darker = {
		Name = "Darker",
		Main1 = rgb(30, 30, 30),
		Main2 = rgb(25, 25, 25),
		Main3 = rgb(20, 20, 20),
		Outline1 = rgb(18, 18, 18),
		Outline2 = rgb(40, 40, 40),
		Outline3 = rgb(15, 15, 15),
		TextBox = rgb(22, 22, 22),
		Menu = rgb(18, 18, 18),
		ListSelection = rgb(0, 80, 160),
		Button = rgb(40, 40, 40),
		ButtonHover = rgb(50, 50, 50),
		ButtonPress = rgb(28, 28, 28),
		Highlight = rgb(55, 55, 55),
		Text = rgb(240, 240, 240),
		TextDim = rgb(160, 160, 160),
		PlaceholderText = rgb(80, 80, 80),
		Important = rgb(255, 70, 70),
		Success = rgb(60, 180, 100),
		Warning = rgb(240, 180, 40),
		Accent = rgb(0, 100, 200),
		ScrollBar = rgb(55, 55, 55),
		ScrollBarHover = rgb(75, 75, 75),
		Separator = rgb(25, 25, 25),
		TabActive = rgb(40, 40, 40),
		TabInactive = rgb(22, 22, 22),
		Notification = rgb(25, 25, 25),
		NotificationBorder = rgb(50, 50, 50),
		Syntax = {
			Text = rgb(200, 200, 200),
			Background = rgb(18, 18, 18),
			Selection = rgb(255, 255, 255),
			SelectionBack = rgb(0, 70, 140),
			Operator = rgb(200, 200, 200),
			Number = rgb(255, 190, 0),
			String = rgb(160, 230, 140),
			Comment = rgb(90, 90, 90),
			Keyword = rgb(240, 100, 115),
			Error = rgb(255, 50, 50),
			FindBackground = rgb(130, 108, 0),
			MatchingWord = rgb(70, 70, 70),
			BuiltIn = rgb(120, 200, 240),
			CurrentLine = rgb(30, 35, 50),
			LocalMethod = rgb(245, 243, 165),
			LocalProperty = rgb(85, 150, 230),
			Nil = rgb(255, 190, 0),
			Bool = rgb(255, 190, 0),
			Function = rgb(240, 100, 115),
			Local = rgb(240, 100, 115),
			Self = rgb(240, 100, 115),
			FunctionName = rgb(245, 243, 165),
			Bracket = rgb(200, 200, 200),
			TypeAnnotation = rgb(70, 190, 165),
		},
	},
	Light = {
		Name = "Light",
		Main1 = rgb(243, 243, 243),
		Main2 = rgb(235, 235, 235),
		Main3 = rgb(250, 250, 250),
		Outline1 = rgb(210, 210, 210),
		Outline2 = rgb(195, 195, 195),
		Outline3 = rgb(220, 220, 220),
		TextBox = rgb(255, 255, 255),
		Menu = rgb(248, 248, 248),
		ListSelection = rgb(0, 120, 215),
		Button = rgb(225, 225, 225),
		ButtonHover = rgb(215, 215, 215),
		ButtonPress = rgb(200, 200, 200),
		Highlight = rgb(210, 210, 210),
		Text = rgb(30, 30, 30),
		TextDim = rgb(100, 100, 100),
		PlaceholderText = rgb(160, 160, 160),
		Important = rgb(200, 40, 40),
		Success = rgb(30, 150, 80),
		Warning = rgb(200, 140, 0),
		Accent = rgb(0, 120, 215),
		ScrollBar = rgb(195, 195, 195),
		ScrollBarHover = rgb(170, 170, 170),
		Separator = rgb(220, 220, 220),
		TabActive = rgb(255, 255, 255),
		TabInactive = rgb(235, 235, 235),
		Notification = rgb(255, 255, 255),
		NotificationBorder = rgb(200, 200, 200),
		Syntax = {
			Text = rgb(30, 30, 30),
			Background = rgb(255, 255, 255),
			Selection = rgb(0, 0, 0),
			SelectionBack = rgb(173, 214, 255),
			Operator = rgb(30, 30, 30),
			Number = rgb(9, 134, 88),
			String = rgb(163, 21, 21),
			Comment = rgb(0, 128, 0),
			Keyword = rgb(0, 0, 255),
			Error = rgb(255, 0, 0),
			FindBackground = rgb(255, 255, 150),
			MatchingWord = rgb(230, 230, 230),
			BuiltIn = rgb(38, 127, 153),
			CurrentLine = rgb(240, 240, 255),
			LocalMethod = rgb(116, 83, 0),
			LocalProperty = rgb(0, 70, 140),
			Nil = rgb(9, 134, 88),
			Bool = rgb(9, 134, 88),
			Function = rgb(0, 0, 255),
			Local = rgb(0, 0, 255),
			Self = rgb(0, 0, 255),
			FunctionName = rgb(116, 83, 0),
			Bracket = rgb(30, 30, 30),
			TypeAnnotation = rgb(38, 127, 153),
		},
	},
	New = {
		Name = "New",
		Main1 = rgb(48, 50, 56),
		Main2 = rgb(40, 42, 48),
		Main3 = rgb(34, 36, 42),
		Outline1 = rgb(28, 30, 35),
		Outline2 = rgb(56, 60, 68),
		Outline3 = rgb(24, 26, 30),
		TextBox = rgb(34, 36, 42),
		Menu = rgb(28, 30, 35),
		ListSelection = rgb(0, 110, 200),
		Button = rgb(60, 64, 72),
		ButtonHover = rgb(70, 74, 84),
		ButtonPress = rgb(45, 48, 54),
		Highlight = rgb(78, 82, 92),
		Text = rgb(232, 234, 240),
		TextDim = rgb(170, 176, 188),
		PlaceholderText = rgb(110, 114, 124),
		Important = rgb(255, 90, 90),
		Success = rgb(80, 200, 130),
		Warning = rgb(255, 200, 60),
		Accent = rgb(56, 142, 235),
		ScrollBar = rgb(78, 82, 92),
		ScrollBarHover = rgb(98, 102, 114),
		Separator = rgb(36, 38, 44),
		TabActive = rgb(60, 64, 72),
		TabInactive = rgb(34, 36, 42),
		Notification = rgb(40, 42, 48),
		NotificationBorder = rgb(70, 74, 84),
		Syntax = {
			Text = rgb(220, 222, 228),
			Background = rgb(34, 36, 42),
			Selection = rgb(255, 255, 255),
			SelectionBack = rgb(0, 110, 200),
			Operator = rgb(220, 222, 228),
			Number = rgb(255, 198, 0),
			String = rgb(173, 241, 149),
			Comment = rgb(110, 114, 124),
			Keyword = rgb(248, 109, 124),
			Error = rgb(255, 60, 60),
			FindBackground = rgb(141, 118, 0),
			MatchingWord = rgb(78, 82, 92),
			BuiltIn = rgb(132, 214, 247),
			CurrentLine = rgb(48, 56, 78),
			LocalMethod = rgb(253, 251, 172),
			LocalProperty = rgb(97, 161, 241),
			Nil = rgb(255, 198, 0),
			Bool = rgb(255, 198, 0),
			Function = rgb(248, 109, 124),
			Local = rgb(248, 109, 124),
			Self = rgb(248, 109, 124),
			FunctionName = rgb(253, 251, 172),
			Bracket = rgb(220, 222, 228),
			TypeAnnotation = rgb(78, 201, 176),
		},
	},
	Dex = {
		Name = "Dex",
		Main1 = rgb(52, 52, 52),
		Main2 = rgb(45, 45, 45),
		Main3 = rgb(38, 38, 38),
		Outline1 = rgb(33, 33, 33),
		Outline2 = rgb(55, 55, 55),
		Outline3 = rgb(30, 30, 30),
		TextBox = rgb(38, 38, 38),
		Menu = rgb(32, 32, 32),
		ListSelection = rgb(11, 90, 175),
		Button = rgb(60, 60, 60),
		ButtonHover = rgb(68, 68, 68),
		ButtonPress = rgb(40, 40, 40),
		Highlight = rgb(75, 75, 75),
		Text = rgb(255, 255, 255),
		TextDim = rgb(180, 180, 180),
		PlaceholderText = rgb(100, 100, 100),
		Important = rgb(255, 80, 80),
		Success = rgb(80, 200, 120),
		Warning = rgb(255, 200, 50),
		Accent = rgb(0, 162, 255),
		ScrollBar = rgb(80, 80, 80),
		ScrollBarHover = rgb(100, 100, 100),
		Separator = rgb(40, 40, 40),
		TabActive = rgb(60, 60, 60),
		TabInactive = rgb(38, 38, 38),
		Notification = rgb(45, 45, 45),
		NotificationBorder = rgb(70, 70, 70),
		Syntax = {
			Text = rgb(204, 204, 204),
			Background = rgb(36, 36, 36),
			Selection = rgb(255, 255, 255),
			SelectionBack = rgb(11, 90, 175),
			Operator = rgb(204, 204, 204),
			Number = rgb(255, 198, 0),
			String = rgb(173, 241, 149),
			Comment = rgb(102, 102, 102),
			Keyword = rgb(248, 109, 124),
			Error = rgb(255, 60, 60),
			FindBackground = rgb(141, 118, 0),
			MatchingWord = rgb(85, 85, 85),
			BuiltIn = rgb(132, 214, 247),
			CurrentLine = rgb(45, 50, 65),
			LocalMethod = rgb(253, 251, 172),
			LocalProperty = rgb(97, 161, 241),
			Nil = rgb(255, 198, 0),
			Bool = rgb(255, 198, 0),
			Function = rgb(248, 109, 124),
			Local = rgb(248, 109, 124),
			Self = rgb(248, 109, 124),
			FunctionName = rgb(253, 251, 172),
			Bracket = rgb(204, 204, 204),
			TypeAnnotation = rgb(78, 201, 176),
		},
	},
	["Old Dex"] = {
		Name = "Old Dex",
		Main1 = rgb(212, 208, 200),
		Main2 = rgb(196, 192, 184),
		Main3 = rgb(228, 224, 216),
		Outline1 = rgb(120, 116, 108),
		Outline2 = rgb(140, 136, 128),
		Outline3 = rgb(160, 156, 148),
		TextBox = rgb(255, 255, 255),
		Menu = rgb(228, 224, 216),
		ListSelection = rgb(49, 106, 197),
		Button = rgb(212, 208, 200),
		ButtonHover = rgb(228, 224, 216),
		ButtonPress = rgb(180, 176, 168),
		Highlight = rgb(196, 192, 184),
		Text = rgb(0, 0, 0),
		TextDim = rgb(80, 80, 80),
		PlaceholderText = rgb(140, 136, 128),
		Important = rgb(180, 30, 30),
		Success = rgb(20, 130, 60),
		Warning = rgb(180, 120, 0),
		Accent = rgb(49, 106, 197),
		ScrollBar = rgb(160, 156, 148),
		ScrollBarHover = rgb(140, 136, 128),
		Separator = rgb(180, 176, 168),
		TabActive = rgb(228, 224, 216),
		TabInactive = rgb(196, 192, 184),
		Notification = rgb(228, 224, 216),
		NotificationBorder = rgb(140, 136, 128),
		Syntax = {
			Text = rgb(0, 0, 0),
			Background = rgb(255, 255, 255),
			Selection = rgb(0, 0, 0),
			SelectionBack = rgb(160, 200, 240),
			Operator = rgb(0, 0, 0),
			Number = rgb(0, 0, 200),
			String = rgb(160, 30, 30),
			Comment = rgb(0, 120, 0),
			Keyword = rgb(0, 0, 200),
			Error = rgb(220, 0, 0),
			FindBackground = rgb(255, 255, 150),
			MatchingWord = rgb(220, 220, 220),
			BuiltIn = rgb(60, 100, 160),
			CurrentLine = rgb(240, 240, 200),
			LocalMethod = rgb(140, 80, 0),
			LocalProperty = rgb(40, 80, 140),
			Nil = rgb(0, 0, 200),
			Bool = rgb(0, 0, 200),
			Function = rgb(0, 0, 200),
			Local = rgb(0, 0, 200),
			Self = rgb(0, 0, 200),
			FunctionName = rgb(140, 80, 0),
			Bracket = rgb(0, 0, 0),
			TypeAnnotation = rgb(60, 100, 160),
		},
	},
	["Synapse X"] = {
		Name = "Synapse X",
		Main1 = rgb(28, 30, 38),
		Main2 = rgb(22, 24, 32),
		Main3 = rgb(18, 20, 28),
		Outline1 = rgb(14, 16, 22),
		Outline2 = rgb(36, 40, 52),
		Outline3 = rgb(10, 12, 18),
		TextBox = rgb(20, 22, 30),
		Menu = rgb(16, 18, 26),
		ListSelection = rgb(124, 77, 255),
		Button = rgb(36, 40, 52),
		ButtonHover = rgb(48, 54, 70),
		ButtonPress = rgb(28, 32, 42),
		Highlight = rgb(60, 68, 88),
		Text = rgb(230, 232, 240),
		TextDim = rgb(160, 168, 188),
		PlaceholderText = rgb(96, 102, 120),
		Important = rgb(255, 80, 120),
		Success = rgb(80, 220, 160),
		Warning = rgb(255, 200, 80),
		Accent = rgb(124, 77, 255),
		ScrollBar = rgb(60, 68, 88),
		ScrollBarHover = rgb(80, 90, 116),
		Separator = rgb(20, 22, 30),
		TabActive = rgb(36, 40, 52),
		TabInactive = rgb(22, 24, 32),
		Notification = rgb(22, 24, 32),
		NotificationBorder = rgb(60, 68, 88),
		Syntax = {
			Text = rgb(220, 222, 235),
			Background = rgb(18, 20, 28),
			Selection = rgb(255, 255, 255),
			SelectionBack = rgb(80, 50, 180),
			Operator = rgb(220, 222, 235),
			Number = rgb(255, 174, 102),
			String = rgb(195, 232, 141),
			Comment = rgb(110, 116, 138),
			Keyword = rgb(199, 146, 234),
			Error = rgb(255, 80, 100),
			FindBackground = rgb(124, 77, 255),
			MatchingWord = rgb(60, 68, 88),
			BuiltIn = rgb(130, 200, 255),
			CurrentLine = rgb(36, 40, 56),
			LocalMethod = rgb(255, 215, 130),
			LocalProperty = rgb(130, 200, 255),
			Nil = rgb(255, 174, 102),
			Bool = rgb(255, 174, 102),
			Function = rgb(199, 146, 234),
			Local = rgb(199, 146, 234),
			Self = rgb(199, 146, 234),
			FunctionName = rgb(255, 215, 130),
			Bracket = rgb(220, 222, 235),
			TypeAnnotation = rgb(124, 220, 220),
		},
	},
	SirMeme = {
		Name = "SirMeme",
		Main1 = rgb(34, 30, 30),
		Main2 = rgb(28, 24, 24),
		Main3 = rgb(22, 20, 20),
		Outline1 = rgb(18, 16, 16),
		Outline2 = rgb(48, 38, 38),
		Outline3 = rgb(14, 12, 12),
		TextBox = rgb(22, 20, 20),
		Menu = rgb(18, 16, 16),
		ListSelection = rgb(200, 60, 60),
		Button = rgb(50, 40, 40),
		ButtonHover = rgb(64, 50, 50),
		ButtonPress = rgb(36, 28, 28),
		Highlight = rgb(80, 60, 60),
		Text = rgb(240, 232, 226),
		TextDim = rgb(180, 168, 162),
		PlaceholderText = rgb(110, 100, 96),
		Important = rgb(255, 90, 90),
		Success = rgb(180, 220, 100),
		Warning = rgb(255, 200, 80),
		Accent = rgb(220, 80, 70),
		ScrollBar = rgb(80, 60, 60),
		ScrollBarHover = rgb(110, 84, 84),
		Separator = rgb(28, 24, 24),
		TabActive = rgb(50, 40, 40),
		TabInactive = rgb(28, 24, 24),
		Notification = rgb(28, 24, 24),
		NotificationBorder = rgb(80, 60, 60),
		Syntax = {
			Text = rgb(232, 224, 218),
			Background = rgb(22, 20, 20),
			Selection = rgb(255, 255, 255),
			SelectionBack = rgb(160, 50, 50),
			Operator = rgb(232, 224, 218),
			Number = rgb(255, 180, 90),
			String = rgb(200, 220, 130),
			Comment = rgb(120, 110, 105),
			Keyword = rgb(255, 130, 110),
			Error = rgb(255, 80, 80),
			FindBackground = rgb(180, 80, 60),
			MatchingWord = rgb(80, 60, 60),
			BuiltIn = rgb(255, 200, 130),
			CurrentLine = rgb(48, 36, 36),
			LocalMethod = rgb(255, 220, 150),
			LocalProperty = rgb(220, 180, 130),
			Nil = rgb(255, 180, 90),
			Bool = rgb(255, 180, 90),
			Function = rgb(255, 130, 110),
			Local = rgb(255, 130, 110),
			Self = rgb(255, 130, 110),
			FunctionName = rgb(255, 220, 150),
			Bracket = rgb(232, 224, 218),
			TypeAnnotation = rgb(180, 200, 220),
		},
	},
}
Theme.PresetOrder = {"New", "Dex", "Old Dex", "Synapse X", "SirMeme", "Dark", "Darker", "Light"}
Theme.Fonts = {
	{Name = "Gotham", Font = Enum.Font.Gotham},
	{Name = "GothamMedium", Font = Enum.Font.GothamMedium},
	{Name = "GothamBold", Font = Enum.Font.GothamBold},
	{Name = "Code", Font = Enum.Font.Code},
	{Name = "Plex", Font = Enum.Font.RobotoMono},
	{Name = "RobotoMono", Font = Enum.Font.RobotoMono},
	{Name = "SourceSans", Font = Enum.Font.SourceSans},
	{Name = "SourceSansBold", Font = Enum.Font.SourceSansBold},
	{Name = "Arial", Font = Enum.Font.Arial},
	{Name = "Ubuntu", Font = Enum.Font.Ubuntu},
}
local function notifyKey(key, newVal, oldVal)
	local keySubscribers = subscribers[key]
	if keySubscribers then
		for _, cb in ipairs(keySubscribers) do
			task.spawn(cb, newVal, oldVal, key)
		end
	end
	for _, cb in ipairs(globalSubscribers) do
		task.spawn(cb, key, newVal, oldVal)
	end
end
local function notifyAll()
	for key, val in pairs(currentTheme) do
		if key ~= "Name" and key ~= "Syntax" then
			notifyKey(key, val, nil)
		end
	end
	if currentTheme.Syntax then
		for key, val in pairs(currentTheme.Syntax) do
			notifyKey("Syntax." .. key, val, nil)
		end
	end
end
function Theme.Init(envRef, settingsRef, serviceTable)
	Env = envRef
	Settings = settingsRef
	HttpService = serviceTable.HttpService or game:GetService("HttpService")
	Lighting = serviceTable.Lighting or game:GetService("Lighting")
	local savedPreset = Settings and Settings.Get and Settings.Get("General.Theme")
	if savedPreset and Theme.Presets[savedPreset] then
		Theme.Apply(savedPreset, true)
	else
		Theme.Apply("Dark", true)
	end
	local savedFont = Settings and Settings.Get and Settings.Get("General.Font")
	if savedFont then
		Theme.SetFont(savedFont, true)
	end
end
function Theme.Apply(presetName, silent)
	local preset = Theme.Presets[presetName]
	if not preset then return false end
	currentPresetName = presetName
	currentTheme = preset
	if Settings and Settings.Set then
		Settings.Set("General.Theme", presetName, true)
	end
	if not silent then
		notifyAll()
	end
	return true
end
function Theme.ApplyCustom(themeTable, silent)
	if type(themeTable) ~= "table" then return false end
	local merged = {}
	for k, v in pairs(Theme.Presets.Dark) do
		if type(v) == "table" and k == "Syntax" then
			merged[k] = {}
			for sk, sv in pairs(v) do
				merged[k][sk] = (themeTable.Syntax and themeTable.Syntax[sk]) or sv
			end
		else
			merged[k] = themeTable[k] or v
		end
	end
	merged.Name = themeTable.Name or "Custom"
	currentPresetName = merged.Name
	currentTheme = merged
	if not silent then
		notifyAll()
	end
	return true
end
function Theme.Get(key)
	if string.find(key, ".", 1, true) then
		local parts = string.split(key, ".")
		local sub = currentTheme[parts[1]]
		if type(sub) == "table" then
			return sub[parts[2]]
		end
		return nil
	end
	return currentTheme[key]
end
function Theme.GetCurrent()
	return currentTheme
end
function Theme.GetCurrentName()
	return currentPresetName
end
function Theme.SetAccent(color)
	local old = currentTheme.Accent
	currentTheme.Accent = color
	notifyKey("Accent", color, old)
end
function Theme.Subscribe(key, callback)
	if not subscribers[key] then
		subscribers[key] = {}
	end
	table.insert(subscribers[key], callback)
	local current = Theme.Get(key)
	if current then
		task.spawn(callback, current, nil, key)
	end
	return function()
		local list = subscribers[key]
		if list then
			local idx = table.find(list, callback)
			if idx then table.remove(list, idx) end
		end
	end
end
function Theme.SubscribeAll(callback)
	table.insert(globalSubscribers, callback)
	return function()
		local idx = table.find(globalSubscribers, callback)
		if idx then table.remove(globalSubscribers, idx) end
	end
end
function Theme.ListPresets()
	local names = {}
	for name in pairs(Theme.Presets) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end
function Theme.Export()
	if not HttpService then return nil end
	local exportable = {}
	for k, v in pairs(currentTheme) do
		if typeof(v) == "Color3" then
			exportable[k] = colorToTable(v)
		elseif type(v) == "table" and k == "Syntax" then
			exportable.Syntax = {}
			for sk, sv in pairs(v) do
				if typeof(sv) == "Color3" then
					exportable.Syntax[sk] = colorToTable(sv)
				end
			end
		else
			exportable[k] = v
		end
	end
	local s, json = pcall(HttpService.JSONEncode, HttpService, exportable)
	return s and json or nil
end
function Theme.Import(jsonStr)
	if not HttpService then return false end
	local s, decoded = pcall(HttpService.JSONDecode, HttpService, jsonStr)
	if not s or type(decoded) ~= "table" then return false end
	local themeTable = {}
	for k, v in pairs(decoded) do
		if type(v) == "table" and #v == 3 and type(v[1]) == "number" then
			themeTable[k] = tableToColor(v)
		elseif type(v) == "table" and k == "Syntax" then
			themeTable.Syntax = {}
			for sk, sv in pairs(v) do
				if type(sv) == "table" and #sv == 3 then
					themeTable.Syntax[sk] = tableToColor(sv)
				end
			end
		else
			themeTable[k] = v
		end
	end
	return Theme.ApplyCustom(themeTable)
end
function Theme.SaveToFile(filename)
	if not Env or not Env.Capabilities.Filesystem then return false end
	local json = Theme.Export()
	if not json then return false end
	local path = "deux/themes/" .. (filename or currentPresetName) .. ".json"
	local s = pcall(Env.writefile, path, json)
	return s
end
function Theme.LoadFromFile(filename)
	if not Env or not Env.Capabilities.Filesystem then return false end
	local path = "deux/themes/" .. filename .. ".json"
	local s, raw = pcall(Env.readfile, path)
	if not s or not raw then return false end
	return Theme.Import(raw)
end
function Theme.ListSavedThemes()
	if not Env or not Env.Capabilities.Filesystem then return {} end
	local s, files = pcall(Env.listfiles, "deux/themes")
	if not s or not files then return {} end
	local themes = {}
	for _, file in ipairs(files) do
		local name = string.match(file, "([^/\\]+)%.json$")
		if name then
			themes[#themes + 1] = name
		end
	end
	return themes
end
function Theme.SetKey(key, value)
	if string.find(key, ".", 1, true) then
		local parts = string.split(key, ".")
		local sub = currentTheme[parts[1]]
		if type(sub) ~= "table" then return false end
		local old = sub[parts[2]]
		sub[parts[2]] = value
		notifyKey(key, value, old)
		return true
	end
	local old = currentTheme[key]
	currentTheme[key] = value
	notifyKey(key, value, old)
	return true
end
local function lerpColor(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end
local function relativeLuminance(c)
	return 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B
end
local function shift(c, amount)
	return Color3.new(
		math.clamp(c.R + amount, 0, 1),
		math.clamp(c.G + amount, 0, 1),
		math.clamp(c.B + amount, 0, 1)
	)
end
function Theme.BuildSmart(seed, accentSeed)
	local lum = relativeLuminance(seed)
	local isLight = lum > 0.55
	local main1 = seed
	local main2 = shift(seed, isLight and -0.06 or -0.04)
	local main3 = shift(seed, isLight and -0.12 or -0.08)
	local outline1 = shift(seed, isLight and -0.20 or -0.12)
	local outline2 = shift(seed, isLight and -0.10 or 0.06)
	local text = isLight and rgb(20, 20, 20) or rgb(240, 240, 240)
	local textDim = isLight and rgb(80, 80, 80) or rgb(170, 170, 170)
	local accent = accentSeed or lerpColor(seed, rgb(56, 142, 235), isLight and 0.5 or 0.7)
	local button = shift(seed, isLight and -0.04 or 0.06)
	local buttonHover = shift(button, isLight and -0.04 or 0.06)
	local buttonPress = shift(button, isLight and -0.10 or -0.06)
	local theme = {
		Name = "Smart",
		Main1 = main1, Main2 = main2, Main3 = main3,
		Outline1 = outline1, Outline2 = outline2, Outline3 = shift(seed, isLight and -0.16 or -0.10),
		TextBox = main3, Menu = main3,
		ListSelection = accent,
		Button = button, ButtonHover = buttonHover, ButtonPress = buttonPress,
		Highlight = shift(button, 0.04),
		Text = text, TextDim = textDim, PlaceholderText = isLight and rgb(140,140,140) or rgb(110,110,110),
		Important = rgb(255, 80, 80), Success = rgb(80, 200, 130), Warning = rgb(255, 200, 50),
		Accent = accent,
		ScrollBar = shift(seed, 0.06), ScrollBarHover = shift(seed, 0.12),
		Separator = main2, TabActive = button, TabInactive = main3,
		Notification = main2, NotificationBorder = outline2,
		Syntax = {
			Text = text,
			Background = main3,
			Selection = isLight and rgb(0,0,0) or rgb(255,255,255),
			SelectionBack = accent,
			Operator = text,
			Number = isLight and rgb(9, 134, 88) or rgb(255, 198, 0),
			String = isLight and rgb(163, 21, 21) or rgb(173, 241, 149),
			Comment = isLight and rgb(0, 128, 0) or rgb(110, 116, 138),
			Keyword = isLight and rgb(0, 0, 200) or rgb(248, 109, 124),
			Error = rgb(255, 60, 60),
			FindBackground = accent,
			MatchingWord = shift(button, 0.06),
			BuiltIn = isLight and rgb(38, 127, 153) or rgb(132, 214, 247),
			CurrentLine = shift(main3, isLight and -0.04 or 0.04),
			LocalMethod = isLight and rgb(116, 83, 0) or rgb(253, 251, 172),
			LocalProperty = isLight and rgb(0, 70, 140) or rgb(97, 161, 241),
			Nil = isLight and rgb(9, 134, 88) or rgb(255, 198, 0),
			Bool = isLight and rgb(9, 134, 88) or rgb(255, 198, 0),
			Function = isLight and rgb(0, 0, 200) or rgb(248, 109, 124),
			Local = isLight and rgb(0, 0, 200) or rgb(248, 109, 124),
			Self = isLight and rgb(0, 0, 200) or rgb(248, 109, 124),
			FunctionName = isLight and rgb(116, 83, 0) or rgb(253, 251, 172),
			Bracket = text,
			TypeAnnotation = isLight and rgb(38, 127, 153) or rgb(78, 201, 176),
		},
	}
	return theme
end
function Theme.SmartFromWorld(silent)
	local seed
	local accentSeed
	if Lighting then
		local amb = Lighting.Ambient
		local out = Lighting.OutdoorAmbient
		local mix = lerpColor(amb, out, 0.5)
		seed = shift(mix, -0.35)
		local brighter = relativeLuminance(amb) > relativeLuminance(out) and amb or out
		accentSeed = lerpColor(brighter, rgb(60, 150, 240), 0.6)
	else
		seed = rgb(40, 42, 48)
		accentSeed = rgb(56, 142, 235)
	end
	local smart = Theme.BuildSmart(seed, accentSeed)
	currentPresetName = "Smart"
	currentTheme = smart
	if Settings and Settings.Set then
		Settings.Set("General.Theme", "Smart", true)
	end
	if not silent then notifyAll() end
	return true
end
local function findFontEntry(name)
	for _, entry in ipairs(Theme.Fonts) do
		if entry.Name == name then return entry end
	end
	return nil
end
function Theme.GetFontName()
	return currentFontName
end
function Theme.GetFont()
	local entry = findFontEntry(currentFontName)
	return entry and entry.Font or Enum.Font.Gotham
end
function Theme.ListFonts()
	local names = {}
	for _, entry in ipairs(Theme.Fonts) do
		names[#names + 1] = entry.Name
	end
	return names
end
function Theme.SetFont(name, silent)
	local entry = findFontEntry(name)
	if not entry then return false end
	local old = currentFontName
	currentFontName = name
	if Settings and Settings.Set then
		Settings.Set("General.Font", name, true)
	end
	if not silent then
		notifyKey("Font", entry.Font, findFontEntry(old) and findFontEntry(old).Font)
	end
	return true
end
function Theme.RegisterFont(name, font)
	if type(name) ~= "string" or not font then return false end
	if findFontEntry(name) then return false end
	Theme.Fonts[#Theme.Fonts + 1] = {Name = name, Font = font, Custom = true}
	return true
end
function Theme.RegisterFontFromAssetId(name, assetId)
	if not assetId then return false end
	local id = tonumber(assetId) or assetId
	local s, fontObject = pcall(function()
		return Font.new("rbxassetid://" .. tostring(id))
	end)
	if not s or not fontObject then return false end
	return Theme.RegisterFont(name, fontObject)
end
return Theme
end
EmbeddedModules["Keybinds"] = function()
local Keybinds = {}
local Settings
local UserInputService
local bindings = {}
local keyState = {}
local connections = {}
local enabled = true
local function keysMatch(required)
	for _, key in ipairs(required) do
		if not keyState[key] then return false end
	end
	return true
end
local function getModifierCount(keys)
	local count = 0
	for _, key in ipairs(keys) do
		if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.RightControl
			or key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift
			or key == Enum.KeyCode.LeftAlt or key == Enum.KeyCode.RightAlt then
			count = count + 1
		end
	end
	return count
end
local function keysToString(keys)
	local names = {}
	local order = {
		[Enum.KeyCode.LeftControl] = 1, [Enum.KeyCode.RightControl] = 1,
		[Enum.KeyCode.LeftShift] = 2, [Enum.KeyCode.RightShift] = 2,
		[Enum.KeyCode.LeftAlt] = 3, [Enum.KeyCode.RightAlt] = 3,
	}
	table.sort(keys, function(a, b)
		local oa, ob = order[a] or 99, order[b] or 99
		if oa ~= ob then return oa < ob end
		return a.Value < b.Value
	end)
	for _, key in ipairs(keys) do
		local name = key.Name
		name = name:gsub("Left", ""):gsub("Right", "")
		names[#names + 1] = name
	end
	return table.concat(names, "+")
end
local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	if not enabled then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	keyState[input.KeyCode] = true
	local candidates = {}
	for name, binding in pairs(bindings) do
		if binding.Enabled and keysMatch(binding.Keys) then
			candidates[#candidates + 1] = binding
		end
	end
	table.sort(candidates, function(a, b) return #a.Keys > #b.Keys end)
	if candidates[1] then
		task.spawn(candidates[1].Callback)
	end
end
local function onInputEnded(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	keyState[input.KeyCode] = false
end
function Keybinds.Init(settingsRef, serviceTable)
	Settings = settingsRef
	UserInputService = serviceTable.UserInputService or game:GetService("UserInputService")
	connections[#connections + 1] = UserInputService.InputBegan:Connect(onInputBegan)
	connections[#connections + 1] = UserInputService.InputEnded:Connect(onInputEnded)
	local savedBinds = Settings and Settings.Get and Settings.Get("Keybinds")
	if type(savedBinds) == "table" then
		for name, keys in pairs(savedBinds) do
			if bindings[name] then
				local resolved = {}
				for _, keyName in ipairs(keys) do
					local s, kc = pcall(function() return Enum.KeyCode[keyName] end)
					if s and kc then resolved[#resolved + 1] = kc end
				end
				if #resolved > 0 then
					bindings[name].Keys = resolved
				end
			end
		end
	end
end
function Keybinds.Register(name, data)
	bindings[name] = {
		Name = name,
		Keys = data.Keys or {},
		Category = data.Category or "General",
		Description = data.Description or name,
		Callback = data.Callback or function() end,
		Enabled = data.Enabled ~= false,
	}
end
function Keybinds.Unregister(name)
	bindings[name] = nil
end
function Keybinds.Rebind(name, newKeys)
	for otherName, other in pairs(bindings) do
		if otherName ~= name and other.Enabled then
			if #other.Keys == #newKeys then
				local match = true
				for i, k in ipairs(newKeys) do
					if other.Keys[i] ~= k then match = false; break end
				end
				if match then
					return false, otherName
				end
			end
		end
	end
	local binding = bindings[name]
	if not binding then return false, "NOT_FOUND" end
	binding.Keys = newKeys
	Keybinds.Save()
	return true
end
function Keybinds.ForceRebind(name, newKeys)
	local binding = bindings[name]
	if not binding then return false end
	binding.Keys = newKeys
	Keybinds.Save()
	return true
end
function Keybinds.SetEnabled(name, state)
	if bindings[name] then
		bindings[name].Enabled = state
	end
end
function Keybinds.SetGlobalEnabled(state)
	enabled = state
end
function Keybinds.GetBinding(name)
	return bindings[name]
end
function Keybinds.GetAll()
	local categories = {}
	for name, binding in pairs(bindings) do
		local cat = binding.Category
		if not categories[cat] then categories[cat] = {} end
		categories[cat][#categories[cat] + 1] = {
			Name = name,
			Keys = binding.Keys,
			KeyString = keysToString(binding.Keys),
			Description = binding.Description,
			Enabled = binding.Enabled,
		}
	end
	for _, list in pairs(categories) do
		table.sort(list, function(a, b) return a.Description < b.Description end)
	end
	return categories
end
function Keybinds.GetKeyString(name)
	local binding = bindings[name]
	if not binding then return "" end
	return keysToString(binding.Keys)
end
function Keybinds.FindConflicts(keys, excludeName)
	local conflicts = {}
	for name, binding in pairs(bindings) do
		if name ~= excludeName and binding.Enabled and #binding.Keys == #keys then
			local match = true
			for i, k in ipairs(keys) do
				if binding.Keys[i] ~= k then match = false; break end
			end
			if match then
				conflicts[#conflicts + 1] = name
			end
		end
	end
	return conflicts
end
function Keybinds.Save()
	if not Settings then return end
	local serialized = {}
	for name, binding in pairs(bindings) do
		local keyNames = {}
		for _, key in ipairs(binding.Keys) do
			keyNames[#keyNames + 1] = key.Name
		end
		serialized[name] = keyNames
	end
	Settings.Set("Keybinds", serialized, false)
end
function Keybinds.ResetAll()
	if Settings then
		Settings.Set("Keybinds", nil, false)
	end
end
function Keybinds.Destroy()
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}
	keyState = {}
end
return Keybinds
end
EmbeddedModules["Notifications"] = function()
local Notifications = {}
local Env, Theme
local TweenService, RunService
local guiParent
local notificationFrame
local activeNotifications = {}
local queue = {}
local MAX_VISIBLE = 5
local DEFAULT_DURATION = 4
local ANIMATION_TIME = 0.25
local NOTIFICATION_HEIGHT = 48
local NOTIFICATION_WIDTH = 320
local NOTIFICATION_PADDING = 6
local CORNER_RADIUS = 6
local Severity = {
	Info = {Icon = "ℹ", ColorKey = "Accent"},
	Success = {Icon = "✓", ColorKey = "Success"},
	Warning = {Icon = "⚠", ColorKey = "Warning"},
	Error = {Icon = "✕", ColorKey = "Important"},
}
local function createNotificationGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DeuxNotifications"
	screenGui.DisplayOrder = 999999
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Env.protectGui(screenGui)
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.BackgroundTransparency = 1
	container.AnchorPoint = Vector2.new(1, 0)
	container.Position = UDim2.new(1, -12, 0, 48)
	container.Size = UDim2.new(0, NOTIFICATION_WIDTH, 1, -60)
	container.ClipsDescendants = false
	container.Parent = screenGui
	notificationFrame = container
	screenGui.Parent = guiParent
	return screenGui
end
local function createToast(message, severity, duration)
	local sevConfig = Severity[severity] or Severity.Info
	local accentColor = Theme and Theme.Get(sevConfig.ColorKey) or Color3.fromRGB(0, 120, 215)
	local bgColor = Theme and Theme.Get("Notification") or Color3.fromRGB(45, 45, 45)
	local borderColor = Theme and Theme.Get("NotificationBorder") or Color3.fromRGB(70, 70, 70)
	local textColor = Theme and Theme.Get("Text") or Color3.fromRGB(255, 255, 255)
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.BackgroundColor3 = bgColor
	toast.BorderSizePixel = 0
	toast.Size = UDim2.new(1, 0, 0, NOTIFICATION_HEIGHT)
	toast.AnchorPoint = Vector2.new(1, 0)
	toast.Position = UDim2.new(1, NOTIFICATION_WIDTH, 0, 0)
	toast.ClipsDescendants = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, CORNER_RADIUS)
	corner.Parent = toast
	local stroke = Instance.new("UIStroke")
	stroke.Color = borderColor
	stroke.Thickness = 1
	stroke.Parent = toast
	local accentBar = Instance.new("Frame")
	accentBar.Name = "Accent"
	accentBar.BackgroundColor3 = accentColor
	accentBar.BorderSizePixel = 0
	accentBar.Size = UDim2.new(0, 3, 1, 0)
	accentBar.Parent = toast
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, CORNER_RADIUS)
	accentCorner.Parent = accentBar
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.new(0, 10, 0, 0)
	icon.Size = UDim2.new(0, 24, 1, 0)
	icon.Font = Enum.Font.GothamBold
	icon.Text = sevConfig.Icon
	icon.TextColor3 = accentColor
	icon.TextSize = 18
	icon.Parent = toast
	local label = Instance.new("TextLabel")
	label.Name = "Message"
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 36, 0, 0)
	label.Size = UDim2.new(1, -48, 1, 0)
	label.Font = Enum.Font.Gotham
	label.Text = message
	label.TextColor3 = textColor
	label.TextSize = 13
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = toast
	return toast
end
local function repositionAll()
	for i, notif in ipairs(activeNotifications) do
		local targetY = (i - 1) * (NOTIFICATION_HEIGHT + NOTIFICATION_PADDING)
		local tween = TweenService:Create(notif.Frame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, targetY)
		})
		tween:Play()
	end
end
local function slideIn(frame)
	frame.Position = UDim2.new(1, NOTIFICATION_WIDTH, 0, (#activeNotifications - 1) * (NOTIFICATION_HEIGHT + NOTIFICATION_PADDING))
	local targetPos = UDim2.new(0, 0, 0, (#activeNotifications - 1) * (NOTIFICATION_HEIGHT + NOTIFICATION_PADDING))
	local tween = TweenService:Create(frame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = targetPos
	})
	tween:Play()
end
local function slideOut(notifData, callback)
	local frame = notifData.Frame
	local tween = TweenService:Create(frame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(1, NOTIFICATION_WIDTH, 0, frame.Position.Y.Offset)
	})
	tween:Play()
	tween.Completed:Connect(function()
		frame:Destroy()
		if callback then callback() end
	end)
end
local function dismiss(notifData)
	local idx = table.find(activeNotifications, notifData)
	if not idx then return end
	table.remove(activeNotifications, idx)
	slideOut(notifData, function()
		repositionAll()
		if #queue > 0 and #activeNotifications < MAX_VISIBLE then
			local queued = table.remove(queue, 1)
			Notifications.Show(queued.Message, queued.Severity, queued.Duration)
		end
	end)
end
function Notifications.Init(envRef, themeRef, serviceTable)
	Env = envRef
	Theme = themeRef
	TweenService = serviceTable.TweenService or game:GetService("TweenService")
	RunService = serviceTable.RunService or game:GetService("RunService")
	guiParent = Env.getGuiParent()
	if guiParent then
		createNotificationGui()
	end
	if Theme and Theme.SubscribeAll then
		Theme.SubscribeAll(function() end)
	end
end
function Notifications.Show(message, severity, duration)
	if not notificationFrame then return end
	severity = severity or "Info"
	duration = duration or DEFAULT_DURATION
	if #activeNotifications >= MAX_VISIBLE then
		queue[#queue + 1] = {Message = message, Severity = severity, Duration = duration}
		return
	end
	local frame = createToast(message, severity, duration)
	frame.Parent = notificationFrame
	local notifData = {
		Frame = frame,
		Message = message,
		Severity = severity,
		CreatedAt = tick(),
	}
	activeNotifications[#activeNotifications + 1] = notifData
	slideIn(frame)
	local button = Instance.new("TextButton")
	button.Name = "DismissHit"
	button.BackgroundTransparency = 1
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Text = ""
	button.ZIndex = 10
	button.Parent = frame
	button.MouseButton1Click:Connect(function()
		dismiss(notifData)
	end)
	task.delay(duration, function()
		if table.find(activeNotifications, notifData) then
			dismiss(notifData)
		end
	end)
end
function Notifications.Info(msg, duration)
	Notifications.Show(msg, "Info", duration)
end
function Notifications.Success(msg, duration)
	Notifications.Show(msg, "Success", duration)
end
function Notifications.Warning(msg, duration)
	Notifications.Show(msg, "Warning", duration)
end
function Notifications.Error(msg, duration)
	Notifications.Show(msg, "Error", duration or 6)
end
function Notifications.Clear()
	for _, notif in ipairs(activeNotifications) do
		notif.Frame:Destroy()
	end
	activeNotifications = {}
	queue = {}
end
function Notifications.GetCount()
	return #activeNotifications + #queue
end
return Notifications
end
EmbeddedModules["Store"] = function()
local Store = {}
local state = {}
local stateSubscribers = {}
local wildcardSubscribers = {}
local eventHandlers = {}
local history = {}
local MAX_HISTORY = 100
function Store.Set(key, value, silent)
	local old = state[key]
	if old == value then return end
	state[key] = value
	history[#history + 1] = {
		Key = key,
		OldValue = old,
		NewValue = value,
		Time = tick(),
	}
	if #history > MAX_HISTORY then
		table.remove(history, 1)
	end
	if silent then return end
	local subs = stateSubscribers[key]
	if subs then
		for _, cb in ipairs(subs) do
			task.spawn(cb, value, old, key)
		end
	end
	for _, cb in ipairs(wildcardSubscribers) do
		task.spawn(cb, key, value, old)
	end
end
function Store.Get(key)
	return state[key]
end
function Store.GetMany(...)
	local results = {}
	for _, key in ipairs({...}) do
		results[#results + 1] = state[key]
	end
	return unpack(results)
end
function Store.Has(key)
	return state[key] ~= nil
end
function Store.Delete(key)
	Store.Set(key, nil)
end
function Store.Subscribe(key, callback)
	if not stateSubscribers[key] then
		stateSubscribers[key] = {}
	end
	table.insert(stateSubscribers[key], callback)
	return function()
		local list = stateSubscribers[key]
		if list then
			local idx = table.find(list, callback)
			if idx then table.remove(list, idx) end
		end
	end
end
function Store.SubscribeAll(callback)
	table.insert(wildcardSubscribers, callback)
	return function()
		local idx = table.find(wildcardSubscribers, callback)
		if idx then table.remove(wildcardSubscribers, idx) end
	end
end
function Store.On(event, callback)
	if not eventHandlers[event] then
		eventHandlers[event] = {}
	end
	table.insert(eventHandlers[event], callback)
	return function()
		local list = eventHandlers[event]
		if list then
			local idx = table.find(list, callback)
			if idx then table.remove(list, idx) end
		end
	end
end
function Store.Emit(event, ...)
	local handlers = eventHandlers[event]
	if not handlers then return end
	local args = {...}
	for _, cb in ipairs(handlers) do
		task.spawn(function()
			cb(unpack(args))
		end)
	end
end
function Store.Request(event, ...)
	local handlers = eventHandlers[event]
	if not handlers then return nil end
	for _, cb in ipairs(handlers) do
		local result = cb(...)
		if result ~= nil then return result end
	end
	return nil
end
function Store.SetSelection(instances)
	if type(instances) ~= "table" then
		instances = {instances}
	end
	Store.Set("selection", instances)
end
function Store.GetSelection()
	return state.selection or {}
end
function Store.AddToSelection(instance)
	local sel = Store.GetSelection()
	if not table.find(sel, instance) then
		local newSel = {unpack(sel)}
		newSel[#newSel + 1] = instance
		Store.Set("selection", newSel)
	end
end
function Store.RemoveFromSelection(instance)
	local sel = Store.GetSelection()
	local idx = table.find(sel, instance)
	if idx then
		local newSel = {unpack(sel)}
		table.remove(newSel, idx)
		Store.Set("selection", newSel)
	end
end
function Store.ClearSelection()
	Store.Set("selection", {})
end
function Store.ToggleSelection(instance)
	local sel = Store.GetSelection()
	if table.find(sel, instance) then
		Store.RemoveFromSelection(instance)
	else
		Store.AddToSelection(instance)
	end
end
function Store.GetHistory(key, limit)
	limit = limit or 20
	local filtered = {}
	for i = #history, 1, -1 do
		if not key or history[i].Key == key then
			filtered[#filtered + 1] = history[i]
			if #filtered >= limit then break end
		end
	end
	return filtered
end
function Store.Undo(key)
	for i = #history, 1, -1 do
		if history[i].Key == key then
			Store.Set(key, history[i].OldValue)
			table.remove(history, i)
			return true
		end
	end
	return false
end
function Store.Reset()
	state = {}
	history = {}
end
function Store.Destroy()
	state = {}
	stateSubscribers = {}
	wildcardSubscribers = {}
	eventHandlers = {}
	history = {}
end
return Store
end
EmbeddedModules["Lib"] = function()
local Main,Lib,Apps,Settings
local Theme,Store,Keybinds,Notifications,Env
local Explorer, Properties, ScriptEditor, Terminal
local RemoteSpy, SaveInstance, DataInspector, NetworkSpy
local APIReference, PluginAPI, WorkspaceTools, Console
local API,RMD,env,service,plr,create,createSimple
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	Theme = data.Theme
	Store = data.Store
	Keybinds = data.Keybinds
	Notifications = data.Notifications
	Env = data.Env
	API = data.API
	RMD = data.RMD
	env = data.Env or data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain(appTable)
	Explorer = appTable and appTable.Explorer or (Apps and Apps.Explorer)
	Properties = appTable and appTable.Properties or (Apps and Apps.Properties)
	ScriptEditor = appTable and appTable.ScriptEditor or (Apps and Apps.ScriptEditor)
	Terminal = appTable and appTable.Terminal or (Apps and Apps.Terminal)
	RemoteSpy = appTable and appTable.RemoteSpy or (Apps and Apps.RemoteSpy)
	SaveInstance = appTable and appTable.SaveInstance or (Apps and Apps.SaveInstance)
	DataInspector = appTable and appTable.DataInspector or (Apps and Apps.DataInspector)
	NetworkSpy = appTable and appTable.NetworkSpy or (Apps and Apps.NetworkSpy)
	APIReference = appTable and appTable.APIReference or (Apps and Apps.APIReference)
	PluginAPI = appTable and appTable.PluginAPI or (Apps and Apps.PluginAPI)
	WorkspaceTools = appTable and appTable.WorkspaceTools or (Apps and Apps.WorkspaceTools)
	Console = appTable and appTable.Console or (Apps and Apps.Console)
end
local function main()
	local Lib = {}
	local renderStepped = service.RunService.RenderStepped
	local signalWait = renderStepped.wait
	local PH = newproxy()
	local SIGNAL = newproxy()
	local function initObj(props,mt)
		local type = type
		local function copy(t)
			local res = {}
			for i,v in pairs(t) do
				if v == SIGNAL then
					res[i] = Lib.Signal.new()
				elseif type(v) == "table" then
					res[i] = copy(v)
				else
					res[i] = v
				end
			end
			return res
		end
		local newObj = copy(props)
		return setmetatable(newObj,mt)
	end
	local function getGuiMT(props,funcs)
		return {__index = function(self,ind) if not props[ind] then return funcs[ind] or self.Gui[ind] end end,
		__newindex = function(self,ind,val) if not props[ind] then self.Gui[ind] = val else rawset(self,ind,val) end end}
	end
	Lib.FormatLuaString = (function()
		local string = string
		local gsub = string.gsub
		local format = string.format
		local char = string.char
		local cleanTable = {['"'] = '\\"', ['\\'] = '\\\\'}
		for i = 0,31 do
			cleanTable[char(i)] = "\\"..format("%03d",i)
		end
		for i = 127,255 do
			cleanTable[char(i)] = "\\"..format("%03d",i)
		end
		return function(str)
			return gsub(str,"[\"\\\0-\31\127-\255]",cleanTable)
		end
	end)()
	Lib.CheckMouseInGui = function(gui)
		if gui == nil then return false end
		local mouse = Main.Mouse
		local guiPosition = gui.AbsolutePosition
		local guiSize = gui.AbsoluteSize
		return mouse.X >= guiPosition.X and mouse.X < guiPosition.X + guiSize.X and mouse.Y >= guiPosition.Y and mouse.Y < guiPosition.Y + guiSize.Y
	end
	Lib.IsShiftDown = function()
		return service.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or service.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	end
	Lib.IsCtrlDown = function()
		return service.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or service.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
	end
	Lib.CreateArrow = function(size,num,dir)
		local max = num
		local arrowFrame = createSimple("Frame",{
			BackgroundTransparency = 1,
			Name = "Arrow",
			Size = UDim2.new(0,size,0,size)
		})
		if dir == "up" then
			for i = 1,num do
				local newLine = createSimple("Frame",{
					BackgroundColor3 = Color3.new(220/255,220/255,220/255),
					BorderSizePixel = 0,
					Position = UDim2.new(0,math.floor(size/2)-(i-1),0,math.floor(size/2)+i-math.floor(max/2)-1),
					Size = UDim2.new(0,i+(i-1),0,1),
					Parent = arrowFrame
				})
			end
			return arrowFrame
		elseif dir == "down" then
			for i = 1,num do
				local newLine = createSimple("Frame",{
					BackgroundColor3 = Color3.new(220/255,220/255,220/255),
					BorderSizePixel = 0,
					Position = UDim2.new(0,math.floor(size/2)-(i-1),0,math.floor(size/2)-i+math.floor(max/2)+1),
					Size = UDim2.new(0,i+(i-1),0,1),
					Parent = arrowFrame
				})
			end
			return arrowFrame
		elseif dir == "left" then
			for i = 1,num do
				local newLine = createSimple("Frame",{
					BackgroundColor3 = Color3.new(220/255,220/255,220/255),
					BorderSizePixel = 0,
					Position = UDim2.new(0,math.floor(size/2)+i-math.floor(max/2)-1,0,math.floor(size/2)-(i-1)),
					Size = UDim2.new(0,1,0,i+(i-1)),
					Parent = arrowFrame
				})
			end
			return arrowFrame
		elseif dir == "right" then
			for i = 1,num do
				local newLine = createSimple("Frame",{
					BackgroundColor3 = Color3.new(220/255,220/255,220/255),
					BorderSizePixel = 0,
					Position = UDim2.new(0,math.floor(size/2)-i+math.floor(max/2)+1,0,math.floor(size/2)-(i-1)),
					Size = UDim2.new(0,1,0,i+(i-1)),
					Parent = arrowFrame
				})
			end
			return arrowFrame
		end
		error("r u ok")
	end
	Lib.ParseXML = (function()
		local func = function()
			local string, print, pairs = string, print, pairs
			local trim = function(s)
				local from = s:match"^%s*()"
				return from > #s and "" or s:match(".*%S", from)
			end
			local gtchar = string.byte('>', 1)
			local slashchar = string.byte('/', 1)
			local D = string.byte('D', 1)
			local E = string.byte('E', 1)
			function parse(s, evalEntities)
				s = s:gsub('<!%-%-(.-)%-%->', '')
				local entities, tentities = {}
				if evalEntities then
					local pos = s:find('<[_%w]')
					if pos then
						s:sub(1, pos):gsub('<!ENTITY%s+([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
							entities[#entities+1] = {name=name, value=entity}
						end)
						tentities = createEntityTable(entities)
						s = replaceEntities(s:sub(pos), tentities)
					end
				end
				local t, l = {}, {}
				local addtext = function(txt)
					txt = txt:match'^%s*(.*%S)' or ''
					if #txt ~= 0 then
						t[#t+1] = {text=txt}
					end
				end
				s:gsub('<([?!/]?)([-:_%w]+)%s*(/?>?)([^<]*)', function(type, name, closed, txt)
					if #type == 0 then
						local a = {}
						if #closed == 0 then
							local len = 0
							for all,aname,_,value,starttxt in string.gmatch(txt, "(.-([-_%w]+)%s*=%s*(.)(.-)%3%s*(/?>?))") do
								len = len + #all
								a[aname] = value
								if #starttxt ~= 0 then
									txt = txt:sub(len+1)
									closed = starttxt
									break
								end
							end
						end
						t[#t+1] = {tag=name, attrs=a, children={}}
						if closed:byte(1) ~= slashchar then
							l[#l+1] = t
							t = t[#t].children
						end
						addtext(txt)
					elseif '/' == type then
						t = l[#l]
						l[#l] = nil
						addtext(txt)
					elseif '!' == type then
						if E == name:byte(1) then
							txt:gsub('([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
								entities[#entities+1] = {name=name, value=entity}
							end, 1)
						end
					end
				end)
				return {children=t, entities=entities, tentities=tentities}
			end
			function parseText(txt)
				return parse(txt)
			end
			function defaultEntityTable()
				return { quot='"', apos='\'', lt='<', gt='>', amp='&', tab='\t', nbsp=' ', }
			end
			function replaceEntities(s, entities)
				return s:gsub('&([^;]+);', entities)
			end
			function createEntityTable(docEntities, resultEntities)
				entities = resultEntities or defaultEntityTable()
				for _,e in pairs(docEntities) do
					e.value = replaceEntities(e.value, entities)
					entities[e.name] = e.value
				end
				return entities
			end
			return parseText
		end
		local newEnv = setmetatable({},{__index = getfenv()})
		setfenv(func,newEnv)
		return func()
	end)()
	Lib.FastWait = function(s)
		if not s then return signalWait(renderStepped) end
		local start = tick()
		while tick() - start < s do signalWait(renderStepped) end
	end
	Lib.ButtonAnim = function(button,data)
		local holding = false
		local disabled = false
		local mode = data and data.Mode or 1
		local control = {}
		if mode == 2 then
			local lerpTo = data.LerpTo or Color3.new(0,0,0)
			local delta = data.LerpDelta or 0.2
			control.StartColor = data.StartColor or button.BackgroundColor3
			control.PressColor = data.PressColor or control.StartColor:lerp(lerpTo,delta)
			control.HoverColor = data.HoverColor or control.StartColor:lerp(control.PressColor,0.6)
			control.OutlineColor = data.OutlineColor
		end
		button.InputBegan:Connect(function(input)
			if disabled then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement and not holding then
				if mode == 1 then
					button.BackgroundTransparency = 0.4
				elseif mode == 2 then
					button.BackgroundColor3 = control.HoverColor
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				holding = true
				if mode == 1 then
					button.BackgroundTransparency = 0
				elseif mode == 2 then
					button.BackgroundColor3 = control.PressColor
					if control.OutlineColor then button.BorderColor3 = control.PressColor end
				end
			end
		end)
		button.InputEnded:Connect(function(input)
			if disabled then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement and not holding then
				if mode == 1 then
					button.BackgroundTransparency = 1
				elseif mode == 2 then
					button.BackgroundColor3 = control.StartColor
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				holding = false
				if mode == 1 then
					button.BackgroundTransparency = Lib.CheckMouseInGui(button) and 0.4 or 1
				elseif mode == 2 then
					button.BackgroundColor3 = Lib.CheckMouseInGui(button) and control.HoverColor or control.StartColor
					if control.OutlineColor then button.BorderColor3 = control.OutlineColor end
				end
			end
		end)
		control.Disable = function()
			disabled = true
			holding = false
			if mode == 1 then
				button.BackgroundTransparency = 1
			elseif mode == 2 then
				button.BackgroundColor3 = control.StartColor
			end
		end
		control.Enable = function()
			disabled = false
		end
		return control
	end
	Lib.FindAndRemove = function(t,item)
		local pos = table.find(t,item)
		if pos then table.remove(t,pos) end
	end
	Lib.AttachTo = function(obj,data)
		local target,posOffX,posOffY,sizeOffX,sizeOffY,resize,con
		local disabled = false
		local function update()
			if not obj or not target then return end
			local targetPos = target.AbsolutePosition
			local targetSize = target.AbsoluteSize
			obj.Position = UDim2.new(0,targetPos.X + posOffX,0,targetPos.Y + posOffY)
			if resize then obj.Size = UDim2.new(0,targetSize.X + sizeOffX,0,targetSize.Y + sizeOffY) end
		end
		local function setup(o,data)
			obj = o
			data = data or {}
			target = data.Target
			posOffX = data.PosOffX or 0
			posOffY = data.PosOffY or 0
			sizeOffX = data.SizeOffX or 0
			sizeOffY = data.SizeOffY or 0
			resize = data.Resize or false
			if con then con:Disconnect() con = nil end
			if target then
				con = target.Changed:Connect(function(prop)
					if not disabled and prop == "AbsolutePosition" or prop == "AbsoluteSize" then
						update()
					end
				end)
			end
			update()
		end
		setup(obj,data)
		return {
			SetData = function(obj,data)
				setup(obj,data)
			end,
			Enable = function()
				disabled = false
				update()
			end,
			Disable = function()
				disabled = true
			end,
			Destroy = function()
				con:Disconnect()
				con = nil
			end,
		}
	end
	Lib.ProtectedGuis = {}
	Lib.ShowGui = function(gui)
		if env and env.protectGui then
			env.protectGui(gui)
		elseif env and env.protectgui then
			pcall(env.protectgui, gui)
		end
		gui.Parent = Main.GuiHolder
	end
	Lib.ColorToBytes = function(col)
		local round = math.round
		return string.format("%d, %d, %d",round(col.r*255),round(col.g*255),round(col.b*255))
	end
	Lib.ReadFile = function(filename)
		if not env or not env.readfile then return end
		local s,contents = pcall(env.readfile,filename)
		if s and contents then return contents end
	end
	Lib.DeferFunc = function(f,...)
		signalWait(renderStepped)
		return f(...)
	end
	Lib.LoadCustomAsset = function(filepath)
		if not env or not env.getcustomasset then return end
		if env.isfile and not env.isfile(filepath) then return end
		local s, asset = pcall(env.getcustomasset, filepath)
		if s then return asset end
	end
	Lib.FetchCustomAsset = function(url,filepath)
		if not env or not env.writefile then return end
		local s,data = pcall(game.HttpGet,game,url)
		if not s then return end
		pcall(env.writefile,filepath,data)
		return Lib.LoadCustomAsset(filepath)
	end
	Lib.Signal = (function()
		local funcs = {}
		local disconnect = function(con)
			local pos = table.find(con.Signal.Connections,con)
			if pos then table.remove(con.Signal.Connections,pos) end
		end
		funcs.Connect = function(self,func)
			if type(func) ~= "function" then error("Attempt to connect a non-function") end
			local con = {
				Signal = self,
				Func = func,
				Disconnect = disconnect
			}
			self.Connections[#self.Connections+1] = con
			return con
		end
		funcs.Fire = function(self,...)
			for i,v in next,self.Connections do
				xpcall(coroutine.wrap(v.Func),function(e) warn(e.."\n"..debug.traceback()) end,...)
			end
		end
		local mt = {
			__index = funcs,
			__tostring = function(self)
				return "Signal: " .. tostring(#self.Connections) .. " Connections"
			end
		}
		local function new()
			local obj = {}
			obj.Connections = {}
			return setmetatable(obj,mt)
		end
		return {new = new}
	end)()
	Lib.Set = (function()
		local funcs = {}
		funcs.Add = function(self,obj)
			if self.Map[obj] then return end
			local list = self.List
			list[#list+1] = obj
			self.Map[obj] = true
			self.Changed:Fire()
		end
		funcs.AddTable = function(self,t)
			local changed
			local list,map = self.List,self.Map
			for i = 1,#t do
				local elem = t[i]
				if not map[elem] then
					list[#list+1] = elem
					map[elem] = true
					changed = true
				end
			end
			if changed then self.Changed:Fire() end
		end
		funcs.Remove = function(self,obj)
			if not self.Map[obj] then return end
			local list = self.List
			local pos = table.find(list,obj)
			if pos then table.remove(list,pos) end
			self.Map[obj] = nil
			self.Changed:Fire()
		end
		funcs.RemoveTable = function(self,t)
			local changed
			local list,map = self.List,self.Map
			local removeSet = {}
			for i = 1,#t do
				local elem = t[i]
				map[elem] = nil
				removeSet[elem] = true
			end
			for i = #list,1,-1 do
				local elem = list[i]
				if removeSet[elem] then
					table.remove(list,i)
					changed = true
				end
			end
			if changed then self.Changed:Fire() end
		end
		funcs.Set = function(self,obj)
			if #self.List == 1 and self.List[1] == obj then return end
			self.List = {obj}
			self.Map = {[obj] = true}
			self.Changed:Fire()
		end
		funcs.SetTable = function(self,t)
			local newList,newMap = {},{}
			self.List,self.Map = newList,newMap
			table.move(t,1,#t,1,newList)
			for i = 1,#t do
				newMap[t[i]] = true
			end
			self.Changed:Fire()
		end
		funcs.Clear = function(self)
			if #self.List == 0 then return end
			self.List = {}
			self.Map = {}
			self.Changed:Fire()
		end
		local mt = {__index = funcs}
		local function new()
			local obj = setmetatable({
				List = {},
				Map = {},
				Changed = Lib.Signal.new()
			},mt)
			return obj
		end
		return {new = new}
	end)()
	Lib.IconMap = (function()
		local funcs = {}
		funcs.GetLabel = function(self)
			local label = Instance.new("ImageLabel")
			self:SetupLabel(label)
			return label
		end
		funcs.SetupLabel = function(self,obj)
			obj.BackgroundTransparency = 1
			obj.ImageRectOffset = Vector2.new(0,0)
			obj.ImageRectSize = Vector2.new(self.IconSizeX,self.IconSizeY)
			obj.ScaleType = Enum.ScaleType.Crop
			obj.Size = UDim2.new(0,self.IconSizeX,0,self.IconSizeY)
		end
		funcs.Display = function(self,obj,index)
			obj.Image = self.MapId
			if not self.NumX then
				obj.ImageRectOffset = Vector2.new(self.IconSizeX*index, 0)
			else
				obj.ImageRectOffset = Vector2.new(self.IconSizeX*(index % self.NumX), self.IconSizeY*math.floor(index / self.NumX))
			end
		end
		funcs.DisplayByKey = function(self,obj,key)
			if self.IndexDict[key] then
				self:Display(obj,self.IndexDict[key])
			end
		end
		funcs.SetDict = function(self,dict)
			self.IndexDict = dict
		end
		local mt = {}
		mt.__index = funcs
		local function new(mapId,mapSizeX,mapSizeY,iconSizeX,iconSizeY)
			local obj = setmetatable({
				MapId = mapId,
				MapSizeX = mapSizeX,
				MapSizeY = mapSizeY,
				IconSizeX = iconSizeX,
				IconSizeY = iconSizeY,
				NumX = mapSizeX/iconSizeX,
				IndexDict = {}
			},mt)
			return obj
		end
		local function newLinear(mapId,iconSizeX,iconSizeY)
			local obj = setmetatable({
				MapId = mapId,
				IconSizeX = iconSizeX,
				IconSizeY = iconSizeY,
				IndexDict = {}
			},mt)
			return obj
		end
		return {new = new, newLinear = newLinear}
	end)()
	Lib.ScrollBar = (function()
		local funcs = {}
		local user = service.UserInputService
		local mouse = plr:GetMouse()
		local checkMouseInGui = Lib.CheckMouseInGui
		local createArrow = Lib.CreateArrow
		local function drawThumb(self)
			local total = self.TotalSpace
			local visible = self.VisibleSpace
			local index = self.Index
			local scrollThumb = self.GuiElems.ScrollThumb
			local scrollThumbFrame = self.GuiElems.ScrollThumbFrame
			if not (self:CanScrollUp()	or self:CanScrollDown()) then
				scrollThumb.Visible = false
			else
				scrollThumb.Visible = true
			end
			if self.Horizontal then
				scrollThumb.Size = UDim2.new(visible/total,0,1,0)
				if scrollThumb.AbsoluteSize.X < 16 then
					scrollThumb.Size = UDim2.new(0,16,1,0)
				end
				local fs = scrollThumbFrame.AbsoluteSize.X
				local bs = scrollThumb.AbsoluteSize.X
				scrollThumb.Position = UDim2.new(self:GetScrollPercent()*(fs-bs)/fs,0,0,0)
			else
				scrollThumb.Size = UDim2.new(1,0,visible/total,0)
				if scrollThumb.AbsoluteSize.Y < 16 then
					scrollThumb.Size = UDim2.new(1,0,0,16)
				end
				local fs = scrollThumbFrame.AbsoluteSize.Y
				local bs = scrollThumb.AbsoluteSize.Y
				scrollThumb.Position = UDim2.new(0,0,self:GetScrollPercent()*(fs-bs)/fs,0)
			end
		end
		local function createFrame(self)
			local newFrame = createSimple("Frame",{Style=0,Active=true,AnchorPoint=Vector2.new(0,0),BackgroundColor3=Color3.new(0.35294118523598,0.35294118523598,0.35294118523598),BackgroundTransparency=0,BorderColor3=Color3.new(0.10588236153126,0.16470588743687,0.20784315466881),BorderSizePixel=0,ClipsDescendants=false,Draggable=false,Position=UDim2.new(1,-16,0,0),Rotation=0,Selectable=false,Size=UDim2.new(0,16,1,0),SizeConstraint=0,Visible=true,ZIndex=1,Name="ScrollBar",})
			local button1 = nil
			local button2 = nil
			if self.Horizontal then
				newFrame.Size = UDim2.new(1,0,0,16)
				button1 = createSimple("ImageButton",{
					Parent = newFrame,
					Name = "Left",
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false
				})
				createArrow(16,4,"left").Parent = button1
				button2 = createSimple("ImageButton",{
					Parent = newFrame,
					Name = "Right",
					Position = UDim2.new(1,-16,0,0),
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false
				})
				createArrow(16,4,"right").Parent = button2
			else
				newFrame.Size = UDim2.new(0,16,1,0)
				button1 = createSimple("ImageButton",{
					Parent = newFrame,
					Name = "Up",
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false
				})
				createArrow(16,4,"up").Parent = button1
				button2 = createSimple("ImageButton",{
					Parent = newFrame,
					Name = "Down",
					Position = UDim2.new(0,0,1,-16),
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutoButtonColor = false
				})
				createArrow(16,4,"down").Parent = button2
			end
			local scrollThumbFrame = createSimple("Frame",{
				BackgroundTransparency = 1,
				Parent = newFrame
			})
			if self.Horizontal then
				scrollThumbFrame.Position = UDim2.new(0,16,0,0)
				scrollThumbFrame.Size = UDim2.new(1,-32,1,0)
			else
				scrollThumbFrame.Position = UDim2.new(0,0,0,16)
				scrollThumbFrame.Size = UDim2.new(1,0,1,-32)
			end
			local scrollThumb = createSimple("Frame",{
				BackgroundColor3 = Color3.new(120/255,120/255,120/255),
				BorderSizePixel = 0,
				Parent = scrollThumbFrame
			})
			local markerFrame = createSimple("Frame",{
				BackgroundTransparency = 1,
				Name = "Markers",
				Size = UDim2.new(1,0,1,0),
				Parent = scrollThumbFrame
			})
			local buttonPress = false
			local thumbPress = false
			local thumbFramePress = false
			button1.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and not buttonPress and self:CanScrollUp() then button1.BackgroundTransparency = 0.8 end
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not self:CanScrollUp() then return end
				buttonPress = true
				button1.BackgroundTransparency = 0.5
				if self:CanScrollUp() then self:ScrollUp() self.Scrolled:Fire() end
				local buttonTick = tick()
				local releaseEvent
				releaseEvent = user.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					releaseEvent:Disconnect()
					if checkMouseInGui(button1) and self:CanScrollUp() then button1.BackgroundTransparency = 0.8 else button1.BackgroundTransparency = 1 end
					buttonPress = false
				end)
				while buttonPress do
					if tick() - buttonTick >= 0.3 and self:CanScrollUp() then
						self:ScrollUp()
						self.Scrolled:Fire()
					end
					wait()
				end
			end)
			button1.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and not buttonPress then button1.BackgroundTransparency = 1 end
			end)
			button2.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and not buttonPress and self:CanScrollDown() then button2.BackgroundTransparency = 0.8 end
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not self:CanScrollDown() then return end
				buttonPress = true
				button2.BackgroundTransparency = 0.5
				if self:CanScrollDown() then self:ScrollDown() self.Scrolled:Fire() end
				local buttonTick = tick()
				local releaseEvent
				releaseEvent = user.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					releaseEvent:Disconnect()
					if checkMouseInGui(button2) and self:CanScrollDown() then button2.BackgroundTransparency = 0.8 else button2.BackgroundTransparency = 1 end
					buttonPress = false
				end)
				while buttonPress do
					if tick() - buttonTick >= 0.3 and self:CanScrollDown() then
						self:ScrollDown()
						self.Scrolled:Fire()
					end
					wait()
				end
			end)
			button2.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and not buttonPress then button2.BackgroundTransparency = 1 end
			end)
			scrollThumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and not thumbPress then scrollThumb.BackgroundTransparency = 0.2 scrollThumb.BackgroundColor3 = self.ThumbSelectColor end
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
				local dir = self.Horizontal and "X" or "Y"
				local lastThumbPos = nil
				buttonPress = false
				thumbFramePress = false
				thumbPress = true
				scrollThumb.BackgroundTransparency = 0
				local mouseOffset = mouse[dir] - scrollThumb.AbsolutePosition[dir]
				local mouseStart = mouse[dir]
				local releaseEvent
				local mouseEvent
				releaseEvent = user.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					releaseEvent:Disconnect()
					if mouseEvent then mouseEvent:Disconnect() end
					if checkMouseInGui(scrollThumb) then scrollThumb.BackgroundTransparency = 0.2 else scrollThumb.BackgroundTransparency = 0 scrollThumb.BackgroundColor3 = self.ThumbColor end
					thumbPress = false
				end)
				self:Update()
				mouseEvent = user.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement and thumbPress and releaseEvent.Connected then
						local thumbFrameSize = scrollThumbFrame.AbsoluteSize[dir]-scrollThumb.AbsoluteSize[dir]
						local pos = mouse[dir] - scrollThumbFrame.AbsolutePosition[dir] - mouseOffset
						if pos > thumbFrameSize then
							pos = thumbFrameSize
						elseif pos < 0 then
							pos = 0
						end
						if lastThumbPos ~= pos then
							lastThumbPos = pos
							self:ScrollTo(math.floor(0.5+pos/thumbFrameSize*(self.TotalSpace-self.VisibleSpace)))
						end
						wait()
					end
				end)
			end)
			scrollThumb.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and not thumbPress then scrollThumb.BackgroundTransparency = 0 scrollThumb.BackgroundColor3 = self.ThumbColor end
			end)
			scrollThumbFrame.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 or checkMouseInGui(scrollThumb) then return end
				local dir = self.Horizontal and "X" or "Y"
				local scrollDir = 0
				if mouse[dir] >= scrollThumb.AbsolutePosition[dir] + scrollThumb.AbsoluteSize[dir] then
					scrollDir = 1
				end
				local function doTick()
					local scrollSize = self.VisibleSpace - 1
					if scrollDir == 0 and mouse[dir] < scrollThumb.AbsolutePosition[dir] then
						self:ScrollTo(self.Index - scrollSize)
					elseif scrollDir == 1 and mouse[dir] >= scrollThumb.AbsolutePosition[dir] + scrollThumb.AbsoluteSize[dir] then
						self:ScrollTo(self.Index + scrollSize)
					end
				end
				thumbPress = false
				thumbFramePress = true
				doTick()
				local thumbFrameTick = tick()
				local releaseEvent
				releaseEvent = user.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					releaseEvent:Disconnect()
					thumbFramePress = false
				end)
				while thumbFramePress do
					if tick() - thumbFrameTick >= 0.3 and checkMouseInGui(scrollThumbFrame) then
						doTick()
					end
					wait()
				end
			end)
			newFrame.MouseWheelForward:Connect(function()
				self:ScrollTo(self.Index - self.WheelIncrement)
			end)
			newFrame.MouseWheelBackward:Connect(function()
				self:ScrollTo(self.Index + self.WheelIncrement)
			end)
			self.GuiElems.ScrollThumb = scrollThumb
			self.GuiElems.ScrollThumbFrame = scrollThumbFrame
			self.GuiElems.Button1 = button1
			self.GuiElems.Button2 = button2
			self.GuiElems.MarkerFrame = markerFrame
			return newFrame
		end
		funcs.Update = function(self,nocallback)
			local total = self.TotalSpace
			local visible = self.VisibleSpace
			local index = self.Index
			local button1 = self.GuiElems.Button1
			local button2 = self.GuiElems.Button2
			self.Index = math.clamp(self.Index,0,math.max(0,total-visible))
			if self.LastTotalSpace ~= self.TotalSpace then
				self.LastTotalSpace = self.TotalSpace
				self:UpdateMarkers()
			end
			if self:CanScrollUp() then
				for i,v in pairs(button1.Arrow:GetChildren()) do
					v.BackgroundTransparency = 0
				end
			else
				button1.BackgroundTransparency = 1
				for i,v in pairs(button1.Arrow:GetChildren()) do
					v.BackgroundTransparency = 0.5
				end
			end
			if self:CanScrollDown() then
				for i,v in pairs(button2.Arrow:GetChildren()) do
					v.BackgroundTransparency = 0
				end
			else
				button2.BackgroundTransparency = 1
				for i,v in pairs(button2.Arrow:GetChildren()) do
					v.BackgroundTransparency = 0.5
				end
			end
			drawThumb(self)
		end
		funcs.UpdateMarkers = function(self)
			local markerFrame = self.GuiElems.MarkerFrame
			markerFrame:ClearAllChildren()
			for i,v in pairs(self.Markers) do
				if i < self.TotalSpace then
					createSimple("Frame",{
						BackgroundTransparency = 0,
						BackgroundColor3 = v,
						BorderSizePixel = 0,
						Position = self.Horizontal and UDim2.new(i/self.TotalSpace,0,1,-6) or UDim2.new(1,-6,i/self.TotalSpace,0),
						Size = self.Horizontal and UDim2.new(0,1,0,6) or UDim2.new(0,6,0,1),
						Name = "Marker"..tostring(i),
						Parent = markerFrame
					})
				end
			end
		end
		funcs.AddMarker = function(self,ind,color)
			self.Markers[ind] = color or Color3.new(0,0,0)
		end
		funcs.ScrollTo = function(self,ind,nocallback)
			self.Index = ind
			self:Update()
			if not nocallback then
				self.Scrolled:Fire()
			end
		end
		funcs.ScrollUp = function(self)
			self.Index = self.Index - self.Increment
			self:Update()
		end
		funcs.ScrollDown = function(self)
			self.Index = self.Index + self.Increment
			self:Update()
		end
		funcs.CanScrollUp = function(self)
			return self.Index > 0
		end
		funcs.CanScrollDown = function(self)
			return self.Index + self.VisibleSpace < self.TotalSpace
		end
		funcs.GetScrollPercent = function(self)
			return self.Index/(self.TotalSpace-self.VisibleSpace)
		end
		funcs.SetScrollPercent = function(self,perc)
			self.Index = math.floor(perc*(self.TotalSpace-self.VisibleSpace))
			self:Update()
		end
		funcs.Texture = function(self,data)
			self.ThumbColor = data.ThumbColor or Color3.new(0,0,0)
			self.ThumbSelectColor = data.ThumbSelectColor or Color3.new(0,0,0)
			self.GuiElems.ScrollThumb.BackgroundColor3 = data.ThumbColor or Color3.new(0,0,0)
			self.Gui.BackgroundColor3 = data.FrameColor or Color3.new(0,0,0)
			self.GuiElems.Button1.BackgroundColor3 = data.ButtonColor or Color3.new(0,0,0)
			self.GuiElems.Button2.BackgroundColor3 = data.ButtonColor or Color3.new(0,0,0)
			for i,v in pairs(self.GuiElems.Button1.Arrow:GetChildren()) do
				v.BackgroundColor3 = data.ArrowColor or Color3.new(0,0,0)
			end
			for i,v in pairs(self.GuiElems.Button2.Arrow:GetChildren()) do
				v.BackgroundColor3 = data.ArrowColor or Color3.new(0,0,0)
			end
		end
		funcs.SetScrollFrame = function(self,frame)
			if self.ScrollUpEvent then self.ScrollUpEvent:Disconnect() self.ScrollUpEvent = nil end
			if self.ScrollDownEvent then self.ScrollDownEvent:Disconnect() self.ScrollDownEvent = nil end
			self.ScrollUpEvent = frame.MouseWheelForward:Connect(function() self:ScrollTo(self.Index - self.WheelIncrement) end)
			self.ScrollDownEvent = frame.MouseWheelBackward:Connect(function() self:ScrollTo(self.Index + self.WheelIncrement) end)
		end
		local mt = {}
		mt.__index = funcs
		local function new(hor)
			local obj = setmetatable({
				Index = 0,
				VisibleSpace = 0,
				TotalSpace = 0,
				Increment = 1,
				WheelIncrement = 1,
				Markers = {},
				GuiElems = {},
				Horizontal = hor,
				LastTotalSpace = 0,
				Scrolled = Lib.Signal.new()
			},mt)
			obj.Gui = createFrame(obj)
			obj:Texture({
				ThumbColor = Color3.fromRGB(60,60,60),
				ThumbSelectColor = Color3.fromRGB(75,75,75),
				ArrowColor = Color3.new(1,1,1),
				FrameColor = Color3.fromRGB(40,40,40),
				ButtonColor = Color3.fromRGB(75,75,75)
			})
			return obj
		end
		return {new = new}
	end)()
	Lib.Window = (function()
		local funcs = {}
		local static = {MinWidth = 200, FreeWidth = 200}
		local mouse = plr:GetMouse()
		local sidesGui,alignIndicator
		local visibleWindows = {}
		local leftSide = {Width = 300, Windows = {}, ResizeCons = {}, Hidden = true}
		local rightSide = {Width = 300, Windows = {}, ResizeCons = {}, Hidden = true}
		local displayOrderStart
		local sideDisplayOrder
		local sideTweenInfo = TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
		local tweens = {}
		local isA = game.IsA
		local theme = {
			MainColor1 = Color3.fromRGB(52,52,52),
			MainColor2 = Color3.fromRGB(45,45,45),
			Button = Color3.fromRGB(60,60,60)
		}
		local function stopTweens()
			for i = 1,#tweens do
				tweens[i]:Cancel()
			end
			tweens = {}
		end
		local function resizeHook(self,resizer,dir)
			local guiMain = self.GuiElems.Main
			resizer.InputBegan:Connect(function(input)
				if not self.Dragging and not self.Resizing and self.Resizable and self.ResizableInternal then
					local isH = dir:find("[WE]") and true
					local isV = dir:find("[NS]") and true
					local signX = dir:find("W",1,true) and -1 or 1
					local signY = dir:find("N",1,true) and -1 or 1
					if self.Minimized and isV then return end
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						resizer.BackgroundTransparency = 0.5
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent
						local offX = mouse.X - resizer.AbsolutePosition.X
						local offY = mouse.Y - resizer.AbsolutePosition.Y
						self.Resizing = resizer
						resizer.BackgroundTransparency = 1
						releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								releaseEvent:Disconnect()
								mouseEvent:Disconnect()
								self.Resizing = false
								resizer.BackgroundTransparency = 1
							end
						end)
						mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
							if self.Resizable and self.ResizableInternal and input.UserInputType == Enum.UserInputType.MouseMovement then
								self:StopTweens()
								local deltaX = input.Position.X - resizer.AbsolutePosition.X - offX
								local deltaY = input.Position.Y - resizer.AbsolutePosition.Y - offY
								if guiMain.AbsoluteSize.X + deltaX*signX < self.MinX then deltaX = signX*(self.MinX - guiMain.AbsoluteSize.X) end
								if guiMain.AbsoluteSize.Y + deltaY*signY < self.MinY then deltaY = signY*(self.MinY - guiMain.AbsoluteSize.Y) end
								if signY < 0 and guiMain.AbsolutePosition.Y + deltaY < 0 then deltaY = -guiMain.AbsolutePosition.Y end
								guiMain.Position = guiMain.Position + UDim2.new(0,(signX < 0 and deltaX or 0),0,(signY < 0 and deltaY or 0))
								self.SizeX = self.SizeX + (isH and deltaX*signX or 0)
								self.SizeY = self.SizeY + (isV and deltaY*signY or 0)
								guiMain.Size = UDim2.new(0,self.SizeX,0,self.Minimized and 20 or self.SizeY)
							end
						end)
					end
				end
			end)
			resizer.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and self.Resizing ~= resizer then
					resizer.BackgroundTransparency = 1
				end
			end)
		end
		local updateWindows
		local function moveToTop(window)
			local found = table.find(visibleWindows,window)
			if found then
				table.remove(visibleWindows,found)
				table.insert(visibleWindows,1,window)
				updateWindows()
			end
		end
		local function sideHasRoom(side,neededSize)
			local maxY = sidesGui.AbsoluteSize.Y - (math.max(0,#side.Windows - 1) * 4)
			local inc = 0
			for i,v in pairs(side.Windows) do
				inc = inc + (v.MinY or 100)
				if inc > maxY - neededSize then return false end
			end
			return true
		end
		local function getSideInsertPos(side,curY)
			local pos = #side.Windows + 1
			local range = {0,sidesGui.AbsoluteSize.Y}
			for i,v in pairs(side.Windows) do
				local midPos = v.PosY + v.SizeY/2
				if curY <= midPos then
					pos = i
					range[2] = midPos
					break
				else
					range[1] = midPos
				end
			end
			return pos,range
		end
		local function focusInput(self,obj)
			if isA(obj,"GuiButton") then
				obj.MouseButton1Down:Connect(function()
					moveToTop(self)
				end)
			elseif isA(obj,"TextBox") then
				obj.Focused:Connect(function()
					moveToTop(self)
				end)
			end
		end
		local createGui = function(self)
			local gui = create({
				{1,"ScreenGui",{Name="Window",}},
				{2,"Frame",{Active=true,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Main",Parent={1},Position=UDim2.new(0.40000000596046,0,0.40000000596046,0),Size=UDim2.new(0,300,0,300),}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,Name="Content",Parent={2},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),ClipsDescendants=true}},
				{4,"Frame",{BackgroundColor3=Color3.fromRGB(33,33,33),BorderSizePixel=0,Name="Line",Parent={3},Size=UDim2.new(1,0,0,1),}},
				{5,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="TopBar",Parent={2},Size=UDim2.new(1,0,0,20),}},
				{6,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={5},Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,0,20),Text="Window",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
				{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Close",Parent={5},Position=UDim2.new(1,-18,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
				{8,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5054663650",Parent={7},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,10,0,10),}},
				{9,"UICorner",{CornerRadius=UDim.new(0,4),Parent={7},}},
				{10,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Minimize",Parent={5},Position=UDim2.new(1,-36,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
				{11,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034768003",Parent={10},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,10,0,10),}},
				{12,"UICorner",{CornerRadius=UDim.new(0,4),Parent={10},}},
				{13,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://1427967925",Name="Outlines",Parent={2},Position=UDim2.new(0,-5,0,-5),ScaleType=1,Size=UDim2.new(1,10,1,10),SliceCenter=Rect.new(6,6,25,25),TileSize=UDim2.new(0,20,0,20),}},
				{14,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="ResizeControls",Parent={2},Position=UDim2.new(0,-5,0,-5),Size=UDim2.new(1,10,1,10),}},
				{15,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="North",Parent={14},Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{16,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="South",Parent={14},Position=UDim2.new(0,5,1,-5),Size=UDim2.new(1,-10,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{17,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="NorthEast",Parent={14},Position=UDim2.new(1,-5,0,0),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{18,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="East",Parent={14},Position=UDim2.new(1,-5,0,5),Size=UDim2.new(0,5,1,-10),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{19,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="West",Parent={14},Position=UDim2.new(0,0,0,5),Size=UDim2.new(0,5,1,-10),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{20,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="SouthEast",Parent={14},Position=UDim2.new(1,-5,1,-5),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{21,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="NorthWest",Parent={14},Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{22,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="SouthWest",Parent={14},Position=UDim2.new(0,0,1,-5),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
			})
			local guiMain = gui.Main
			local guiTopBar = guiMain.TopBar
			local guiResizeControls = guiMain.ResizeControls
			self.GuiElems.Main = guiMain
			self.GuiElems.TopBar = guiMain.TopBar
			self.GuiElems.Content = guiMain.Content
			self.GuiElems.Line = guiMain.Content.Line
			self.GuiElems.Outlines = guiMain.Outlines
			self.GuiElems.Title = guiTopBar.Title
			self.GuiElems.Close = guiTopBar.Close
			self.GuiElems.Minimize = guiTopBar.Minimize
			self.GuiElems.ResizeControls = guiResizeControls
			self.ContentPane = guiMain.Content
			guiTopBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Draggable then
					local releaseEvent,mouseEvent
					local maxX = sidesGui.AbsoluteSize.X
					local initX = guiMain.AbsolutePosition.X
					local initY = guiMain.AbsolutePosition.Y
					local offX = mouse.X - initX
					local offY = mouse.Y - initY
					local alignInsertPos,alignInsertSide
					guiDragging = true
					releaseEvent = game:GetService("UserInputService").InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
							guiDragging = false
							alignIndicator.Parent = nil
							if alignInsertSide then
								local targetSide = (alignInsertSide == "left" and leftSide) or (alignInsertSide == "right" and rightSide)
								self:AlignTo(targetSide,alignInsertPos)
							end
						end
					end)
					mouseEvent = game:GetService("UserInputService").InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement and self.Draggable and not self.Closed then
							if self.Aligned then
								if leftSide.Resizing or rightSide.Resizing then return end
								local posX,posY = input.Position.X-offX,input.Position.Y-offY
								local delta = math.sqrt((posX-initX)^2 + (posY-initY)^2)
								if delta >= 5 then
									self:SetAligned(false)
								end
							else
								local inputX,inputY = input.Position.X,input.Position.Y
								local posX,posY = inputX-offX,inputY-offY
								if posY < 0 then posY = 0 end
								guiMain.Position = UDim2.new(0,posX,0,posY)
								if self.Resizable and self.Alignable then
									if inputX < 25 then
										if sideHasRoom(leftSide,self.MinY or 100) then
											local insertPos,range = getSideInsertPos(leftSide,inputY)
											alignIndicator.Indicator.Position = UDim2.new(0,-15,0,range[1])
											alignIndicator.Indicator.Size = UDim2.new(0,40,0,range[2]-range[1])
											Lib.ShowGui(alignIndicator)
											alignInsertPos = insertPos
											alignInsertSide = "left"
											return
										end
									elseif inputX >= maxX - 25 then
										if sideHasRoom(rightSide,self.MinY or 100) then
											local insertPos,range = getSideInsertPos(rightSide,inputY)
											alignIndicator.Indicator.Position = UDim2.new(0,maxX-25,0,range[1])
											alignIndicator.Indicator.Size = UDim2.new(0,40,0,range[2]-range[1])
											Lib.ShowGui(alignIndicator)
											alignInsertPos = insertPos
											alignInsertSide = "right"
											return
										end
									end
								end
								alignIndicator.Parent = nil
								alignInsertPos = nil
								alignInsertSide = nil
							end
						end
					end)
				end
			end)
			guiTopBar.Close.MouseButton1Click:Connect(function()
				if self.Closed then return end
				self:Close()
			end)
			guiTopBar.Minimize.MouseButton1Click:Connect(function()
				if self.Closed then return end
				if self.Aligned then
					self:SetAligned(false)
				else
					self:SetMinimized()
				end
			end)
			guiTopBar.Minimize.MouseButton2Click:Connect(function()
				if self.Closed then return end
				if not self.Aligned then
					self:SetMinimized(nil,2)
					guiTopBar.Minimize.BackgroundTransparency = 1
				end
			end)
			guiMain.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.Aligned and not self.Closed then
					moveToTop(self)
				end
			end)
			guiMain:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				local absPos = guiMain.AbsolutePosition
				self.PosX = absPos.X
				self.PosY = absPos.Y
			end)
			resizeHook(self,guiResizeControls.North,"N")
			resizeHook(self,guiResizeControls.NorthEast,"NE")
			resizeHook(self,guiResizeControls.East,"E")
			resizeHook(self,guiResizeControls.SouthEast,"SE")
			resizeHook(self,guiResizeControls.South,"S")
			resizeHook(self,guiResizeControls.SouthWest,"SW")
			resizeHook(self,guiResizeControls.West,"W")
			resizeHook(self,guiResizeControls.NorthWest,"NW")
			guiMain.Size = UDim2.new(0,self.SizeX,0,self.SizeY)
			gui.DescendantAdded:Connect(function(obj) focusInput(self,obj) end)
			local descs = gui:GetDescendants()
			for i = 1,#descs do
				focusInput(self,descs[i])
			end
			self.MinimizeAnim = Lib.ButtonAnim(guiTopBar.Minimize)
			self.CloseAnim = Lib.ButtonAnim(guiTopBar.Close)
			return gui
		end
		local function updateSideFrames(noTween)
			stopTweens()
			leftSide.Frame.Size = UDim2.new(0,leftSide.Width,1,0)
			rightSide.Frame.Size = UDim2.new(0,rightSide.Width,1,0)
			leftSide.Frame.Resizer.Position = UDim2.new(0,leftSide.Width,0,0)
			rightSide.Frame.Resizer.Position = UDim2.new(0,-5,0,0)
			local leftHidden = #leftSide.Windows == 0 or leftSide.Hidden
			local rightHidden = #rightSide.Windows == 0 or rightSide.Hidden
			local leftPos = (leftHidden and UDim2.new(0,-leftSide.Width-10,0,0) or UDim2.new(0,0,0,0))
			local rightPos = (rightHidden and UDim2.new(1,10,0,0) or UDim2.new(1,-rightSide.Width,0,0))
			sidesGui.LeftToggle.Text = leftHidden and ">" or "<"
			sidesGui.RightToggle.Text = rightHidden and "<" or ">"
			if not noTween then
				local function insertTween(...)
					local tween = service.TweenService:Create(...)
					tweens[#tweens+1] = tween
					tween:Play()
				end
				insertTween(leftSide.Frame,sideTweenInfo,{Position = leftPos})
				insertTween(rightSide.Frame,sideTweenInfo,{Position = rightPos})
				insertTween(sidesGui.LeftToggle,sideTweenInfo,{Position = UDim2.new(0,#leftSide.Windows == 0 and -16 or 0,0,-36)})
				insertTween(sidesGui.RightToggle,sideTweenInfo,{Position = UDim2.new(1,#rightSide.Windows == 0 and 0 or -16,0,-36)})
			else
				leftSide.Frame.Position = leftPos
				rightSide.Frame.Position = rightPos
				sidesGui.LeftToggle.Position = UDim2.new(0,#leftSide.Windows == 0 and -16 or 0,0,-36)
				sidesGui.RightToggle.Position = UDim2.new(1,#rightSide.Windows == 0 and 0 or -16,0,-36)
			end
		end
		local function getSideFramePos(side)
			local leftHidden = #leftSide.Windows == 0 or leftSide.Hidden
			local rightHidden = #rightSide.Windows == 0 or rightSide.Hidden
			if side == leftSide then
				return (leftHidden and UDim2.new(0,-leftSide.Width-10,0,0) or UDim2.new(0,0,0,0))
			else
				return (rightHidden and UDim2.new(1,10,0,0) or UDim2.new(1,-rightSide.Width,0,0))
			end
		end
		local function sideResized(side)
			local currentPos = 0
			local sideFramePos = getSideFramePos(side)
			for i,v in pairs(side.Windows) do
				v.SizeX = side.Width
				v.GuiElems.Main.Size = UDim2.new(0,side.Width,0,v.SizeY)
				v.GuiElems.Main.Position = UDim2.new(sideFramePos.X.Scale,sideFramePos.X.Offset,0,currentPos)
				currentPos = currentPos + v.SizeY+4
			end
		end
		local function sideResizerHook(resizer,dir,side,pos)
			local mouse = Main.Mouse
			local windows = side.Windows
			resizer.InputBegan:Connect(function(input)
				if not side.Resizing then
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						resizer.BackgroundColor3 = theme.MainColor2
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent
						local offX = mouse.X - resizer.AbsolutePosition.X
						local offY = mouse.Y - resizer.AbsolutePosition.Y
						side.Resizing = resizer
						resizer.BackgroundColor3 = theme.MainColor2
						releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								releaseEvent:Disconnect()
								mouseEvent:Disconnect()
								side.Resizing = false
								resizer.BackgroundColor3 = theme.Button
							end
						end)
						mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
							if not resizer.Parent then
								releaseEvent:Disconnect()
								mouseEvent:Disconnect()
								side.Resizing = false
								return
							end
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								if dir == "V" then
									local delta = input.Position.Y - resizer.AbsolutePosition.Y - offY
									if delta > 0 then
										local neededSize = delta
										for i = pos+1,#windows do
											local window = windows[i]
											local newSize = math.max(window.SizeY-neededSize,(window.MinY or 100))
											neededSize = neededSize - (window.SizeY - newSize)
											window.SizeY = newSize
										end
										windows[pos].SizeY = windows[pos].SizeY + math.max(0,delta-neededSize)
									else
										local neededSize = -delta
										for i = pos,1,-1 do
											local window = windows[i]
											local newSize = math.max(window.SizeY-neededSize,(window.MinY or 100))
											neededSize = neededSize - (window.SizeY - newSize)
											window.SizeY = newSize
										end
										windows[pos+1].SizeY = windows[pos+1].SizeY + math.max(0,-delta-neededSize)
									end
									updateSideFrames()
									sideResized(side)
								elseif dir == "H" then
									local maxWidth = math.max(300,sidesGui.AbsoluteSize.X-static.FreeWidth)
									local otherSide = (side == leftSide and rightSide or leftSide)
									local delta = input.Position.X - resizer.AbsolutePosition.X - offX
									delta = (side == leftSide and delta or -delta)
									local proposedSize = math.max(static.MinWidth,side.Width + delta)
									if proposedSize + otherSide.Width <= maxWidth then
										side.Width = proposedSize
									else
										local newOtherSize = maxWidth - proposedSize
										if newOtherSize >= static.MinWidth then
											side.Width = proposedSize
											otherSide.Width = newOtherSize
										else
											side.Width = maxWidth - static.MinWidth
											otherSide.Width = static.MinWidth
										end
									end
									updateSideFrames(true)
									sideResized(side)
									sideResized(otherSide)
								end
							end
						end)
					end
				end
			end)
			resizer.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and side.Resizing ~= resizer then
					resizer.BackgroundColor3 = theme.Button
				end
			end)
		end
		local function renderSide(side,noTween)
			local currentPos = 0
			local sideFramePos = getSideFramePos(side)
			local template = side.WindowResizer:Clone()
			for i,v in pairs(side.ResizeCons) do v:Disconnect() end
			for i,v in pairs(side.Frame:GetChildren()) do if v.Name == "WindowResizer" then v:Destroy() end end
			side.ResizeCons = {}
			side.Resizing = nil
			for i,v in pairs(side.Windows) do
				v.SidePos = i
				local isEnd = i == #side.Windows
				local size = UDim2.new(0,side.Width,0,v.SizeY)
				local pos = UDim2.new(sideFramePos.X.Scale,sideFramePos.X.Offset,0,currentPos)
				Lib.ShowGui(v.Gui)
				if noTween then
					v.GuiElems.Main.Size = size
					v.GuiElems.Main.Position = pos
				else
					local tween = service.TweenService:Create(v.GuiElems.Main,sideTweenInfo,{Size = size, Position = pos})
					tweens[#tweens+1] = tween
					tween:Play()
				end
				currentPos = currentPos + v.SizeY+4
				if not isEnd then
					local newTemplate = template:Clone()
					newTemplate.Position = UDim2.new(1,-side.Width,0,currentPos-4)
					side.ResizeCons[#side.ResizeCons+1] = v.Gui.Main:GetPropertyChangedSignal("Size"):Connect(function()
						newTemplate.Position = UDim2.new(1,-side.Width,0, v.GuiElems.Main.Position.Y.Offset + v.GuiElems.Main.Size.Y.Offset)
					end)
					side.ResizeCons[#side.ResizeCons+1] = v.Gui.Main:GetPropertyChangedSignal("Position"):Connect(function()
						newTemplate.Position = UDim2.new(1,-side.Width,0, v.GuiElems.Main.Position.Y.Offset + v.GuiElems.Main.Size.Y.Offset)
					end)
					sideResizerHook(newTemplate,"V",side,i)
					newTemplate.Parent = side.Frame
				end
			end
		end
		local function updateSide(side,noTween)
			local oldHeight = 0
			local currentPos = 0
			local neededSize = 0
			local windows = side.Windows
			local height = sidesGui.AbsoluteSize.Y - (math.max(0,#windows - 1) * 4)
			for i,v in pairs(windows) do oldHeight = oldHeight + v.SizeY end
			for i,v in pairs(windows) do
				if i == #windows then
					v.SizeY = height-currentPos
					neededSize = math.max(0,(v.MinY or 100)-v.SizeY)
				else
					v.SizeY = math.max(math.floor(v.SizeY/oldHeight*height),v.MinY or 100)
				end
				currentPos = currentPos + v.SizeY
			end
			if neededSize > 0 then
				for i = #windows-1,1,-1 do
					local window = windows[i]
					local newSize = math.max(window.SizeY-neededSize,(window.MinY or 100))
					neededSize = neededSize - (window.SizeY - newSize)
					window.SizeY = newSize
				end
				local lastWindow = windows[#windows]
				lastWindow.SizeY = (lastWindow.MinY or 100)-neededSize
			end
			renderSide(side,noTween)
		end
		updateWindows = function(noTween)
			updateSideFrames(noTween)
			updateSide(leftSide,noTween)
			updateSide(rightSide,noTween)
			local count = 0
			for i = #visibleWindows,1,-1 do
				visibleWindows[i].Gui.DisplayOrder = displayOrderStart + count
				Lib.ShowGui(visibleWindows[i].Gui)
				count = count + 1
			end
		end
		funcs.SetMinimized = function(self,set,mode)
			local oldVal = self.Minimized
			local newVal
			if set == nil then newVal = not self.Minimized else newVal = set end
			self.Minimized = newVal
			if not mode then mode = 1 end
			local resizeControls = self.GuiElems.ResizeControls
			local minimizeControls = {"North","NorthEast","NorthWest","South","SouthEast","SouthWest"}
			for i = 1,#minimizeControls do
				local control = resizeControls:FindFirstChild(minimizeControls[i])
				if control then control.Visible = not newVal end
			end
			if mode == 1 or mode == 2 then
				self:StopTweens()
				if mode == 1 then
					self.GuiElems.Main:TweenSize(UDim2.new(0,self.SizeX,0,newVal and 20 or self.SizeY),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				else
					local maxY = sidesGui.AbsoluteSize.Y
					local newPos = UDim2.new(0,self.PosX,0,newVal and math.min(maxY-20,self.PosY + self.SizeY - 20) or math.max(0,self.PosY - self.SizeY + 20))
					self.GuiElems.Main:TweenPosition(newPos,Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
					self.GuiElems.Main:TweenSize(UDim2.new(0,self.SizeX,0,newVal and 20 or self.SizeY),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				end
				self.GuiElems.Minimize.ImageLabel.Image = newVal and "rbxassetid://5060023708" or "rbxassetid://5034768003"
			end
			if oldVal ~= newVal then
				if newVal then
					self.OnMinimize:Fire()
				else
					self.OnRestore:Fire()
				end
			end
		end
		funcs.Resize = function(self,sizeX,sizeY)
			self.SizeX = sizeX or self.SizeX
			self.SizeY = sizeY or self.SizeY
			self.GuiElems.Main.Size = UDim2.new(0,self.SizeX,0,self.SizeY)
		end
		funcs.SetSize = funcs.Resize
		funcs.GetContent = function(self)
			return self.ContentPane or (self.GuiElems and self.GuiElems.Content)
		end
		funcs.GetContentFrame = funcs.GetContent
		funcs.SetTitle = function(self,title)
			self.GuiElems.Title.Text = title
		end
		funcs.SetResizable = function(self,val)
			self.Resizable = val
			self.GuiElems.ResizeControls.Visible = self.Resizable and self.ResizableInternal
		end
		funcs.SetResizableInternal = function(self,val)
			self.ResizableInternal = val
			self.GuiElems.ResizeControls.Visible = self.Resizable and self.ResizableInternal
		end
		funcs.SetAligned = function(self,val)
			self.Aligned = val
			self:SetResizableInternal(not val)
			self.GuiElems.Main.Active = not val
			self.GuiElems.Main.Outlines.Visible = not val
			if not val then
				for i,v in pairs(leftSide.Windows) do if v == self then table.remove(leftSide.Windows,i) break end end
				for i,v in pairs(rightSide.Windows) do if v == self then table.remove(rightSide.Windows,i) break end end
				if not table.find(visibleWindows,self) then table.insert(visibleWindows,1,self) end
				self.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5034768003"
				self.Side = nil
				updateWindows()
			else
				self:SetMinimized(false,3)
				for i,v in pairs(visibleWindows) do if v == self then table.remove(visibleWindows,i) break end end
				self.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5448127505"
			end
		end
		funcs.Add = function(self,obj,name)
			if type(obj) == "table" and obj.Gui and obj.Gui:IsA("GuiObject") then
				obj.Gui.Parent = self.ContentPane
			else
				obj.Parent = self.ContentPane
			end
			if name then self.Elements[name] = obj end
		end
		funcs.GetElement = function(self,obj,name)
			return self.Elements[name]
		end
		funcs.AlignTo = function(self,side,pos,size,silent)
			if table.find(side.Windows,self) or self.Closed then return end
			size = size or self.SizeY
			if size > 0 and size <= 1 then
				local totalSideHeight = 0
				for i,v in pairs(side.Windows) do totalSideHeight = totalSideHeight + v.SizeY end
				self.SizeY = (totalSideHeight > 0 and totalSideHeight * size * 2) or size
			else
				self.SizeY = (size > 0 and size or 100)
			end
			self:SetAligned(true)
			self.Side = side
			self.SizeX = side.Width
			self.Gui.DisplayOrder = sideDisplayOrder + 1
			for i,v in pairs(side.Windows) do v.Gui.DisplayOrder = sideDisplayOrder end
			pos = math.min(#side.Windows+1, pos or 1)
			self.SidePos = pos
			table.insert(side.Windows, pos, self)
			if not silent then
				side.Hidden = false
			end
			updateWindows(silent)
		end
		funcs.Close = function(self)
			self.Closed = true
			self:SetResizableInternal(false)
			Lib.FindAndRemove(leftSide.Windows,self)
			Lib.FindAndRemove(rightSide.Windows,self)
			Lib.FindAndRemove(visibleWindows,self)
			self.MinimizeAnim.Disable()
			self.CloseAnim.Disable()
			self.ClosedSide = self.Side
			self.Side = nil
			self.OnDeactivate:Fire()
			if not self.Aligned then
				self:StopTweens()
				local ti = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
				local closeTime = tick()
				self.LastClose = closeTime
				self:DoTween(self.GuiElems.Main,ti,{Size = UDim2.new(0,self.SizeX,0,20)})
				self:DoTween(self.GuiElems.Title,ti,{TextTransparency = 1})
				self:DoTween(self.GuiElems.Minimize.ImageLabel,ti,{ImageTransparency = 1})
				self:DoTween(self.GuiElems.Close.ImageLabel,ti,{ImageTransparency = 1})
				Lib.FastWait(0.2)
				if closeTime ~= self.LastClose then return end
				self:DoTween(self.GuiElems.TopBar,ti,{BackgroundTransparency = 1})
				self:DoTween(self.GuiElems.Outlines,ti,{ImageTransparency = 1})
				Lib.FastWait(0.2)
				if closeTime ~= self.LastClose then return end
			end
			self.Aligned = false
			self.Gui.Parent = nil
			updateWindows(true)
		end
		funcs.Hide = funcs.Close
		funcs.IsVisible = function(self)
			return not self.Closed and ((self.Side and not self.Side.Hidden) or not self.Side)
		end
		funcs.IsContentVisible = function(self)
			return self:IsVisible() and not self.Minimized
		end
		funcs.Focus = function(self)
			moveToTop(self)
		end
		funcs.MoveInBoundary = function(self)
			local posX,posY = self.PosX,self.PosY
			local maxX,maxY = sidesGui.AbsoluteSize.X,sidesGui.AbsoluteSize.Y
			posX = math.min(posX,maxX-self.SizeX)
			posY = math.min(posY,maxY-20)
			self.GuiElems.Main.Position = UDim2.new(0,posX,0,posY)
		end
		funcs.DoTween = function(self,...)
			local tween = service.TweenService:Create(...)
			self.Tweens[#self.Tweens+1] = tween
			tween:Play()
		end
		funcs.StopTweens = function(self)
			for i,v in pairs(self.Tweens) do
				v:Cancel()
			end
			self.Tweens = {}
		end
		funcs.Show = function(self,data)
			return static.ShowWindow(self,data)
		end
		funcs.ShowAndFocus = function(self,data)
			static.ShowWindow(self,data)
			service.RunService.RenderStepped:wait()
			self:Focus()
		end
		static.ShowWindow = function(window,data)
			data = data or {}
			local align = data.Align
			local pos = data.Pos
			local size = data.Size
			local targetSide = (align == "left" and leftSide) or (align == "right" and rightSide)
			if not window.Closed then
				if not window.Aligned then
					window:SetMinimized(false)
				elseif window.Side and not data.Silent then
					static.SetSideVisible(window.Side,true)
				end
				return
			end
			window.Closed = false
			window.LastClose = tick()
			window.GuiElems.Title.TextTransparency = 0
			window.GuiElems.Minimize.ImageLabel.ImageTransparency = 0
			window.GuiElems.Close.ImageLabel.ImageTransparency = 0
			window.GuiElems.TopBar.BackgroundTransparency = 0
			window.GuiElems.Outlines.ImageTransparency = 0
			window.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5034768003"
			window.GuiElems.Main.Active = true
			window.GuiElems.Main.Outlines.Visible = true
			window:SetMinimized(false,3)
			window:SetResizableInternal(true)
			window.MinimizeAnim.Enable()
			window.CloseAnim.Enable()
			if align then
				window:AlignTo(targetSide,pos,size,data.Silent)
			else
				if align == nil and window.ClosedSide then
					window:AlignTo(window.ClosedSide,window.SidePos,size,true)
					static.SetSideVisible(window.ClosedSide,true)
				else
					if table.find(visibleWindows,window) then return end
					window.GuiElems.Main.Size = UDim2.new(0,window.SizeX,0,20)
					local ti = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
					window:StopTweens()
					window:DoTween(window.GuiElems.Main,ti,{Size = UDim2.new(0,window.SizeX,0,window.SizeY)})
					window.SizeY = size or window.SizeY
					table.insert(visibleWindows,1,window)
					updateWindows()
				end
			end
			window.ClosedSide = nil
			window.OnActivate:Fire()
		end
		static.ToggleSide = function(name)
			local side = (name == "left" and leftSide or rightSide)
			side.Hidden = not side.Hidden
			for i,v in pairs(side.Windows) do
				if side.Hidden then
					v.OnDeactivate:Fire()
				else
					v.OnActivate:Fire()
				end
			end
			updateWindows()
		end
		static.SetSideVisible = function(s,vis)
			local side = (type(s) == "table" and s) or (s == "left" and leftSide or rightSide)
			side.Hidden = not vis
			for i,v in pairs(side.Windows) do
				if side.Hidden then
					v.OnDeactivate:Fire()
				else
					v.OnActivate:Fire()
				end
			end
			updateWindows()
		end
		static.Init = function()
			displayOrderStart = Main.DisplayOrders.Window
			sideDisplayOrder = Main.DisplayOrders.SideWindow
			sidesGui = Instance.new("ScreenGui")
			local leftFrame = create({
				{1,"Frame",{Active=true,Name="LeftSide",BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,}},
				{2,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="Resizer",Parent={1},Size=UDim2.new(0,5,1,0),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={2},Position=UDim2.new(0,0,0,0),Size=UDim2.new(0,1,1,0),}},
				{4,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="WindowResizer",Parent={1},Position=UDim2.new(1,-300,0,0),Size=UDim2.new(1,0,0,4),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{5,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={4},Size=UDim2.new(1,0,0,1),}},
			})
			leftSide.Frame = leftFrame
			leftFrame.Position = UDim2.new(0,-leftSide.Width-10,0,0)
			leftSide.WindowResizer = leftFrame.WindowResizer
			leftFrame.WindowResizer.Parent = nil
			leftFrame.Parent = sidesGui
			local rightFrame = create({
				{1,"Frame",{Active=true,Name="RightSide",BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,}},
				{2,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="Resizer",Parent={1},Size=UDim2.new(0,5,1,0),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={2},Position=UDim2.new(0,4,0,0),Size=UDim2.new(0,1,1,0),}},
				{4,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="WindowResizer",Parent={1},Position=UDim2.new(1,-300,0,0),Size=UDim2.new(1,0,0,4),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
				{5,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={4},Size=UDim2.new(1,0,0,1),}},
			})
			rightSide.Frame = rightFrame
			rightFrame.Position = UDim2.new(1,10,0,0)
			rightSide.WindowResizer = rightFrame.WindowResizer
			rightFrame.WindowResizer.Parent = nil
			rightFrame.Parent = sidesGui
			sideResizerHook(leftFrame.Resizer,"H",leftSide)
			sideResizerHook(rightFrame.Resizer,"H",rightSide)
			alignIndicator = Instance.new("ScreenGui")
			alignIndicator.DisplayOrder = Main.DisplayOrders.Core
			local indicator = Instance.new("Frame",alignIndicator)
			indicator.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			indicator.BorderSizePixel = 0
			indicator.BackgroundTransparency = 0.8
			indicator.Name = "Indicator"
			local corner = Instance.new("UICorner",indicator)
			corner.CornerRadius = UDim.new(0,10)
			local leftToggle = create({{1,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderMode=2,Font=10,Name="LeftToggle",Position=UDim2.new(0,0,0,-36),Size=UDim2.new(0,16,0,36),Text="<",TextColor3=Color3.new(1,1,1),TextSize=14,}}})
			local rightToggle = leftToggle:Clone()
			rightToggle.Name = "RightToggle"
			rightToggle.Position = UDim2.new(1,-16,0,-36)
			Lib.ButtonAnim(leftToggle,{Mode = 2,PressColor = Color3.fromRGB(32,32,32)})
			Lib.ButtonAnim(rightToggle,{Mode = 2,PressColor = Color3.fromRGB(32,32,32)})
			leftToggle.MouseButton1Click:Connect(function()
				static.ToggleSide("left")
			end)
			rightToggle.MouseButton1Click:Connect(function()
				static.ToggleSide("right")
			end)
			leftToggle.Parent = sidesGui
			rightToggle.Parent = sidesGui
			sidesGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				local maxWidth = math.max(300,sidesGui.AbsoluteSize.X-static.FreeWidth)
				leftSide.Width = math.max(static.MinWidth,math.min(leftSide.Width,maxWidth-rightSide.Width))
				rightSide.Width = math.max(static.MinWidth,math.min(rightSide.Width,maxWidth-leftSide.Width))
				for i = 1,#visibleWindows do
					visibleWindows[i]:MoveInBoundary()
				end
				updateWindows(true)
			end)
			sidesGui.DisplayOrder = sideDisplayOrder - 1
			Lib.ShowGui(sidesGui)
			updateSideFrames()
		end
		local mt = {__index = funcs}
		static.new = function()
			local obj = setmetatable({
				Minimized = false,
				Dragging = false,
				Resizing = false,
				Aligned = false,
				Draggable = true,
				Resizable = true,
				ResizableInternal = true,
				Alignable = true,
				Closed = true,
				SizeX = 300,
				SizeY = 300,
				MinX = 200,
				MinY = 200,
				PosX = 0,
				PosY = 0,
				GuiElems = {},
				Tweens = {},
				Elements = {},
				OnActivate = Lib.Signal.new(),
				OnDeactivate = Lib.Signal.new(),
				OnMinimize = Lib.Signal.new(),
				OnRestore = Lib.Signal.new()
			},mt)
			obj.Gui = createGui(obj)
			return obj
		end
		return static
	end)()
	Lib.ContextMenu = (function()
		local funcs = {}
		local mouse
		local function createGui(self)
			local contextGui = create({
				{1,"ScreenGui",{DisplayOrder=1000000,Name="Context",ZIndexBehavior=1,}},
				{2,"Frame",{Active=true,BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),Name="Main",Parent={1},Position=UDim2.new(0.5,-100,0.5,-150),Size=UDim2.new(0,200,0,100),}},
				{3,"UICorner",{CornerRadius=UDim.new(0,4),Parent={2},}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),Name="Container",Parent={2},Position=UDim2.new(0,1,0,1),Size=UDim2.new(1,-2,1,-2),}},
				{5,"UICorner",{CornerRadius=UDim.new(0,4),Parent={4},}},
				{6,"ScrollingFrame",{Active=true,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),Name="List",Parent={4},Position=UDim2.new(0,2,0,2),ScrollBarImageColor3=Color3.new(0,0,0),ScrollBarThickness=4,Size=UDim2.new(1,-4,1,-4),VerticalScrollBarInset=1,}},
				{7,"UIListLayout",{Parent={6},SortOrder=2,}},
				{8,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="SearchFrame",Parent={4},Size=UDim2.new(1,0,0,24),Visible=false,}},
				{9,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.1176470592618,0.1176470592618,0.1176470592618),BorderSizePixel=0,Name="SearchContainer",Parent={8},Position=UDim2.new(0,3,0,3),Size=UDim2.new(1,-6,0,18),}},
				{10,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="SearchBox",Parent={9},PlaceholderColor3=Color3.new(0.39215689897537,0.39215689897537,0.39215689897537),PlaceholderText="Search",Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-8,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
				{11,"UICorner",{CornerRadius=UDim.new(0,2),Parent={9},}},
				{12,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={8},Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),}},
				{13,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Font=3,Name="Entry",Parent={1},Size=UDim2.new(1,0,0,22),Text="",TextSize=14,Visible=false,}},
				{14,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="EntryName",Parent={13},Position=UDim2.new(0,24,0,0),Size=UDim2.new(1,-24,1,0),Text="Duplicate",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{15,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Shortcut",Parent={13},Position=UDim2.new(0,24,0,0),Size=UDim2.new(1,-30,1,0),Text="Ctrl+D",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{16,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ImageRectOffset=Vector2.new(304,0),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={13},Position=UDim2.new(0,2,0,3),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
				{17,"UICorner",{CornerRadius=UDim.new(0,4),Parent={13},}},
				{18,"Frame",{BackgroundColor3=Color3.new(0.21568629145622,0.21568629145622,0.21568629145622),BackgroundTransparency=1,BorderSizePixel=0,Name="Divider",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,7),Visible=false,}},
				{19,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="Line",Parent={18},Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,1),}},
				{20,"TextLabel",{AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="DividerName",Parent={18},Position=UDim2.new(0,2,0.5,0),Size=UDim2.new(1,-4,1,0),Text="Objects",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.60000002384186,TextXAlignment=0,Visible=false,}},
			})
			self.GuiElems.Main = contextGui.Main
			self.GuiElems.List = contextGui.Main.Container.List
			self.GuiElems.Entry = contextGui.Entry
			self.GuiElems.Divider = contextGui.Divider
			self.GuiElems.SearchFrame = contextGui.Main.Container.SearchFrame
			self.GuiElems.SearchBar = self.GuiElems.SearchFrame.SearchContainer.SearchBox
			Lib.ViewportTextBox.convert(self.GuiElems.SearchBar)
			self.GuiElems.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
				local lower,find = string.lower,string.find
				local searchText = lower(self.GuiElems.SearchBar.Text)
				local items = self.Items
				local map = self.ItemToEntryMap
				if searchText ~= "" then
					local results = {}
					local count = 1
					for i = 1,#items do
						local item = items[i]
						local entry = map[item]
						if entry then
							if not item.Divider and find(lower(item.Name),searchText,1,true) then
								results[count] = item
								count = count + 1
							else
								entry.Visible = false
							end
						end
					end
					table.sort(results,function(a,b) return a.Name < b.Name end)
					for i = 1,#results do
						local entry = map[results[i]]
						entry.LayoutOrder = i
						entry.Visible = true
					end
				else
					for i = 1,#items do
						local entry = map[items[i]]
						if entry then entry.LayoutOrder = i entry.Visible = true end
					end
				end
				local toSize = self.GuiElems.List.UIListLayout.AbsoluteContentSize.Y + 6
				self.GuiElems.List.CanvasSize = UDim2.new(0,0,0,toSize-6)
			end)
			return contextGui
		end
		funcs.Add = function(self,item)
			local newItem = {
				Name = item.Name or "Item",
				Icon = item.Icon or "",
				Shortcut = item.Shortcut or "",
				OnClick = item.OnClick,
				OnHover = item.OnHover,
				Disabled = item.Disabled or false,
				DisabledIcon = item.DisabledIcon or "",
				IconMap = item.IconMap,
				OnRightClick = item.OnRightClick
			}
			if self.QueuedDivider then
				local text = self.QueuedDividerText and #self.QueuedDividerText > 0 and self.QueuedDividerText
				self:AddDivider(text)
			end
			self.Items[#self.Items+1] = newItem
			self.Updated = nil
		end
		funcs.AddRegistered = function(self,name,disabled)
			if not self.Registered[name] then error(name.." is not registered") end
			if self.QueuedDivider then
				local text = self.QueuedDividerText and #self.QueuedDividerText > 0 and self.QueuedDividerText
				self:AddDivider(text)
			end
			self.Registered[name].Disabled = disabled
			self.Items[#self.Items+1] = self.Registered[name]
			self.Updated = nil
		end
		funcs.Register = function(self,name,item)
			self.Registered[name] = {
				Name = item.Name or "Item",
				Icon = item.Icon or "",
				Shortcut = item.Shortcut or "",
				OnClick = item.OnClick,
				OnHover = item.OnHover,
				DisabledIcon = item.DisabledIcon or "",
				IconMap = item.IconMap,
				OnRightClick = item.OnRightClick
			}
		end
		funcs.UnRegister = function(self,name)
			self.Registered[name] = nil
		end
		funcs.AddDivider = function(self,text)
			self.QueuedDivider = false
			local textWidth = text and service.TextService:GetTextSize(text,14,Enum.Font.SourceSans,Vector2.new(999999999,20)).X or nil
			table.insert(self.Items,{Divider = true, Text = text, TextSize = textWidth and textWidth+4})
			self.Updated = nil
		end
		funcs.QueueDivider = function(self,text)
			self.QueuedDivider = true
			self.QueuedDividerText = text or ""
		end
		funcs.Clear = function(self)
			self.Items = {}
			self.Updated = nil
		end
		funcs.Refresh = function(self)
			for i,v in pairs(self.GuiElems.List:GetChildren()) do
				if not v:IsA("UIListLayout") then
					v:Destroy()
				end
			end
			local map = {}
			self.ItemToEntryMap = map
			local dividerFrame = self.GuiElems.Divider
			local contextList = self.GuiElems.List
			local entryFrame = self.GuiElems.Entry
			local items = self.Items
			for i = 1,#items do
				local item = items[i]
				if item.Divider then
					local newDivider = dividerFrame:Clone()
					newDivider.Line.BackgroundColor3 = self.Theme.DividerColor
					if item.Text then
						newDivider.Size = UDim2.new(1,0,0,20)
						newDivider.Line.Position = UDim2.new(0,item.TextSize,0.5,0)
						newDivider.Line.Size = UDim2.new(1,-item.TextSize,0,1)
						newDivider.DividerName.TextColor3 = self.Theme.TextColor
						newDivider.DividerName.Text = item.Text
						newDivider.DividerName.Visible = true
					end
					newDivider.Visible = true
					map[item] = newDivider
					newDivider.Parent = contextList
				else
					local newEntry = entryFrame:Clone()
					newEntry.BackgroundColor3 = self.Theme.HighlightColor
					newEntry.EntryName.TextColor3 = self.Theme.TextColor
					newEntry.EntryName.Text = item.Name
					newEntry.Shortcut.Text = item.Shortcut
					if item.Disabled then
						newEntry.EntryName.TextColor3 = Color3.new(150/255,150/255,150/255)
						newEntry.Shortcut.TextColor3 = Color3.new(150/255,150/255,150/255)
					end
					if self.Iconless then
						newEntry.EntryName.Position = UDim2.new(0,2,0,0)
						newEntry.EntryName.Size = UDim2.new(1,-4,0,20)
						newEntry.Icon.Visible = false
					else
						local iconIndex = item.Disabled and item.DisabledIcon or item.Icon
						if item.IconMap then
							if type(iconIndex) == "number" then
								item.IconMap:Display(newEntry.Icon,iconIndex)
							elseif type(iconIndex) == "string" then
								item.IconMap:DisplayByKey(newEntry.Icon,iconIndex)
							end
						elseif type(iconIndex) == "string" then
							newEntry.Icon.Image = iconIndex
						end
					end
					if not item.Disabled then
						if item.OnClick then
							newEntry.MouseButton1Click:Connect(function()
								item.OnClick(item.Name)
								if not item.NoHide then
									self:Hide()
								end
							end)
						end
						if item.OnRightClick then
							newEntry.MouseButton2Click:Connect(function()
								item.OnRightClick(item.Name)
								if not item.NoHide then
									self:Hide()
								end
							end)
						end
					end
					newEntry.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							newEntry.BackgroundTransparency = 0
						end
					end)
					newEntry.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							newEntry.BackgroundTransparency = 1
						end
					end)
					newEntry.Visible = true
					map[item] = newEntry
					newEntry.Parent = contextList
				end
			end
			self.Updated = true
		end
		funcs.Show = function(self,x,y)
			local elems = self.GuiElems
			elems.SearchFrame.Visible = self.SearchEnabled
			elems.List.Position = UDim2.new(0,2,0,2 + (self.SearchEnabled and 24 or 0))
			elems.List.Size = UDim2.new(1,-4,1,-4 - (self.SearchEnabled and 24 or 0))
			if self.SearchEnabled and self.ClearSearchOnShow then elems.SearchBar.Text = "" end
			self.GuiElems.List.CanvasPosition = Vector2.new(0,0)
			if not self.Updated then
				self:Refresh()
			end
			local reverseY = false
			local x,y = x or mouse.X, y or mouse.Y
			local maxX,maxY = mouse.ViewSizeX,mouse.ViewSizeY
			if x + self.Width > maxX then
				x = self.ReverseX and x - self.Width or maxX - self.Width
			end
			elems.Main.Position = UDim2.new(0,x,0,y)
			elems.Main.Size = UDim2.new(0,self.Width,0,0)
			self.Gui.DisplayOrder = Main.DisplayOrders.Menu
			Lib.ShowGui(self.Gui)
			local toSize = elems.List.UIListLayout.AbsoluteContentSize.Y + 6
			if self.MaxHeight and toSize > self.MaxHeight then
				elems.List.CanvasSize = UDim2.new(0,0,0,toSize-6)
				toSize = self.MaxHeight
			else
				elems.List.CanvasSize = UDim2.new(0,0,0,0)
			end
			if y + toSize > maxY then reverseY = true end
			local closable
			if self.CloseEvent then self.CloseEvent:Disconnect() end
			self.CloseEvent = service.UserInputService.InputBegan:Connect(function(input)
				if not closable or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
				if not Lib.CheckMouseInGui(elems.Main) then
					self.CloseEvent:Disconnect()
					self:Hide()
				end
			end)
			if reverseY then
				elems.Main.Position = UDim2.new(0,x,0,y-(self.ReverseYOffset or 0))
				local newY = y - toSize - (self.ReverseYOffset or 0)
				y = newY >= 0 and newY or 0
				elems.Main:TweenSizeAndPosition(UDim2.new(0,self.Width,0,toSize),UDim2.new(0,x,0,y),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.2,true)
			else
				elems.Main:TweenSize(UDim2.new(0,self.Width,0,toSize),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.2,true)
			end
			Lib.FastWait()
			if self.SearchEnabled and self.FocusSearchOnShow then elems.SearchBar:CaptureFocus() end
			closable = true
		end
		funcs.Hide = function(self)
			self.Gui.Parent = nil
		end
		funcs.ApplyTheme = function(self,data)
			local theme = self.Theme
			theme.ContentColor = data.ContentColor or Settings.Theme.Menu
			theme.OutlineColor = data.OutlineColor or Settings.Theme.Menu
			theme.DividerColor = data.DividerColor or Settings.Theme.Outline2
			theme.TextColor = data.TextColor or Settings.Theme.Text
			theme.HighlightColor = data.HighlightColor or Settings.Theme.Main1
			self.GuiElems.Main.BackgroundColor3 = theme.OutlineColor
			self.GuiElems.Main.Container.BackgroundColor3 = theme.ContentColor
		end
		local mt = {__index = funcs}
		local function new()
			if not mouse then mouse = Main.Mouse or service.Players.LocalPlayer:GetMouse() end
			local obj = setmetatable({
				Width = 200,
				MaxHeight = nil,
				Iconless = false,
				SearchEnabled = false,
				ClearSearchOnShow = true,
				FocusSearchOnShow = true,
				Updated = false,
				QueuedDivider = false,
				QueuedDividerText = "",
				Items = {},
				Registered = {},
				GuiElems = {},
				Theme = {}
			},mt)
			obj.Gui = createGui(obj)
			obj:ApplyTheme({})
			return obj
		end
		return {new = new}
	end)()
	Lib.CodeFrame = (function()
		local funcs = {}
		local typeMap = {
			[1] = "String",
			[2] = "String",
			[3] = "String",
			[4] = "Comment",
			[5] = "Operator",
			[6] = "Number",
			[7] = "Keyword",
			[8] = "BuiltIn",
			[9] = "LocalMethod",
			[10] = "LocalProperty",
			[11] = "Nil",
			[12] = "Bool",
			[13] = "Function",
			[14] = "Local",
			[15] = "Self",
			[16] = "FunctionName",
			[17] = "Bracket"
		}
		local specialKeywordsTypes = {
			["nil"] = 11,
			["true"] = 12,
			["false"] = 12,
			["function"] = 13,
			["local"] = 14,
			["self"] = 15
		}
		local keywords = {
			["and"] = true,
			["break"] = true,
			["do"] = true,
			["else"] = true,
			["elseif"] = true,
			["end"] = true,
			["false"] = true,
			["for"] = true,
			["function"] = true,
			["if"] = true,
			["in"] = true,
			["local"] = true,
			["nil"] = true,
			["not"] = true,
			["or"] = true,
			["repeat"] = true,
			["return"] = true,
			["then"] = true,
			["true"] = true,
			["until"] = true,
			["while"] = true,
			["plugin"] = true
		}
		local builtIns = {
			["delay"] = true,
			["elapsedTime"] = true,
			["require"] = true,
			["spawn"] = true,
			["tick"] = true,
			["time"] = true,
			["typeof"] = true,
			["UserSettings"] = true,
			["wait"] = true,
			["warn"] = true,
			["game"] = true,
			["shared"] = true,
			["script"] = true,
			["workspace"] = true,
			["assert"] = true,
			["collectgarbage"] = true,
			["error"] = true,
			["getfenv"] = true,
			["getmetatable"] = true,
			["ipairs"] = true,
			["loadstring"] = true,
			["newproxy"] = true,
			["next"] = true,
			["pairs"] = true,
			["pcall"] = true,
			["print"] = true,
			["rawequal"] = true,
			["rawget"] = true,
			["rawset"] = true,
			["select"] = true,
			["setfenv"] = true,
			["setmetatable"] = true,
			["tonumber"] = true,
			["tostring"] = true,
			["type"] = true,
			["unpack"] = true,
			["xpcall"] = true,
			["_G"] = true,
			["_VERSION"] = true,
			["coroutine"] = true,
			["debug"] = true,
			["math"] = true,
			["os"] = true,
			["string"] = true,
			["table"] = true,
			["bit32"] = true,
			["utf8"] = true,
			["Axes"] = true,
			["BrickColor"] = true,
			["CFrame"] = true,
			["Color3"] = true,
			["ColorSequence"] = true,
			["ColorSequenceKeypoint"] = true,
			["DockWidgetPluginGuiInfo"] = true,
			["Enum"] = true,
			["Faces"] = true,
			["Instance"] = true,
			["NumberRange"] = true,
			["NumberSequence"] = true,
			["NumberSequenceKeypoint"] = true,
			["PathWaypoint"] = true,
			["PhysicalProperties"] = true,
			["Random"] = true,
			["Ray"] = true,
			["Rect"] = true,
			["Region3"] = true,
			["Region3int16"] = true,
			["TweenInfo"] = true,
			["UDim"] = true,
			["UDim2"] = true,
			["Vector2"] = true,
			["Vector2int16"] = true,
			["Vector3"] = true,
			["Vector3int16"] = true
		}
		local builtInInited = false
		local richReplace = {
			["'"] = "&apos;",
			["\""] = "&quot;",
			["<"] = "&lt;",
			[">"] = "&gt;",
			["&"] = "&amp;"
		}
		local tabSub = "\205"
		local tabReplacement = (" %s%s "):format(tabSub,tabSub)
		local tabJumps = {
			[("[^%s] %s"):format(tabSub,tabSub)] = 0,
			[(" %s%s"):format(tabSub,tabSub)] = -1,
			[("%s%s "):format(tabSub,tabSub)] = 2,
			[("%s [^%s]"):format(tabSub,tabSub)] = 1,
		}
		local tweenService = service.TweenService
		local lineTweens = {}
		local function initBuiltIn()
			local env = getfenv()
			local type = type
			local tostring = tostring
			for name,_ in next,builtIns do
				local envVal = env[name]
				if type(envVal) == "table" then
					local items = {}
					for i,v in next,envVal do
						items[i] = true
					end
					builtIns[name] = items
				end
			end
			local enumEntries = {}
			local enums = Enum:GetEnums()
			for i = 1,#enums do
				enumEntries[tostring(enums[i])] = true
			end
			builtIns["Enum"] = enumEntries
			builtInInited = true
		end
		local function setupEditBox(obj)
			local editBox = obj.GuiElems.EditBox
			editBox.Focused:Connect(function()
				obj:ConnectEditBoxEvent()
				obj.Editing = true
			end)
			editBox.FocusLost:Connect(function()
				obj:DisconnectEditBoxEvent()
				obj.Editing = false
			end)
			editBox:GetPropertyChangedSignal("Text"):Connect(function()
				local text = editBox.Text
				if #text == 0 or obj.EditBoxCopying then return end
				editBox.Text = ""
				obj:AppendText(text)
			end)
		end
		local function setupMouseSelection(obj)
			local mouse = plr:GetMouse()
			local codeFrame = obj.GuiElems.LinesFrame
			local lines = obj.Lines
			codeFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local fontSizeX,fontSizeY = math.ceil(obj.FontSize/2),obj.FontSize
					local relX = mouse.X - codeFrame.AbsolutePosition.X
					local relY = mouse.Y - codeFrame.AbsolutePosition.Y
					local selX = math.round(relX / fontSizeX) + obj.ViewX
					local selY = math.floor(relY / fontSizeY) + obj.ViewY
					local releaseEvent,mouseEvent,scrollEvent
					local scrollPowerV,scrollPowerH = 0,0
					selY = math.min(#lines-1,selY)
					local relativeLine = lines[selY+1] or ""
					selX = math.min(#relativeLine, selX + obj:TabAdjust(selX,selY))
					obj.SelectionRange = {{-1,-1},{-1,-1}}
					obj:MoveCursor(selX,selY)
					obj.FloatCursorX = selX
					local function updateSelection()
						local relX = mouse.X - codeFrame.AbsolutePosition.X
						local relY = mouse.Y - codeFrame.AbsolutePosition.Y
						local sel2X = math.max(0,math.round(relX / fontSizeX) + obj.ViewX)
						local sel2Y = math.max(0,math.floor(relY / fontSizeY) + obj.ViewY)
						sel2Y = math.min(#lines-1,sel2Y)
						local relativeLine = lines[sel2Y+1] or ""
						sel2X = math.min(#relativeLine, sel2X + obj:TabAdjust(sel2X,sel2Y))
						if sel2Y < selY or (sel2Y == selY and sel2X < selX) then
							obj.SelectionRange = {{sel2X,sel2Y},{selX,selY}}
						else
							obj.SelectionRange = {{selX,selY},{sel2X,sel2Y}}
						end
						obj:MoveCursor(sel2X,sel2Y)
						obj.FloatCursorX = sel2X
						obj:Refresh()
					end
					releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
							scrollEvent:Disconnect()
							obj:SetCopyableSelection()
						end
					end)
					mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							local upDelta = mouse.Y - codeFrame.AbsolutePosition.Y
							local downDelta = mouse.Y - codeFrame.AbsolutePosition.Y - codeFrame.AbsoluteSize.Y
							local leftDelta = mouse.X - codeFrame.AbsolutePosition.X
							local rightDelta = mouse.X - codeFrame.AbsolutePosition.X - codeFrame.AbsoluteSize.X
							scrollPowerV = 0
							scrollPowerH = 0
							if downDelta > 0 then
								scrollPowerV = math.floor(downDelta*0.05) + 1
							elseif upDelta < 0 then
								scrollPowerV = math.ceil(upDelta*0.05) - 1
							end
							if rightDelta > 0 then
								scrollPowerH = math.floor(rightDelta*0.05) + 1
							elseif leftDelta < 0 then
								scrollPowerH = math.ceil(leftDelta*0.05) - 1
							end
							updateSelection()
						end
					end)
					scrollEvent = game:GetService("RunService").RenderStepped:Connect(function()
						if scrollPowerV ~= 0 or scrollPowerH ~= 0 then
							obj:ScrollDelta(scrollPowerH,scrollPowerV)
							updateSelection()
						end
					end)
					obj:Refresh()
				end
			end)
		end
		local function makeFrame(obj)
			local frame = create({
				{1,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel = 0,Position=UDim2.new(0.5,-300,0.5,-200),Size=UDim2.new(0,600,0,400),}},
			})
			local elems = {}
			local linesFrame = Instance.new("Frame")
			linesFrame.Name = "Lines"
			linesFrame.BackgroundTransparency = 1
			linesFrame.Size = UDim2.new(1,0,1,0)
			linesFrame.ClipsDescendants = true
			linesFrame.Parent = frame
			local lineNumbersLabel = Instance.new("TextLabel")
			lineNumbersLabel.Name = "LineNumbers"
			lineNumbersLabel.BackgroundTransparency = 1
			lineNumbersLabel.Font = Enum.Font.Code
			lineNumbersLabel.TextXAlignment = Enum.TextXAlignment.Right
			lineNumbersLabel.TextYAlignment = Enum.TextYAlignment.Top
			lineNumbersLabel.ClipsDescendants = true
			lineNumbersLabel.RichText = true
			lineNumbersLabel.Parent = frame
			local cursor = Instance.new("Frame")
			cursor.Name = "Cursor"
			cursor.BackgroundColor3 = Color3.fromRGB(220,220,220)
			cursor.BorderSizePixel = 0
			cursor.Parent = frame
			local editBox = Instance.new("TextBox")
			editBox.Name = "EditBox"
			editBox.MultiLine = true
			editBox.Visible = false
			editBox.Parent = frame
			lineTweens.Invis = tweenService:Create(cursor,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency = 1})
			lineTweens.Vis = tweenService:Create(cursor,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency = 0})
			elems.LinesFrame = linesFrame
			elems.LineNumbersLabel = lineNumbersLabel
			elems.Cursor = cursor
			elems.EditBox = editBox
			elems.ScrollCorner = create({{1,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="ScrollCorner",Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,16,0,16),Visible=false,}}})
			elems.ScrollCorner.Parent = frame
			linesFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					obj:SetEditing(true,input)
				end
			end)
			obj.Frame = frame
			obj.Gui = frame
			obj.GuiElems = elems
			setupEditBox(obj)
			setupMouseSelection(obj)
			return frame
		end
		funcs.GetSelectionText = function(self)
			if not self:IsValidRange() then return "" end
			local selectionRange = self.SelectionRange
			local selX,selY = selectionRange[1][1], selectionRange[1][2]
			local sel2X,sel2Y = selectionRange[2][1], selectionRange[2][2]
			local deltaLines = sel2Y-selY
			local lines = self.Lines
			if not lines[selY+1] or not lines[sel2Y+1] then return "" end
			if deltaLines == 0 then
				return self:ConvertText(lines[selY+1]:sub(selX+1,sel2X), false)
			end
			local leftSub = lines[selY+1]:sub(selX+1)
			local rightSub = lines[sel2Y+1]:sub(1,sel2X)
			local result = leftSub.."\n"
			for i = selY+1,sel2Y-1 do
				result = result..lines[i+1].."\n"
			end
			result = result..rightSub
			return self:ConvertText(result,false)
		end
		funcs.SetCopyableSelection = function(self)
			local text = self:GetSelectionText()
			local editBox = self.GuiElems.EditBox
			self.EditBoxCopying = true
			editBox.Text = text
			editBox.SelectionStart = 1
			editBox.CursorPosition = #editBox.Text + 1
			self.EditBoxCopying = false
		end
		funcs.ConnectEditBoxEvent = function(self)
			if self.EditBoxEvent then
				self.EditBoxEvent:Disconnect()
			end
			self.EditBoxEvent = service.UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				local keycodes = Enum.KeyCode
				local keycode = input.KeyCode
				local function setupMove(key,func)
					local endCon,finished
					endCon = service.UserInputService.InputEnded:Connect(function(input)
						if input.KeyCode ~= key then return end
						endCon:Disconnect()
						finished = true
					end)
					func()
					Lib.FastWait(0.5)
					while not finished do func() Lib.FastWait(0.03) end
				end
				if keycode == keycodes.Down then
					setupMove(keycodes.Down,function()
						self.CursorX = self.FloatCursorX
						self.CursorY = self.CursorY + 1
						self:UpdateCursor()
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Up then
					setupMove(keycodes.Up,function()
						self.CursorX = self.FloatCursorX
						self.CursorY = self.CursorY - 1
						self:UpdateCursor()
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Left then
					setupMove(keycodes.Left,function()
						local line = self.Lines[self.CursorY+1] or ""
						self.CursorX = self.CursorX - 1 - (line:sub(self.CursorX-3,self.CursorX) == tabReplacement and 3 or 0)
						if self.CursorX < 0 then
							self.CursorY = self.CursorY - 1
							local line2 = self.Lines[self.CursorY+1] or ""
							self.CursorX = #line2
						end
						self.FloatCursorX = self.CursorX
						self:UpdateCursor()
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Right then
					setupMove(keycodes.Right,function()
						local line = self.Lines[self.CursorY+1] or ""
						self.CursorX = self.CursorX + 1 + (line:sub(self.CursorX+1,self.CursorX+4) == tabReplacement and 3 or 0)
						if self.CursorX > #line then
							self.CursorY = self.CursorY + 1
							self.CursorX = 0
						end
						self.FloatCursorX = self.CursorX
						self:UpdateCursor()
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Backspace then
					setupMove(keycodes.Backspace,function()
						local startRange,endRange
						if self:IsValidRange() then
							startRange = self.SelectionRange[1]
							endRange = self.SelectionRange[2]
						else
							endRange = {self.CursorX,self.CursorY}
						end
						if not startRange then
							local line = self.Lines[self.CursorY+1] or ""
							self.CursorX = self.CursorX - 1 - (line:sub(self.CursorX-3,self.CursorX) == tabReplacement and 3 or 0)
							if self.CursorX < 0 then
								self.CursorY = self.CursorY - 1
								local line2 = self.Lines[self.CursorY+1] or ""
								self.CursorX = #line2
							end
							self.FloatCursorX = self.CursorX
							self:UpdateCursor()
							startRange = startRange or {self.CursorX,self.CursorY}
						end
						self:DeleteRange({startRange,endRange},false,true)
						self:ResetSelection(true)
						self:JumpToCursor()
					end)
				elseif keycode == keycodes.Delete then
					setupMove(keycodes.Delete,function()
						local startRange,endRange
						if self:IsValidRange() then
							startRange = self.SelectionRange[1]
							endRange = self.SelectionRange[2]
						else
							startRange = {self.CursorX,self.CursorY}
						end
						if not endRange then
							local line = self.Lines[self.CursorY+1] or ""
							local endCursorX = self.CursorX + 1 + (line:sub(self.CursorX+1,self.CursorX+4) == tabReplacement and 3 or 0)
							local endCursorY = self.CursorY
							if endCursorX > #line then
								endCursorY = endCursorY + 1
								endCursorX = 0
							end
							self:UpdateCursor()
							endRange = endRange or {endCursorX,endCursorY}
						end
						self:DeleteRange({startRange,endRange},false,true)
						self:ResetSelection(true)
						self:JumpToCursor()
					end)
				elseif service.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
					if keycode == keycodes.A then
						self.SelectionRange = {{0,0},{#self.Lines[#self.Lines],#self.Lines-1}}
						self:SetCopyableSelection()
						self:Refresh()
					end
				end
			end)
		end
		funcs.DisconnectEditBoxEvent = function(self)
			if self.EditBoxEvent then
				self.EditBoxEvent:Disconnect()
			end
		end
		funcs.ResetSelection = function(self,norefresh)
			self.SelectionRange = {{-1,-1},{-1,-1}}
			if not norefresh then self:Refresh() end
		end
		funcs.IsValidRange = function(self,range)
			local selectionRange = range or self.SelectionRange
			local selX,selY = selectionRange[1][1], selectionRange[1][2]
			local sel2X,sel2Y = selectionRange[2][1], selectionRange[2][2]
			if selX == -1 or (selX == sel2X and selY == sel2Y) then return false end
			return true
		end
		funcs.DeleteRange = function(self,range,noprocess,updatemouse)
			range = range or self.SelectionRange
			if not self:IsValidRange(range) then return end
			local lines = self.Lines
			local selX,selY = range[1][1], range[1][2]
			local sel2X,sel2Y = range[2][1], range[2][2]
			local deltaLines = sel2Y-selY
			if not lines[selY+1] or not lines[sel2Y+1] then return end
			local leftSub = lines[selY+1]:sub(1,selX)
			local rightSub = lines[sel2Y+1]:sub(sel2X+1)
			lines[selY+1] = leftSub..rightSub
			local remove = table.remove
			for i = 1,deltaLines do
				remove(lines,selY+2)
			end
			if range == self.SelectionRange then self.SelectionRange = {{-1,-1},{-1,-1}} end
			if updatemouse then
				self.CursorX = selX
				self.CursorY = selY
				self:UpdateCursor()
			end
			if not noprocess then
				self:ProcessTextChange()
			end
		end
		funcs.AppendText = function(self,text)
			self:DeleteRange(nil,true,true)
			local lines,cursorX,cursorY = self.Lines,self.CursorX,self.CursorY
			local line = lines[cursorY+1]
			local before = line:sub(1,cursorX)
			local after = line:sub(cursorX+1)
			text = text:gsub("\r\n","\n")
			text = self:ConvertText(text,true)
			local textLines = text:split("\n")
			local insert = table.insert
			for i = 1,#textLines do
				local linePos = cursorY+i
				if i > 1 then insert(lines,linePos,"") end
				local textLine = textLines[i]
				local newBefore = (i == 1 and before or "")
				local newAfter = (i == #textLines and after or "")
				lines[linePos] = newBefore..textLine..newAfter
			end
			if #textLines > 1 then cursorX = 0 end
			self:ProcessTextChange()
			self.CursorX = cursorX + #textLines[#textLines]
			self.CursorY = cursorY + #textLines-1
			self:UpdateCursor()
		end
		funcs.ScrollDelta = function(self,x,y)
			self.ScrollV:ScrollTo(self.ScrollV.Index + y)
			self.ScrollH:ScrollTo(self.ScrollH.Index + x)
		end
		funcs.TabAdjust = function(self,x,y)
			local lines = self.Lines
			local line = lines[y+1]
			x=x+1
			if line then
				local left = line:sub(x-1,x-1)
				local middle = line:sub(x,x)
				local right = line:sub(x+1,x+1)
				local selRange = (#left > 0 and left or " ") .. (#middle > 0 and middle or " ") .. (#right > 0 and right or " ")
				for i,v in pairs(tabJumps) do
					if selRange:find(i) then
						return v
					end
				end
			end
			return 0
		end
		funcs.SetEditing = function(self,on,input)
			self:UpdateCursor(input)
			if on then
				if self.Editable then
					self.GuiElems.EditBox.Text = ""
					self.GuiElems.EditBox:CaptureFocus()
				end
			else
				self.GuiElems.EditBox:ReleaseFocus()
			end
		end
		funcs.CursorAnim = function(self,on)
			local cursor = self.GuiElems.Cursor
			local animTime = tick()
			self.LastAnimTime = animTime
			if not on then return end
			lineTweens.Invis:Cancel()
			lineTweens.Vis:Cancel()
			cursor.BackgroundTransparency = 0
			coroutine.wrap(function()
				while self.Editable do
					Lib.FastWait(0.5)
					if self.LastAnimTime ~= animTime then return end
					lineTweens.Invis:Play()
					Lib.FastWait(0.4)
					if self.LastAnimTime ~= animTime then return end
					lineTweens.Vis:Play()
					Lib.FastWait(0.2)
				end
			end)()
		end
		funcs.MoveCursor = function(self,x,y)
			self.CursorX = x
			self.CursorY = y
			self:UpdateCursor()
			self:JumpToCursor()
		end
		funcs.JumpToCursor = function(self)
			self:Refresh()
		end
		funcs.UpdateCursor = function(self,input)
			local linesFrame = self.GuiElems.LinesFrame
			local cursor = self.GuiElems.Cursor
			local hSize = math.max(0,linesFrame.AbsoluteSize.X)
			local vSize = math.max(0,linesFrame.AbsoluteSize.Y)
			local maxLines = math.ceil(vSize / self.FontSize)
			local maxCols = math.ceil(hSize / math.ceil(self.FontSize/2))
			local viewX,viewY = self.ViewX,self.ViewY
			local totalLinesStr = tostring(#self.Lines)
			local fontWidth = math.ceil(self.FontSize / 2)
			local linesOffset = #totalLinesStr*fontWidth + 4*fontWidth
			if input then
				local linesFrame = self.GuiElems.LinesFrame
				local frameX,frameY = linesFrame.AbsolutePosition.X,linesFrame.AbsolutePosition.Y
				local mouseX,mouseY = input.Position.X,input.Position.Y
				local fontSizeX,fontSizeY = math.ceil(self.FontSize/2),self.FontSize
				self.CursorX = self.ViewX + math.round((mouseX - frameX) / fontSizeX)
				self.CursorY = self.ViewY + math.floor((mouseY - frameY) / fontSizeY)
			end
			local cursorX,cursorY = self.CursorX,self.CursorY
			local line = self.Lines[cursorY+1] or ""
			if cursorX > #line then cursorX = #line
			elseif cursorX < 0 then cursorX = 0 end
			if cursorY >= #self.Lines then
				cursorY = math.max(0,#self.Lines-1)
			elseif cursorY < 0 then
				cursorY = 0
			end
			cursorX = cursorX + self:TabAdjust(cursorX,cursorY)
			self.CursorX = cursorX
			self.CursorY = cursorY
			local cursorVisible = (cursorX >= viewX) and (cursorY >= viewY) and (cursorX <= viewX + maxCols) and (cursorY <= viewY + maxLines)
			if cursorVisible then
				local offX = (cursorX - viewX)
				local offY = (cursorY - viewY)
				cursor.Position = UDim2.new(0,linesOffset + offX*math.ceil(self.FontSize/2) - 1,0,offY*self.FontSize)
				cursor.Size = UDim2.new(0,1,0,self.FontSize+2)
				cursor.Visible = true
				self:CursorAnim(true)
			else
				cursor.Visible = false
			end
		end
		funcs.MapNewLines = function(self)
			local newLines = {}
			local count = 1
			local text = self.Text
			local find = string.find
			local init = 1
			local pos = find(text,"\n",init,true)
			while pos do
				newLines[count] = pos
				count = count + 1
				init = pos + 1
				pos = find(text,"\n",init,true)
			end
			self.NewLines = newLines
		end
		funcs.PreHighlight = function(self)
			local start = tick()
			local text = self.Text:gsub("\\\\","  ")
			local textLen = #text
			local found = {}
			local foundMap = {}
			local extras = {}
			local find = string.find
			local sub = string.sub
			self.ColoredLines = {}
			local function findAll(str,pattern,typ,raw)
				local count = #found+1
				local init = 1
				local x,y,extra = find(str,pattern,init,raw)
				while x do
					found[count] = x
					foundMap[x] = typ
					if extra then
						extras[x] = extra
					end
					count = count+1
					init = y+1
					x,y,extra = find(str,pattern,init,raw)
				end
			end
			local start = tick()
			findAll(text,'"',1,true)
			findAll(text,"'",2,true)
			findAll(text,"%[(=*)%[",3)
			findAll(text,"--",4,true)
			table.sort(found)
			local newLines = self.NewLines
			local curLine = 0
			local lineTableCount = 1
			local lineStart = 0
			local lineEnd = 0
			local lastEnding = 0
			local foundHighlights = {}
			for i = 1,#found do
				local pos = found[i]
				if pos <= lastEnding then continue end
				local ending = pos
				local typ = foundMap[pos]
				if typ == 1 then
					ending = find(text,'"',pos+1,true)
					while ending and sub(text,ending-1,ending-1) == "\\" do
						ending = find(text,'"',ending+1,true)
					end
					if not ending then ending = textLen end
				elseif typ == 2 then
					ending = find(text,"'",pos+1,true)
					while ending and sub(text,ending-1,ending-1) == "\\" do
						ending = find(text,"'",ending+1,true)
					end
					if not ending then ending = textLen end
				elseif typ == 3 then
					_,ending = find(text,"]"..extras[pos].."]",pos+1,true)
					if not ending then ending = textLen end
				elseif typ == 4 then
					local ahead = foundMap[pos+2]
					if ahead == 3 then
						_,ending = find(text,"]"..extras[pos+2].."]",pos+1,true)
						if not ending then ending = textLen end
					else
						ending = find(text,"\n",pos+1,true) or textLen
					end
				end
				while pos > lineEnd do
					curLine = curLine + 1
					lineEnd = newLines[curLine] or textLen+1
				end
				while true do
					local lineTable = foundHighlights[curLine]
					if not lineTable then lineTable = {} foundHighlights[curLine] = lineTable end
					lineTable[pos] = {typ,ending}
					if ending > lineEnd then
						curLine = curLine + 1
						lineEnd = newLines[curLine] or textLen+1
					else
						break
					end
				end
				lastEnding = ending
			end
			self.PreHighlights = foundHighlights
		end
		funcs.HighlightLine = function(self,line)
			local cached = self.ColoredLines[line]
			if cached then return cached end
			local sub = string.sub
			local find = string.find
			local match = string.match
			local highlights = {}
			local preHighlights = self.PreHighlights[line] or {}
			local lineText = self.Lines[line] or ""
			local lineLen = #lineText
			local lastEnding = 0
			local currentType = 0
			local lastWord = nil
			local wordBeginsDotted = false
			local funcStatus = 0
			local lineStart = self.NewLines[line-1] or 0
			local preHighlightMap = {}
			for pos,data in next,preHighlights do
				local relativePos = pos-lineStart
				if relativePos < 1 then
					currentType = data[1]
					lastEnding = data[2] - lineStart
				else
					preHighlightMap[relativePos] = {data[1],data[2]-lineStart}
				end
			end
			for col = 1,#lineText do
				if col <= lastEnding then highlights[col] = currentType continue end
				local pre = preHighlightMap[col]
				if pre then
					currentType = pre[1]
					lastEnding = pre[2]
					highlights[col] = currentType
					wordBeginsDotted = false
					lastWord = nil
					funcStatus = 0
				else
					local char = sub(lineText,col,col)
					if find(char,"[%a_]") then
						local word = match(lineText,"[%a%d_]+",col)
						local wordType = (keywords[word] and 7) or (builtIns[word] and 8)
						lastEnding = col+#word-1
						if wordType ~= 7 then
							if wordBeginsDotted then
								local prevBuiltIn = lastWord and builtIns[lastWord]
								wordType = (prevBuiltIn and type(prevBuiltIn) == "table" and prevBuiltIn[word] and 8) or 10
							end
							if wordType ~= 8 then
								local x,y,br = find(lineText,"^%s*([%({\"'])",lastEnding+1)
								if x then
									wordType = (funcStatus > 0 and br == "(" and 16) or 9
									funcStatus = 0
								end
							end
						else
							wordType = specialKeywordsTypes[word] or wordType
							funcStatus = (word == "function" and 1 or 0)
						end
						lastWord = word
						wordBeginsDotted = false
						if funcStatus > 0 then funcStatus = 1 end
						if wordType then
							currentType = wordType
							highlights[col] = currentType
						else
							currentType = nil
						end
					elseif find(char,"%p") then
						local isDot = (char == ".")
						local isNum = isDot and find(sub(lineText,col+1,col+1),"%d")
						highlights[col] = (isNum and 6 or 5)
						if not isNum then
							local dotStr = isDot and match(lineText,"%.%.?%.?",col)
							if dotStr and #dotStr > 1 then
								currentType = 5
								lastEnding = col+#dotStr-1
								wordBeginsDotted = false
								lastWord = nil
								funcStatus = 0
							else
								if isDot then
									if wordBeginsDotted then
										lastWord = nil
									else
										wordBeginsDotted = true
									end
								else
									wordBeginsDotted = false
									lastWord = nil
								end
								funcStatus = ((isDot or char == ":") and funcStatus == 1 and 2) or 0
							end
						end
					elseif find(char,"%d") then
						local _,endPos = find(lineText,"%x+",col)
						local endPart = sub(lineText,endPos,endPos+1)
						if (endPart == "e+" or endPart == "e-") and find(sub(lineText,endPos+2,endPos+2),"%d") then
							endPos = endPos + 1
						end
						currentType = 6
						lastEnding = endPos
						highlights[col] = 6
						wordBeginsDotted = false
						lastWord = nil
						funcStatus = 0
					else
						highlights[col] = currentType
						local _,endPos = find(lineText,"%s+",col)
						if endPos then
							lastEnding = endPos
						end
					end
				end
			end
			self.ColoredLines[line] = highlights
			return highlights
		end
		funcs.Refresh = function(self)
			local start = tick()
			local linesFrame = self.Frame.Lines
			local hSize = math.max(0,linesFrame.AbsoluteSize.X)
			local vSize = math.max(0,linesFrame.AbsoluteSize.Y)
			local maxLines = math.ceil(vSize / self.FontSize)
			local maxCols = math.ceil(hSize / math.ceil(self.FontSize/2))
			local gsub = string.gsub
			local sub = string.sub
			local viewX,viewY = self.ViewX,self.ViewY
			local lineNumberStr = ""
			for row = 1,maxLines do
				local lineFrame = self.LineFrames[row]
				if not lineFrame then
					lineFrame = Instance.new("Frame")
					lineFrame.Name = "Line"
					lineFrame.Position = UDim2.new(0,0,0,(row-1)*self.FontSize)
					lineFrame.Size = UDim2.new(1,0,0,self.FontSize)
					lineFrame.BorderSizePixel = 0
					lineFrame.BackgroundTransparency = 1
					local selectionHighlight = Instance.new("Frame")
					selectionHighlight.Name = "SelectionHighlight"
					selectionHighlight.BorderSizePixel = 0
					selectionHighlight.BackgroundColor3 = Settings.Theme.Syntax.SelectionBack
					selectionHighlight.Parent = lineFrame
					local label = Instance.new("TextLabel")
					label.Name = "Label"
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.Code
					label.TextSize = self.FontSize
					label.Size = UDim2.new(1,0,0,self.FontSize)
					label.RichText = true
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextColor3 = self.Colors.Text
					label.ZIndex = 2
					label.Parent = lineFrame
					lineFrame.Parent = linesFrame
					self.LineFrames[row] = lineFrame
				end
				local relaY = viewY + row
				local lineText = self.Lines[relaY] or ""
				local resText = ""
				local highlights = self:HighlightLine(relaY)
				local colStart = viewX + 1
				local richTemplates = self.RichTemplates
				local textTemplate = richTemplates.Text
				local selectionTemplate = richTemplates.Selection
				local curType = highlights[colStart]
				local curTemplate = richTemplates[typeMap[curType]] or textTemplate
				local selectionRange = self.SelectionRange
				local selPos1 = selectionRange[1]
				local selPos2 = selectionRange[2]
				local selRow,selColumn = selPos1[2],selPos1[1]
				local sel2Row,sel2Column = selPos2[2],selPos2[1]
				local selRelaX,selRelaY = viewX,relaY-1
				if selRelaY >= selPos1[2] and selRelaY <= selPos2[2] then
					local fontSizeX = math.ceil(self.FontSize/2)
					local posX = (selRelaY == selPos1[2] and selPos1[1] or 0) - viewX
					local sizeX = (selRelaY == selPos2[2] and selPos2[1]-posX-viewX or maxCols+viewX)
					lineFrame.SelectionHighlight.Position = UDim2.new(0,posX*fontSizeX,0,0)
					lineFrame.SelectionHighlight.Size = UDim2.new(0,sizeX*fontSizeX,1,0)
					lineFrame.SelectionHighlight.Visible = true
				else
					lineFrame.SelectionHighlight.Visible = false
				end
				local inSelection = selRelaY >= selRow and selRelaY <= sel2Row and (selRelaY == selRow and viewX >= selColumn or selRelaY ~= selRow) and (selRelaY == sel2Row and viewX < sel2Column or selRelaY ~= sel2Row)
				if inSelection then
					curType = -999
					curTemplate = selectionTemplate
				end
				for col = 2,maxCols do
					local relaX = viewX + col
					local selRelaX = relaX-1
					local posType = highlights[relaX]
					local inSelection = selRelaY >= selRow and selRelaY <= sel2Row and (selRelaY == selRow and selRelaX >= selColumn or selRelaY ~= selRow) and (selRelaY == sel2Row and selRelaX < sel2Column or selRelaY ~= sel2Row)
					if inSelection then
						posType = -999
					end
					if posType ~= curType then
						local template = (inSelection and selectionTemplate) or richTemplates[typeMap[posType]] or textTemplate
						if template ~= curTemplate then
							local nextText = gsub(sub(lineText,colStart,relaX-1),"['\"<>&]",richReplace)
							resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. nextText .. "</font>") or nextText)
							colStart = relaX
							curTemplate = template
						end
						curType = posType
					end
				end
				local lastText = gsub(sub(lineText,colStart,viewX+maxCols),"['\"<>&]",richReplace)
				if #lastText > 0 then
					resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. lastText .. "</font>") or lastText)
				end
				if self.Lines[relaY] then
					lineNumberStr = lineNumberStr .. (relaY == self.CursorY and ("<b>"..relaY.."</b>\n") or relaY .. "\n")
				end
				lineFrame.Label.Text = resText
			end
			for i = maxLines+1,#self.LineFrames do
				self.LineFrames[i]:Destroy()
				self.LineFrames[i] = nil
			end
			self.Frame.LineNumbers.Text = lineNumberStr
			self:UpdateCursor()
		end
		funcs.UpdateView = function(self)
			local totalLinesStr = tostring(#self.Lines)
			local fontWidth = math.ceil(self.FontSize / 2)
			local linesOffset = #totalLinesStr*fontWidth + 4*fontWidth
			local linesFrame = self.Frame.Lines
			local hSize = linesFrame.AbsoluteSize.X
			local vSize = linesFrame.AbsoluteSize.Y
			local maxLines = math.ceil(vSize / self.FontSize)
			local totalWidth = self.MaxTextCols*fontWidth
			local scrollV = self.ScrollV
			local scrollH = self.ScrollH
			scrollV.VisibleSpace = maxLines
			scrollV.TotalSpace = #self.Lines + 1
			scrollH.VisibleSpace = math.ceil(hSize/fontWidth)
			scrollH.TotalSpace = self.MaxTextCols + 1
			scrollV.Gui.Visible = #self.Lines + 1 > maxLines
			scrollH.Gui.Visible = totalWidth > hSize
			local oldOffsets = self.FrameOffsets
			self.FrameOffsets = Vector2.new(scrollV.Gui.Visible and -16 or 0, scrollH.Gui.Visible and -16 or 0)
			if oldOffsets ~= self.FrameOffsets then
				self:UpdateView()
			else
				scrollV:ScrollTo(self.ViewY,true)
				scrollH:ScrollTo(self.ViewX,true)
				if scrollV.Gui.Visible and scrollH.Gui.Visible then
					scrollV.Gui.Size = UDim2.new(0,16,1,-16)
					scrollH.Gui.Size = UDim2.new(1,-16,0,16)
					self.GuiElems.ScrollCorner.Visible = true
				else
					scrollV.Gui.Size = UDim2.new(0,16,1,0)
					scrollH.Gui.Size = UDim2.new(1,0,0,16)
					self.GuiElems.ScrollCorner.Visible = false
				end
				self.ViewY = scrollV.Index
				self.ViewX = scrollH.Index
				self.Frame.Lines.Position = UDim2.new(0,linesOffset,0,0)
				self.Frame.Lines.Size = UDim2.new(1,-linesOffset+oldOffsets.X,1,oldOffsets.Y)
				self.Frame.LineNumbers.Position = UDim2.new(0,fontWidth,0,0)
				self.Frame.LineNumbers.Size = UDim2.new(0,#totalLinesStr*fontWidth,1,oldOffsets.Y)
				self.Frame.LineNumbers.TextSize = self.FontSize
			end
		end
		funcs.ProcessTextChange = function(self)
			local maxCols = 0
			local lines = self.Lines
			for i = 1,#lines do
				local lineLen = #lines[i]
				if lineLen > maxCols then
					maxCols = lineLen
				end
			end
			self.MaxTextCols = maxCols
			self:UpdateView()
			self.Text = table.concat(self.Lines,"\n")
			self:MapNewLines()
			self:PreHighlight()
			self:Refresh()
		end
		funcs.ConvertText = function(self,text,toEditor)
			if toEditor then
				return text:gsub("\t",(" %s%s "):format(tabSub,tabSub))
			else
				return text:gsub((" %s%s "):format(tabSub,tabSub),"\t")
			end
		end
		funcs.GetText = function(self)
			local source = table.concat(self.Lines,"\n")
			return self:ConvertText(source,false)
		end
		funcs.SetText = function(self,txt)
			txt = self:ConvertText(txt,true)
			local lines = self.Lines
			table.clear(lines)
			local count = 1
			for line in txt:gmatch("([^\n\r]*)[\n\r]?") do
				local len = #line
				lines[count] = line
				count = count + 1
			end
			self:ProcessTextChange()
		end
		funcs.MakeRichTemplates = function(self)
			local floor = math.floor
			local templates = {}
			for name,color in pairs(self.Colors) do
				templates[name] = ('<font color="rgb(%s,%s,%s)">'):format(floor(color.r*255),floor(color.g*255),floor(color.b*255))
			end
			self.RichTemplates = templates
		end
		funcs.ApplyTheme = function(self)
			local colors = Settings.Theme.Syntax
			self.Colors = colors
			self.Frame.LineNumbers.TextColor3 = colors.Text
			self.Frame.BackgroundColor3 = colors.Background
		end
		local mt = {__index = funcs}
		local function new()
			if not builtInInited then initBuiltIn() end
			local scrollV = Lib.ScrollBar.new()
			local scrollH = Lib.ScrollBar.new(true)
			scrollH.Gui.Position = UDim2.new(0,0,1,-16)
			local obj = setmetatable({
				FontSize = 15,
				ViewX = 0,
				ViewY = 0,
				Colors = Settings.Theme.Syntax,
				ColoredLines = {},
				Lines = {""},
				LineFrames = {},
				Editable = true,
				Editing = false,
				CursorX = 0,
				CursorY = 0,
				FloatCursorX = 0,
				Text = "",
				PreHighlights = {},
				SelectionRange = {{-1,-1},{-1,-1}},
				NewLines = {},
				FrameOffsets = Vector2.new(0,0),
				MaxTextCols = 0,
				ScrollV = scrollV,
				ScrollH = scrollH
			},mt)
			scrollV.WheelIncrement = 3
			scrollH.Increment = 2
			scrollH.WheelIncrement = 7
			scrollV.Scrolled:Connect(function()
				obj.ViewY = scrollV.Index
				obj:Refresh()
			end)
			scrollH.Scrolled:Connect(function()
				obj.ViewX = scrollH.Index
				obj:Refresh()
			end)
			makeFrame(obj)
			obj:MakeRichTemplates()
			obj:ApplyTheme()
			scrollV:SetScrollFrame(obj.Frame.Lines)
			scrollV.Gui.Parent = obj.Frame
			scrollH.Gui.Parent = obj.Frame
			obj:UpdateView()
			obj.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				obj:UpdateView()
				obj:Refresh()
			end)
			return obj
		end
		return {new = new}
	end)()
	Lib.Checkbox = (function()
		local funcs = {}
		local c3 = Color3.fromRGB
		local v2 = Vector2.new
		local ud2s = UDim2.fromScale
		local ud2o = UDim2.fromOffset
		local ud = UDim.new
		local max = math.max
		local new = Instance.new
		local TweenSize = new("Frame").TweenSize
		local ti = TweenInfo.new
		local delay = delay
		local function ripple(object, color)
			local circle = new('Frame')
			circle.BackgroundColor3 = color
			circle.BackgroundTransparency = 0.75
			circle.BorderSizePixel = 0
			circle.AnchorPoint = v2(0.5, 0.5)
			circle.Size = ud2o()
			circle.Position = ud2s(0.5, 0.5)
			circle.Parent = object
			local rounding = new('UICorner')
			rounding.CornerRadius = ud(1)
			rounding.Parent = circle
			local abssz = object.AbsoluteSize
			local size = max(abssz.X, abssz.Y) * 5/3
			TweenSize(circle, ud2o(size, size), "Out", "Quart", 0.4)
			service.TweenService:Create(circle, ti(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
			service.Debris:AddItem(circle, 0.4)
		end
		local function initGui(self,frame)
			local checkbox = frame or create({
				{1,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Checkbox",Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,16,0,16),}},
				{2,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ripples",Parent={1},Size=UDim2.new(1,0,1,0),}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.10196078568697,0.10196078568697,0.10196078568697),BorderSizePixel=0,Name="outline",Parent={1},Size=UDim2.new(0,16,0,16),}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="filler",Parent={3},Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,14,0,14),}},
				{5,"Frame",{BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="top",Parent={4},Size=UDim2.new(0,16,0,0),}},
				{6,"Frame",{AnchorPoint=Vector2.new(0,1),BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="bottom",Parent={4},Position=UDim2.new(0,0,0,14),Size=UDim2.new(0,16,0,0),}},
				{7,"Frame",{BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="left",Parent={4},Size=UDim2.new(0,0,0,16),}},
				{8,"Frame",{AnchorPoint=Vector2.new(1,0),BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="right",Parent={4},Position=UDim2.new(0,14,0,0),Size=UDim2.new(0,0,0,16),}},
				{9,"Frame",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Name="checkmark",Parent={4},Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,0,0,20),}},
				{10,"ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://6234266378",Parent={9},Position=UDim2.new(0.5,0,0.5,0),ScaleType=3,Size=UDim2.new(0,15,0,11),}},
				{11,"ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6401617475",ImageColor3=Color3.new(0.20784313976765,0.69803923368454,0.98431372642517),Name="checkmark2",Parent={4},Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,12,0,12),Visible=false,}},
				{12,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6425281788",ImageTransparency=0.20000000298023,Name="middle",Parent={4},ScaleType=2,Size=UDim2.new(1,0,1,0),TileSize=UDim2.new(0,2,0,2),Visible=false,}},
				{13,"UICorner",{CornerRadius=UDim.new(0,2),Parent={3},}},
			})
			local outline = checkbox.outline
			local filler = outline.filler
			local checkmark = filler.checkmark
			local ripples_container = checkbox.ripples
			local top, bottom, left, right = filler.top, filler.bottom, filler.left, filler.right
			self.Gui = checkbox
			self.GuiElems = {
				Top = top,
				Bottom = bottom,
				Left = left,
				Right = right,
				Outline = outline,
				Filler = filler,
				Checkmark = checkmark,
				Checkmark2 = filler.checkmark2,
				Middle = filler.middle
			}
			checkbox.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					local release
					release = service.UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							release:Disconnect()
							if Lib.CheckMouseInGui(checkbox) then
								if self.Style == 0 then
									ripple(ripples_container, self.Disabled and self.Colors.Disabled or self.Colors.Primary)
								end
								if not self.Disabled then
									self:SetState(not self.Toggled,true)
								else
									self:Paint()
								end
								self.OnInput:Fire()
							end
						end
					end)
				end
			end)
			self:Paint()
		end
		funcs.Collapse = function(self,anim)
			local guiElems = self.GuiElems
			if anim then
				TweenSize(guiElems.Top, ud2o(14, 14), "In", "Quart", 4/15, true)
				TweenSize(guiElems.Bottom, ud2o(14, 14), "In", "Quart", 4/15, true)
				TweenSize(guiElems.Left, ud2o(14, 14), "In", "Quart", 4/15, true)
				TweenSize(guiElems.Right, ud2o(14, 14), "In", "Quart", 4/15, true)
			else
				guiElems.Top.Size = ud2o(14, 14)
				guiElems.Bottom.Size = ud2o(14, 14)
				guiElems.Left.Size = ud2o(14, 14)
				guiElems.Right.Size = ud2o(14, 14)
			end
		end
		funcs.Expand = function(self,anim)
			local guiElems = self.GuiElems
			if anim then
				TweenSize(guiElems.Top, ud2o(14, 0), "InOut", "Quart", 4/15, true)
				TweenSize(guiElems.Bottom, ud2o(14, 0), "InOut", "Quart", 4/15, true)
				TweenSize(guiElems.Left, ud2o(0, 14), "InOut", "Quart", 4/15, true)
				TweenSize(guiElems.Right, ud2o(0, 14), "InOut", "Quart", 4/15, true)
			else
				guiElems.Top.Size = ud2o(14, 0)
				guiElems.Bottom.Size = ud2o(14, 0)
				guiElems.Left.Size = ud2o(0, 14)
				guiElems.Right.Size = ud2o(0, 14)
			end
		end
		funcs.Paint = function(self)
			local guiElems = self.GuiElems
			if self.Style == 0 then
				local color_base = self.Disabled and self.Colors.Disabled
				guiElems.Outline.BackgroundColor3 = color_base or (self.Toggled and self.Colors.Primary) or self.Colors.Secondary
				local walls_color = color_base or self.Colors.Primary
				guiElems.Top.BackgroundColor3 = walls_color
				guiElems.Bottom.BackgroundColor3 = walls_color
				guiElems.Left.BackgroundColor3 = walls_color
				guiElems.Right.BackgroundColor3 = walls_color
			else
				guiElems.Outline.BackgroundColor3 = self.Disabled and self.Colors.Disabled or self.Colors.Secondary
				guiElems.Filler.BackgroundColor3 = self.Disabled and self.Colors.DisabledBackground or self.Colors.Background
				guiElems.Checkmark2.ImageColor3 = self.Disabled and self.Colors.DisabledCheck or self.Colors.Primary
			end
		end
		funcs.SetState = function(self,val,anim)
			self.Toggled = val
			if self.OutlineColorTween then self.OutlineColorTween:Cancel() end
			local setStateTime = tick()
			self.LastSetStateTime = setStateTime
			if self.Toggled then
				if self.Style == 0 then
					if anim then
						self.OutlineColorTween = service.TweenService:Create(self.GuiElems.Outline, ti(4/15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {BackgroundColor3 = self.Colors.Primary})
						self.OutlineColorTween:Play()
						delay(0.15, function()
							if setStateTime ~= self.LastSetStateTime then return end
							self:Paint()
							TweenSize(self.GuiElems.Checkmark, ud2o(14, 20), "Out", "Bounce", 2/15, true)
						end)
					else
						self.GuiElems.Outline.BackgroundColor3 = self.Colors.Primary
						self:Paint()
						self.GuiElems.Checkmark.Size = ud2o(14, 20)
					end
					self:Collapse(anim)
				else
					self:Paint()
					self.GuiElems.Checkmark2.Visible = true
					self.GuiElems.Middle.Visible = false
				end
			else
				if self.Style == 0 then
					if anim then
						self.OutlineColorTween = service.TweenService:Create(self.GuiElems.Outline, ti(4/15, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {BackgroundColor3 = self.Colors.Secondary})
						self.OutlineColorTween:Play()
						delay(0.15, function()
							if setStateTime ~= self.LastSetStateTime then return end
							self:Paint()
							TweenSize(self.GuiElems.Checkmark, ud2o(0, 20), "Out", "Quad", 1/15, true)
						end)
					else
						self.GuiElems.Outline.BackgroundColor3 = self.Colors.Secondary
						self:Paint()
						self.GuiElems.Checkmark.Size = ud2o(0, 20)
					end
					self:Expand(anim)
				else
					self:Paint()
					self.GuiElems.Checkmark2.Visible = false
					self.GuiElems.Middle.Visible = self.Toggled == nil
				end
			end
		end
		local mt = {__index = funcs}
		local function new(style)
			local obj = setmetatable({
				Toggled = false,
				Disabled = false,
				OnInput = Lib.Signal.new(),
				Style = style or 0,
				Colors = {
					Background = c3(36,36,36),
					Primary = c3(49,176,230),
					Secondary = c3(25,25,25),
					Disabled = c3(64,64,64),
					DisabledBackground = c3(52,52,52),
					DisabledCheck = c3(80,80,80)
				}
			},mt)
			initGui(obj)
			return obj
		end
		local function fromFrame(frame)
			local obj = setmetatable({
				Toggled = false,
				Disabled = false,
				Colors = {
					Background = c3(36,36,36),
					Primary = c3(49,176,230),
					Secondary = c3(25,25,25),
					Disabled = c3(64,64,64),
					DisabledBackground = c3(52,52,52)
				}
			},mt)
			initGui(obj,frame)
			return obj
		end
		return {new = new, fromFrame}
	end)()
	Lib.BrickColorPicker = (function()
		local funcs = {}
		local paletteCount = 0
		local mouse = service.Players.LocalPlayer:GetMouse()
		local hexStartX = 4
		local hexSizeX = 27
		local hexTriangleStart = 1
		local hexTriangleSize = 8
		local bottomColors = {
			Color3.fromRGB(17,17,17),
			Color3.fromRGB(99,95,98),
			Color3.fromRGB(163,162,165),
			Color3.fromRGB(205,205,205),
			Color3.fromRGB(223,223,222),
			Color3.fromRGB(237,234,234),
			Color3.fromRGB(27,42,53),
			Color3.fromRGB(91,93,105),
			Color3.fromRGB(159,161,172),
			Color3.fromRGB(202,203,209),
			Color3.fromRGB(231,231,236),
			Color3.fromRGB(248,248,248)
		}
		local function isMouseInHexagon(hex)
			local relativeX = mouse.X - hex.AbsolutePosition.X
			local relativeY = mouse.Y - hex.AbsolutePosition.Y
			if relativeX >= hexStartX and relativeX < hexStartX + hexSizeX then
				relativeX = relativeX - 4
				local relativeWidth = (13-math.min(relativeX,26 - relativeX))/13
				if relativeY >= hexTriangleStart + hexTriangleSize*relativeWidth and relativeY < hex.AbsoluteSize.Y - hexTriangleStart - hexTriangleSize*relativeWidth then
					return true
				end
			end
			return false
		end
		local function hexInput(self,hex,color)
			hex.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and isMouseInHexagon(hex) then
					self.OnSelect:Fire(color)
					self:Close()
				end
			end)
			hex.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and isMouseInHexagon(hex) then
					self.OnPreview:Fire(color)
				end
			end)
		end
		local function createGui(self)
			local gui = create({
				{1,"ScreenGui",{Name="BrickColor",}},
				{2,"Frame",{Active=true,BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),Parent={1},Position=UDim2.new(0.40000000596046,0,0.40000000596046,0),Size=UDim2.new(0,337,0,380),}},
				{3,"TextButton",{BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="MoreColors",Parent={2},Position=UDim2.new(0,5,1,-30),Size=UDim2.new(1,-10,0,25),Text="More Colors",TextColor3=Color3.new(1,1,1),TextSize=14,}},
				{4,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://1281023007",ImageColor3=Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Name="Hex",Parent={2},Size=UDim2.new(0,35,0,35),Visible=false,}},
			})
			local colorFrame = gui.Frame
			local hex = colorFrame.Hex
			for row = 1,13 do
				local columns = math.min(row,14-row)+6
				for column = 1,columns do
					local nextColor = BrickColor.palette(paletteCount).Color
					local newHex = hex:Clone()
					newHex.Position = UDim2.new(0, (column-1)*25-(columns-7)*13+3*26 + 1, 0, (row-1)*23 + 4)
					newHex.ImageColor3 = nextColor
					newHex.Visible = true
					hexInput(self,newHex,nextColor)
					newHex.Parent = colorFrame
					paletteCount = paletteCount + 1
				end
			end
			for column = 1,12 do
				local nextColor = bottomColors[column]
				local newHex = hex:Clone()
				newHex.Position = UDim2.new(0, (column-1)*25-(12-7)*13+3*26 + 3, 0, 308)
				newHex.ImageColor3 = nextColor
				newHex.Visible = true
				hexInput(self,newHex,nextColor)
				newHex.Parent = colorFrame
				paletteCount = paletteCount + 1
			end
			colorFrame.MoreColors.MouseButton1Click:Connect(function()
				self.OnMoreColors:Fire()
				self:Close()
			end)
			self.Gui = gui
		end
		funcs.SetMoreColorsVisible = function(self,vis)
			local colorFrame = self.Gui.Frame
			colorFrame.Size = UDim2.new(0,337,0,380 - (not vis and 33 or 0))
			colorFrame.MoreColors.Visible = vis
		end
		funcs.Show = function(self,x,y,prevColor)
			self.PrevColor = prevColor or self.PrevColor
			local reverseY = false
			local x,y = x or mouse.X, y or mouse.Y
			local maxX,maxY = mouse.ViewSizeX,mouse.ViewSizeY
			Lib.ShowGui(self.Gui)
			local sizeX,sizeY = self.Gui.Frame.AbsoluteSize.X,self.Gui.Frame.AbsoluteSize.Y
			if x + sizeX > maxX then x = self.ReverseX and x - sizeX or maxX - sizeX end
			if y + sizeY > maxY then reverseY = true end
			local closable = false
			if self.CloseEvent then self.CloseEvent:Disconnect() end
			self.CloseEvent = service.UserInputService.InputBegan:Connect(function(input)
				if not closable or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
				if not Lib.CheckMouseInGui(self.Gui.Frame) then
					self.CloseEvent:Disconnect()
					self:Close()
				end
			end)
			if reverseY then
				local newY = y - sizeY - (self.ReverseYOffset or 0)
				y = newY >= 0 and newY or 0
			end
			self.Gui.Frame.Position = UDim2.new(0,x,0,y)
			Lib.FastWait()
			closable = true
		end
		funcs.Close = function(self)
			self.Gui.Parent = nil
			self.OnCancel:Fire()
		end
		local mt = {__index = funcs}
		local function new()
			local obj = setmetatable({
				OnPreview = Lib.Signal.new(),
				OnSelect = Lib.Signal.new(),
				OnCancel = Lib.Signal.new(),
				OnMoreColors = Lib.Signal.new(),
				PrevColor = Color3.new(0,0,0)
			},mt)
			createGui(obj)
			return obj
		end
		return {new = new}
	end)()
	Lib.ColorPicker = (function()
		local funcs = {}
		local function new()
			local newMt = setmetatable({},{})
			newMt.OnSelect = Lib.Signal.new()
			newMt.OnCancel = Lib.Signal.new()
			newMt.OnPreview = Lib.Signal.new()
			local guiContents = create({
				{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
				{2,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="BasicColors",Parent={1},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,180,0,200),}},
				{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,0,0,-5),Size=UDim2.new(1,0,0,26),Text="Basic Colors",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Blue",Parent={1},Position=UDim2.new(1,-63,0,255),Size=UDim2.new(0,52,0,16),}},
				{5,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={4},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{6,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={5},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={6},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{8,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={7},Size=UDim2.new(0,16,0,8),}},
				{9,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{10,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{11,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{12,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={6},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{13,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={12},Size=UDim2.new(0,16,0,8),}},
				{14,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{15,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{16,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{17,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={4},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Blue:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{18,"Frame",{BackgroundColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,ClipsDescendants=true,Name="ColorSpaceFrame",Parent={1},Position=UDim2.new(1,-261,0,4),Size=UDim2.new(0,222,0,202),}},
				{19,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),BorderSizePixel=0,Image="rbxassetid://1072518406",Name="ColorSpace",Parent={18},Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,220,0,200),}},
				{20,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Scope",Parent={19},Position=UDim2.new(0,210,0,190),Size=UDim2.new(0,20,0,20),}},
				{21,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Name="Line",Parent={20},Position=UDim2.new(0,9,0,0),Size=UDim2.new(0,2,0,20),}},
				{22,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Name="Line",Parent={20},Position=UDim2.new(0,0,0,9),Size=UDim2.new(0,20,0,2),}},
				{23,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="CustomColors",Parent={1},Position=UDim2.new(0,5,0,210),Size=UDim2.new(0,180,0,90),}},
				{24,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={23},Size=UDim2.new(1,0,0,20),Text="Custom Colors (RC = Set)",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{25,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Green",Parent={1},Position=UDim2.new(1,-63,0,233),Size=UDim2.new(0,52,0,16),}},
				{26,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={25},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{27,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={26},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{28,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={27},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{29,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={28},Size=UDim2.new(0,16,0,8),}},
				{30,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{31,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{32,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{33,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={27},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{34,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={33},Size=UDim2.new(0,16,0,8),}},
				{35,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{36,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{37,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{38,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={25},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Green:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{39,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Hue",Parent={1},Position=UDim2.new(1,-180,0,211),Size=UDim2.new(0,52,0,16),}},
				{40,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={39},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{41,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={40},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{42,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={41},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{43,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={42},Size=UDim2.new(0,16,0,8),}},
				{44,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{45,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{46,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{47,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={41},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{48,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={47},Size=UDim2.new(0,16,0,8),}},
				{49,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{50,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{51,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{52,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={39},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Hue:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{53,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="Preview",Parent={1},Position=UDim2.new(1,-260,0,211),Size=UDim2.new(0,35,1,-245),}},
				{54,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Red",Parent={1},Position=UDim2.new(1,-63,0,211),Size=UDim2.new(0,52,0,16),}},
				{55,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={54},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{56,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={55},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{57,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={56},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{58,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={57},Size=UDim2.new(0,16,0,8),}},
				{59,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{60,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{61,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{62,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={56},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{63,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={62},Size=UDim2.new(0,16,0,8),}},
				{64,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{65,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{66,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{67,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={54},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Red:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{68,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Sat",Parent={1},Position=UDim2.new(1,-180,0,233),Size=UDim2.new(0,52,0,16),}},
				{69,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={68},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{70,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={69},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{71,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={70},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{72,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={71},Size=UDim2.new(0,16,0,8),}},
				{73,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{74,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{75,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{76,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={70},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{77,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={76},Size=UDim2.new(0,16,0,8),}},
				{78,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{79,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{80,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{81,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={68},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Sat:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{82,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Val",Parent={1},Position=UDim2.new(1,-180,0,255),Size=UDim2.new(0,52,0,16),}},
				{83,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={82},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="255",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{84,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={83},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
				{85,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={84},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{86,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={85},Size=UDim2.new(0,16,0,8),}},
				{87,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
				{88,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{89,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
				{90,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={84},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
				{91,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={90},Size=UDim2.new(0,16,0,8),}},
				{92,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
				{93,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
				{94,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
				{95,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={82},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Val:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{96,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Cancel",Parent={1},Position=UDim2.new(1,-105,1,-28),Size=UDim2.new(0,100,0,25),Text="Cancel",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{97,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Ok",Parent={1},Position=UDim2.new(1,-210,1,-28),Size=UDim2.new(0,100,0,25),Text="OK",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{98,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Image="rbxassetid://1072518502",Name="ColorStrip",Parent={1},Position=UDim2.new(1,-30,0,5),Size=UDim2.new(0,13,0,200),}},
				{99,"Frame",{BackgroundColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={1},Position=UDim2.new(1,-16,0,1),Size=UDim2.new(0,5,0,208),}},
				{100,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={99},Position=UDim2.new(0,-2,0,-4),Size=UDim2.new(0,8,0,16),}},
				{101,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,2,0,8),Size=UDim2.new(0,1,0,1),}},
				{102,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,3,0,7),Size=UDim2.new(0,1,0,3),}},
				{103,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,4,0,6),Size=UDim2.new(0,1,0,5),}},
				{104,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,1,0,7),}},
				{105,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,6,0,4),Size=UDim2.new(0,1,0,9),}},
			})
			local window = Lib.Window.new()
			window.Resizable = false
			window.Alignable = false
			window:SetTitle("Color Picker")
			window:Resize(450,330)
			for i,v in pairs(guiContents:GetChildren()) do
				v.Parent = window.GuiElems.Content
			end
			newMt.Window = window
			newMt.Gui = window.Gui
			local pickerGui = window.Gui.Main
			local pickerTopBar = pickerGui.TopBar
			local pickerFrame = pickerGui.Content
			local colorSpace = pickerFrame.ColorSpaceFrame.ColorSpace
			local colorStrip = pickerFrame.ColorStrip
			local previewFrame = pickerFrame.Preview
			local basicColorsFrame = pickerFrame.BasicColors
			local customColorsFrame = pickerFrame.CustomColors
			local okButton = pickerFrame.Ok
			local cancelButton = pickerFrame.Cancel
			local closeButton = pickerTopBar.Close
			local colorScope = colorSpace.Scope
			local colorArrow = pickerFrame.ArrowFrame.Arrow
			local hueInput = pickerFrame.Hue.Input
			local satInput = pickerFrame.Sat.Input
			local valInput = pickerFrame.Val.Input
			local redInput = pickerFrame.Red.Input
			local greenInput = pickerFrame.Green.Input
			local blueInput = pickerFrame.Blue.Input
			local user = game:GetService("UserInputService")
			local mouse = game:GetService("Players").LocalPlayer:GetMouse()
			local hue,sat,val = 0,0,1
			local red,green,blue = 1,1,1
			local chosenColor = Color3.new(0,0,0)
			local basicColors = {Color3.new(0,0,0),Color3.new(0.66666668653488,0,0),Color3.new(0,0.33333334326744,0),Color3.new(0.66666668653488,0.33333334326744,0),Color3.new(0,0.66666668653488,0),Color3.new(0.66666668653488,0.66666668653488,0),Color3.new(0,1,0),Color3.new(0.66666668653488,1,0),Color3.new(0,0,0.49803924560547),Color3.new(0.66666668653488,0,0.49803924560547),Color3.new(0,0.33333334326744,0.49803924560547),Color3.new(0.66666668653488,0.33333334326744,0.49803924560547),Color3.new(0,0.66666668653488,0.49803924560547),Color3.new(0.66666668653488,0.66666668653488,0.49803924560547),Color3.new(0,1,0.49803924560547),Color3.new(0.66666668653488,1,0.49803924560547),Color3.new(0,0,1),Color3.new(0.66666668653488,0,1),Color3.new(0,0.33333334326744,1),Color3.new(0.66666668653488,0.33333334326744,1),Color3.new(0,0.66666668653488,1),Color3.new(0.66666668653488,0.66666668653488,1),Color3.new(0,1,1),Color3.new(0.66666668653488,1,1),Color3.new(0.33333334326744,0,0),Color3.new(1,0,0),Color3.new(0.33333334326744,0.33333334326744,0),Color3.new(1,0.33333334326744,0),Color3.new(0.33333334326744,0.66666668653488,0),Color3.new(1,0.66666668653488,0),Color3.new(0.33333334326744,1,0),Color3.new(1,1,0),Color3.new(0.33333334326744,0,0.49803924560547),Color3.new(1,0,0.49803924560547),Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Color3.new(1,0.33333334326744,0.49803924560547),Color3.new(0.33333334326744,0.66666668653488,0.49803924560547),Color3.new(1,0.66666668653488,0.49803924560547),Color3.new(0.33333334326744,1,0.49803924560547),Color3.new(1,1,0.49803924560547),Color3.new(0.33333334326744,0,1),Color3.new(1,0,1),Color3.new(0.33333334326744,0.33333334326744,1),Color3.new(1,0.33333334326744,1),Color3.new(0.33333334326744,0.66666668653488,1),Color3.new(1,0.66666668653488,1),Color3.new(0.33333334326744,1,1),Color3.new(1,1,1)}
			local customColors = {}
			local function updateColor(noupdate)
				local relativeX,relativeY,relativeStripY = 219 - hue*219, 199 - sat*199, 199 - val*199
				local hsvColor = Color3.fromHSV(hue,sat,val)
				if noupdate == 2 or not noupdate then
					hueInput.Text = tostring(math.ceil(359*hue))
					satInput.Text = tostring(math.ceil(255*sat))
					valInput.Text = tostring(math.floor(255*val))
				end
				if noupdate == 1 or not noupdate then
					redInput.Text = tostring(math.floor(255*red))
					greenInput.Text = tostring(math.floor(255*green))
					blueInput.Text = tostring(math.floor(255*blue))
				end
				chosenColor = Color3.new(red,green,blue)
				colorScope.Position = UDim2.new(0,relativeX-9,0,relativeY-9)
				colorStrip.ImageColor3 = Color3.fromHSV(hue,sat,1)
				colorArrow.Position = UDim2.new(0,-2,0,relativeStripY-4)
				previewFrame.BackgroundColor3 = chosenColor
				newMt.Color = chosenColor
				newMt.OnPreview:Fire(chosenColor)
			end
			local function colorSpaceInput()
				local relativeX = mouse.X - colorSpace.AbsolutePosition.X
				local relativeY = mouse.Y - colorSpace.AbsolutePosition.Y
				if relativeX < 0 then relativeX = 0 elseif relativeX > 219 then relativeX = 219 end
				if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end
				hue = (219 - relativeX)/219
				sat = (199 - relativeY)/199
				local hsvColor = Color3.fromHSV(hue,sat,val)
				red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
				updateColor()
			end
			local function colorStripInput()
				local relativeY = mouse.Y - colorStrip.AbsolutePosition.Y
				if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end
				val = (199 - relativeY)/199
				local hsvColor = Color3.fromHSV(hue,sat,val)
				red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
				updateColor()
			end
			local function hookButtons(frame,func)
				frame.ArrowFrame.Up.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						frame.ArrowFrame.Up.BackgroundTransparency = 0.5
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,runEvent
						local startTime = tick()
						local pressing = true
						local startNum = tonumber(frame.Text)
						if not startNum then return end
						releaseEvent = user.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							pressing = false
						end)
						startNum = startNum + 1
						func(startNum)
						while pressing do
							if tick()-startTime > 0.3 then
								startNum = startNum + 1
								func(startNum)
							end
							wait(0.1)
						end
					end
				end)
				frame.ArrowFrame.Up.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						frame.ArrowFrame.Up.BackgroundTransparency = 1
					end
				end)
				frame.ArrowFrame.Down.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						frame.ArrowFrame.Down.BackgroundTransparency = 0.5
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,runEvent
						local startTime = tick()
						local pressing = true
						local startNum = tonumber(frame.Text)
						if not startNum then return end
						releaseEvent = user.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							pressing = false
						end)
						startNum = startNum - 1
						func(startNum)
						while pressing do
							if tick()-startTime > 0.3 then
								startNum = startNum - 1
								func(startNum)
							end
							wait(0.1)
						end
					end
				end)
				frame.ArrowFrame.Down.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						frame.ArrowFrame.Down.BackgroundTransparency = 1
					end
				end)
			end
			colorSpace.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local releaseEvent,mouseEvent
					releaseEvent = user.InputEnded:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
						releaseEvent:Disconnect()
						mouseEvent:Disconnect()
					end)
					mouseEvent = user.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							colorSpaceInput()
						end
					end)
					colorSpaceInput()
				end
			end)
			colorStrip.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local releaseEvent,mouseEvent
					releaseEvent = user.InputEnded:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
						releaseEvent:Disconnect()
						mouseEvent:Disconnect()
					end)
					mouseEvent = user.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							colorStripInput()
						end
					end)
					colorStripInput()
				end
			end)
			local function updateHue(str)
				local num = tonumber(str)
				if num then
					hue = math.clamp(math.floor(num),0,359)/359
					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
					hueInput.Text = tostring(hue*359)
					updateColor(1)
				end
			end
			hueInput.FocusLost:Connect(function() updateHue(hueInput.Text) end) hookButtons(hueInput,updateHue)
			local function updateSat(str)
				local num = tonumber(str)
				if num then
					sat = math.clamp(math.floor(num),0,255)/255
					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
					satInput.Text = tostring(sat*255)
					updateColor(1)
				end
			end
			satInput.FocusLost:Connect(function() updateSat(satInput.Text) end) hookButtons(satInput,updateSat)
			local function updateVal(str)
				local num = tonumber(str)
				if num then
					val = math.clamp(math.floor(num),0,255)/255
					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
					valInput.Text = tostring(val*255)
					updateColor(1)
				end
			end
			valInput.FocusLost:Connect(function() updateVal(valInput.Text) end) hookButtons(valInput,updateVal)
			local function updateRed(str)
				local num = tonumber(str)
				if num then
					red = math.clamp(math.floor(num),0,255)/255
					local newColor = Color3.new(red,green,blue)
					hue,sat,val = Color3.toHSV(newColor)
					redInput.Text = tostring(red*255)
					updateColor(2)
				end
			end
			redInput.FocusLost:Connect(function() updateRed(redInput.Text) end) hookButtons(redInput,updateRed)
			local function updateGreen(str)
				local num = tonumber(str)
				if num then
					green = math.clamp(math.floor(num),0,255)/255
					local newColor = Color3.new(red,green,blue)
					hue,sat,val = Color3.toHSV(newColor)
					greenInput.Text = tostring(green*255)
					updateColor(2)
				end
			end
			greenInput.FocusLost:Connect(function() updateGreen(greenInput.Text) end) hookButtons(greenInput,updateGreen)
			local function updateBlue(str)
				local num = tonumber(str)
				if num then
					blue = math.clamp(math.floor(num),0,255)/255
					local newColor = Color3.new(red,green,blue)
					hue,sat,val = Color3.toHSV(newColor)
					blueInput.Text = tostring(blue*255)
					updateColor(2)
				end
			end
			blueInput.FocusLost:Connect(function() updateBlue(blueInput.Text) end) hookButtons(blueInput,updateBlue)
			local colorChoice = Instance.new("TextButton")
			colorChoice.Name = "Choice"
			colorChoice.Size = UDim2.new(0,25,0,18)
			colorChoice.BorderColor3 = Color3.fromRGB(55,55,55)
			colorChoice.Text = ""
			colorChoice.AutoButtonColor = false
			local row = 0
			local column = 0
			for i,v in pairs(basicColors) do
				local newColor = colorChoice:Clone()
				newColor.BackgroundColor3 = v
				newColor.Position = UDim2.new(0,1 + 30*column,0,21 + 23*row)
				newColor.MouseButton1Click:Connect(function()
					red,green,blue = v.r,v.g,v.b
					local newColor = Color3.new(red,green,blue)
					hue,sat,val = Color3.toHSV(newColor)
					updateColor()
				end)
				newColor.Parent = basicColorsFrame
				column = column + 1
				if column == 6 then row = row + 1 column = 0 end
			end
			row = 0
			column = 0
			for i = 1,12 do
				local color = customColors[i] or Color3.new(0,0,0)
				local newColor = colorChoice:Clone()
				newColor.BackgroundColor3 = color
				newColor.Position = UDim2.new(0,1 + 30*column,0,20 + 23*row)
				newColor.MouseButton1Click:Connect(function()
					local curColor = customColors[i] or Color3.new(0,0,0)
					red,green,blue = curColor.r,curColor.g,curColor.b
					hue,sat,val = Color3.toHSV(curColor)
					updateColor()
				end)
				newColor.MouseButton2Click:Connect(function()
					customColors[i] = chosenColor
					newColor.BackgroundColor3 = chosenColor
				end)
				newColor.Parent = customColorsFrame
				column = column + 1
				if column == 6 then row = row + 1 column = 0 end
			end
			okButton.MouseButton1Click:Connect(function() newMt.OnSelect:Fire(chosenColor) window:Close() end)
			okButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then okButton.BackgroundTransparency = 0.4 end end)
			okButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then okButton.BackgroundTransparency = 0 end end)
			cancelButton.MouseButton1Click:Connect(function() newMt.OnCancel:Fire() window:Close() end)
			cancelButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0.4 end end)
			cancelButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0 end end)
			updateColor()
			newMt.SetColor = function(self,color)
				red,green,blue = color.r,color.g,color.b
				hue,sat,val = Color3.toHSV(color)
				updateColor()
			end
			newMt.Show = function(self)
				self.Window:Show()
			end
			return newMt
		end
		return {new = new}
	end)()
	Lib.NumberSequenceEditor = (function()
		local function new()
			local newMt = setmetatable({},{})
			newMt.OnSelect = Lib.Signal.new()
			newMt.OnCancel = Lib.Signal.new()
			newMt.OnPreview = Lib.Signal.new()
			local guiContents = create({
				{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
				{2,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Time",Parent={1},Position=UDim2.new(0,40,0,210),Size=UDim2.new(0,60,0,20),}},
				{3,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={2},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{4,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Time",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{5,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Close",Parent={1},Position=UDim2.new(1,-90,0,210),Size=UDim2.new(0,80,0,20),Text="Close",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{6,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Reset",Parent={1},Position=UDim2.new(1,-180,0,210),Size=UDim2.new(0,80,0,20),Text="Reset",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Delete",Parent={1},Position=UDim2.new(0,380,0,210),Size=UDim2.new(0,80,0,20),Text="Delete",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{8,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="NumberLineOutlines",Parent={1},Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-20,0,170),}},
				{9,"Frame",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Name="NumberLine",Parent={1},Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-20,0,170),}},
				{10,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Value",Parent={1},Position=UDim2.new(0,170,0,210),Size=UDim2.new(0,60,0,20),}},
				{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={10},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Value",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{12,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={10},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{13,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Envelope",Parent={1},Position=UDim2.new(0,300,0,210),Size=UDim2.new(0,60,0,20),}},
				{14,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={13},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{15,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={13},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Envelope",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
			})
			local window = Lib.Window.new()
			window.Resizable = false
			window:Resize(680,265)
			window:SetTitle("NumberSequence Editor")
			newMt.Window = window
			newMt.Gui = window.Gui
			for i,v in pairs(guiContents:GetChildren()) do
				v.Parent = window.GuiElems.Content
			end
			local gui = window.Gui
			local pickerGui = gui.Main
			local pickerTopBar = pickerGui.TopBar
			local pickerFrame = pickerGui.Content
			local numberLine = pickerFrame.NumberLine
			local numberLineOutlines = pickerFrame.NumberLineOutlines
			local timeBox = pickerFrame.Time.Input
			local valueBox = pickerFrame.Value.Input
			local envelopeBox = pickerFrame.Envelope.Input
			local deleteButton = pickerFrame.Delete
			local resetButton = pickerFrame.Reset
			local closeButton = pickerFrame.Close
			local topClose = pickerTopBar.Close
			local points = {{1,0,3},{8,0.05,1},{5,0.6,2},{4,0.7,4},{6,1,4}}
			local lines = {}
			local eLines = {}
			local beginPoint = points[1]
			local endPoint = points[#points]
			local currentlySelected = nil
			local currentPoint = nil
			local resetSequence = nil
			local user = game:GetService("UserInputService")
			local mouse = game:GetService("Players").LocalPlayer:GetMouse()
			for i = 2,10 do
				local newLine = Instance.new("Frame")
				newLine.BackgroundTransparency = 0.5
				newLine.BackgroundColor3 = Color3.new(96/255,96/255,96/255)
				newLine.BorderSizePixel = 0
				newLine.Size = UDim2.new(0,1,1,0)
				newLine.Position = UDim2.new((i-1)/(11-1),0,0,0)
				newLine.Parent = numberLineOutlines
			end
			for i = 2,4 do
				local newLine = Instance.new("Frame")
				newLine.BackgroundTransparency = 0.5
				newLine.BackgroundColor3 = Color3.new(96/255,96/255,96/255)
				newLine.BorderSizePixel = 0
				newLine.Size = UDim2.new(1,0,0,1)
				newLine.Position = UDim2.new(0,0,(i-1)/(5-1),0)
				newLine.Parent = numberLineOutlines
			end
			local lineTemp = Instance.new("Frame")
			lineTemp.BackgroundColor3 = Color3.new(0,0,0)
			lineTemp.BorderSizePixel = 0
			lineTemp.Size = UDim2.new(0,1,0,1)
			local sequenceLine = Instance.new("Frame")
			sequenceLine.BackgroundColor3 = Color3.new(0,0,0)
			sequenceLine.BorderSizePixel = 0
			sequenceLine.Size = UDim2.new(0,1,0,0)
			for i = 1,numberLine.AbsoluteSize.X do
				local line = sequenceLine:Clone()
				eLines[i] = line
				line.Name = "E"..tostring(i)
				line.BackgroundTransparency = 0.5
				line.BackgroundColor3 = Color3.new(199/255,44/255,28/255)
				line.Position = UDim2.new(0,i-1,0,0)
				line.Parent = numberLine
			end
			for i = 1,numberLine.AbsoluteSize.X do
				local line = sequenceLine:Clone()
				lines[i] = line
				line.Name = tostring(i)
				line.Position = UDim2.new(0,i-1,0,0)
				line.Parent = numberLine
			end
			local envelopeDrag = Instance.new("Frame")
			envelopeDrag.BackgroundTransparency = 1
			envelopeDrag.BackgroundColor3 = Color3.new(0,0,0)
			envelopeDrag.BorderSizePixel = 0
			envelopeDrag.Size = UDim2.new(0,7,0,20)
			envelopeDrag.Visible = false
			envelopeDrag.ZIndex = 2
			local envelopeDragLine = Instance.new("Frame",envelopeDrag)
			envelopeDragLine.Name = "Line"
			envelopeDragLine.BackgroundColor3 = Color3.new(0,0,0)
			envelopeDragLine.BorderSizePixel = 0
			envelopeDragLine.Position = UDim2.new(0,3,0,0)
			envelopeDragLine.Size = UDim2.new(0,1,0,20)
			envelopeDragLine.ZIndex = 2
			local envelopeDragTop,envelopeDragBottom = envelopeDrag:Clone(),envelopeDrag:Clone()
			envelopeDragTop.Parent = numberLine
			envelopeDragBottom.Parent = numberLine
			local function buildSequence()
				local newPoints = {}
				for i,v in pairs(points) do
					table.insert(newPoints,NumberSequenceKeypoint.new(v[2],v[1],v[3]))
				end
				newMt.Sequence = NumberSequence.new(newPoints)
				newMt.OnSelect:Fire(newMt.Sequence)
			end
			local function round(num,places)
				local multi = 10^places
				return math.floor(num*multi + 0.5)/multi
			end
			local function updateInputs(point)
				if point then
					currentPoint = point
					local rawT,rawV,rawE = point[2],point[1],point[3]
					timeBox.Text = round(rawT,(rawT < 0.01 and 5) or (rawT < 0.1 and 4) or 3)
					valueBox.Text = round(rawV,(rawV < 0.01 and 5) or (rawV < 0.1 and 4) or (rawV < 1 and 3) or 2)
					envelopeBox.Text = round(rawE,(rawE < 0.01 and 5) or (rawE < 0.1 and 4) or (rawV < 1 and 3) or 2)
					local envelopeDistance = numberLine.AbsoluteSize.Y*(point[3]/10)
					envelopeDragTop.Position = UDim2.new(0,point[4].Position.X.Offset-1,0,point[4].Position.Y.Offset-envelopeDistance-17)
					envelopeDragTop.Visible = true
					envelopeDragBottom.Position = UDim2.new(0,point[4].Position.X.Offset-1,0,point[4].Position.Y.Offset+envelopeDistance+2)
					envelopeDragBottom.Visible = true
				end
			end
			envelopeDragTop.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not currentPoint or Lib.CheckMouseInGui(currentPoint[4].Select) then return end
				local mouseEvent,releaseEvent
				local maxSize = numberLine.AbsoluteSize.Y
				local mouseDelta = math.abs(envelopeDragTop.AbsolutePosition.Y - mouse.Y)
				envelopeDragTop.Line.Position = UDim2.new(0,2,0,0)
				envelopeDragTop.Line.Size = UDim2.new(0,3,0,20)
				releaseEvent = user.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					mouseEvent:Disconnect()
					releaseEvent:Disconnect()
					envelopeDragTop.Line.Position = UDim2.new(0,3,0,0)
					envelopeDragTop.Line.Size = UDim2.new(0,1,0,20)
				end)
				mouseEvent = user.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						local topDiff = (currentPoint[4].AbsolutePosition.Y+2)-(mouse.Y-mouseDelta)-19
						local newEnvelope = 10*(math.max(topDiff,0)/maxSize)
						local maxEnvelope = math.min(currentPoint[1],10-currentPoint[1])
						currentPoint[3] = math.min(newEnvelope,maxEnvelope)
						newMt:Redraw()
						buildSequence()
						updateInputs(currentPoint)
					end
				end)
			end)
			envelopeDragBottom.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not currentPoint or Lib.CheckMouseInGui(currentPoint[4].Select) then return end
				local mouseEvent,releaseEvent
				local maxSize = numberLine.AbsoluteSize.Y
				local mouseDelta = math.abs(envelopeDragBottom.AbsolutePosition.Y - mouse.Y)
				envelopeDragBottom.Line.Position = UDim2.new(0,2,0,0)
				envelopeDragBottom.Line.Size = UDim2.new(0,3,0,20)
				releaseEvent = user.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					mouseEvent:Disconnect()
					releaseEvent:Disconnect()
					envelopeDragBottom.Line.Position = UDim2.new(0,3,0,0)
					envelopeDragBottom.Line.Size = UDim2.new(0,1,0,20)
				end)
				mouseEvent = user.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						local bottomDiff = (mouse.Y+(20-mouseDelta))-(currentPoint[4].AbsolutePosition.Y+2)-19
						local newEnvelope = 10*(math.max(bottomDiff,0)/maxSize)
						local maxEnvelope = math.min(currentPoint[1],10-currentPoint[1])
						currentPoint[3] = math.min(newEnvelope,maxEnvelope)
						newMt:Redraw()
						buildSequence()
						updateInputs(currentPoint)
					end
				end)
			end)
			local function placePoint(point)
				local newPoint = Instance.new("Frame")
				newPoint.Name = "Point"
				newPoint.BorderSizePixel = 0
				newPoint.Size = UDim2.new(0,5,0,5)
				newPoint.Position = UDim2.new(0,math.floor((numberLine.AbsoluteSize.X-1) * point[2])-2,0,numberLine.AbsoluteSize.Y*(10-point[1])/10-2)
				newPoint.BackgroundColor3 = Color3.new(0,0,0)
				local newSelect = Instance.new("Frame")
				newSelect.Name = "Select"
				newSelect.BackgroundTransparency = 1
				newSelect.BackgroundColor3 = Color3.new(199/255,44/255,28/255)
				newSelect.Position = UDim2.new(0,-2,0,-2)
				newSelect.Size = UDim2.new(0,9,0,9)
				newSelect.Parent = newPoint
				newPoint.Parent = numberLine
				newSelect.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						for i,v in pairs(points) do v[4].Select.BackgroundTransparency = 1 end
						newSelect.BackgroundTransparency = 0
						updateInputs(point)
					end
					if input.UserInputType == Enum.UserInputType.MouseButton1 and not currentlySelected then
						currentPoint = point
						local mouseEvent,releaseEvent
						currentlySelected = true
						newSelect.BackgroundColor3 = Color3.new(249/255,191/255,59/255)
						local oldEnvelope = point[3]
						releaseEvent = user.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							mouseEvent:Disconnect()
							releaseEvent:Disconnect()
							currentlySelected = nil
							newSelect.BackgroundColor3 = Color3.new(199/255,44/255,28/255)
						end)
						mouseEvent = user.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								local maxX = numberLine.AbsoluteSize.X-1
								local relativeX = mouse.X - numberLine.AbsolutePosition.X
								if relativeX < 0 then relativeX = 0 end
								if relativeX > maxX then relativeX = maxX end
								local maxY = numberLine.AbsoluteSize.Y-1
								local relativeY = mouse.Y - numberLine.AbsolutePosition.Y
								if relativeY < 0 then relativeY = 0 end
								if relativeY > maxY then relativeY = maxY end
								if point ~= beginPoint and point ~= endPoint then
									point[2] = relativeX/maxX
								end
								point[1] = 10-(relativeY/maxY)*10
								local maxEnvelope = math.min(point[1],10-point[1])
								point[3] = math.min(oldEnvelope,maxEnvelope)
								newMt:Redraw()
								updateInputs(point)
								for i,v in pairs(points) do v[4].Select.BackgroundTransparency = 1 end
								newSelect.BackgroundTransparency = 0
								buildSequence()
							end
						end)
					end
				end)
				return newPoint
			end
			local function placePoints()
				for i,v in pairs(points) do
					v[4] = placePoint(v)
				end
			end
			local function redraw(self)
				local numberLineSize = numberLine.AbsoluteSize
				table.sort(points,function(a,b) return a[2] < b[2] end)
				for i,v in pairs(points) do
					v[4].Position = UDim2.new(0,math.floor((numberLineSize.X-1) * v[2])-2,0,(numberLineSize.Y-1)*(10-v[1])/10-2)
				end
				lines[1].Size = UDim2.new(0,1,0,0)
				for i = 1,#points-1 do
					local fromPoint = points[i]
					local toPoint = points[i+1]
					local deltaY = toPoint[4].Position.Y.Offset-fromPoint[4].Position.Y.Offset
					local deltaX = toPoint[4].Position.X.Offset-fromPoint[4].Position.X.Offset
					local slope = deltaY/deltaX
					local fromEnvelope = fromPoint[3]
					local nextEnvelope = toPoint[3]
					local currentRise = math.abs(slope)
					local totalRise = 0
					local maxRise = math.abs(toPoint[4].Position.Y.Offset-fromPoint[4].Position.Y.Offset)
					for lineCount = math.min(fromPoint[4].Position.X.Offset+1,toPoint[4].Position.X.Offset),toPoint[4].Position.X.Offset do
						if deltaX == 0 and deltaY == 0 then return end
						local riseNow = math.floor(currentRise)
						local line = lines[lineCount+3]
						if line then
							if totalRise+riseNow > maxRise then riseNow = maxRise-totalRise end
							if math.sign(slope) == -1 then
								line.Position = UDim2.new(0,lineCount+2,0,fromPoint[4].Position.Y.Offset + -(totalRise+riseNow)+2)
							else
								line.Position = UDim2.new(0,lineCount+2,0,fromPoint[4].Position.Y.Offset + totalRise+2)
							end
							line.Size = UDim2.new(0,1,0,math.max(riseNow,1))
						end
						totalRise = totalRise + riseNow
						currentRise = currentRise - riseNow + math.abs(slope)
						local envPercent = (lineCount-fromPoint[4].Position.X.Offset)/(toPoint[4].Position.X.Offset-fromPoint[4].Position.X.Offset)
						local envLerp = fromEnvelope+(nextEnvelope-fromEnvelope)*envPercent
						local relativeSize = (envLerp/10)*numberLineSize.Y
						local line = eLines[lineCount + 3]
						if line then
							line.Position = UDim2.new(0,lineCount+2,0,lines[lineCount+3].Position.Y.Offset-math.floor(relativeSize))
							line.Size = UDim2.new(0,1,0,math.floor(relativeSize*2))
						end
					end
				end
			end
			newMt.Redraw = redraw
			local function loadSequence(self,seq)
				resetSequence = seq
				for i,v in pairs(points) do if v[4] then v[4]:Destroy() end end
				points = {}
				for i,v in pairs(seq.Keypoints) do
					local maxEnvelope = math.min(v.Value,10-v.Value)
					local newPoint = {v.Value,v.Time,math.min(v.Envelope,maxEnvelope)}
					newPoint[4] = placePoint(newPoint)
					table.insert(points,newPoint)
				end
				beginPoint = points[1]
				endPoint = points[#points]
				currentlySelected = nil
				redraw()
				envelopeDragTop.Visible = false
				envelopeDragBottom.Visible = false
			end
			newMt.SetSequence = loadSequence
			timeBox.FocusLost:Connect(function()
				local point = currentPoint
				local num = tonumber(timeBox.Text)
				if point and num and point ~= beginPoint and point ~= endPoint then
					num = math.clamp(num,0,1)
					point[2] = num
					redraw()
					buildSequence()
					updateInputs(point)
				end
			end)
			valueBox.FocusLost:Connect(function()
				local point = currentPoint
				local num = tonumber(valueBox.Text)
				if point and num then
					local oldEnvelope = point[3]
					num = math.clamp(num,0,10)
					point[1] = num
					local maxEnvelope = math.min(point[1],10-point[1])
					point[3] = math.min(oldEnvelope,maxEnvelope)
					redraw()
					buildSequence()
					updateInputs(point)
				end
			end)
			envelopeBox.FocusLost:Connect(function()
				local point = currentPoint
				local num = tonumber(envelopeBox.Text)
				if point and num then
					num = math.clamp(num,0,5)
					local maxEnvelope = math.min(point[1],10-point[1])
					point[3] = math.min(num,maxEnvelope)
					redraw()
					buildSequence()
					updateInputs(point)
				end
			end)
			local function buttonAnimations(button,inverse)
				button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then button.BackgroundTransparency = (inverse and 0.5 or 0.4) end end)
				button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then button.BackgroundTransparency = (inverse and 1 or 0) end end)
			end
			numberLine.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and #points < 20 then
					if Lib.CheckMouseInGui(envelopeDragTop) or Lib.CheckMouseInGui(envelopeDragBottom) then return end
					for i,v in pairs(points) do
						if Lib.CheckMouseInGui(v[4].Select) then return end
					end
					local maxX = numberLine.AbsoluteSize.X-1
					local relativeX = mouse.X - numberLine.AbsolutePosition.X
					if relativeX < 0 then relativeX = 0 end
					if relativeX > maxX then relativeX = maxX end
					local maxY = numberLine.AbsoluteSize.Y-1
					local relativeY = mouse.Y - numberLine.AbsolutePosition.Y
					if relativeY < 0 then relativeY = 0 end
					if relativeY > maxY then relativeY = maxY end
					local raw = relativeX/maxX
					local newPoint = {10-(relativeY/maxY)*10,raw,0}
					newPoint[4] = placePoint(newPoint)
					table.insert(points,newPoint)
					redraw()
					buildSequence()
				end
			end)
			deleteButton.MouseButton1Click:Connect(function()
				if currentPoint and currentPoint ~= beginPoint and currentPoint ~= endPoint then
					for i,v in pairs(points) do
						if v == currentPoint then
							v[4]:Destroy()
							table.remove(points,i)
							break
						end
					end
					currentlySelected = nil
					redraw()
					buildSequence()
					updateInputs(points[1])
				end
			end)
			resetButton.MouseButton1Click:Connect(function()
				if resetSequence then
					newMt:SetSequence(resetSequence)
					buildSequence()
				end
			end)
			closeButton.MouseButton1Click:Connect(function()
				window:Close()
			end)
			buttonAnimations(deleteButton)
			buttonAnimations(resetButton)
			buttonAnimations(closeButton)
			placePoints()
			redraw()
			newMt.Show = function(self)
				window:Show()
			end
			return newMt
		end
		return {new = new}
	end)()
	Lib.ColorSequenceEditor = (function()
		local function new()
			local newMt = setmetatable({},{})
			newMt.OnSelect = Lib.Signal.new()
			newMt.OnCancel = Lib.Signal.new()
			newMt.OnPreview = Lib.Signal.new()
			newMt.OnPickColor = Lib.Signal.new()
			local guiContents = create({
				{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
				{2,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="ColorLine",Parent={1},Position=UDim2.new(0,10,0,5),Size=UDim2.new(1,-20,0,70),}},
				{3,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Gradient",Parent={2},Size=UDim2.new(1,0,1,0),}},
				{4,"UIGradient",{Parent={3},}},
				{5,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Arrows",Parent={1},Position=UDim2.new(0,1,0,73),Size=UDim2.new(1,-2,0,16),}},
				{6,"Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,BorderSizePixel=0,Name="Cursor",Parent={1},Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,1,0,80),}},
				{7,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Time",Parent={1},Position=UDim2.new(0,40,0,95),Size=UDim2.new(0,100,0,20),}},
				{8,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={7},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,98,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
				{9,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={7},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Time",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{10,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="ColorBox",Parent={1},Position=UDim2.new(0,220,0,95),Size=UDim2.new(0,20,0,20),}},
				{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={10},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Color",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
				{12,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Close",Parent={1},Position=UDim2.new(1,-90,0,95),Size=UDim2.new(0,80,0,20),Text="Close",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{13,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Reset",Parent={1},Position=UDim2.new(1,-180,0,95),Size=UDim2.new(0,80,0,20),Text="Reset",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{14,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Delete",Parent={1},Position=UDim2.new(0,280,0,95),Size=UDim2.new(0,80,0,20),Text="Delete",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
				{15,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={1},Size=UDim2.new(0,16,0,16),Visible=false,}},
				{16,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,2),}},
				{17,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,7,0,5),Size=UDim2.new(0,3,0,2),}},
				{18,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,5,0,2),}},
				{19,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,5,0,9),Size=UDim2.new(0,7,0,2),}},
				{20,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,4,0,11),Size=UDim2.new(0,9,0,2),}},
			})
			local window = Lib.Window.new()
			window.Resizable = false
			window:Resize(650,150)
			window:SetTitle("ColorSequence Editor")
			newMt.Window = window
			newMt.Gui = window.Gui
			for i,v in pairs(guiContents:GetChildren()) do
				v.Parent = window.GuiElems.Content
			end
			local gui = window.Gui
			local pickerGui = gui.Main
			local pickerTopBar = pickerGui.TopBar
			local pickerFrame = pickerGui.Content
			local colorLine = pickerFrame.ColorLine
			local gradient = colorLine.Gradient.UIGradient
			local arrowFrame = pickerFrame.Arrows
			local arrow = pickerFrame.Arrow
			local cursor = pickerFrame.Cursor
			local timeBox = pickerFrame.Time.Input
			local colorBox = pickerFrame.ColorBox
			local deleteButton = pickerFrame.Delete
			local resetButton = pickerFrame.Reset
			local closeButton = pickerFrame.Close
			local topClose = pickerTopBar.Close
			local user = game:GetService("UserInputService")
			local mouse = game:GetService("Players").LocalPlayer:GetMouse()
			local colors = {{Color3.new(1,0,1),0},{Color3.new(0.2,0.9,0.2),0.2},{Color3.new(0.4,0.5,0.9),0.7},{Color3.new(0.6,1,1),1}}
			local resetSequence = nil
			local beginPoint = colors[1]
			local endPoint = colors[#colors]
			local currentlySelected = nil
			local currentPoint = nil
			local sequenceLine = Instance.new("Frame")
			sequenceLine.BorderSizePixel = 0
			sequenceLine.Size = UDim2.new(0,1,1,0)
			newMt.Sequence = ColorSequence.new(Color3.new(1,1,1))
			local function buildSequence(noupdate)
				local newPoints = {}
				table.sort(colors,function(a,b) return a[2] < b[2] end)
				for i,v in pairs(colors) do
					table.insert(newPoints,ColorSequenceKeypoint.new(v[2],v[1]))
				end
				newMt.Sequence = ColorSequence.new(newPoints)
				if not noupdate then newMt.OnSelect:Fire(newMt.Sequence) end
			end
			local function round(num,places)
				local multi = 10^places
				return math.floor(num*multi + 0.5)/multi
			end
			local function updateInputs(point)
				if point then
					currentPoint = point
					local raw = point[2]
					timeBox.Text = round(raw,(raw < 0.01 and 5) or (raw < 0.1 and 4) or 3)
					colorBox.BackgroundColor3 = point[1]
				end
			end
			local function placeArrow(ind,point)
				local newArrow = arrow:Clone()
				newArrow.Position = UDim2.new(0,ind-1,0,0)
				newArrow.Visible = true
				newArrow.Parent = arrowFrame
				newArrow.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						cursor.Visible = true
						cursor.Position = UDim2.new(0,9 + newArrow.Position.X.Offset,0,0)
					end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						updateInputs(point)
						if point == beginPoint or point == endPoint or currentlySelected then return end
						local mouseEvent,releaseEvent
						currentlySelected = true
						releaseEvent = user.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							mouseEvent:Disconnect()
							releaseEvent:Disconnect()
							currentlySelected = nil
							cursor.Visible = false
						end)
						mouseEvent = user.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								local maxSize = colorLine.AbsoluteSize.X-1
								local relativeX = mouse.X - colorLine.AbsolutePosition.X
								if relativeX < 0 then relativeX = 0 end
								if relativeX > maxSize then relativeX = maxSize end
								local raw = relativeX/maxSize
								point[2] = relativeX/maxSize
								updateInputs(point)
								cursor.Visible = true
								cursor.Position = UDim2.new(0,9 + newArrow.Position.X.Offset,0,0)
								buildSequence()
								newMt:Redraw()
							end
						end)
					end
				end)
				newArrow.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						cursor.Visible = false
					end
				end)
				return newArrow
			end
			local function placeArrows()
				for i,v in pairs(colors) do
					v[3] = placeArrow(math.floor((colorLine.AbsoluteSize.X-1) * v[2]) + 1,v)
				end
			end
			local function redraw(self)
				gradient.Color = newMt.Sequence or ColorSequence.new(Color3.new(1,1,1))
				for i = 2,#colors do
					local nextColor = colors[i]
					local endPos = math.floor((colorLine.AbsoluteSize.X-1) * nextColor[2]) + 1
					nextColor[3].Position = UDim2.new(0,endPos,0,0)
				end
			end
			newMt.Redraw = redraw
			local function loadSequence(self,seq)
				resetSequence = seq
				for i,v in pairs(colors) do if v[3] then v[3]:Destroy() end end
				colors = {}
				currentlySelected = nil
				for i,v in pairs(seq.Keypoints) do
					local newPoint = {v.Value,v.Time}
					newPoint[3] = placeArrow(v.Time,newPoint)
					table.insert(colors,newPoint)
				end
				beginPoint = colors[1]
				endPoint = colors[#colors]
				currentlySelected = nil
				updateInputs(colors[1])
				buildSequence(true)
				redraw()
			end
			newMt.SetSequence = loadSequence
			local function buttonAnimations(button,inverse)
				button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then button.BackgroundTransparency = (inverse and 0.5 or 0.4) end end)
				button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then button.BackgroundTransparency = (inverse and 1 or 0) end end)
			end
			colorLine.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and #colors < 20 then
					local maxSize = colorLine.AbsoluteSize.X-1
					local relativeX = mouse.X - colorLine.AbsolutePosition.X
					if relativeX < 0 then relativeX = 0 end
					if relativeX > maxSize then relativeX = maxSize end
					local raw = relativeX/maxSize
					local fromColor = nil
					local toColor = nil
					for i,col in pairs(colors) do
						if col[2] >= raw then
							fromColor = colors[math.max(i-1,1)]
							toColor = colors[i]
							break
						end
					end
					local lerpColor = fromColor[1]:lerp(toColor[1],(raw-fromColor[2])/(toColor[2]-fromColor[2]))
					local newPoint = {lerpColor,raw}
					newPoint[3] = placeArrow(newPoint[2],newPoint)
					table.insert(colors,newPoint)
					updateInputs(newPoint)
					buildSequence()
					redraw()
				end
			end)
			colorLine.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					local maxSize = colorLine.AbsoluteSize.X-1
					local relativeX = mouse.X - colorLine.AbsolutePosition.X
					if relativeX < 0 then relativeX = 0 end
					if relativeX > maxSize then relativeX = maxSize end
					cursor.Visible = true
					cursor.Position = UDim2.new(0,10 + relativeX,0,0)
				end
			end)
			colorLine.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					local inArrow = false
					for i,v in pairs(colors) do
						if Lib.CheckMouseInGui(v[3]) then
							inArrow = v[3]
						end
					end
					cursor.Visible = inArrow and true or false
					if inArrow then cursor.Position = UDim2.new(0,9 + inArrow.Position.X.Offset,0,0) end
				end
			end)
			timeBox:GetPropertyChangedSignal("Text"):Connect(function()
				local point = currentPoint
				local num = tonumber(timeBox.Text)
				if point and num and point ~= beginPoint and point ~= endPoint then
					num = math.clamp(num,0,1)
					point[2] = num
					buildSequence()
					redraw()
				end
			end)
			colorBox.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local editor = newMt.ColorPicker
					if not editor then
						editor = Lib.ColorPicker.new()
						editor.Window:SetTitle("ColorSequence Color Picker")
						editor.OnSelect:Connect(function(col)
							if currentPoint then
								currentPoint[1] = col
							end
							buildSequence()
							redraw()
						end)
						newMt.ColorPicker = editor
					end
					editor.Window:ShowAndFocus()
				end
			end)
			deleteButton.MouseButton1Click:Connect(function()
				if currentPoint and currentPoint ~= beginPoint and currentPoint ~= endPoint then
					for i,v in pairs(colors) do
						if v == currentPoint then
							v[3]:Destroy()
							table.remove(colors,i)
							break
						end
					end
					currentlySelected = nil
					updateInputs(colors[1])
					buildSequence()
					redraw()
				end
			end)
			resetButton.MouseButton1Click:Connect(function()
				if resetSequence then
					newMt:SetSequence(resetSequence)
				end
			end)
			closeButton.MouseButton1Click:Connect(function()
				window:Close()
			end)
			topClose.MouseButton1Click:Connect(function()
				window:Close()
			end)
			buttonAnimations(deleteButton)
			buttonAnimations(resetButton)
			buttonAnimations(closeButton)
			placeArrows()
			redraw()
			newMt.Show = function(self)
				window:Show()
			end
			return newMt
		end
		return {new = new}
	end)()
	Lib.ViewportTextBox = (function()
		local textService = game:GetService("TextService")
		local props = {
			OffsetX = 0,
			TextBox = PH,
			CursorPos = -1,
			Gui = PH,
			View = PH
		}
		local funcs = {}
		funcs.Update = function(self)
			local cursorPos = self.CursorPos or -1
			local text = self.TextBox.Text
			if text == "" then self.TextBox.Position = UDim2.new(0,0,0,0) return end
			if cursorPos == -1 then return end
			local cursorText = text:sub(1,cursorPos-1)
			local pos = nil
			local leftEnd = -self.TextBox.Position.X.Offset
			local rightEnd = leftEnd + self.View.AbsoluteSize.X
			local totalTextSize = textService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
			local cursorTextSize = textService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
			if cursorTextSize > rightEnd then
				pos = math.max(-1,cursorTextSize - self.View.AbsoluteSize.X + 2)
			elseif cursorTextSize < leftEnd then
				pos = math.max(-1,cursorTextSize-2)
			elseif totalTextSize < rightEnd then
				pos = math.max(-1,totalTextSize - self.View.AbsoluteSize.X + 2)
			end
			if pos then
				self.TextBox.Position = UDim2.new(0,-pos,0,0)
				self.TextBox.Size = UDim2.new(1,pos,1,0)
			end
		end
		funcs.GetText = function(self)
			return self.TextBox.Text
		end
		funcs.SetText = function(self,text)
			self.TextBox.Text = text
		end
		local mt = getGuiMT(props,funcs)
		local function convert(textbox)
			local obj = initObj(props,mt)
			local view = Instance.new("Frame")
			view.BackgroundTransparency = textbox.BackgroundTransparency
			view.BackgroundColor3 = textbox.BackgroundColor3
			view.BorderSizePixel = textbox.BorderSizePixel
			view.BorderColor3 = textbox.BorderColor3
			view.Position = textbox.Position
			view.Size = textbox.Size
			view.ClipsDescendants = true
			view.Name = textbox.Name
			textbox.BackgroundTransparency = 1
			textbox.Position = UDim2.new(0,0,0,0)
			textbox.Size = UDim2.new(1,0,1,0)
			textbox.TextXAlignment = Enum.TextXAlignment.Left
			textbox.Name = "Input"
			obj.TextBox = textbox
			obj.View = view
			obj.Gui = view
			textbox.Changed:Connect(function(prop)
				if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
					local cursorPos = obj.TextBox.CursorPosition
					if cursorPos ~= -1 then obj.CursorPos = cursorPos end
					obj:Update()
				end
			end)
			obj:Update()
			view.Parent = textbox.Parent
			textbox.Parent = view
			return obj
		end
		local function new()
			local textBox = Instance.new("TextBox")
			textBox.Size = UDim2.new(0,100,0,20)
			textBox.BackgroundColor3 = Settings.Theme.TextBox
			textBox.BorderColor3 = Settings.Theme.Outline3
			textBox.ClearTextOnFocus = false
			textBox.TextColor3 = Settings.Theme.Text
			textBox.Font = Enum.Font.SourceSans
			textBox.TextSize = 14
			textBox.Text = ""
			return convert(textBox)
		end
		return {new = new, convert = convert}
	end)()
	Lib.Label = (function()
		local props,funcs = {},{}
		local mt = getGuiMT(props,funcs)
		local function new()
			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextColor3 = Settings.Theme.Text
			label.TextTransparency = 0.1
			label.Size = UDim2.new(0,100,0,20)
			label.Font = Enum.Font.SourceSans
			label.TextSize = 14
			local obj = setmetatable({
				Gui = label
			},mt)
			return obj
		end
		return {new = new}
	end)()
	Lib.Frame = (function()
		local props,funcs = {},{}
		local mt = getGuiMT(props,funcs)
		local function new()
			local fr = Instance.new("Frame")
			fr.BackgroundColor3 = Settings.Theme.Main1
			fr.BorderColor3 = Settings.Theme.Outline1
			fr.Size = UDim2.new(0,50,0,50)
			local obj = setmetatable({
				Gui = fr
			},mt)
			return obj
		end
		return {new = new}
	end)()
	Lib.Button = (function()
		local props = {
			Gui = PH,
			Anim = PH,
			Disabled = false,
			OnClick = SIGNAL,
			OnDown = SIGNAL,
			OnUp = SIGNAL,
			AllowedButtons = {1}
		}
		local funcs = {}
		local tableFind = table.find
		funcs.Trigger = function(self,event,button)
			if not self.Disabled and tableFind(self.AllowedButtons,button) then
				self["On"..event]:Fire(button)
			end
		end
		funcs.SetDisabled = function(self,dis)
			self.Disabled = dis
			if dis then
				self.Anim:Disable()
				self.Gui.TextTransparency = 0.5
			else
				self.Anim.Enable()
				self.Gui.TextTransparency = 0
			end
		end
		local mt = getGuiMT(props,funcs)
		local function new()
			local b = Instance.new("TextButton")
			b.AutoButtonColor = false
			b.TextColor3 = Settings.Theme.Text
			b.TextTransparency = 0.1
			b.Size = UDim2.new(0,100,0,20)
			b.Font = Enum.Font.SourceSans
			b.TextSize = 14
			b.BackgroundColor3 = Settings.Theme.Button
			b.BorderColor3 = Settings.Theme.Outline2
			local obj = initObj(props,mt)
			obj.Gui = b
			obj.Anim = Lib.ButtonAnim(b,{Mode = 2, StartColor = Settings.Theme.Button, HoverColor = Settings.Theme.ButtonHover, PressColor = Settings.Theme.ButtonPress, OutlineColor = Settings.Theme.Outline2})
			b.MouseButton1Click:Connect(function() obj:Trigger("Click",1) end)
			b.MouseButton1Down:Connect(function() obj:Trigger("Down",1) end)
			b.MouseButton1Up:Connect(function() obj:Trigger("Up",1) end)
			b.MouseButton2Click:Connect(function() obj:Trigger("Click",2) end)
			b.MouseButton2Down:Connect(function() obj:Trigger("Down",2) end)
			b.MouseButton2Up:Connect(function() obj:Trigger("Up",2) end)
			return obj
		end
		return {new = new}
	end)()
	Lib.DropDown = (function()
		local props = {
			Gui = PH,
			Anim = PH,
			Context = PH,
			Selected = PH,
			Disabled = false,
			CanBeEmpty = true,
			Options = {},
			GuiElems = {},
			OnSelect = SIGNAL
		}
		local funcs = {}
		funcs.Update = function(self)
			local options = self.Options
			if #options > 0 then
				if not self.Selected then
					if not self.CanBeEmpty then
						self.Selected = options[1]
						self.GuiElems.Label.Text = options[1]
					else
						self.GuiElems.Label.Text = "- Select -"
					end
				else
					self.GuiElems.Label.Text = self.Selected
				end
			else
				self.GuiElems.Label.Text = "- Select -"
			end
		end
		funcs.ShowOptions = function(self)
			local context = self.Context
			context.Width = self.Gui.AbsoluteSize.X
			context.ReverseYOffset = self.Gui.AbsoluteSize.Y
			context:Show(self.Gui.AbsolutePosition.X, self.Gui.AbsolutePosition.Y + context.ReverseYOffset)
		end
		funcs.SetOptions = function(self,opts)
			self.Options = opts
			local context = self.Context
			local options = self.Options
			context:Clear()
			local onClick = function(option) self.Selected = option self.OnSelect:Fire(option) self:Update() end
			if self.CanBeEmpty then
				context:Add({Name = "- Select -", OnClick = function() self.Selected = nil self.OnSelect:Fire(nil) self:Update() end})
			end
			for i = 1,#options do
				context:Add({Name = options[i], OnClick = onClick})
			end
			self:Update()
		end
		funcs.SetSelected = function(self,opt)
			self.Selected = type(opt) == "number" and self.Options[opt] or opt
			self:Update()
		end
		local mt = getGuiMT(props,funcs)
		local function new()
			local f = Instance.new("TextButton")
			f.AutoButtonColor = false
			f.Text = ""
			f.Size = UDim2.new(0,100,0,20)
			f.BackgroundColor3 = Settings.Theme.TextBox
			f.BorderColor3 = Settings.Theme.Outline3
			local label = Lib.Label.new()
			label.Position = UDim2.new(0,2,0,0)
			label.Size = UDim2.new(1,-22,1,0)
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.Parent = f
			local arrow = create({
				{1,"Frame",{BackgroundTransparency=1,Name="EnumArrow",Position=UDim2.new(1,-16,0,2),Size=UDim2.new(0,16,0,16),}},
				{2,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,8,0,9),Size=UDim2.new(0,1,0,1),}},
				{3,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,7,0,8),Size=UDim2.new(0,3,0,1),}},
				{4,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,5,0,1),}},
			})
			arrow.Parent = f
			local obj = initObj(props,mt)
			obj.Gui = f
			obj.Anim = Lib.ButtonAnim(f,{Mode = 2, StartColor = Settings.Theme.TextBox, LerpTo = Settings.Theme.Button, LerpDelta = 0.15})
			obj.Context = Lib.ContextMenu.new()
			obj.Context.Iconless = true
			obj.Context.MaxHeight = 200
			obj.Selected = nil
			obj.GuiElems = {Label = label}
			f.MouseButton1Down:Connect(function() obj:ShowOptions() end)
			obj:Update()
			return obj
		end
		return {new = new}
	end)()
	Lib.ClickSystem = (function()
		local props = {
			LastItem = PH,
			OnDown = SIGNAL,
			OnRelease = SIGNAL,
			AllowedButtons = {1},
			Combo = 0,
			MaxCombo = 2,
			ComboTime = 0.5,
			Items = {},
			ItemCons = {},
			ClickId = -1,
			LastButton = ""
		}
		local funcs = {}
		local tostring = tostring
		local disconnect = function(con)
			local pos = table.find(con.Signal.Connections,con)
			if pos then table.remove(con.Signal.Connections,pos) end
		end
		funcs.Trigger = function(self,item,button)
			if table.find(self.AllowedButtons,button) then
				if self.LastButton ~= button or self.LastItem ~= item or self.Combo == self.MaxCombo or tick() - self.ClickId > self.ComboTime then
					self.Combo = 0
					self.LastButton = button
					self.LastItem = item
				end
				self.Combo = self.Combo + 1
				self.ClickId = tick()
				local release
				release = service.UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType["MouseButton"..button] then
						release:Disconnect()
						if Lib.CheckMouseInGui(item) and self.LastButton == button and self.LastItem == item then
							self["OnRelease"]:Fire(item,self.Combo,button)
						end
					end
				end)
				self["OnDown"]:Fire(item,self.Combo,button)
			end
		end
		funcs.Add = function(self,item)
			if table.find(self.Items,item) then return end
			local cons = {}
			cons[1] = item.MouseButton1Down:Connect(function() self:Trigger(item,1) end)
			cons[2] = item.MouseButton2Down:Connect(function() self:Trigger(item,2) end)
			self.ItemCons[item] = cons
			self.Items[#self.Items+1] = item
		end
		funcs.Remove = function(self,item)
			local ind = table.find(self.Items,item)
			if not ind then return end
			for i,v in pairs(self.ItemCons[item]) do
				v:Disconnect()
			end
			self.ItemCons[item] = nil
			table.remove(self.Items,ind)
		end
		local mt = {__index = funcs}
		local function new()
			local obj = initObj(props,mt)
			return obj
		end
		return {new = new}
	end)()
	Lib.BatchProcessor = (function()
		local props = {
			Queue = {},
			Processing = false,
			Callback = nil,
			OnProcess = SIGNAL,
		}
		local funcs = {}
		funcs.Add = function(self, item)
			self.Queue[#self.Queue + 1] = item
			if not self.Processing then
				self.Processing = true
				task.defer(function()
					local batch = self.Queue
					self.Queue = {}
					self.Processing = false
					if self.Callback then
						self.Callback(batch)
					end
					self["OnProcess"]:Fire(batch)
				end)
			end
		end
		funcs.SetCallback = function(self, cb)
			self.Callback = cb
		end
		funcs.Clear = function(self)
			self.Queue = {}
		end
		local mt = {__index = funcs}
		local function new(callback)
			local obj = initObj(props, mt)
			obj.Callback = callback
			return obj
		end
		return {new = new}
	end)()
	Lib.InstancesEqual = function(a, b)
		if a == b then return true end
		local s, result = pcall(function() return a == b end)
		return s and result
	end
	Lib.GetThemeColor = function(key)
		if Theme and Theme.Get then
			return Theme.Get(key)
		end
		if Settings and Settings.Theme then
			return Settings.Theme[key]
		end
		return Color3.fromRGB(50, 50, 50)
	end
	return Lib
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["Explorer"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	Theme = data.Theme
	Store = data.Store
	Keybinds = data.Keybinds
	Notifications = data.Notifications
	Env = data.Env
	API = data.API
	RMD = data.RMD
	env = data.Env or data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain(appTable)
end
local function main()
	local Explorer = {}
	local tree = {}
	local nodeMap = {}
	local selection = {}
	local expanded = {}
	local bookmarks = {}
	local nilInstances = {}
	local selectionHistory = {}
	local searchQuery = ""
	local searchResults = {}
	local searchActive = false
	local ROW_HEIGHT = 20
	local INDENT_WIDTH = 18
	local ICON_SIZE = 16
	local MAX_VISIBLE_ROWS = 50
	local BATCH_INTERVAL = 0
	local connections = {}
	local descendantAddedBatch
	local descendantRemovedBatch
	local Node = {}
	Node.__index = Node
	function Node.new(instance, parent, depth)
		local self = setmetatable({}, Node)
		self.Instance = instance
		self.Parent = parent
		self.Depth = depth or 0
		self.Children = {}
		self.Expanded = false
		self.Visible = true
		self.Selected = false
		self.Bookmarked = false
		self.GuiRow = nil
		self.ClassName = ""
		self.Name = ""
		pcall(function()
			self.ClassName = instance.ClassName
			self.Name = instance.Name
		end)
		return self
	end
	function Node:Refresh()
		pcall(function()
			self.ClassName = self.Instance.ClassName
			self.Name = self.Instance.Name
		end)
	end
	function Node:GetIcon()
		if Main.MiscIcons then
			return nil
		end
		return nil
	end
	local function buildNode(instance, parentNode, depth)
		if nodeMap[instance] then return nodeMap[instance] end
		local node = Node.new(instance, parentNode, depth)
		nodeMap[instance] = node
		if parentNode then
			parentNode.Children[#parentNode.Children + 1] = node
		end
		return node
	end
	local function removeNode(instance)
		local node = nodeMap[instance]
		if not node then return end
		if node.Parent then
			local children = node.Parent.Children
			for i = #children, 1, -1 do
				if children[i] == node then
					table.remove(children, i)
					break
				end
			end
		end
		local function removeRecursive(n)
			for _, child in ipairs(n.Children) do
				removeRecursive(child)
			end
			nodeMap[n.Instance] = nil
		end
		removeRecursive(node)
	end
	local function buildTree()
		tree = {}
		nodeMap = {}
		local rootServices = {
			game:GetService("Workspace"),
			game:GetService("Players"),
			game:GetService("Lighting"),
			game:GetService("ReplicatedFirst"),
			game:GetService("ReplicatedStorage"),
			game:GetService("ServerScriptService"),
			game:GetService("ServerStorage"),
			game:GetService("StarterGui"),
			game:GetService("StarterPack"),
			game:GetService("StarterPlayer"),
			game:GetService("SoundService"),
			game:GetService("Chat"),
			game:GetService("LocalizationService"),
			game:GetService("TestService"),
		}
		local rootNode = Node.new(game, nil, 0)
		rootNode.Name = "game"
		rootNode.ClassName = "DataModel"
		rootNode.Expanded = true
		nodeMap[game] = rootNode
		for _, svc in ipairs(rootServices) do
			if svc then
				local svcNode = buildNode(svc, rootNode, 1)
				svcNode.Expanded = false
			end
		end
	end
	local function expandNode(node)
		if node.Expanded then return end
		node.Expanded = true
		expanded[node.Instance] = true
		local s, children = pcall(function() return node.Instance:GetChildren() end)
		if not s then return end
		node.Children = {}
		for _, child in ipairs(children) do
			buildNode(child, node, node.Depth + 1)
		end
		table.sort(node.Children, function(a, b)
			if a.ClassName == b.ClassName then
				return a.Name < b.Name
			end
			return a.ClassName < b.ClassName
		end)
	end
	local function collapseNode(node)
		node.Expanded = false
		expanded[node.Instance] = nil
	end
	local function toggleNode(node)
		if node.Expanded then
			collapseNode(node)
		else
			expandNode(node)
		end
		Explorer.Render()
	end
	local flatList = {}
	local function buildFlatList()
		flatList = {}
		local function recurse(node)
			if not node.Visible then return end
			flatList[#flatList + 1] = node
			if node.Expanded then
				for _, child in ipairs(node.Children) do
					recurse(child)
				end
			end
		end
		local rootNode = nodeMap[game]
		if rootNode then
			for _, child in ipairs(rootNode.Children) do
				recurse(child)
			end
		end
	end
	local function clearSelection()
		for _, inst in ipairs(selection) do
			local node = nodeMap[inst]
			if node then node.Selected = false end
		end
		selection = {}
		Store.SetSelection({})
	end
	local function selectNode(node, additive, range)
		if not node then return end
		if not additive and not range then
			clearSelection()
		end
		if range and #selection > 0 then
			local lastIdx, thisIdx
			for i, n in ipairs(flatList) do
				if n.Instance == selection[#selection] then lastIdx = i end
				if n == node then thisIdx = i end
			end
			if lastIdx and thisIdx then
				local startIdx = math.min(lastIdx, thisIdx)
				local endIdx = math.max(lastIdx, thisIdx)
				for i = startIdx, endIdx do
					local n = flatList[i]
					if n and not n.Selected then
						n.Selected = true
						selection[#selection + 1] = n.Instance
					end
				end
			end
		else
			if additive and node.Selected then
				node.Selected = false
				for i, inst in ipairs(selection) do
					if inst == node.Instance then
						table.remove(selection, i)
						break
					end
				end
			else
				node.Selected = true
				selection[#selection + 1] = node.Instance
			end
		end
		Store.SetSelection(selection)
		selectionHistory[#selectionHistory + 1] = {unpack(selection)}
		Explorer.Render()
	end
	local function selectInstance(instance)
		local node = nodeMap[instance]
		if not node then
			local ancestry = {}
			local current = instance
			pcall(function()
				while current and current ~= game do
					current = current.Parent
					if current then ancestry[#ancestry + 1] = current end
				end
			end)
			for i = #ancestry, 1, -1 do
				local ancestorNode = nodeMap[ancestry[i]]
				if ancestorNode then
					expandNode(ancestorNode)
				end
			end
			node = nodeMap[instance]
		end
		if node then
			clearSelection()
			selectNode(node)
			Explorer.ScrollToNode(node)
		end
	end
	local function addBookmark(instance)
		if table.find(bookmarks, instance) then return end
		bookmarks[#bookmarks + 1] = instance
		local node = nodeMap[instance]
		if node then node.Bookmarked = true end
		Explorer.SaveBookmarks()
		if Notifications then Notifications.Info("Bookmarked: " .. tostring(instance)) end
	end
	local function removeBookmark(instance)
		local idx = table.find(bookmarks, instance)
		if idx then
			table.remove(bookmarks, idx)
			local node = nodeMap[instance]
			if node then node.Bookmarked = false end
			Explorer.SaveBookmarks()
		end
	end
	local function toggleBookmark(instance)
		if table.find(bookmarks, instance) then
			removeBookmark(instance)
		else
			addBookmark(instance)
		end
	end
	Explorer.SaveBookmarks = function()
		if not Env or not Env.Capabilities.Filesystem then return end
		local paths = {}
		for _, inst in ipairs(bookmarks) do
			pcall(function() paths[#paths + 1] = inst:GetFullName() end)
		end
		local json = service.HttpService:JSONEncode(paths)
		pcall(Env.writefile, "deux/saved/bookmarks/" .. tostring(game.PlaceId) .. ".json", json)
	end
	Explorer.LoadBookmarks = function()
		if not Env or not Env.Capabilities.Filesystem then return end
		local s, raw = pcall(Env.readfile, "deux/saved/bookmarks/" .. tostring(game.PlaceId) .. ".json")
		if not s or not raw then return end
		local s2, paths = pcall(service.HttpService.JSONDecode, service.HttpService, raw)
		if not s2 or type(paths) ~= "table" then return end
		for _, path in ipairs(paths) do
			local parts = string.split(path, ".")
			local current = game
			for i = 2, #parts do
				local s3, child = pcall(function() return current:FindFirstChild(parts[i]) end)
				if s3 and child then
					current = child
				else
					current = nil
					break
				end
			end
			if current and current ~= game then
				bookmarks[#bookmarks + 1] = current
				local node = nodeMap[current]
				if node then node.Bookmarked = true end
			end
		end
	end
	local SearchFilters = {}
	SearchFilters.class = function(inst, value)
		local s, cn = pcall(function() return inst.ClassName end)
		if not s then return false end
		return string.lower(cn) == string.lower(value) or inst:IsA(value)
	end
	SearchFilters.name = function(inst, value)
		local s, name = pcall(function() return inst.Name end)
		if not s then return false end
		local s2, match = pcall(string.find, string.lower(name), string.lower(value))
		return s2 and match ~= nil
	end
	SearchFilters.tag = function(inst, value)
		local s, tags = pcall(function() return game:GetService("CollectionService"):GetTags(inst) end)
		if not s then return false end
		for _, tag in ipairs(tags) do
			if string.lower(tag) == string.lower(value) then return true end
		end
		return false
	end
	SearchFilters.prop = function(inst, value)
		local propName, propVal = string.match(value, "^(.-)=(.+)$")
		if not propName then return false end
		local s, actualVal = pcall(function() return inst[propName] end)
		if not s then return false end
		return tostring(actualVal) == propVal
	end
	SearchFilters["nil"] = function(inst, value)
		local s, parent = pcall(function() return inst.Parent end)
		return s and parent == nil
	end
	SearchFilters.service = function(inst, value)
		local s, fullName = pcall(function() return inst:GetFullName() end)
		if not s then return false end
		local parts = string.split(fullName, ".")
		return parts[2] and string.lower(parts[2]) == string.lower(value)
	end
	local function parseSearchQuery(query)
		local filters = {}
		for key, value in string.gmatch(query, "(%w+):([^%s]+)") do
			filters[#filters + 1] = {Type = key, Value = value}
		end
		local remaining = string.gsub(query, "%w+:[^%s]+", ""):match("^%s*(.-)%s*$")
		if remaining and remaining ~= "" then
			filters[#filters + 1] = {Type = "name", Value = remaining}
		end
		return filters
	end
	local function matchesSearch(instance, filters)
		for _, filter in ipairs(filters) do
			local handler = SearchFilters[filter.Type]
			if handler then
				if not handler(instance, filter.Value) then
					return false
				end
			end
		end
		return true
	end
	local function performSearch(query)
		searchQuery = query
		if not query or query == "" then
			searchActive = false
			searchResults = {}
			Explorer.Render()
			return
		end
		searchActive = true
		local filters = parseSearchQuery(query)
		searchResults = {}
		local maxResults = Settings.Get("Explorer.MaxSearchResults") or 500
		local function searchIn(parent)
			if #searchResults >= maxResults then return end
			local s, children = pcall(function() return parent:GetDescendants() end)
			if not s then return end
			for _, desc in ipairs(children) do
				if #searchResults >= maxResults then break end
				if matchesSearch(desc, filters) then
					searchResults[#searchResults + 1] = desc
				end
			end
		end
		searchIn(game)
		Explorer.Render()
	end
	local clickToSelectEnabled = true
	local selectionBox = nil
	local guiSelectionOutline = nil
	local function setupClickToSelect()
		if not Settings.Get("Explorer.ClickToSelect3D") then return end
		local mouse = Main.Mouse
		local uis = service.UserInputService
		connections[#connections + 1] = uis.InputBegan:Connect(function(input, processed)
			if processed then return end
			if not clickToSelectEnabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			if not uis:IsKeyDown(Enum.KeyCode.LeftAlt) then return end
			local target = mouse.Target
			if not target then return end
			local additive = uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl)
			local node = nodeMap[target]
			if not node then
				selectInstance(target)
			else
				selectNode(node, additive)
			end
			if Settings.Get("Explorer.PartSelectionBox") and target:IsA("BasePart") then
				if selectionBox then selectionBox:Destroy() end
				selectionBox = Instance.new("SelectionBox")
				selectionBox.Adornee = target
				selectionBox.Color3 = Theme.Get("Accent") or Color3.fromRGB(0, 120, 215)
				selectionBox.LineThickness = 0.03
				selectionBox.SurfaceTransparency = 0.8
				selectionBox.Parent = Env.getGuiParent()
				Store.Subscribe("selection", function(newSel)
					if not table.find(newSel, target) then
						if selectionBox then selectionBox:Destroy(); selectionBox = nil end
					end
				end)
			end
		end)
		connections[#connections + 1] = uis.InputBegan:Connect(function(input, processed)
			if processed then return end
			if not clickToSelectEnabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			if not uis:IsKeyDown(Enum.KeyCode.LeftAlt) then return end
			if not Settings.Get("Explorer.ClickToSelectGUI") then return end
			local mousePos = uis:GetMouseLocation()
			local guis = plr.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
			if #guis > 0 then
				local topGui = guis[1]
				local additive = uis:IsKeyDown(Enum.KeyCode.LeftControl)
				selectInstance(topGui)
			end
		end)
	end
	local function refreshNilInstances()
		if not Env or not Env.getnilinstances then
			nilInstances = {}
			return
		end
		local s, insts = pcall(Env.getnilinstances)
		if s and type(insts) == "table" then
			nilInstances = insts
		end
	end
	local function setupDescendantListeners()
		descendantAddedBatch = Lib.BatchProcessor.new(function(batch)
			for _, instance in ipairs(batch) do
				local parentNode = nodeMap[instance.Parent]
				if parentNode and parentNode.Expanded then
					buildNode(instance, parentNode, parentNode.Depth + 1)
				end
			end
			if #batch > 0 then
				Explorer.Render()
			end
		end)
		descendantRemovedBatch = Lib.BatchProcessor.new(function(batch)
			for _, instance in ipairs(batch) do
				removeNode(instance)
				for i = #selection, 1, -1 do
					if selection[i] == instance then
						table.remove(selection, i)
					end
				end
			end
			if #batch > 0 then
				Store.SetSelection(selection)
				Explorer.Render()
			end
		end)
		connections[#connections + 1] = game.DescendantAdded:Connect(function(instance)
			descendantAddedBatch:Add(instance)
		end)
		connections[#connections + 1] = game.DescendantRemoving:Connect(function(instance)
			descendantRemovedBatch:Add(instance)
		end)
	end
	local function createContextMenu(node)
		if not Lib.ContextMenu then return end
		local inst = node.Instance
		local menu = Lib.ContextMenu.new()
		menu:Add({Name = "Copy Path", OnClick = function()
			local s, path = pcall(function() return inst:GetFullName() end)
			if s and Env.setclipboard then
				Env.setclipboard('game.' .. path)
				if Notifications then Notifications.Info("Path copied") end
			end
		end})
		menu:Add({Name = "Copy as Lua", OnClick = function()
			local s, path = pcall(function() return inst:GetFullName() end)
			if s and Env.setclipboard then
				local parts = string.split(path, ".")
				local lua = 'game:GetService("' .. parts[2] .. '")'
				for i = 3, #parts do
					lua = lua .. ':FindFirstChild("' .. parts[i] .. '")'
				end
				Env.setclipboard(lua)
				if Notifications then Notifications.Info("Lua path copied") end
			end
		end})
		menu:AddSeparator()
		local s1, isPart = pcall(function() return inst:IsA("BasePart") end)
		if s1 and isPart then
			menu:Add({Name = "Teleport To", OnClick = function()
				pcall(function()
					local char = plr.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						char.HumanoidRootPart.CFrame = inst.CFrame + Vector3.new(0, 5, 0)
					end
				end)
			end})
		end
		local s2, isScript = pcall(function() return inst:IsA("LuaSourceContainer") end)
		if s2 and isScript then
			menu:Add({Name = "View Script", OnClick = function()
				Store.Emit("open_script", inst)
			end})
		end
		menu:AddSeparator()
		local isBookmarked = table.find(bookmarks, inst) ~= nil
		menu:Add({Name = isBookmarked and "Remove Bookmark" or "Add Bookmark", OnClick = function()
			toggleBookmark(inst)
		end})
		menu:Add({Name = "Select Children", OnClick = function()
			local s3, children = pcall(function() return inst:GetChildren() end)
			if s3 then
				for _, child in ipairs(children) do
					local childNode = nodeMap[child]
					if childNode then selectNode(childNode, true) end
				end
			end
		end})
		menu:AddSeparator()
		menu:Add({Name = "Delete", OnClick = function()
			pcall(function() inst:Destroy() end)
		end})
		menu:Add({Name = "Clone", OnClick = function()
			pcall(function()
				local clone = inst:Clone()
				if clone then clone.Parent = inst.Parent end
			end)
		end})
		menu:Add({Name = "Rename", OnClick = function()
			Explorer.StartRename(node)
		end})
		menu:AddSeparator()
		menu:Add({Name = "Save Instance", OnClick = function()
			Store.Emit("save_instance", inst)
		end})
		menu:Add({Name = "Explore Data", OnClick = function()
			Store.Emit("explore_data", inst)
		end})
		return menu
	end
	local scrollFrame
	local rowPool = {}
	local visibleRows = {}
	local scrollOffset = 0
	Explorer.Render = function()
		if not scrollFrame then return end
		buildFlatList()
		local displayList = searchActive and searchResults or flatList
		local totalRows = #displayList
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalRows * ROW_HEIGHT)
		local viewHeight = scrollFrame.AbsoluteSize.Y
		local startIdx = math.floor(scrollFrame.CanvasPosition.Y / ROW_HEIGHT) + 1
		local endIdx = math.min(startIdx + math.ceil(viewHeight / ROW_HEIGHT) + 1, totalRows)
		for _, row in ipairs(visibleRows) do
			row.Visible = false
		end
		visibleRows = {}
		for i = startIdx, endIdx do
			local item = displayList[i]
			if not item then continue end
			local row = Explorer.GetOrCreateRow(i - startIdx + 1)
			local instance = searchActive and item or item.Instance
			local node = searchActive and nodeMap[item] or item
			local depth = node and node.Depth or 0
			local isSelected = node and node.Selected or false
			local isBookmarked = node and node.Bookmarked or false
			row.Position = UDim2.new(0, 0, 0, (i - 1) * ROW_HEIGHT)
			row.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
			row.Visible = true
			local indent = depth * INDENT_WIDTH
			row.NameLabel.Position = UDim2.new(0, indent + ICON_SIZE + 4, 0, 0)
			local name, className = "", ""
			pcall(function()
				name = instance.Name
				className = instance.ClassName
			end)
			row.NameLabel.Text = name
			row.ClassLabel.Text = className
			row.ClassLabel.Position = UDim2.new(0, indent + ICON_SIZE + 4 + row.NameLabel.TextBounds.X + 6, 0, 0)
			local bgColor = isSelected and (Theme.Get("ListSelection") or Color3.fromRGB(11, 90, 175)) or Color3.fromRGB(0, 0, 0)
			row.BackgroundColor3 = bgColor
			row.BackgroundTransparency = isSelected and 0 or 1
			if row.BookmarkDot then
				row.BookmarkDot.Visible = isBookmarked
			end
			local hasChildren = false
			if node then
				pcall(function() hasChildren = #instance:GetChildren() > 0 end)
			end
			if row.Arrow then
				row.Arrow.Visible = hasChildren
				row.Arrow.Rotation = (node and node.Expanded) and 90 or 0
				row.Arrow.Position = UDim2.new(0, indent, 0, 2)
			end
			row._Node = node
			row._Instance = instance
			visibleRows[#visibleRows + 1] = row
		end
	end
	Explorer.GetOrCreateRow = function(poolIdx)
		if rowPool[poolIdx] then return rowPool[poolIdx] end
		local row = createSimple("TextButton", {
			Name = "Row" .. poolIdx,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
			Text = "",
			AutoButtonColor = false,
			Parent = scrollFrame,
		})
		local arrow = createSimple("TextLabel", {
			Name = "Arrow",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 0, 0, 2),
			Text = "▶",
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextSize = 8,
			Font = Enum.Font.Gotham,
			Parent = row,
		})
		local nameLabel = createSimple("TextLabel", {
			Name = "NameLabel",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -60, 1, 0),
			Position = UDim2.new(0, 20, 0, 0),
			Text = "",
			TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255),
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		local classLabel = createSimple("TextLabel", {
			Name = "ClassLabel",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 100, 1, 0),
			Position = UDim2.new(0, 120, 0, 0),
			Text = "",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(120, 120, 120),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		local bookmarkDot = createSimple("Frame", {
			Name = "BookmarkDot",
			BackgroundColor3 = Color3.fromRGB(255, 200, 50),
			Size = UDim2.new(0, 4, 0, 4),
			Position = UDim2.new(1, -8, 0.5, -2),
			Visible = false,
			Parent = row,
		})
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = bookmarkDot
		row.Arrow = arrow
		row.NameLabel = nameLabel
		row.ClassLabel = classLabel
		row.BookmarkDot = bookmarkDot
		row.MouseButton1Click:Connect(function()
			local node = row._Node
			if not node then return end
			local uis = service.UserInputService
			local shift = uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift)
			local ctrl = uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl)
			selectNode(node, ctrl, shift)
		end)
		row.MouseButton1Down:Connect(function()
		end)
		row.MouseButton2Click:Connect(function()
			local node = row._Node
			if not node then return end
			if not node.Selected then selectNode(node) end
			local menu = createContextMenu(node)
			if menu then menu:Show() end
		end)
		arrow.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local node = row._Node
				if node then toggleNode(node) end
			end
		end)
		rowPool[poolIdx] = row
		return row
	end
	Explorer.ScrollToNode = function(node)
		if not scrollFrame then return end
		buildFlatList()
		for i, n in ipairs(flatList) do
			if n == node then
				local targetY = (i - 1) * ROW_HEIGHT
				scrollFrame.CanvasPosition = Vector2.new(0, math.max(0, targetY - scrollFrame.AbsoluteSize.Y / 2))
				break
			end
		end
	end
	Explorer.StartRename = function(node)
		if not node or not node.GuiRow then return end
		if Notifications then Notifications.Info("Rename not yet implemented in-line") end
	end
	Explorer.Init = function()
		Explorer.Window = Lib.Window.new()
		Explorer.Window:SetTitle("Explorer")
		Explorer.Window:SetResizable(true)
		Explorer.Window:SetSize(300, 500)
		local content = Explorer.Window:GetContentFrame()
		local searchBar = createSimple("Frame", {
			Name = "SearchBar",
			BackgroundColor3 = Theme.Get("TextBox") or Color3.fromRGB(38, 38, 38),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 26),
			Parent = content,
		})
		local searchCorner = Instance.new("UICorner")
		searchCorner.CornerRadius = UDim.new(0, 4)
		searchCorner.Parent = searchBar
		local searchInput = createSimple("TextBox", {
			Name = "Input",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			Text = "",
			PlaceholderText = "Search... (class:Part name:Door tag:NPC)",
			PlaceholderColor3 = Theme.Get("PlaceholderText") or Color3.fromRGB(100, 100, 100),
			TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = searchBar,
		})
		local searchDebounce
		searchInput:GetPropertyChangedSignal("Text"):Connect(function()
			if searchDebounce then task.cancel(searchDebounce) end
			searchDebounce = task.delay(0.3, function()
				performSearch(searchInput.Text)
			end)
		end)
		local toolbar = createSimple("Frame", {
			Name = "Toolbar",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 0, 28),
			Parent = content,
		})
		local bookmarkBtn = createSimple("TextButton", {
			Name = "Bookmarks",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 60, 1, 0),
			Text = "★ Pins",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			Parent = toolbar,
		})
		local nilBtn = createSimple("TextButton", {
			Name = "NilInstances",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 80, 1, 0),
			Position = UDim2.new(0, 62, 0, 0),
			Text = "∅ Nil Insts",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			Parent = toolbar,
		})
		local refreshBtn = createSimple("TextButton", {
			Name = "Refresh",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 50, 1, 0),
			Position = UDim2.new(1, -50, 0, 0),
			Text = "⟳",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180),
			TextSize = 14,
			Font = Enum.Font.Gotham,
			Parent = toolbar,
		})
		scrollFrame = createSimple("ScrollingFrame", {
			Name = "TreeScroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, -52),
			Position = UDim2.new(0, 0, 0, 52),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Get("ScrollBar") or Color3.fromRGB(80, 80, 80),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			Parent = content,
		})
		scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			Explorer.Render()
		end)
		scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Explorer.Render()
		end)
		bookmarkBtn.MouseButton1Click:Connect(function()
			searchActive = true
			searchResults = bookmarks
			Explorer.Render()
		end)
		nilBtn.MouseButton1Click:Connect(function()
			refreshNilInstances()
			searchActive = true
			searchResults = nilInstances
			Explorer.Render()
		end)
		refreshBtn.MouseButton1Click:Connect(function()
			buildTree()
			Explorer.Render()
			if Notifications then Notifications.Info("Explorer refreshed") end
		end)
		buildTree()
		local wsNode = nodeMap[game:GetService("Workspace")]
		if wsNode then expandNode(wsNode) end
		local plrNode = nodeMap[game:GetService("Players")]
		if plrNode then expandNode(plrNode) end
		setupDescendantListeners()
		setupClickToSelect()
		Explorer.LoadBookmarks()
		Keybinds.Register("Explorer.Delete", {
			Keys = {Enum.KeyCode.Delete},
			Category = "Explorer",
			Description = "Delete selected instances",
			Callback = function()
				for _, inst in ipairs(selection) do
					pcall(function() inst:Destroy() end)
				end
				clearSelection()
			end
		})
		Keybinds.Register("Explorer.CopyPath", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.C},
			Category = "Explorer",
			Description = "Copy path of selected instance",
			Callback = function()
				if #selection > 0 and Env.setclipboard then
					local s, path = pcall(function() return selection[1]:GetFullName() end)
					if s then Env.setclipboard("game." .. path) end
				end
			end
		})
		Keybinds.Register("Explorer.Bookmark", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.B},
			Category = "Explorer",
			Description = "Toggle bookmark on selected",
			Callback = function()
				for _, inst in ipairs(selection) do
					toggleBookmark(inst)
				end
			end
		})
		Store.On("navigate", function(instance)
			if instance then selectInstance(instance) end
		end)
		Explorer.Render()
	end
	Explorer.GetSelection = function() return selection end
	Explorer.SetSelection = function(insts)
		clearSelection()
		for _, inst in ipairs(insts) do
			local node = nodeMap[inst]
			if node then selectNode(node, true) end
		end
	end
	Explorer.SelectInstance = selectInstance
	Explorer.PerformSearch = performSearch
	Explorer.GetBookmarks = function() return bookmarks end
	Explorer.AddBookmark = addBookmark
	Explorer.RemoveBookmark = removeBookmark
	Explorer.GetNilInstances = function() return nilInstances end
	Explorer.RefreshNilInstances = refreshNilInstances
	Explorer.RegisterSearchFilter = function(name, handler)
		SearchFilters[name] = handler
	end
	Explorer.Destroy = function()
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		connections = {}
		if selectionBox then selectionBox:Destroy() end
	end
	return Explorer
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["Properties"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	Theme = data.Theme
	Store = data.Store
	Keybinds = data.Keybinds
	Notifications = data.Notifications
	Env = data.Env
	API = data.API
	RMD = data.RMD
	env = data.Env or data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local function main()
	local Properties = {}
	local currentInstances = {}
	local propertyRows = {}
	local categoryStates = {}
	local searchFilter = ""
	local showDeprecated = false
	local showHidden = false
	local showAttributes = true
	local showTags = true
	local showConnections = true
	local propertyHistory = {}
	local MAX_HISTORY = 50
	local ROW_HEIGHT = 24
	local connections = {}
	local scrollFrame
	local changeListeners = {}
	local function valueToLua(value)
		local t = typeof(value)
		if t == "string" then
			return string.format("%q", value)
		elseif t == "number" then
			return tostring(value)
		elseif t == "boolean" then
			return tostring(value)
		elseif t == "nil" then
			return "nil"
		elseif t == "Vector3" then
			return string.format("Vector3.new(%s, %s, %s)", value.X, value.Y, value.Z)
		elseif t == "Vector2" then
			return string.format("Vector2.new(%s, %s)", value.X, value.Y)
		elseif t == "CFrame" then
			local c = {value:GetComponents()}
			return "CFrame.new(" .. table.concat(c, ", ") .. ")"
		elseif t == "Color3" then
			return string.format("Color3.fromRGB(%d, %d, %d)", math.round(value.R*255), math.round(value.G*255), math.round(value.B*255))
		elseif t == "BrickColor" then
			return string.format('BrickColor.new("%s")', value.Name)
		elseif t == "UDim" then
			return string.format("UDim.new(%s, %s)", value.Scale, value.Offset)
		elseif t == "UDim2" then
			return string.format("UDim2.new(%s, %s, %s, %s)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
		elseif t == "Rect" then
			return string.format("Rect.new(%s, %s, %s, %s)", value.Min.X, value.Min.Y, value.Max.X, value.Max.Y)
		elseif t == "NumberRange" then
			return string.format("NumberRange.new(%s, %s)", value.Min, value.Max)
		elseif t == "Ray" then
			return string.format("Ray.new(Vector3.new(%s, %s, %s), Vector3.new(%s, %s, %s))", value.Origin.X, value.Origin.Y, value.Origin.Z, value.Direction.X, value.Direction.Y, value.Direction.Z)
		elseif t == "Instance" then
			local s, path = pcall(function() return value:GetFullName() end)
			if s then return 'game.' .. path end
			return "nil --[[Instance]]"
		elseif t == "EnumItem" then
			return tostring(value)
		elseif t == "NumberSequence" then
			local points = {}
			for _, kp in ipairs(value.Keypoints) do
				points[#points + 1] = string.format("NumberSequenceKeypoint.new(%s, %s, %s)", kp.Time, kp.Value, kp.Envelope)
			end
			return "NumberSequence.new({" .. table.concat(points, ", ") .. "})"
		elseif t == "ColorSequence" then
			local points = {}
			for _, kp in ipairs(value.Keypoints) do
				points[#points + 1] = string.format("ColorSequenceKeypoint.new(%s, Color3.fromRGB(%d, %d, %d))", kp.Time, math.round(kp.Value.R*255), math.round(kp.Value.G*255), math.round(kp.Value.B*255))
			end
			return "ColorSequence.new({" .. table.concat(points, ", ") .. "})"
		elseif t == "Font" then
			return string.format('Font.new("%s", Enum.FontWeight.%s, Enum.FontStyle.%s)', value.Family, value.Weight.Name, value.Style.Name)
		else
			return tostring(value)
		end
	end
	local function valueToDisplay(value)
		local t = typeof(value)
		if t == "Color3" then
			return string.format("[%d, %d, %d]", math.round(value.R*255), math.round(value.G*255), math.round(value.B*255))
		elseif t == "Instance" then
			local s, name = pcall(function() return value.Name end)
			return s and name or "nil"
		elseif t == "string" then
			if #value > 50 then return value:sub(1, 47) .. "..." end
			return value
		else
			local str = tostring(value)
			if #str > 60 then return str:sub(1, 57) .. "..." end
			return str
		end
	end
	local function getProperties(instance)
		if not instance or not API then return {} end
		local className
		pcall(function() className = instance.ClassName end)
		if not className then return {} end
		local props = API.GetMember(className, "Properties")
		if not props then return {} end
		local filtered = {}
		for _, prop in ipairs(props) do
			local dominated = false
			if not showDeprecated and prop.Tags and prop.Tags.Deprecated then dominated = true end
			if not showHidden and prop.Tags and (prop.Tags.Hidden or prop.Tags.NotScriptable) then dominated = true end
			if not dominated then
				if searchFilter == "" or string.find(string.lower(prop.Name), string.lower(searchFilter), 1, true) then
					filtered[#filtered + 1] = prop
				end
			end
		end
		return filtered
	end
	local function getPropertyValue(instance, propName)
		local s, val = pcall(function() return instance[propName] end)
		if s then return val, true end
		if Env and Env.gethiddenproperty then
			local s2, val2 = pcall(Env.gethiddenproperty, instance, propName)
			if s2 then return val2, true end
		end
		return nil, false
	end
	local function setPropertyValue(instance, propName, value)
		local oldVal = getPropertyValue(instance, propName)
		local s, err = pcall(function() instance[propName] = value end)
		if not s then
			if Env and Env.sethiddenproperty then
				s, err = pcall(Env.sethiddenproperty, instance, propName, value)
			end
		end
		if s then
			propertyHistory[#propertyHistory + 1] = {
				Instance = instance,
				Property = propName,
				OldValue = oldVal,
				NewValue = value,
				Time = tick()
			}
			if #propertyHistory > MAX_HISTORY then table.remove(propertyHistory, 1) end
		else
			if Notifications then Notifications.Error("Failed to set " .. propName .. ": " .. tostring(err)) end
		end
		return s
	end
	local function getMultiValue(propName)
		if #currentInstances == 0 then return nil, false, false end
		if #currentInstances == 1 then
			local val, ok = getPropertyValue(currentInstances[1], propName)
			return val, ok, false
		end
		local firstVal, firstOk = getPropertyValue(currentInstances[1], propName)
		if not firstOk then return nil, false, true end
		local maxCheck = Settings.Get("Properties.MaxConflictCheck") or 50
		local conflict = false
		for i = 2, math.min(#currentInstances, maxCheck) do
			local val, ok = getPropertyValue(currentInstances[i], propName)
			if not ok or val ~= firstVal then
				conflict = true
				break
			end
		end
		return firstVal, true, conflict
	end
	local function setMultiValue(propName, value)
		for _, inst in ipairs(currentInstances) do
			setPropertyValue(inst, propName, value)
		end
		Properties.Render()
	end
	local function getAttributes(instance)
		local s, attrs = pcall(function() return instance:GetAttributes() end)
		if not s then return {} end
		local list = {}
		for name, value in pairs(attrs) do
			if searchFilter == "" or string.find(string.lower(name), string.lower(searchFilter), 1, true) then
				list[#list + 1] = {Name = name, Value = value, Type = typeof(value)}
			end
		end
		table.sort(list, function(a, b) return a.Name < b.Name end)
		return list
	end
	local function setAttribute(instance, name, value)
		pcall(function() instance:SetAttribute(name, value) end)
	end
	local function deleteAttribute(instance, name)
		pcall(function() instance:SetAttribute(name, nil) end)
	end
	local function renameAttribute(instance, oldName, newName)
		local val = nil
		pcall(function() val = instance:GetAttribute(oldName) end)
		if val ~= nil then
			pcall(function()
				instance:SetAttribute(oldName, nil)
				instance:SetAttribute(newName, val)
			end)
		end
	end
	local CollectionService
	local function getTags(instance)
		if not CollectionService then
			CollectionService = service.CollectionService
		end
		local s, tags = pcall(function() return CollectionService:GetTags(instance) end)
		if not s then return {} end
		local filtered = {}
		for _, tag in ipairs(tags) do
			if searchFilter == "" or string.find(string.lower(tag), string.lower(searchFilter), 1, true) then
				filtered[#filtered + 1] = tag
			end
		end
		table.sort(filtered)
		return filtered
	end
	local function addTag(instance, tag)
		if not CollectionService then CollectionService = service.CollectionService end
		pcall(function() CollectionService:AddTag(instance, tag) end)
	end
	local function removeTag(instance, tag)
		if not CollectionService then CollectionService = service.CollectionService end
		pcall(function() CollectionService:RemoveTag(instance, tag) end)
	end
	local function getSignalConnections(instance, eventName)
		if not Env or not Env.getconnections then return {} end
		local s, signal = pcall(function() return instance[eventName] end)
		if not s or not signal then return {} end
		local s2, conns = pcall(Env.getconnections, signal)
		if not s2 then return {} end
		local list = {}
		for _, conn in ipairs(conns) do
			list[#list + 1] = {
				Function = conn.Function,
				State = conn.State or "Active",
				Enable = conn.Enable,
				Disable = conn.Disable,
				Fire = conn.Fire,
			}
		end
		return list
	end
	local function undoLast()
		if #propertyHistory == 0 then return end
		local entry = propertyHistory[#propertyHistory]
		table.remove(propertyHistory, #propertyHistory)
		pcall(function() entry.Instance[entry.Property] = entry.OldValue end)
		Properties.Render()
		if Notifications then Notifications.Info("Undid: " .. entry.Property) end
	end
	local rowPool = {}
	local visibleRows = {}
	local headerLabel, instanceCountLabel
	Properties.Render = function()
		if not scrollFrame then return end
		for _, row in ipairs(visibleRows) do
			row.Visible = false
		end
		visibleRows = {}
		if #currentInstances == 0 then
			if headerLabel then headerLabel.Text = "No selection" end
			if instanceCountLabel then instanceCountLabel.Text = "" end
			return
		end
		local primary = currentInstances[1]
		local className = ""
		pcall(function() className = primary.ClassName end)
		if headerLabel then headerLabel.Text = className end
		if instanceCountLabel then
			instanceCountLabel.Text = #currentInstances > 1 and ("(" .. #currentInstances .. " selected)") or ""
		end
		local displayRows = {}
		local props = getProperties(primary)
		local categories = {}
		local categoryMap = {}
		for _, prop in ipairs(props) do
			local cat = prop.Category or "Other"
			if not categoryMap[cat] then
				categoryMap[cat] = {}
				categories[#categories + 1] = cat
			end
			categoryMap[cat][#categoryMap[cat] + 1] = prop
		end
		if API and API.CategoryOrder then
			table.sort(categories, function(a, b)
				local oa = API.CategoryOrder[a] or 9999
				local ob = API.CategoryOrder[b] or 9999
				return oa < ob
			end)
		end
		for _, cat in ipairs(categories) do
			displayRows[#displayRows + 1] = {Type = "category", Name = cat, Expanded = categoryStates[cat] ~= false}
			if categoryStates[cat] ~= false then
				for _, prop in ipairs(categoryMap[cat]) do
					local val, ok, conflict = getMultiValue(prop.Name)
					displayRows[#displayRows + 1] = {
						Type = "property",
						Name = prop.Name,
						Value = val,
						ValueOk = ok,
						Conflict = conflict,
						ValueType = prop.ValueType,
						Tags = prop.Tags,
						Security = prop.Security,
					}
				end
			end
		end
		if showAttributes then
			local attrs = getAttributes(primary)
			if #attrs > 0 then
				displayRows[#displayRows + 1] = {Type = "category", Name = "Attributes", Expanded = categoryStates["Attributes"] ~= false}
				if categoryStates["Attributes"] ~= false then
					for _, attr in ipairs(attrs) do
						displayRows[#displayRows + 1] = {
							Type = "attribute",
							Name = attr.Name,
							Value = attr.Value,
							ValueOk = true,
							Conflict = false,
							AttrType = attr.Type,
						}
					end
				end
			end
		end
		if showTags then
			local tags = getTags(primary)
			displayRows[#displayRows + 1] = {Type = "category", Name = "Tags", Expanded = categoryStates["Tags"] ~= false}
			if categoryStates["Tags"] ~= false then
				for _, tag in ipairs(tags) do
					displayRows[#displayRows + 1] = {Type = "tag", Name = tag}
				end
				displayRows[#displayRows + 1] = {Type = "tag_add"}
			end
		end
		if showConnections and Env and Env.Capabilities.Connections then
			local events = API.GetMember(className, "Events")
			if events and #events > 0 then
				local hasAny = false
				local connRows = {}
				for _, event in ipairs(events) do
					local conns = getSignalConnections(primary, event.Name)
					if #conns > 0 then
						hasAny = true
						connRows[#connRows + 1] = {Type = "event_header", Name = event.Name, Count = #conns}
					end
				end
				if hasAny then
					displayRows[#displayRows + 1] = {Type = "category", Name = "Connections", Expanded = categoryStates["Connections"] ~= false}
					if categoryStates["Connections"] ~= false then
						for _, cr in ipairs(connRows) do
							displayRows[#displayRows + 1] = cr
						end
					end
				end
			end
		end
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #displayRows * ROW_HEIGHT)
		local viewHeight = scrollFrame.AbsoluteSize.Y
		local startIdx = math.floor(scrollFrame.CanvasPosition.Y / ROW_HEIGHT) + 1
		local endIdx = math.min(startIdx + math.ceil(viewHeight / ROW_HEIGHT) + 1, #displayRows)
		for i = startIdx, endIdx do
			local data = displayRows[i]
			if not data then continue end
			local poolIdx = i - startIdx + 1
			local row = Properties.GetOrCreateRow(poolIdx)
			row.Position = UDim2.new(0, 0, 0, (i - 1) * ROW_HEIGHT)
			row.Visible = true
			if data.Type == "category" then
				row.NameLabel.Text = (data.Expanded and "▼ " or "▶ ") .. data.Name
				row.NameLabel.Font = Enum.Font.GothamBold
				row.NameLabel.TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255)
				row.NameLabel.Size = UDim2.new(1, -8, 1, 0)
				row.ValueLabel.Text = ""
				row.BackgroundColor3 = Theme.Get("Main2") or Color3.fromRGB(45, 45, 45)
				row.BackgroundTransparency = 0
				row.ColorSwatch.Visible = false
				row._Data = data
			elseif data.Type == "property" or data.Type == "attribute" then
				row.NameLabel.Text = data.Name
				row.NameLabel.Font = Enum.Font.Gotham
				row.NameLabel.TextColor3 = data.Tags and data.Tags.Deprecated and (Theme.Get("PlaceholderText") or Color3.fromRGB(100,100,100)) or (Theme.Get("Text") or Color3.fromRGB(255,255,255))
				row.NameLabel.Size = UDim2.new(0.5, -4, 1, 0)
				if data.Conflict then
					row.ValueLabel.Text = "<multiple>"
					row.ValueLabel.TextColor3 = Theme.Get("Warning") or Color3.fromRGB(255, 200, 50)
				elseif data.ValueOk then
					row.ValueLabel.Text = valueToDisplay(data.Value)
					row.ValueLabel.TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180)
				else
					row.ValueLabel.Text = "⚠ unreadable"
					row.ValueLabel.TextColor3 = Theme.Get("Important") or Color3.fromRGB(255, 80, 80)
				end
				row.BackgroundTransparency = 1
				local isColor = data.ValueOk and typeof(data.Value) == "Color3"
				row.ColorSwatch.Visible = isColor
				if isColor then
					row.ColorSwatch.BackgroundColor3 = data.Value
				end
				row._Data = data
			elseif data.Type == "tag" then
				row.NameLabel.Text = "  🏷 " .. data.Name
				row.NameLabel.Font = Enum.Font.Gotham
				row.NameLabel.TextColor3 = Theme.Get("Accent") or Color3.fromRGB(0, 120, 215)
				row.NameLabel.Size = UDim2.new(1, -30, 1, 0)
				row.ValueLabel.Text = "✕"
				row.ValueLabel.TextColor3 = Theme.Get("Important") or Color3.fromRGB(255, 80, 80)
				row.BackgroundTransparency = 1
				row.ColorSwatch.Visible = false
				row._Data = data
			elseif data.Type == "tag_add" then
				row.NameLabel.Text = "  + Add Tag..."
				row.NameLabel.Font = Enum.Font.Gotham
				row.NameLabel.TextColor3 = Theme.Get("PlaceholderText") or Color3.fromRGB(100, 100, 100)
				row.NameLabel.Size = UDim2.new(1, 0, 1, 0)
				row.ValueLabel.Text = ""
				row.BackgroundTransparency = 1
				row.ColorSwatch.Visible = false
				row._Data = data
			elseif data.Type == "event_header" then
				row.NameLabel.Text = "  ⚡ " .. data.Name
				row.NameLabel.Font = Enum.Font.Gotham
				row.NameLabel.TextColor3 = Theme.Get("Success") or Color3.fromRGB(80, 200, 120)
				row.NameLabel.Size = UDim2.new(0.7, 0, 1, 0)
				row.ValueLabel.Text = tostring(data.Count) .. " conn"
				row.ValueLabel.TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180)
				row.BackgroundTransparency = 1
				row.ColorSwatch.Visible = false
				row._Data = data
			end
			visibleRows[#visibleRows + 1] = row
		end
	end
	Properties.GetOrCreateRow = function(poolIdx)
		if rowPool[poolIdx] then return rowPool[poolIdx] end
		local row = createSimple("TextButton", {
			Name = "PropRow" .. poolIdx,
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
			Text = "",
			AutoButtonColor = false,
			Parent = scrollFrame,
		})
		local nameLabel = createSimple("TextLabel", {
			Name = "NameLabel",
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -4, 1, 0),
			Position = UDim2.new(0, 6, 0, 0),
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		local valueLabel = createSimple("TextLabel", {
			Name = "ValueLabel",
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -16, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Text = "",
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		local colorSwatch = createSimple("Frame", {
			Name = "ColorSwatch",
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0, 14, 0, 14),
			Position = UDim2.new(1, -18, 0, 5),
			Visible = false,
			Parent = row,
		})
		local swatchCorner = Instance.new("UICorner")
		swatchCorner.CornerRadius = UDim.new(0, 3)
		swatchCorner.Parent = colorSwatch
		row.NameLabel = nameLabel
		row.ValueLabel = valueLabel
		row.ColorSwatch = colorSwatch
		row._Data = nil
		row.MouseButton1Click:Connect(function()
			local data = row._Data
			if not data then return end
			if data.Type == "category" then
				categoryStates[data.Name] = not (categoryStates[data.Name] ~= false)
				Properties.Render()
			elseif data.Type == "tag" then
			elseif data.Type == "tag_add" then
				if Notifications then Notifications.Info("Tag add: use right-click menu") end
			end
		end)
		row.MouseButton2Click:Connect(function()
			local data = row._Data
			if not data then return end
			Properties.ShowContextMenu(data)
		end)
		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if row._Data and row._Data.Type ~= "category" then
					row.BackgroundColor3 = Theme.Get("Highlight") or Color3.fromRGB(75, 75, 75)
					row.BackgroundTransparency = 0.5
				end
			end
		end)
		row.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if row._Data and row._Data.Type ~= "category" then
					row.BackgroundTransparency = 1
				end
			end
		end)
		rowPool[poolIdx] = row
		return row
	end
	Properties.ShowContextMenu = function(data)
		if not Lib.ContextMenu then return end
		local menu = Lib.ContextMenu.new()
		if data.Type == "property" or data.Type == "attribute" then
			menu:Add({Name = "Copy Value (Display)", OnClick = function()
				if Env.setclipboard then
					Env.setclipboard(valueToDisplay(data.Value))
					if Notifications then Notifications.Info("Copied display value") end
				end
			end})
			menu:Add({Name = "Copy Value (Lua)", OnClick = function()
				if Env.setclipboard then
					Env.setclipboard(valueToLua(data.Value))
					if Notifications then Notifications.Info("Copied as Lua") end
				end
			end})
			menu:Add({Name = "Copy Property Path", OnClick = function()
				if Env.setclipboard and #currentInstances > 0 then
					local inst = currentInstances[1]
					local s, path = pcall(function() return inst:GetFullName() end)
					if s then
						Env.setclipboard("game." .. path .. "." .. data.Name)
						if Notifications then Notifications.Info("Copied property path") end
					end
				end
			end})
			menu:AddSeparator()
			if data.ValueOk and typeof(data.Value) == "Instance" then
				menu:Add({Name = "Select in Explorer", OnClick = function()
					Store.Emit("navigate", data.Value)
				end})
				menu:AddSeparator()
			end
			menu:Add({Name = "View in API Reference", OnClick = function()
				Store.Emit("open_api_ref", data.Name)
			end})
		end
		if data.Type == "attribute" then
			menu:AddSeparator()
			menu:Add({Name = "Delete Attribute", OnClick = function()
				for _, inst in ipairs(currentInstances) do
					deleteAttribute(inst, data.Name)
				end
				Properties.Render()
				if Notifications then Notifications.Success("Deleted attribute: " .. data.Name) end
			end})
			menu:Add({Name = "Rename Attribute", OnClick = function()
				if Notifications then Notifications.Info("Rename via terminal: attr rename " .. data.Name .. " newName") end
			end})
		end
		if data.Type == "tag" then
			menu:Add({Name = "Remove Tag", OnClick = function()
				for _, inst in ipairs(currentInstances) do
					removeTag(inst, data.Name)
				end
				Properties.Render()
				if Notifications then Notifications.Success("Removed tag: " .. data.Name) end
			end})
			menu:Add({Name = "Select All With Tag", OnClick = function()
				if not CollectionService then CollectionService = service.CollectionService end
				local tagged = CollectionService:GetTagged(data.Name)
				Store.SetSelection(tagged)
				if Notifications then Notifications.Info("Selected " .. #tagged .. " instances with tag: " .. data.Name) end
			end})
		end
		menu:Show()
	end
	local function onSelectionChanged(newSelection)
		for _, conn in ipairs(changeListeners) do
			conn:Disconnect()
		end
		changeListeners = {}
		currentInstances = newSelection or {}
		for _, inst in ipairs(currentInstances) do
			local s, conn = pcall(function()
				return inst.Changed:Connect(function()
					Properties.Render()
				end)
			end)
			if s and conn then
				changeListeners[#changeListeners + 1] = conn
			end
		end
		Properties.Render()
	end
	Properties.Init = function()
		Properties.Window = Lib.Window.new()
		Properties.Window:SetTitle("Properties")
		Properties.Window:SetResizable(true)
		Properties.Window:SetSize(300, 500)
		local content = Properties.Window:GetContentFrame()
		headerLabel = createSimple("TextLabel", {
			Name = "Header",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -80, 0, 22),
			Position = UDim2.new(0, 6, 0, 2),
			Text = "No selection",
			TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = content,
		})
		instanceCountLabel = createSimple("TextLabel", {
			Name = "Count",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 70, 0, 22),
			Position = UDim2.new(1, -76, 0, 2),
			Text = "",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(150, 150, 150),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = content,
		})
		local searchBar = createSimple("Frame", {
			Name = "SearchBar",
			BackgroundColor3 = Theme.Get("TextBox") or Color3.fromRGB(38, 38, 38),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 0, 24),
			Parent = content,
		})
		local searchInput = createSimple("TextBox", {
			Name = "Input",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 6, 0, 0),
			Text = "",
			PlaceholderText = "Filter properties...",
			PlaceholderColor3 = Theme.Get("PlaceholderText") or Color3.fromRGB(100, 100, 100),
			TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = searchBar,
		})
		searchInput:GetPropertyChangedSignal("Text"):Connect(function()
			searchFilter = searchInput.Text
			Properties.Render()
		end)
		local toggleBar = createSimple("Frame", {
			Name = "Toggles",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.new(0, 0, 0, 47),
			Parent = content,
		})
		local function makeToggle(name, x, getter, setter)
			local btn = createSimple("TextButton", {
				Name = name,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 70, 1, 0),
				Position = UDim2.new(0, x, 0, 0),
				Text = (getter() and "● " or "○ ") .. name,
				TextColor3 = getter() and (Theme.Get("Accent") or Color3.fromRGB(0,120,215)) or (Theme.Get("TextDim") or Color3.fromRGB(120,120,120)),
				TextSize = 10,
				Font = Enum.Font.Gotham,
				Parent = toggleBar,
			})
			btn.MouseButton1Click:Connect(function()
				setter(not getter())
				btn.Text = (getter() and "● " or "○ ") .. name
				btn.TextColor3 = getter() and (Theme.Get("Accent") or Color3.fromRGB(0,120,215)) or (Theme.Get("TextDim") or Color3.fromRGB(120,120,120))
				Properties.Render()
			end)
		end
		makeToggle("Depr", 0, function() return showDeprecated end, function(v) showDeprecated = v end)
		makeToggle("Hidden", 72, function() return showHidden end, function(v) showHidden = v end)
		makeToggle("Attrs", 144, function() return showAttributes end, function(v) showAttributes = v end)
		makeToggle("Tags", 216, function() return showTags end, function(v) showTags = v end)
		scrollFrame = createSimple("ScrollingFrame", {
			Name = "PropScroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, -68),
			Position = UDim2.new(0, 0, 0, 68),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Get("ScrollBar") or Color3.fromRGB(80, 80, 80),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = content,
		})
		scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			Properties.Render()
		end)
		scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Properties.Render()
		end)
		Store.Subscribe("selection", function(newSel)
			onSelectionChanged(newSel)
		end)
		showDeprecated = Settings.Get("Properties.ShowDeprecated") or false
		showHidden = Settings.Get("Properties.ShowHidden") or false
		showAttributes = Settings.Get("Properties.ShowAttributes") ~= false
		showTags = Settings.Get("Properties.ShowTags") ~= false
		showConnections = Settings.Get("Properties.ShowConnections") ~= false
		Keybinds.Register("Properties.Undo", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.Z},
			Category = "Properties",
			Description = "Undo last property change",
			Callback = undoLast,
		})
		Keybinds.Register("Properties.CopyValue", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.LeftShift, Enum.KeyCode.C},
			Category = "Properties",
			Description = "Copy selected property as Lua",
			Callback = function()
				if Notifications then Notifications.Info("Use right-click to copy property values") end
			end,
		})
	end
	Properties.GetCurrentInstances = function() return currentInstances end
	Properties.SetPropertyValue = setPropertyValue
	Properties.GetPropertyValue = getPropertyValue
	Properties.AddTag = addTag
	Properties.RemoveTag = removeTag
	Properties.SetAttribute = setAttribute
	Properties.DeleteAttribute = deleteAttribute
	Properties.RenameAttribute = renameAttribute
	Properties.UndoLast = undoLast
	Properties.ValueToLua = valueToLua
	Properties.ValueToDisplay = valueToDisplay
	Properties.Destroy = function()
		for _, conn in ipairs(connections) do conn:Disconnect() end
		for _, conn in ipairs(changeListeners) do conn:Disconnect() end
		connections = {}
		changeListeners = {}
	end
	return Properties
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["ScriptEditor"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	Theme = data.Theme
	Store = data.Store
	Keybinds = data.Keybinds
	Notifications = data.Notifications
	Env = data.Env
	API = data.API
	RMD = data.RMD
	env = data.Env or data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local function main()
	local ScriptEditor = {}
	local tabs = {}
	local activeTabIdx = 0
	local connections = {}
	local tabBar, codeFrame, statusBar, findBar
	local lineNumbers, codeInput, codeDisplay
	local Keywords = {
		["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
		["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
		["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
		["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
		["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
		["while"] = true, ["continue"] = true, ["type"] = true, ["export"] = true,
		["typeof"] = true,
	}
	local BuiltIns = {
		["print"] = true, ["warn"] = true, ["error"] = true, ["assert"] = true,
		["pcall"] = true, ["xpcall"] = true, ["select"] = true, ["next"] = true,
		["pairs"] = true, ["ipairs"] = true, ["unpack"] = true, ["rawget"] = true,
		["rawset"] = true, ["rawequal"] = true, ["rawlen"] = true,
		["setmetatable"] = true, ["getmetatable"] = true, ["tonumber"] = true,
		["tostring"] = true, ["type"] = true, ["typeof"] = true,
		["require"] = true, ["loadstring"] = true, ["newproxy"] = true,
		["coroutine"] = true, ["string"] = true, ["table"] = true, ["math"] = true,
		["os"] = true, ["debug"] = true, ["bit32"] = true, ["utf8"] = true,
		["task"] = true, ["buffer"] = true,
		["game"] = true, ["workspace"] = true, ["script"] = true, ["Instance"] = true,
		["Vector3"] = true, ["Vector2"] = true, ["CFrame"] = true, ["Color3"] = true,
		["UDim2"] = true, ["UDim"] = true, ["Enum"] = true, ["Ray"] = true,
		["Rect"] = true, ["Region3"] = true, ["TweenInfo"] = true,
		["NumberSequence"] = true, ["ColorSequence"] = true, ["NumberRange"] = true,
		["BrickColor"] = true, ["Random"] = true, ["tick"] = true, ["time"] = true,
		["wait"] = true, ["delay"] = true, ["spawn"] = true,
	}
	local function escapeRichText(str)
		return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
	end
	local function colorTag(color, text)
		local r, g, b = math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255)
		return string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text)
	end
	local function highlightLine(line, syntaxColors)
		local result = {}
		local i = 1
		local len = #line
		while i <= len do
			local char = line:sub(i, i)
			if char == "-" and line:sub(i + 1, i + 1) == "-" then
				local rest = escapeRichText(line:sub(i))
				result[#result + 1] = colorTag(syntaxColors.Comment, rest)
				break
			end
			if char == '"' then
				local j = i + 1
				while j <= len do
					local c = line:sub(j, j)
					if c == "\\" then j = j + 2
					elseif c == '"' then j = j + 1; break
					else j = j + 1 end
				end
				result[#result + 1] = colorTag(syntaxColors.String, escapeRichText(line:sub(i, j - 1)))
				i = j
				continue
			end
			if char == "'" then
				local j = i + 1
				while j <= len do
					local c = line:sub(j, j)
					if c == "\\" then j = j + 2
					elseif c == "'" then j = j + 1; break
					else j = j + 1 end
				end
				result[#result + 1] = colorTag(syntaxColors.String, escapeRichText(line:sub(i, j - 1)))
				i = j
				continue
			end
			if char:match("%d") or (char == "." and line:sub(i + 1, i + 1):match("%d")) then
				local j = i
				if line:sub(i, i + 1) == "0x" or line:sub(i, i + 1) == "0X" then
					j = i + 2
					while j <= len and line:sub(j, j):match("[%da-fA-F_]") do j = j + 1 end
				else
					while j <= len and line:sub(j, j):match("[%d_]") do j = j + 1 end
					if j <= len and line:sub(j, j) == "." then
						j = j + 1
						while j <= len and line:sub(j, j):match("[%d_]") do j = j + 1 end
					end
					if j <= len and line:sub(j, j):match("[eE]") then
						j = j + 1
						if j <= len and line:sub(j, j):match("[%+%-]") then j = j + 1 end
						while j <= len and line:sub(j, j):match("[%d_]") do j = j + 1 end
					end
				end
				result[#result + 1] = colorTag(syntaxColors.Number, escapeRichText(line:sub(i, j - 1)))
				i = j
				continue
			end
			if char:match("[%a_]") then
				local j = i + 1
				while j <= len and line:sub(j, j):match("[%w_]") do j = j + 1 end
				local word = line:sub(i, j - 1)
				local escaped = escapeRichText(word)
				if Keywords[word] then
					if word == "true" or word == "false" then
						result[#result + 1] = colorTag(syntaxColors.Bool, escaped)
					elseif word == "nil" then
						result[#result + 1] = colorTag(syntaxColors.Nil, escaped)
					elseif word == "self" then
						result[#result + 1] = colorTag(syntaxColors.Self, escaped)
					elseif word == "function" or word == "local" then
						result[#result + 1] = colorTag(syntaxColors.Keyword, escaped)
					else
						result[#result + 1] = colorTag(syntaxColors.Keyword, escaped)
					end
				elseif BuiltIns[word] then
					result[#result + 1] = colorTag(syntaxColors.BuiltIn, escaped)
				else
					local nextChar = line:sub(j, j)
					if nextChar == "(" then
						result[#result + 1] = colorTag(syntaxColors.FunctionName, escaped)
					else
						result[#result + 1] = colorTag(syntaxColors.Text, escaped)
					end
				end
				i = j
				continue
			end
			if char:match("[%(%)%{%}%[%]]") then
				result[#result + 1] = colorTag(syntaxColors.Bracket, escapeRichText(char))
				i = i + 1
				continue
			end
			if char:match("[%+%-%*/%^%%=~<>%.#,;:]") then
				result[#result + 1] = colorTag(syntaxColors.Operator, escapeRichText(char))
				i = i + 1
				continue
			end
			result[#result + 1] = escapeRichText(char)
			i = i + 1
		end
		return table.concat(result)
	end
	local function highlightSource(source)
		local syntaxColors = Theme.GetCurrent().Syntax
		local lines = string.split(source, "\n")
		local highlighted = {}
		for idx, line in ipairs(lines) do
			highlighted[#highlighted + 1] = highlightLine(line, syntaxColors)
		end
		return table.concat(highlighted, "\n")
	end
	local function getActiveTab()
		return tabs[activeTabIdx]
	end
	local function addTab(scriptInst, source, name)
		for i, tab in ipairs(tabs) do
			if tab.Script == scriptInst then
				activeTabIdx = i
				ScriptEditor.RenderTabs()
				ScriptEditor.RenderCode()
				return
			end
		end
		local tab = {
			Script = scriptInst,
			Source = source or "",
			Name = name or "Untitled",
			Modified = false,
			DecompileTime = nil,
			CursorLine = 1,
			CursorCol = 1,
			ScrollY = 0,
		}
		tabs[#tabs + 1] = tab
		activeTabIdx = #tabs
		ScriptEditor.RenderTabs()
		ScriptEditor.RenderCode()
	end
	local function closeTab(idx)
		if idx < 1 or idx > #tabs then return end
		table.remove(tabs, idx)
		if activeTabIdx > #tabs then activeTabIdx = #tabs end
		if activeTabIdx < 1 then activeTabIdx = 0 end
		ScriptEditor.RenderTabs()
		ScriptEditor.RenderCode()
	end
	local function switchTab(idx)
		if idx < 1 or idx > #tabs then return end
		local current = getActiveTab()
		if current and codeInput then
			current.CursorLine = ScriptEditor.GetCursorLine()
			current.ScrollY = codeFrame and codeFrame.CanvasPosition.Y or 0
		end
		activeTabIdx = idx
		ScriptEditor.RenderTabs()
		ScriptEditor.RenderCode()
	end
	local function decompileScript(scriptInst)
		if not Env or not Env.Capabilities.Decompile then
			if Notifications then Notifications.Error("Decompile unavailable on " .. (Env and Env.ExecutorName or "this executor")) end
			return "-- Decompile not available"
		end
		local startTime = tick()
		local s, source = pcall(Env.decompile, scriptInst)
		local elapsed = math.round((tick() - startTime) * 1000)
		if s and source then
			return source, elapsed
		else
			local errMsg = tostring(source)
			if Notifications then Notifications.Warning("Decompile failed: " .. errMsg:sub(1, 80)) end
			return "-- Decompile failed: " .. errMsg, elapsed
		end
	end
	local function getBytecode(scriptInst)
		if not Env or not Env.getscriptbytecode then
			return "-- Bytecode unavailable"
		end
		local s, bc = pcall(Env.getscriptbytecode, scriptInst)
		if s then return bc end
		return "-- Failed to get bytecode: " .. tostring(bc)
	end
	ScriptEditor.OpenScript = function(scriptInst)
		if not scriptInst then return end
		local name = ""
		pcall(function() name = scriptInst.Name end)
		local source
		local s, src = pcall(function() return scriptInst.Source end)
		if s and src and src ~= "" then
			source = src
			addTab(scriptInst, source, name)
			return
		end
		if Settings.Get("ScriptEditor.AutoDecompile") ~= false then
			local decompiled, elapsed = decompileScript(scriptInst)
			addTab(scriptInst, decompiled, name)
			local tab = getActiveTab()
			if tab then tab.DecompileTime = elapsed end
			ScriptEditor.UpdateStatusBar()
		else
			addTab(scriptInst, "-- Press Ctrl+D to decompile", name)
		end
	end
	local findState = {
		Query = "",
		Replace = "",
		UseRegex = false,
		CaseSensitive = false,
		Matches = {},
		CurrentMatch = 0,
	}
	local function performFind(query, source, useRegex, caseSensitive)
		local matches = {}
		if not query or query == "" then return matches end
		local searchSource = caseSensitive and source or string.lower(source)
		local searchQuery = caseSensitive and query or string.lower(query)
		if useRegex then
			local start = 1
			while true do
				local s, e = string.find(searchSource, searchQuery, start)
				if not s then break end
				matches[#matches + 1] = {Start = s, End = e}
				start = e + 1
				if start > #searchSource then break end
			end
		else
			local start = 1
			while true do
				local s = string.find(searchSource, searchQuery, start, true)
				if not s then break end
				matches[#matches + 1] = {Start = s, End = s + #query - 1}
				start = s + 1
			end
		end
		return matches
	end
	local function replaceAll(query, replacement, source, useRegex, caseSensitive)
		if useRegex then
			if caseSensitive then
				return string.gsub(source, query, replacement)
			else
				return string.gsub(source, query, replacement)
			end
		else
			local result = source
			if not caseSensitive then
				local lower = string.lower(source)
				local lowerQuery = string.lower(query)
				local parts = {}
				local pos = 1
				while true do
					local s = string.find(lower, lowerQuery, pos, true)
					if not s then
						parts[#parts + 1] = source:sub(pos)
						break
					end
					parts[#parts + 1] = source:sub(pos, s - 1)
					parts[#parts + 1] = replacement
					pos = s + #query
				end
				result = table.concat(parts)
			else
				result = source:gsub(query, replacement)
			end
			return result
		end
	end
	local function runCurrentBuffer()
		local tab = getActiveTab()
		if not tab then return end
		local source = tab.Source
		if not source or source == "" then return end
		local fn, err = loadstring(source, tab.Name or "DeuxEditor")
		if not fn then
			if Notifications then Notifications.Error("Syntax error: " .. tostring(err)) end
			return
		end
		local fenv = setmetatable({
			script = tab.Script,
			game = game,
			workspace = workspace,
		}, {__index = getfenv(0)})
		setfenv(fn, fenv)
		local s, runErr = pcall(fn)
		if s then
			if Notifications then Notifications.Success("Script executed successfully") end
		else
			if Notifications then Notifications.Error("Runtime error: " .. tostring(runErr):sub(1, 120)) end
		end
	end
	ScriptEditor.GetCursorLine = function()
		if not codeInput then return 1 end
		local text = codeInput.Text
		local pos = codeInput.CursorPosition
		if pos < 0 then return 1 end
		local line = 1
		for i = 1, math.min(pos, #text) do
			if text:sub(i, i) == "\n" then line = line + 1 end
		end
		return line
	end
	ScriptEditor.GetLineCount = function()
		local tab = getActiveTab()
		if not tab then return 0 end
		local _, count = tab.Source:gsub("\n", "")
		return count + 1
	end
	ScriptEditor.RenderTabs = function()
		if not tabBar then return end
		for _, child in ipairs(tabBar:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for i, tab in ipairs(tabs) do
			local isActive = (i == activeTabIdx)
			local tabBtn = createSimple("TextButton", {
				Name = "Tab" .. i,
				BackgroundColor3 = isActive and (Theme.Get("TabActive") or Color3.fromRGB(60,60,60)) or (Theme.Get("TabInactive") or Color3.fromRGB(38,38,38)),
				BorderSizePixel = 0,
				Size = UDim2.new(0, math.min(120, 60 + #tab.Name * 6), 1, 0),
				Position = UDim2.new(0, (i-1) * 125, 0, 0),
				Text = (tab.Modified and "● " or "") .. tab.Name,
				TextColor3 = isActive and (Theme.Get("Text") or Color3.fromRGB(255,255,255)) or (Theme.Get("TextDim") or Color3.fromRGB(160,160,160)),
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextTruncate = Enum.TextTruncate.AtEnd,
				AutoButtonColor = false,
				Parent = tabBar,
			})
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = tabBtn
			local closeBtn = createSimple("TextButton", {
				Name = "Close",
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(1, -18, 0, 3),
				Text = "×",
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextSize = 14,
				Font = Enum.Font.GothamBold,
				Parent = tabBtn,
			})
			tabBtn.MouseButton1Click:Connect(function() switchTab(i) end)
			closeBtn.MouseButton1Click:Connect(function() closeTab(i) end)
		end
	end
	ScriptEditor.RenderCode = function()
		if not codeDisplay or not codeInput then return end
		local tab = getActiveTab()
		if not tab then
			codeInput.Text = ""
			codeDisplay.Text = ""
			if lineNumbers then lineNumbers.Text = "" end
			return
		end
		if codeInput.Text ~= tab.Source then
			codeInput.Text = tab.Source
		end
		local highlighted = highlightSource(tab.Source)
		codeDisplay.Text = highlighted
		if lineNumbers then
			local lineCount = ScriptEditor.GetLineCount()
			local nums = {}
			for i = 1, lineCount do nums[#nums + 1] = tostring(i) end
			lineNumbers.Text = table.concat(nums, "\n")
		end
		ScriptEditor.UpdateStatusBar()
	end
	ScriptEditor.UpdateStatusBar = function()
		if not statusBar then return end
		local tab = getActiveTab()
		if not tab then
			statusBar.Text = "No file open"
			return
		end
		local lineCount = ScriptEditor.GetLineCount()
		local curLine = tab.CursorLine or 1
		local curCol = tab.CursorCol or 1
		local decompInfo = tab.DecompileTime and (" | Decompiled in " .. tab.DecompileTime .. "ms") or ""
		local modifiedInfo = tab.Modified and " | Modified" or ""
		statusBar.Text = string.format("Ln %d, Col %d | %d lines%s%s", curLine, curCol, lineCount, decompInfo, modifiedInfo)
	end
	ScriptEditor.Init = function()
		ScriptEditor.Window = Lib.Window.new()
		ScriptEditor.Window:SetTitle("Script Editor")
		ScriptEditor.Window:SetResizable(true)
		ScriptEditor.Window:SetSize(500, 400)
		local content = ScriptEditor.Window:GetContentFrame()
		tabBar = createSimple("Frame", {
			Name = "TabBar",
			BackgroundColor3 = Theme.Get("Main2") or Color3.fromRGB(35, 35, 35),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 24),
			ClipsDescendants = true,
			Parent = content,
		})
		codeFrame = createSimple("ScrollingFrame", {
			Name = "CodeFrame",
			BackgroundColor3 = Theme.Get("Syntax").Background or Color3.fromRGB(36, 36, 36),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, -48),
			Position = UDim2.new(0, 0, 0, 24),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Get("ScrollBar") or Color3.fromRGB(80, 80, 80),
			CanvasSize = UDim2.new(0, 2000, 0, 5000),
			Parent = content,
		})
		lineNumbers = createSimple("TextLabel", {
			Name = "LineNumbers",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 36, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			Text = "1",
			TextColor3 = Theme.Get("PlaceholderText") or Color3.fromRGB(100, 100, 100),
			TextSize = Settings.Get("ScriptEditor.FontSize") or 14,
			Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = codeFrame,
		})
		codeDisplay = createSimple("TextLabel", {
			Name = "CodeDisplay",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -44, 1, 0),
			Position = UDim2.new(0, 44, 0, 0),
			Text = "",
			RichText = true,
			TextColor3 = Theme.Get("Syntax").Text or Color3.fromRGB(204, 204, 204),
			TextSize = Settings.Get("ScriptEditor.FontSize") or 14,
			Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = false,
			Parent = codeFrame,
		})
		codeInput = createSimple("TextBox", {
			Name = "CodeInput",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -44, 1, 0),
			Position = UDim2.new(0, 44, 0, 0),
			Text = "",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextTransparency = 1,
			TextSize = Settings.Get("ScriptEditor.FontSize") or 14,
			Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = false,
			ClearTextOnFocus = false,
			MultiLine = true,
			Parent = codeFrame,
		})
		codeInput:GetPropertyChangedSignal("Text"):Connect(function()
			local tab = getActiveTab()
			if not tab then return end
			if tab.Source ~= codeInput.Text then
				tab.Source = codeInput.Text
				tab.Modified = true
				ScriptEditor.RenderCode()
			end
		end)
		codeInput:GetPropertyChangedSignal("CursorPosition"):Connect(function()
			local tab = getActiveTab()
			if tab then
				tab.CursorLine = ScriptEditor.GetCursorLine()
				ScriptEditor.UpdateStatusBar()
			end
		end)
		statusBar = createSimple("TextLabel", {
			Name = "StatusBar",
			BackgroundColor3 = Theme.Get("Main2") or Color3.fromRGB(35, 35, 35),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 1, -22),
			Text = "No file open",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(150, 150, 150),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = content,
		})
		local statusPad = createSimple("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			Parent = statusBar,
		})
		Keybinds.Register("ScriptEditor.Run", {
			Keys = {Enum.KeyCode.F5},
			Category = "Script Editor",
			Description = "Run current buffer",
			Callback = runCurrentBuffer,
		})
		Keybinds.Register("ScriptEditor.Decompile", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.D},
			Category = "Script Editor",
			Description = "Re-decompile current script",
			Callback = function()
				local tab = getActiveTab()
				if tab and tab.Script then
					local source, elapsed = decompileScript(tab.Script)
					tab.Source = source
					tab.DecompileTime = elapsed
					tab.Modified = false
					ScriptEditor.RenderCode()
					if Notifications then Notifications.Info("Re-decompiled in " .. (elapsed or "?") .. "ms") end
				end
			end,
		})
		Keybinds.Register("ScriptEditor.Find", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.F},
			Category = "Script Editor",
			Description = "Find in current script",
			Callback = function()
				ScriptEditor.ToggleFindBar()
			end,
		})
		Keybinds.Register("ScriptEditor.Save", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.S},
			Category = "Script Editor",
			Description = "Save script to file",
			Callback = function()
				local tab = getActiveTab()
				if not tab then return end
				if Env.Capabilities.Filesystem then
					local path = "deux/saved/scripts/" .. tostring(game.PlaceId) .. "_" .. (tab.Name or "untitled") .. ".lua"
					pcall(Env.writefile, path, tab.Source)
					tab.Modified = false
					ScriptEditor.RenderTabs()
					if Notifications then Notifications.Success("Saved: " .. path) end
				elseif Env.setclipboard then
					Env.setclipboard(tab.Source)
					if Notifications then Notifications.Info("Copied to clipboard (no filesystem)") end
				end
			end,
		})
		Keybinds.Register("ScriptEditor.CloseTab", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.W},
			Category = "Script Editor",
			Description = "Close current tab",
			Callback = function() closeTab(activeTabIdx) end,
		})
		Store.On("open_script", function(scriptInst)
			ScriptEditor.OpenScript(scriptInst)
			ScriptEditor.Window:Show()
		end)
	end
	ScriptEditor.ToggleFindBar = function()
		if Notifications then Notifications.Info("Find: Ctrl+F (coming in next patch)") end
	end
	ScriptEditor.GetTabs = function() return tabs end
	ScriptEditor.GetActiveTab = getActiveTab
	ScriptEditor.AddTab = addTab
	ScriptEditor.CloseTab = closeTab
	ScriptEditor.SwitchTab = switchTab
	ScriptEditor.RunBuffer = runCurrentBuffer
	ScriptEditor.Decompile = decompileScript
	ScriptEditor.GetBytecode = getBytecode
	ScriptEditor.Highlight = highlightSource
	ScriptEditor.Destroy = function()
		for _, conn in ipairs(connections) do conn:Disconnect() end
		connections = {}
	end
	return ScriptEditor
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["Terminal"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	Theme = data.Theme
	Store = data.Store
	Keybinds = data.Keybinds
	Notifications = data.Notifications
	Env = data.Env
	API = data.API
	RMD = data.RMD
	env = data.Env or data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain(appTable)
end
local function main()
	local Terminal = {}
	local commands = {}
	local commandList = {}
	local history = {}
	local historyIndex = 0
	local outputLines = {}
	local MAX_OUTPUT = 2000
	local inputText = ""
	local completionCandidates = {}
	local completionIndex = 0
	local connections = {}
	local window, inputBox, outputScroll, outputFrame
	local autoScrollEnabled = true
	local function fuzzyMatch(query, str)
		query = query:lower()
		str = str:lower()
		local qi = 1
		for i = 1, #str do
			if str:sub(i, i) == query:sub(qi, qi) then
				qi = qi + 1
				if qi > #query then return true end
			end
		end
		return false
	end
	local function resolveInstance(path)
		if not path or path == "" then return nil end
		local current = game
		for segment in path:gmatch("[^%.]+") do
			local child = current:FindFirstChild(segment)
			if not child then return nil end
			current = child
		end
		return current
	end
	local function getFullPath(inst)
		if not inst then return "nil" end
		local parts = {}
		local current = inst
		while current and current ~= game do
			table.insert(parts, 1, current.Name)
			current = current.Parent
		end
		return "game." .. table.concat(parts, ".")
	end
	local function truncateArgs(args, maxLen)
		maxLen = maxLen or 80
		local s = tostring(args)
		if #s > maxLen then
			return s:sub(1, maxLen) .. "..."
		end
		return s
	end
	local function appendOutput(text, color, clickData)
		table.insert(outputLines, {
			Text = tostring(text),
			Color = color,
			ClickData = clickData,
		})
		if #outputLines > MAX_OUTPUT then
			table.remove(outputLines, 1)
		end
		Terminal:RenderOutput()
	end
	local function clearOutput()
		outputLines = {}
		Terminal:RenderOutput()
	end
	local function printOutput(...)
		local parts = {}
		for i = 1, select("#", ...) do
			parts[i] = tostring(select(i, ...))
		end
		appendOutput(table.concat(parts, " "))
	end
	local function printError(msg)
		appendOutput(msg, Theme.Get("Error") or Color3.fromRGB(255, 80, 80))
	end
	local function printSuccess(msg)
		appendOutput(msg, Theme.Get("Success") or Color3.fromRGB(80, 255, 120))
	end
	local function printInstanceLink(inst)
		local path = getFullPath(inst)
		appendOutput(path, Theme.Get("Link") or Color3.fromRGB(100, 180, 255), {
			type = "navigate",
			instance = inst,
		})
	end
	function Terminal:RegisterCommand(def)
		assert(def.Name, "Command must have a Name")
		assert(def.Run, "Command must have a Run function")
		def.Aliases = def.Aliases or {}
		def.Args = def.Args or ""
		def.Description = def.Description or ""
		def.Category = def.Category or "General"
		def.Complete = def.Complete or nil
		commands[def.Name:lower()] = def
		for _, alias in ipairs(def.Aliases) do
			commands[alias:lower()] = def
		end
		table.insert(commandList, def)
	end
	function Terminal:GetCommand(name)
		return commands[name:lower()]
	end
	local function getCompletions(text)
		local results = {}
		local parts = text:split(" ")
		local cmdPart = parts[1] or ""
		if #parts <= 1 then
			for _, cmd in ipairs(commandList) do
				if fuzzyMatch(cmdPart, cmd.Name) then
					table.insert(results, cmd.Name)
				end
				for _, alias in ipairs(cmd.Aliases) do
					if fuzzyMatch(cmdPart, alias) then
						table.insert(results, alias)
					end
				end
			end
		else
			local argText = parts[#parts] or ""
			local cmd = commands[cmdPart:lower()]
			if cmd and cmd.Complete then
				results = cmd.Complete(argText, parts) or {}
			else
				local parentPath = argText:match("(.+)%.") or ""
				local partial = argText:match("%.([^%.]+)$") or argText
				local parent = parentPath ~= "" and resolveInstance(parentPath) or game
				if parent then
					for _, child in ipairs(parent:GetChildren()) do
						if fuzzyMatch(partial, child.Name) then
							local full = parentPath ~= "" and (parentPath .. "." .. child.Name) or child.Name
							table.insert(results, full)
						end
					end
				end
			end
		end
		return results
	end
	local function executeCommand(raw)
		if not raw or raw:match("^%s*$") then return end
		table.insert(history, raw)
		historyIndex = #history + 1
		pcall(function()
			if Settings and Settings.Terminal then
				Settings.Terminal.History = history
			end
		end)
		appendOutput("> " .. raw, Theme.Get("Muted") or Color3.fromRGB(180, 180, 180))
		local parts = raw:split(" ")
		local cmdName = table.remove(parts, 1)
		local cmd = commands[cmdName:lower()]
		if not cmd then
			printError("Unknown command: " .. cmdName .. ". Type 'help' for commands.")
			return
		end
		local ok, err = pcall(cmd.Run, parts, raw)
		if not ok then
			printError("Error: " .. tostring(err))
		end
	end
	local function registerBuiltIns()
		Terminal:RegisterCommand({
			Name = "select",
			Aliases = {"sel"},
			Args = "<path>",
			Description = "Select an instance in the explorer",
			Category = "Navigation",
			Run = function(args)
				local path = table.concat(args, " ")
				local inst = resolveInstance(path)
				if inst then
					Store.Emit("select_instance", inst)
					printSuccess("Selected: " .. getFullPath(inst))
				else
					printError("Instance not found: " .. path)
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "goto",
			Aliases = {"go", "nav"},
			Args = "<path>",
			Description = "Expand and scroll to an instance in the explorer",
			Category = "Navigation",
			Run = function(args)
				local path = table.concat(args, " ")
				local inst = resolveInstance(path)
				if inst then
					Store.Emit("navigate_to", inst)
					printSuccess("Navigated to: " .. getFullPath(inst))
				else
					printError("Instance not found: " .. path)
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "find",
			Aliases = {"search", "f"},
			Args = "<filters>",
			Description = "Search instances (delegates to Explorer.PerformSearch)",
			Category = "Navigation",
			Run = function(args)
				local query = table.concat(args, " ")
				if query == "" then
					printError("Usage: find <query>")
					return
				end
				if Apps and Apps.Explorer and Apps.Explorer.PerformSearch then
					Apps.Explorer.PerformSearch(query)
					printSuccess("Search initiated: " .. query)
				else
					printError("Explorer module not available")
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "tree",
			Aliases = {"ls"},
			Args = "[depth]",
			Description = "Show descendants of selected instance",
			Category = "Navigation",
			Run = function(args)
				local depth = tonumber(args[1]) or 3
				local sel = Store.Get("selected_instance")
				if not sel then
					printError("No instance selected")
					return
				end
				local function printTree(inst, indent, remaining)
					if remaining <= 0 then return end
					local prefix = string.rep("  ", indent)
					appendOutput(prefix .. inst.ClassName .. ' "' .. inst.Name .. '"')
					for _, child in ipairs(inst:GetChildren()) do
						printTree(child, indent + 1, remaining - 1)
					end
				end
				printTree(sel, 0, depth)
			end,
		})
		Terminal:RegisterCommand({
			Name = "dump",
			Aliases = {"props"},
			Args = "<path>",
			Description = "Dump all properties of an instance",
			Category = "Inspection",
			Run = function(args)
				local path = table.concat(args, " ")
				local inst = resolveInstance(path)
				if not inst then
					inst = Store.Get("selected_instance")
				end
				if not inst then
					printError("No instance to dump. Select one or provide a path.")
					return
				end
				appendOutput("--- " .. inst.ClassName .. ": " .. inst.Name .. " ---")
				local props = API:GetProperties(inst)
				if props then
					for _, prop in ipairs(props) do
						local ok2, val = pcall(function() return inst[prop.Name] end)
						if ok2 then
							appendOutput("  " .. prop.Name .. " = " .. truncateArgs(val))
						end
					end
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "hook",
			Aliases = {},
			Args = "<inst>.<event>",
			Description = "Hook a remote/event (delegates to RemoteSpy)",
			Category = "Debug",
			Run = function(args)
				local spec = table.concat(args, " ")
				if Apps and Apps.RemoteSpy then
					Apps.RemoteSpy:HookFromTerminal(spec)
					printSuccess("Hook requested: " .. spec)
				else
					printError("RemoteSpy module not available")
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "unhook",
			Aliases = {},
			Args = "<id>",
			Description = "Remove a hook by ID",
			Category = "Debug",
			Run = function(args)
				local id = args[1]
				if not id then
					printError("Usage: unhook <id>")
					return
				end
				if Apps and Apps.RemoteSpy then
					Apps.RemoteSpy:Unhook(id)
					printSuccess("Unhooked: " .. id)
				else
					printError("RemoteSpy module not available")
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "gc",
			Aliases = {},
			Args = "filter:<type>",
			Description = "Show GC objects by type",
			Category = "Debug",
			Run = function(args)
				if not Env.Capabilities or not Env.Capabilities.GC then
					printError("GC capability not available")
					return
				end
				local filterType = nil
				for _, arg in ipairs(args) do
					local t = arg:match("filter:(.+)")
					if t then filterType = t end
				end
				local objects = Env.getgc(true) or {}
				local count = 0
				for _, obj in ipairs(objects) do
					if not filterType or type(obj) == filterType then
						count = count + 1
						if count <= 100 then
							appendOutput("  [" .. type(obj) .. "] " .. truncateArgs(tostring(obj), 60))
						end
					end
				end
				printSuccess("Total matching: " .. count .. (count > 100 and " (showing first 100)" or ""))
			end,
		})
		Terminal:RegisterCommand({
			Name = "loadstring",
			Aliases = {"fetch", "run"},
			Args = "<url>",
			Description = "Fetch and execute a script from URL",
			Category = "Execution",
			Run = function(args)
				local url = args[1]
				if not url then
					printError("Usage: loadstring <url>")
					return
				end
				printOutput("Fetching: " .. url)
				local ok, result = pcall(function()
					local source = game:HttpGet(url)
					return Env.loadstring(source)()
				end)
				if ok then
					printSuccess("Executed successfully")
				else
					printError("Execution failed: " .. tostring(result))
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "save",
			Aliases = {},
			Args = "place | selection",
			Description = "Save game or selection (delegates to SaveInstance)",
			Category = "File",
			Run = function(args)
				local mode = args[1] or "place"
				if Apps and Apps.SaveInstance then
					if mode == "place" then
						Apps.SaveInstance:SavePlace()
						printSuccess("Save place initiated...")
					elseif mode == "selection" then
						local sel = Store.Get("selected_instance")
						if sel then
							Apps.SaveInstance:SaveModel(sel)
							printSuccess("Save model initiated for: " .. sel.Name)
						else
							printError("No instance selected")
						end
					else
						printError("Usage: save place | save selection")
					end
				else
					printError("SaveInstance module not available")
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "bookmark",
			Aliases = {"bm"},
			Args = "add | list | rm <index>",
			Description = "Manage bookmarks",
			Category = "Navigation",
			Run = function(args)
				local action = args[1] or "list"
				if action == "add" then
					local sel = Store.Get("selected_instance")
					if sel then
						Store.Emit("bookmark_add", sel)
						printSuccess("Bookmarked: " .. getFullPath(sel))
					else
						printError("No instance selected")
					end
				elseif action == "list" then
					local bms = Store.Get("bookmarks") or {}
					if #bms == 0 then
						printOutput("No bookmarks.")
					else
						for i, bm in ipairs(bms) do
							appendOutput("  [" .. i .. "] " .. getFullPath(bm))
						end
					end
				elseif action == "rm" or action == "remove" then
					local idx = tonumber(args[2])
					if idx then
						Store.Emit("bookmark_remove", idx)
						printSuccess("Removed bookmark #" .. idx)
					else
						printError("Usage: bookmark rm <index>")
					end
				else
					printError("Usage: bookmark add | list | rm <index>")
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "theme",
			Aliases = {},
			Args = "<name>",
			Description = "Switch UI theme",
			Category = "Settings",
			Run = function(args)
				local name = args[1]
				if not name then
					printOutput("Current theme: " .. (Settings.Theme or "default"))
					return
				end
				if Theme.SetTheme then
					Theme.SetTheme(name)
					printSuccess("Theme set to: " .. name)
				else
					printError("Theme switching not available")
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "settings",
			Aliases = {"set", "config"},
			Args = "<key> [value]",
			Description = "Get or set a setting",
			Category = "Settings",
			Run = function(args)
				local key = args[1]
				if not key then
					printError("Usage: settings <key> [value]")
					return
				end
				local value = args[2]
				if value then
					pcall(function()
						Settings[key] = tonumber(value) or value
					end)
					printSuccess(key .. " = " .. tostring(Settings[key]))
				else
					local val = Settings[key]
					if val ~= nil then
						printOutput(key .. " = " .. tostring(val))
					else
						printError("Setting not found: " .. key)
					end
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "clear",
			Aliases = {"cls"},
			Args = "",
			Description = "Clear the terminal output",
			Category = "General",
			Run = function()
				clearOutput()
			end,
		})
		Terminal:RegisterCommand({
			Name = "help",
			Aliases = {"?", "commands"},
			Args = "[command]",
			Description = "Show available commands or help for a specific command",
			Category = "General",
			Run = function(args)
				local target = args[1]
				if target then
					local cmd = commands[target:lower()]
					if cmd then
						appendOutput("--- " .. cmd.Name .. " ---")
						appendOutput("  Usage: " .. cmd.Name .. " " .. cmd.Args)
						appendOutput("  Description: " .. cmd.Description)
						appendOutput("  Category: " .. cmd.Category)
						if #cmd.Aliases > 0 then
							appendOutput("  Aliases: " .. table.concat(cmd.Aliases, ", "))
						end
					else
						printError("Unknown command: " .. target)
					end
				else
					local categories = {}
					local catOrder = {}
					for _, cmd in ipairs(commandList) do
						if not categories[cmd.Category] then
							categories[cmd.Category] = {}
							table.insert(catOrder, cmd.Category)
						end
						table.insert(categories[cmd.Category], cmd)
					end
					for _, cat in ipairs(catOrder) do
						appendOutput("[" .. cat .. "]")
						for _, cmd in ipairs(categories[cat]) do
							appendOutput("  " .. cmd.Name .. " " .. cmd.Args .. " - " .. cmd.Description)
						end
					end
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "exec",
			Aliases = {"x", "lua"},
			Args = "<code>",
			Description = "Execute Lua code inline",
			Category = "Execution",
			Run = function(args, raw)
				local code = raw:match("^%S+%s+(.+)$")
				if not code or code == "" then
					printError("Usage: exec <code>")
					return
				end
				local fn, compileErr = Env.loadstring(code)
				if not fn then
					printError("Compile error: " .. tostring(compileErr))
					return
				end
				local results = {pcall(fn)}
				local success = table.remove(results, 1)
				if success then
					if #results > 0 then
						for _, v in ipairs(results) do
							printOutput(tostring(v))
						end
					else
						printSuccess("(no output)")
					end
				else
					printError(tostring(results[1]))
				end
			end,
		})
		Terminal:RegisterCommand({
			Name = "version",
			Aliases = {"ver", "about"},
			Args = "",
			Description = "Show Deux version and executor info",
			Category = "General",
			Run = function()
				appendOutput("Deux " .. (Main.Version or "unknown"))
				local build = rawget(_G, "DeuxBuild")
				if build then
					appendOutput("Build: " .. tostring(build.Commit or "?") .. " @ " .. tostring(build.BuildTime or "?"))
					if build.Credits then
						appendOutput("Credits: " .. table.concat(build.Credits, ", "))
					end
				end
				appendOutput("Executor: " .. (Env.Executor or "unknown"))
				appendOutput("Lua: " .. (Env.LuaVersion or _VERSION or "unknown"))
				if Env.getexecutorname then
					appendOutput("Name: " .. tostring(Env.getexecutorname()))
				end
			end,
		})
	end
	function Terminal:RenderOutput()
		if not outputFrame then return end
		for _, child in ipairs(outputFrame:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		local yOffset = 0
		local lineHeight = 18
		for i, line in ipairs(outputLines) do
			local label = createSimple("TextLabel", {
				Name = "Line_" .. i,
				Parent = outputFrame,
				Position = UDim2.new(0, 4, 0, yOffset),
				Size = UDim2.new(1, -8, 0, lineHeight),
				BackgroundTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 14,
				TextColor3 = line.Color or Theme.Get("Text") or Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				RichText = true,
				Text = line.Text,
			})
			if line.ClickData and line.ClickData.type == "navigate" then
				local btn = createSimple("TextButton", {
					Name = "ClickOverlay",
					Parent = label,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
				})
				btn.MouseButton1Click:Connect(function()
					Store.Emit("navigate_to", line.ClickData.instance)
				end)
			end
			yOffset = yOffset + lineHeight
		end
		outputFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
		if autoScrollEnabled then
			outputFrame.CanvasPosition = Vector2.new(0, math.max(0, yOffset - outputFrame.AbsoluteSize.Y))
		end
	end
	function Terminal:BuildUI()
		window = Lib.Window.new()
		window:SetTitle("Terminal")
		window:SetSize(600, 400)
		local content = window:GetContent()
		outputScroll = createSimple("ScrollingFrame", {
			Name = "Output",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, -30),
			BackgroundColor3 = Theme.Get("Background") or Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		outputFrame = outputScroll
		inputBox = createSimple("TextBox", {
			Name = "Input",
			Parent = content,
			Position = UDim2.new(0, 0, 1, -30),
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Theme.Get("InputBackground") or Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextColor3 = Theme.Get("Text") or Color3.new(1, 1, 1),
			PlaceholderText = "Type a command...",
			PlaceholderColor3 = Theme.Get("Muted") or Color3.fromRGB(120, 120, 120),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		inputBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local text = inputBox.Text
				inputBox.Text = ""
				executeCommand(text)
			end
		end)
		inputBox:GetPropertyChangedSignal("Text"):Connect(function()
			inputText = inputBox.Text
			completionCandidates = {}
			completionIndex = 0
		end)
		local UIS = service.UserInputService
		table.insert(connections, UIS.InputBegan:Connect(function(input, gameProcessed)
			if not inputBox:IsFocused() then return end
			if input.KeyCode == Enum.KeyCode.Up then
				if #history > 0 then
					historyIndex = math.max(1, historyIndex - 1)
					inputBox.Text = history[historyIndex] or ""
				end
			elseif input.KeyCode == Enum.KeyCode.Down then
				historyIndex = math.min(#history + 1, historyIndex + 1)
				inputBox.Text = history[historyIndex] or ""
			elseif input.KeyCode == Enum.KeyCode.Tab then
				if #completionCandidates == 0 then
					completionCandidates = getCompletions(inputBox.Text)
					completionIndex = 1
				else
					completionIndex = (completionIndex % #completionCandidates) + 1
				end
				if #completionCandidates > 0 then
					local parts = inputBox.Text:split(" ")
					parts[#parts] = completionCandidates[completionIndex]
					inputBox.Text = table.concat(parts, " ")
				end
			end
		end))
		pcall(function()
			if Settings and Settings.Terminal and Settings.Terminal.History then
				history = Settings.Terminal.History
				historyIndex = #history + 1
			end
		end)
	end
	function Terminal:Init()
		registerBuiltIns()
		Terminal:BuildUI()
		appendOutput("Deux Terminal ready. Type 'help' for commands.")
	end
	function Terminal:Destroy()
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		connections = {}
		if window then
			window:Close()
		end
	end
	Terminal:Init()
	return Terminal
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["RemoteSpy"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	Theme = data.Theme
	Store = data.Store
	Keybinds = data.Keybinds
	Notifications = data.Notifications
	Env = data.Env
	API = data.API
	RMD = data.RMD
	env = data.Env or data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain(appTable)
end
local function main()
	local RemoteSpy = {}
	local hooks = {}
	local hookCounter = 0
	local logs = {}
	local maxLogs = 5000
	local filterText = ""
	local filterFn = nil
	local autoScroll = true
	local paused = false
	local connections = {}
	local originalFunctions = {}
	local window, logList, filterBar, hookPanel
	local logEntryHeight = 22
	local function generateId()
		hookCounter = hookCounter + 1
		return "hook_" .. hookCounter
	end
	local function getTimestamp()
		return os.clock()
	end
	local function getFullPath(inst)
		if not inst then return "nil" end
		local parts = {}
		local current = inst
		while current and current ~= game do
			table.insert(parts, 1, current.Name)
			current = current.Parent
		end
		return "game." .. table.concat(parts, ".")
	end
	local function serializeArgs(args)
		if not args then return "{}" end
		local parts = {}
		for i, v in ipairs(args) do
			local t = typeof(v)
			if t == "Instance" then
				parts[i] = getFullPath(v)
			elseif t == "string" then
				parts[i] = '"' .. v:sub(1, 100) .. '"'
			elseif t == "table" then
				parts[i] = "{...}"
			else
				parts[i] = tostring(v)
			end
		end
		return "{" .. table.concat(parts, ", ") .. "}"
	end
	local function compileFilter(expr)
		if not expr or expr == "" then
			return nil
		end
		local code = "return function(method, instance, args) return " .. expr .. " end"
		local fn, err = Env.loadstring(code)
		if fn then
			local ok, predicate = pcall(fn)
			if ok then return predicate end
		end
		return nil
	end
	local function matchesFilter(entry)
		if not filterFn then return true end
		local ok, result = pcall(filterFn, entry.Method, entry.Instance, entry.Args)
		return ok and result
	end
	local function addLogEntry(entry)
		if paused then return end
		if not matchesFilter(entry) then return end
		table.insert(logs, entry)
		if #logs > maxLogs then
			table.remove(logs, 1)
		end
		RemoteSpy:RenderLogEntry(entry, #logs)
	end
	function RemoteSpy:CreateHook(config)
		if not Env.hookfunction and not Env.hookmetamethod then
			Notifications.Info("Hook capabilities not available", 3)
			return nil
		end
		local id = generateId()
		local hookDef = {
			Id = id,
			Type = config.Type or "function",
			Target = config.Target,
			Method = config.Method or "",
			Enabled = config.Enabled ~= false,
			EditArgs = config.EditArgs,
			EditReturn = config.EditReturn,
			Block = config.Block or false,
			LogArgs = config.LogArgs ~= false,
			LogReturns = config.LogReturns ~= false,
			Original = nil,
		}
		local success, err = pcall(function()
			if hookDef.Type == "metamethod" then
				local old
				old = Env.hookmetamethod(game, hookDef.Method, function(self, ...)
					if not hookDef.Enabled then
						return old(self, ...)
					end
					local method = ""
					if hookDef.Method == "__namecall" then
						method = Env.getnamecallmethod and Env.getnamecallmethod() or ""
					else
						method = hookDef.Method
					end
					local args = {...}
					local entry = {
						Timestamp = getTimestamp(),
						Method = method,
						Instance = self,
						Args = hookDef.LogArgs and args or nil,
						Returns = nil,
						Blocked = hookDef.Block,
						HookId = id,
					}
					if hookDef.Block then
						addLogEntry(entry)
						return nil
					end
					if hookDef.EditArgs then
						args = hookDef.EditArgs(args) or args
					end
					local results = {old(self, unpack(args))}
					if hookDef.LogReturns then
						entry.Returns = results
					end
					if hookDef.EditReturn then
						results = hookDef.EditReturn(results) or results
					end
					addLogEntry(entry)
					return unpack(results)
				end)
				hookDef.Original = old
				originalFunctions[id] = old
			elseif hookDef.Type == "function" then
				local target = hookDef.Target
				local methodName = hookDef.Method
				if target and methodName then
					local oldFn = target[methodName]
					local newFn = Env.hookfunction(oldFn, function(...)
						if not hookDef.Enabled then
							return oldFn(...)
						end
						local args = {...}
						local self = args[1]
						local callArgs = {select(2, ...)}
						local entry = {
							Timestamp = getTimestamp(),
							Method = methodName,
							Instance = (typeof(self) == "Instance") and self or nil,
							Args = hookDef.LogArgs and callArgs or nil,
							Returns = nil,
							Blocked = hookDef.Block,
							HookId = id,
						}
						if hookDef.Block then
							addLogEntry(entry)
							return nil
						end
						if hookDef.EditArgs then
							callArgs = hookDef.EditArgs(callArgs) or callArgs
						end
						local results = {oldFn(self, unpack(callArgs))}
						if hookDef.LogReturns then
							entry.Returns = results
						end
						if hookDef.EditReturn then
							results = hookDef.EditReturn(results) or results
						end
						addLogEntry(entry)
						return unpack(results)
					end)
					hookDef.Original = oldFn
					originalFunctions[id] = oldFn
				end
			elseif hookDef.Type == "gc" then
				if Env.hookfunction and hookDef.Target then
					local oldFn = hookDef.Target
					Env.hookfunction(oldFn, function(...)
						if not hookDef.Enabled then
							return oldFn(...)
						end
						local args = {...}
						local entry = {
							Timestamp = getTimestamp(),
							Method = hookDef.Method or "gc_closure",
							Instance = nil,
							Args = hookDef.LogArgs and args or nil,
							Returns = nil,
							Blocked = hookDef.Block,
							HookId = id,
						}
						if hookDef.Block then
							addLogEntry(entry)
							return nil
						end
						local results = {oldFn(...)}
						if hookDef.LogReturns then
							entry.Returns = results
						end
						addLogEntry(entry)
						return unpack(results)
					end)
					hookDef.Original = oldFn
					originalFunctions[id] = oldFn
				end
			end
		end)
		if not success then
			Notifications.Info("Hook failed: " .. tostring(err), 3)
			return nil
		end
		hooks[id] = hookDef
		RemoteSpy:RenderHookPanel()
		return id
	end
	function RemoteSpy:Unhook(id)
		local hookDef = hooks[id]
		if not hookDef then return false end
		if hookDef.Type == "function" and hookDef.Original and hookDef.Target then
			pcall(function()
				Env.hookfunction(hookDef.Target[hookDef.Method], hookDef.Original)
			end)
		end
		hooks[id] = nil
		originalFunctions[id] = nil
		RemoteSpy:RenderHookPanel()
		return true
	end
	function RemoteSpy:SetHookEnabled(id, enabled)
		if hooks[id] then
			hooks[id].Enabled = enabled
		end
	end
	function RemoteSpy:Replay(logEntry)
		if not logEntry or not logEntry.Instance then return end
		pcall(function()
			logEntry.Instance[logEntry.Method](logEntry.Instance, unpack(logEntry.Args or {}))
		end)
	end
	function RemoteSpy:HookFromTerminal(spec)
		if spec:match("^__") then
			return self:CreateHook({
				Type = "metamethod",
				Method = spec,
			})
		else
			local instPath, method = spec:match("(.+)%.(%w+)$")
			if instPath and method then
				local inst = game
				for seg in instPath:gmatch("[^%.]+") do
					if seg ~= "game" then
						inst = inst:FindFirstChild(seg)
						if not inst then break end
					end
				end
				if inst then
					return self:CreateHook({
						Type = "function",
						Target = inst,
						Method = method,
					})
				end
			end
		end
		return nil
	end
	function RemoteSpy:ApplyPreset(name)
		if name == "default" or name == "Remote Spy" then
			self:CreateHook({
				Type = "metamethod",
				Method = "__namecall",
			})
			Notifications.Info("Default preset applied (namecall hook active)", 3)
		end
	end
	function RemoteSpy:SaveProfile(name)
		local profile = {}
		for id, hookDef in pairs(hooks) do
			table.insert(profile, {
				Type = hookDef.Type,
				Method = hookDef.Method,
				Enabled = hookDef.Enabled,
				Block = hookDef.Block,
				LogArgs = hookDef.LogArgs,
				LogReturns = hookDef.LogReturns,
			})
		end
		local json = service.HttpService:JSONEncode(profile)
		local path = "deux/saved/hooks/" .. (name or "default") .. ".json"
		if Env.writefile then
			Env.writefile(path, json)
			Notifications.Info("Profile saved: " .. path, 3)
		end
	end
	function RemoteSpy:LoadProfile(name)
		local path = "deux/saved/hooks/" .. (name or "default") .. ".json"
		if Env.readfile and Env.isfile and Env.isfile(path) then
			local json = Env.readfile(path)
			local profile = service.HttpService:JSONDecode(json)
			for _, entry in ipairs(profile) do
				self:CreateHook(entry)
			end
			Notifications.Info("Profile loaded: " .. name, 3)
		end
	end
	function RemoteSpy:CopyAsScript(logEntry)
		if not logEntry then return end
		local lines = {}
		table.insert(lines, "-- RemoteSpy Replay Script")
		table.insert(lines, "-- Method: " .. (logEntry.Method or "?"))
		if logEntry.Instance then
			local path = getFullPath(logEntry.Instance)
			table.insert(lines, 'local remote = game:GetService("' .. path:match("game%.(%w+)") .. '")')
			table.insert(lines, "-- Full path: " .. path)
			local argsStr = serializeArgs(logEntry.Args)
			table.insert(lines, "remote:" .. logEntry.Method .. "(" .. argsStr .. ")")
		end
		local script = table.concat(lines, "\n")
		if Env.setclipboard then
			Env.setclipboard(script)
			Notifications.Info("Copied replay script to clipboard", 2)
		end
		return script
	end
	function RemoteSpy:RenderLogEntry(entry, index)
		if not logList then return end
		local yPos = (index - 1) * logEntryHeight
		local color = Theme.Get("Text") or Color3.new(1, 1, 1)
		if entry.Blocked then
			color = Theme.Get("Error") or Color3.fromRGB(255, 80, 80)
		end
		local text = string.format("[%.2f] %s %s %s",
			entry.Timestamp,
			entry.Method or "?",
			entry.Instance and entry.Instance.Name or "",
			serializeArgs(entry.Args):sub(1, 60)
		)
		local label = createSimple("TextButton", {
			Name = "Log_" .. index,
			Parent = logList,
			Position = UDim2.new(0, 0, 0, yPos),
			Size = UDim2.new(1, 0, 0, logEntryHeight),
			BackgroundTransparency = index % 2 == 0 and 0.95 or 1,
			BackgroundColor3 = Theme.Get("Row") or Color3.fromRGB(40, 40, 40),
			BorderSizePixel = 0,
			Font = Enum.Font.Code,
			TextSize = 13,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "  " .. text,
			AutoButtonColor = true,
		})
		label.MouseButton1Click:Connect(function()
			RemoteSpy:ShowLogDetail(entry)
		end)
		logList.CanvasSize = UDim2.new(0, 0, 0, index * logEntryHeight)
		if autoScroll then
			logList.CanvasPosition = Vector2.new(0, math.max(0, index * logEntryHeight - logList.AbsoluteSize.Y))
		end
	end
	function RemoteSpy:ShowLogDetail(entry)
		local detail = string.format(
			"Method: %s\nInstance: %s\nArgs: %s\nReturns: %s\nBlocked: %s\nHookId: %s",
			entry.Method or "?",
			entry.Instance and getFullPath(entry.Instance) or "nil",
			serializeArgs(entry.Args),
			serializeArgs(entry.Returns),
			tostring(entry.Blocked),
			entry.HookId or "?"
		)
		if Env.setclipboard then
			Env.setclipboard(detail)
			Notifications.Info("Log detail copied to clipboard", 2)
		end
	end
	function RemoteSpy:RenderHookPanel()
		if not hookPanel then return end
		for _, child in ipairs(hookPanel:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local y = 0
		for id, hookDef in pairs(hooks) do
			local row = createSimple("Frame", {
				Name = "Hook_" .. id,
				Parent = hookPanel,
				Position = UDim2.new(0, 0, 0, y),
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 0.9,
				BackgroundColor3 = Theme.Get("Row") or Color3.fromRGB(40, 40, 40),
			})
			createSimple("TextLabel", {
				Parent = row,
				Position = UDim2.new(0, 4, 0, 0),
				Size = UDim2.new(0.6, 0, 1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = hookDef.Enabled and (Theme.Get("Text") or Color3.new(1,1,1)) or (Theme.Get("Muted") or Color3.fromRGB(100,100,100)),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = hookDef.Method .. " [" .. hookDef.Type .. "]",
			})
			local toggleBtn = createSimple("TextButton", {
				Parent = row,
				Position = UDim2.new(0.7, 0, 0, 2),
				Size = UDim2.new(0.12, 0, 0, 20),
				BackgroundColor3 = hookDef.Enabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60),
				Font = Enum.Font.Code,
				TextSize = 11,
				TextColor3 = Color3.new(1,1,1),
				Text = hookDef.Enabled and "ON" or "OFF",
			})
			toggleBtn.MouseButton1Click:Connect(function()
				hookDef.Enabled = not hookDef.Enabled
				RemoteSpy:RenderHookPanel()
			end)
			local rmBtn = createSimple("TextButton", {
				Parent = row,
				Position = UDim2.new(0.85, 0, 0, 2),
				Size = UDim2.new(0.12, 0, 0, 20),
				BackgroundColor3 = Color3.fromRGB(180, 40, 40),
				Font = Enum.Font.Code,
				TextSize = 11,
				TextColor3 = Color3.new(1,1,1),
				Text = "X",
			})
			rmBtn.MouseButton1Click:Connect(function()
				RemoteSpy:Unhook(id)
			end)
			y = y + 26
		end
		hookPanel.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	function RemoteSpy:BuildUI()
		window = Lib.Window.new()
		window:SetTitle("Remote Spy")
		window:SetSize(700, 450)
		local content = window:GetContent()
		filterBar = createSimple("TextBox", {
			Name = "Filter",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0.7, -4, 0, 26),
			BackgroundColor3 = Theme.Get("InputBackground") or Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Font = Enum.Font.Code,
			TextSize = 13,
			TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
			PlaceholderText = "Filter: method == 'FireServer' and instance.Name:find('Remote')",
			PlaceholderColor3 = Theme.Get("Muted") or Color3.fromRGB(100,100,100),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		filterBar.FocusLost:Connect(function()
			filterText = filterBar.Text
			filterFn = compileFilter(filterText)
		end)
		local autoScrollBtn = createSimple("TextButton", {
			Name = "AutoScroll",
			Parent = content,
			Position = UDim2.new(0.7, 0, 0, 0),
			Size = UDim2.new(0.15, 0, 0, 26),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			Text = "Auto-Scroll: ON",
		})
		autoScrollBtn.MouseButton1Click:Connect(function()
			autoScroll = not autoScroll
			autoScrollBtn.Text = "Auto-Scroll: " .. (autoScroll and "ON" or "OFF")
		end)
		local copyBtn = createSimple("TextButton", {
			Name = "CopyScript",
			Parent = content,
			Position = UDim2.new(0.85, 0, 0, 0),
			Size = UDim2.new(0.15, 0, 0, 26),
			BackgroundColor3 = Color3.fromRGB(50, 80, 120),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			Text = "Copy Script",
		})
		copyBtn.MouseButton1Click:Connect(function()
			if #logs > 0 then
				RemoteSpy:CopyAsScript(logs[#logs])
			end
		end)
		logList = createSimple("ScrollingFrame", {
			Name = "LogList",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 30),
			Size = UDim2.new(0.7, 0, 1, -30),
			BackgroundColor3 = Theme.Get("Background") or Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		hookPanel = createSimple("ScrollingFrame", {
			Name = "HookPanel",
			Parent = content,
			Position = UDim2.new(0.7, 4, 0, 30),
			Size = UDim2.new(0.3, -4, 1, -30),
			BackgroundColor3 = Theme.Get("Panel") or Color3.fromRGB(25, 25, 30),
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
	end
	function RemoteSpy:Init()
		pcall(function()
			if Settings.RemoteSpy and Settings.RemoteSpy.MaxLogs then
				maxLogs = Settings.RemoteSpy.MaxLogs
			end
		end)
		RemoteSpy:BuildUI()
		pcall(function()
			if Settings.RemoteSpy and Settings.RemoteSpy.AutoStart then
				RemoteSpy:ApplyPreset("default")
			end
		end)
	end
	function RemoteSpy:ClearLogs()
		logs = {}
		if logList then
			for _, child in ipairs(logList:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			logList.CanvasSize = UDim2.new(0, 0, 0, 0)
		end
	end
	function RemoteSpy:GetLogs()
		return logs
	end
	function RemoteSpy:GetHooks()
		return hooks
	end
	function RemoteSpy:Destroy()
		for id in pairs(hooks) do
			self:Unhook(id)
		end
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		connections = {}
		if window then
			window:Close()
		end
	end
	RemoteSpy:Init()
	return RemoteSpy
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["SaveInstance"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	Theme = data.Theme
	Store = data.Store
	Keybinds = data.Keybinds
	Notifications = data.Notifications
	Env = data.Env
	API = data.API
	RMD = data.RMD
	env = data.Env or data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain(appTable)
end
local function main()
	local SaveInstance = {}
	local isSaving = false
	local connections = {}
	local options = {
		Scope = "place",
		IncludeScriptSource = true,
		OptimizeMeshes = true,
		ScrubPlayerData = true,
		FileFormat = "rbxlx",
		ModelFormat = "rbxmx",
	}
	local window, optionsFrame, statusLabel, saveButton
	local function getTimestamp()
		return os.date("%Y%m%d_%H%M%S")
	end
	local function getPlaceId()
		return tostring(game.PlaceId or "0")
	end
	local function getOutputPath(format)
		format = format or options.FileFormat
		return "deux/saved/places/" .. getPlaceId() .. "_" .. getTimestamp() .. "." .. format
	end
	local function getModelOutputPath(name, format)
		format = format or options.ModelFormat
		name = name or "model"
		name = name:gsub("[^%w_%-]", "_")
		return "deux/saved/places/" .. name .. "_" .. getTimestamp() .. "." .. format
	end
	local function setStatus(text)
		if statusLabel then
			statusLabel.Text = text
		end
	end
	local function ensureDirectory()
		if Env.makefolder and not Env.isfolder("deux/saved/places") then
			pcall(function()
				Env.makefolder("deux")
				Env.makefolder("deux/saved")
				Env.makefolder("deux/saved/places")
			end)
		end
	end
	function SaveInstance:SavePlace(overrideOptions)
		if isSaving then
			Notifications.Info("Already saving, please wait...", 3)
			return
		end
		if not Env.saveinstance then
			Notifications.Info("saveinstance not available in this executor", 3)
			return
		end
		isSaving = true
		setStatus("Saving place...")
		local opts = {}
		for k, v in pairs(options) do opts[k] = v end
		if overrideOptions then
			for k, v in pairs(overrideOptions) do opts[k] = v end
		end
		ensureDirectory()
		local path = getOutputPath(opts.FileFormat)
		task.spawn(function()
			local ok, err = pcall(function()
				local saveOpts = {
					FilePath = path,
					ExtraInstances = {},
					DecompileScripts = opts.IncludeScriptSource,
					NilInstances = opts.Scope == "nil",
					RemovePlayerCharacters = opts.ScrubPlayerData,
					SavePlayers = not opts.ScrubPlayerData,
				}
				Env.saveinstance(saveOpts)
			end)
			isSaving = false
			if ok then
				setStatus("Saved!")
				Notifications.Info("Place saved: " .. path, 5)
			else
				setStatus("Failed: " .. tostring(err))
				Notifications.Info("Save failed: " .. tostring(err), 5)
			end
			task.delay(3, function()
				setStatus("Ready")
			end)
		end)
	end
	function SaveInstance:SaveModel(instance, overrideOptions)
		if isSaving then
			Notifications.Info("Already saving, please wait...", 3)
			return
		end
		if not instance then
			Notifications.Info("No instance provided", 3)
			return
		end
		if not Env.saveinstance then
			Notifications.Info("saveinstance not available in this executor", 3)
			return
		end
		isSaving = true
		setStatus("Saving model: " .. instance.Name .. "...")
		local opts = {}
		for k, v in pairs(options) do opts[k] = v end
		if overrideOptions then
			for k, v in pairs(overrideOptions) do opts[k] = v end
		end
		ensureDirectory()
		local path = getModelOutputPath(instance.Name, opts.ModelFormat)
		task.spawn(function()
			local ok, err = pcall(function()
				local saveOpts = {
					FilePath = path,
					ExtraInstances = {instance},
					DecompileScripts = opts.IncludeScriptSource,
					Mode = "model",
				}
				Env.saveinstance(saveOpts)
			end)
			isSaving = false
			if ok then
				setStatus("Saved!")
				Notifications.Info("Model saved: " .. path, 5)
			else
				setStatus("Failed: " .. tostring(err))
				Notifications.Info("Save failed: " .. tostring(err), 5)
			end
			task.delay(3, function()
				setStatus("Ready")
			end)
		end)
	end
	function SaveInstance:BuildUI()
		window = Lib.Window.new()
		window:SetTitle("Save Instance")
		window:SetSize(400, 340)
		local content = window:GetContent()
		local yOffset = 0
		local rowHeight = 28
		local padding = 4
		local function addOptionRow(label, optionKey, values)
			local row = createSimple("Frame", {
				Name = "Row_" .. optionKey,
				Parent = content,
				Position = UDim2.new(0, 0, 0, yOffset),
				Size = UDim2.new(1, 0, 0, rowHeight),
				BackgroundTransparency = 1,
			})
			createSimple("TextLabel", {
				Parent = row,
				Position = UDim2.new(0, 8, 0, 0),
				Size = UDim2.new(0.5, -8, 1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextSize = 14,
				TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = label,
			})
			if values then
				local btn = createSimple("TextButton", {
					Parent = row,
					Position = UDim2.new(0.5, 4, 0, 2),
					Size = UDim2.new(0.5, -12, 0, rowHeight - 4),
					BackgroundColor3 = Theme.Get("InputBackground") or Color3.fromRGB(40, 40, 40),
					Font = Enum.Font.Code,
					TextSize = 13,
					TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
					Text = tostring(options[optionKey]),
				})
				btn.MouseButton1Click:Connect(function()
					local currentIdx = 1
					for i, v in ipairs(values) do
						if tostring(options[optionKey]) == tostring(v) then
							currentIdx = i
							break
						end
					end
					currentIdx = (currentIdx % #values) + 1
					options[optionKey] = values[currentIdx]
					btn.Text = tostring(options[optionKey])
				end)
			else
				local btn = createSimple("TextButton", {
					Parent = row,
					Position = UDim2.new(0.5, 4, 0, 2),
					Size = UDim2.new(0.5, -12, 0, rowHeight - 4),
					BackgroundColor3 = options[optionKey] and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60),
					Font = Enum.Font.Code,
					TextSize = 13,
					TextColor3 = Color3.new(1,1,1),
					Text = options[optionKey] and "ON" or "OFF",
				})
				btn.MouseButton1Click:Connect(function()
					options[optionKey] = not options[optionKey]
					btn.Text = options[optionKey] and "ON" or "OFF"
					btn.BackgroundColor3 = options[optionKey] and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
				end)
			end
			yOffset = yOffset + rowHeight + padding
		end
		addOptionRow("Scope", "Scope", {"place", "selection", "nil"})
		addOptionRow("Include Script Source", "IncludeScriptSource")
		addOptionRow("Optimize Meshes", "OptimizeMeshes")
		addOptionRow("Scrub Player Data", "ScrubPlayerData")
		addOptionRow("File Format", "FileFormat", {"rbxlx", "rbxl"})
		addOptionRow("Model Format", "ModelFormat", {"rbxmx", "rbxm"})
		yOffset = yOffset + 10
		statusLabel = createSimple("TextLabel", {
			Name = "Status",
			Parent = content,
			Position = UDim2.new(0, 8, 0, yOffset),
			Size = UDim2.new(1, -16, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansItalic,
			TextSize = 14,
			TextColor3 = Theme.Get("Muted") or Color3.fromRGB(160, 160, 160),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Ready",
		})
		yOffset = yOffset + 30
		saveButton = createSimple("TextButton", {
			Name = "SavePlace",
			Parent = content,
			Position = UDim2.new(0, 8, 0, yOffset),
			Size = UDim2.new(0.45, -8, 0, 32),
			BackgroundColor3 = Color3.fromRGB(50, 120, 200),
			Font = Enum.Font.SourceSansBold,
			TextSize = 15,
			TextColor3 = Color3.new(1,1,1),
			Text = "Save Place",
		})
		saveButton.MouseButton1Click:Connect(function()
			SaveInstance:SavePlace()
		end)
		local saveSelBtn = createSimple("TextButton", {
			Name = "SaveSelection",
			Parent = content,
			Position = UDim2.new(0.5, 4, 0, yOffset),
			Size = UDim2.new(0.45, -8, 0, 32),
			BackgroundColor3 = Color3.fromRGB(50, 160, 100),
			Font = Enum.Font.SourceSansBold,
			TextSize = 15,
			TextColor3 = Color3.new(1,1,1),
			Text = "Save Selection",
		})
		saveSelBtn.MouseButton1Click:Connect(function()
			local sel = Store.Get("selected_instance")
			if sel then
				SaveInstance:SaveModel(sel)
			else
				Notifications.Info("No instance selected", 3)
			end
		end)
	end
	function SaveInstance:Init()
		pcall(function()
			if Settings.SaveInstance then
				for k, v in pairs(Settings.SaveInstance) do
					if options[k] ~= nil then
						options[k] = v
					end
				end
			end
		end)
		SaveInstance:BuildUI()
		table.insert(connections, Store.On("save_instance", function(instance)
			if instance then
				SaveInstance:SaveModel(instance)
			else
				SaveInstance:SavePlace()
			end
		end))
	end
	function SaveInstance:GetOptions()
		return options
	end
	function SaveInstance:SetOption(key, value)
		if options[key] ~= nil then
			options[key] = value
		end
	end
	function SaveInstance:Destroy()
		for _, conn in ipairs(connections) do
			if typeof(conn) == "RBXScriptConnection" then
				conn:Disconnect()
			end
		end
		connections = {}
		if window then
			window:Close()
		end
	end
	SaveInstance:Init()
	return SaveInstance
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["DataInspector"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	Theme = data.Theme
	Store = data.Store
	Keybinds = data.Keybinds
	Notifications = data.Notifications
	Env = data.Env
	API = data.API
	RMD = data.RMD
	env = data.Env or data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local function main()
	local DataInspector = {}
	local connections = {}
	local gcCache = {}
	local gcLastRefresh = 0
	local activeTab = "gc"
	local tabs = {}
	local filterType = nil
	local filterSource = ""
	local filterName = ""
	local filterUpvalue = ""
	local ROW_HEIGHT = 22
	local visibleRows = {}
	local scrollOffset = 0
	local totalItems = 0
	local selectedItem = nil
	local decompileCache = {}
	local window, contentFrame, listFrame, detailFrame
	local tabBar, filterFrame, statusLabel
	local function hasGC()
		return Env.Capabilities and Env.Capabilities.GC and Env.getgc
	end
	local function hasDebug()
		return Env.Capabilities and Env.Capabilities.Debug
	end
	local function hasDecompile()
		return Env.decompile ~= nil
	end
	function DataInspector:RefreshGC()
		if not hasGC() then
			Notifications.Info("GC capability not available", 3)
			return
		end
		gcCache = Env.getgc(true) or {}
		gcLastRefresh = os.clock()
		DataInspector:ApplyFilters()
	end
	function DataInspector:ApplyFilters()
		visibleRows = {}
		for _, obj in ipairs(gcCache) do
			local objType = type(obj)
			local pass = true
			if filterType and objType ~= filterType then
				pass = false
			end
			if pass and filterSource ~= "" and objType == "function" then
				local info = Env.getinfo and Env.getinfo(obj)
				if info then
					local src = info.source or info.short_src or ""
					if not src:lower():find(filterSource:lower(), 1, true) then
						pass = false
					end
				end
			end
			if pass and filterName ~= "" then
				local name = tostring(obj)
				if objType == "function" and Env.getinfo then
					local info = Env.getinfo(obj)
					if info and info.name then
						name = info.name
					end
				end
				if not name:lower():find(filterName:lower(), 1, true) then
					pass = false
				end
			end
			if pass and filterUpvalue ~= "" and objType == "function" then
				local found = false
				if Env.getupvalues then
					local upvals = Env.getupvalues(obj)
					if upvals then
						for _, v in pairs(upvals) do
							if tostring(v):lower():find(filterUpvalue:lower(), 1, true) then
								found = true
								break
							end
						end
					end
				end
				if not found then pass = false end
			end
			if pass then
				table.insert(visibleRows, obj)
			end
		end
		totalItems = #visibleRows
		DataInspector:RenderList()
	end
	function DataInspector:ShowFunctionDetail(fn)
		if type(fn) ~= "function" then return end
		selectedItem = fn
		local detail = {
			Type = "function",
			Info = nil,
			Constants = {},
			Upvalues = {},
			Source = nil,
			ScriptPath = nil,
			References = {},
		}
		if Env.getinfo then
			detail.Info = Env.getinfo(fn)
			if detail.Info then
				detail.ScriptPath = detail.Info.source or detail.Info.short_src
			end
		end
		if Env.getconstants then
			local ok, consts = pcall(Env.getconstants, fn)
			if ok then detail.Constants = consts or {} end
		end
		if Env.getupvalues then
			local ok, upvals = pcall(Env.getupvalues, fn)
			if ok then detail.Upvalues = upvals or {} end
		end
		if hasDecompile() then
			if decompileCache[fn] then
				detail.Source = decompileCache[fn]
			else
				task.spawn(function()
					local ok, src = pcall(Env.decompile, fn)
					if ok then
						decompileCache[fn] = src
						detail.Source = src
						DataInspector:RenderDetail(detail)
					end
				end)
			end
		end
		DataInspector:RenderDetail(detail)
	end
	function DataInspector:FindReferences(value)
		if not hasGC() then return {} end
		local refs = {}
		local seen = {}
		for _, obj in ipairs(gcCache) do
			if type(obj) == "table" and not seen[obj] then
				seen[obj] = true
				for k, v in pairs(obj) do
					if v == value then
						table.insert(refs, {
							Holder = obj,
							Key = k,
							Path = "table[" .. tostring(k) .. "]",
						})
					end
				end
			elseif type(obj) == "function" and not seen[obj] then
				seen[obj] = true
				if Env.getupvalues then
					local ok, upvals = pcall(Env.getupvalues, obj)
					if ok and upvals then
						for idx, v in pairs(upvals) do
							if v == value then
								local name = "upvalue_" .. idx
								if Env.getinfo then
									local info = Env.getinfo(obj)
									if info and info.name then
										name = info.name .. ".upval[" .. idx .. "]"
									end
								end
								table.insert(refs, {
									Holder = obj,
									Key = idx,
									Path = name,
								})
							end
						end
					end
				end
			end
		end
		return refs
	end
	function DataInspector:OpenReferenceTab(value)
		local refs = DataInspector:FindReferences(value)
		table.insert(tabs, {
			Value = value,
			References = refs,
			Label = tostring(value):sub(1, 30),
		})
		DataInspector:RenderReferenceTabs()
	end
	function DataInspector:BuildSignature(fn)
		if type(fn) ~= "function" then return nil end
		local consts = {}
		local upvals = {}
		if Env.getconstants then
			local ok, c = pcall(Env.getconstants, fn)
			if ok then consts = c or {} end
		end
		if Env.getupvalues then
			local ok, u = pcall(Env.getupvalues, fn)
			if ok then upvals = u or {} end
		end
		local stableConsts = {}
		for i, v in ipairs(consts) do
			if type(v) == "string" and #v > 2 and #v < 100 then
				table.insert(stableConsts, {Index = i, Value = v})
			end
		end
		local lines = {}
		table.insert(lines, "-- Constant-Signature Finder")
		table.insert(lines, "local target = nil")
		table.insert(lines, "for _, fn in ipairs(getgc(true)) do")
		table.insert(lines, "    if type(fn) == 'function' then")
		table.insert(lines, "        local consts = getconstants(fn)")
		if #stableConsts > 0 then
			local checks = {}
			for _, sc in ipairs(stableConsts) do
				table.insert(checks, string.format("consts[%d] == %q", sc.Index, sc.Value))
			end
			table.insert(lines, "        if " .. table.concat(checks, " and ") .. " then")
		else
			table.insert(lines, "        if false then -- no stable constants found")
		end
		table.insert(lines, "            target = fn")
		table.insert(lines, "            break")
		table.insert(lines, "        end")
		table.insert(lines, "    end")
		table.insert(lines, "end")
		table.insert(lines, "return target")
		return table.concat(lines, "\n")
	end
	function DataInspector:GetThreads()
		if not Env.getthreads then return {} end
		local ok, threads = pcall(Env.getthreads)
		if not ok then return {} end
		local results = {}
		for i, thread in ipairs(threads or {}) do
			local status = coroutine.status(thread)
			local tb = ""
			if Env.getinfo then
				pcall(function()
					local info = Env.getinfo(thread)
					if info then
						tb = (info.source or "") .. ":" .. (info.currentline or "?")
					end
				end)
			end
			table.insert(results, {
				Thread = thread,
				Status = status,
				Traceback = tb,
				Index = i,
			})
		end
		return results
	end
	function DataInspector:RenderList()
		if not listFrame then return end
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("Frame") then
				child:Destroy()
			end
		end
		local viewHeight = listFrame.AbsoluteSize.Y
		local startIdx = math.floor(scrollOffset / ROW_HEIGHT) + 1
		local endIdx = math.min(totalItems, startIdx + math.ceil(viewHeight / ROW_HEIGHT) + 1)
		for i = startIdx, endIdx do
			local obj = visibleRows[i]
			if not obj then break end
			local objType = type(obj)
			local displayText = "[" .. objType .. "] "
			if objType == "function" and Env.getinfo then
				local info = Env.getinfo(obj)
				if info and info.name and info.name ~= "" then
					displayText = displayText .. info.name
				elseif info and info.short_src then
					displayText = displayText .. info.short_src .. ":" .. (info.currentline or "?")
				else
					displayText = displayText .. tostring(obj)
				end
			elseif objType == "table" then
				local count = 0
				for _ in pairs(obj) do count = count + 1 if count > 10 then break end end
				displayText = displayText .. "{" .. count .. (count > 10 and "+" or "") .. " entries}"
			else
				displayText = displayText .. tostring(obj):sub(1, 60)
			end
			local yPos = (i - 1) * ROW_HEIGHT - scrollOffset
			local row = createSimple("TextButton", {
				Name = "Row_" .. i,
				Parent = listFrame,
				Position = UDim2.new(0, 0, 0, yPos),
				Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
				BackgroundTransparency = i % 2 == 0 and 0.95 or 1,
				BackgroundColor3 = Theme.Get("Row") or Color3.fromRGB(35, 35, 40),
				BorderSizePixel = 0,
				Font = Enum.Font.Code,
				TextSize = 13,
				TextColor3 = Theme.Get("Text") or Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "  " .. displayText,
				AutoButtonColor = true,
			})
			row.MouseButton1Click:Connect(function()
				if objType == "function" then
					DataInspector:ShowFunctionDetail(obj)
				elseif objType == "table" then
					DataInspector:OpenReferenceTab(obj)
				end
			end)
		end
		listFrame.CanvasSize = UDim2.new(0, 0, 0, totalItems * ROW_HEIGHT)
	end
	function DataInspector:RenderDetail(detail)
		if not detailFrame then return end
		for _, child in ipairs(detailFrame:GetChildren()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then
				child:Destroy()
			end
		end
		local y = 0
		local lineH = 18
		local function addLine(text, color)
			createSimple("TextLabel", {
				Parent = detailFrame,
				Position = UDim2.new(0, 4, 0, y),
				Size = UDim2.new(1, -8, 0, lineH),
				BackgroundTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = color or Theme.Get("Text") or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = text,
				TextWrapped = true,
			})
			y = y + lineH
		end
		if not detail then
			addLine("No item selected")
			return
		end
		addLine("--- Function Detail ---", Theme.Get("Accent") or Color3.fromRGB(100, 180, 255))
		if detail.Info then
			addLine("Name: " .. (detail.Info.name or "anonymous"))
			addLine("Source: " .. (detail.ScriptPath or "unknown"))
			if detail.Info.currentline then
				addLine("Line: " .. detail.Info.currentline)
			end
			if detail.Info.numparams then
				addLine("Params: " .. detail.Info.numparams)
			end
		end
		y = y + 4
		addLine("Constants (" .. #detail.Constants .. "):", Theme.Get("Accent") or Color3.fromRGB(100, 180, 255))
		for i, c in ipairs(detail.Constants) do
			if i > 50 then
				addLine("  ... (" .. (#detail.Constants - 50) .. " more)")
				break
			end
			addLine("  [" .. i .. "] " .. type(c) .. " = " .. tostring(c):sub(1, 60))
		end
		y = y + 4
		local upvalCount = 0
		for _ in pairs(detail.Upvalues) do upvalCount = upvalCount + 1 end
		addLine("Upvalues (" .. upvalCount .. "):", Theme.Get("Accent") or Color3.fromRGB(100, 180, 255))
		local uvIdx = 0
		for k, v in pairs(detail.Upvalues) do
			uvIdx = uvIdx + 1
			if uvIdx > 50 then
				addLine("  ... (more)")
				break
			end
			addLine("  [" .. tostring(k) .. "] " .. type(v) .. " = " .. tostring(v):sub(1, 60))
		end
		if detail.Source then
			y = y + 4
			addLine("Decompiled Source:", Theme.Get("Accent") or Color3.fromRGB(100, 180, 255))
			for line in detail.Source:gmatch("[^\n]+") do
				addLine("  " .. line)
			end
		elseif hasDecompile() then
			addLine("(Decompiling...)", Theme.Get("Muted") or Color3.fromRGB(120,120,120))
		end
		y = y + 8
		local sigBtn = createSimple("TextButton", {
			Parent = detailFrame,
			Position = UDim2.new(0, 4, 0, y),
			Size = UDim2.new(0.5, -8, 0, 24),
			BackgroundColor3 = Color3.fromRGB(60, 100, 160),
			Font = Enum.Font.Code,
			TextSize = 12,
			TextColor3 = Color3.new(1,1,1),
			Text = "Copy Signature Finder",
		})
		sigBtn.MouseButton1Click:Connect(function()
			if selectedItem then
				local snippet = DataInspector:BuildSignature(selectedItem)
				if snippet and Env.setclipboard then
					Env.setclipboard(snippet)
					Notifications.Info("Signature snippet copied!", 2)
				end
			end
		end)
		local refBtn = createSimple("TextButton", {
			Parent = detailFrame,
			Position = UDim2.new(0.5, 4, 0, y),
			Size = UDim2.new(0.5, -8, 0, 24),
			BackgroundColor3 = Color3.fromRGB(100, 60, 160),
			Font = Enum.Font.Code,
			TextSize = 12,
			TextColor3 = Color3.new(1,1,1),
			Text = "Find References",
		})
		refBtn.MouseButton1Click:Connect(function()
			if selectedItem then
				DataInspector:OpenReferenceTab(selectedItem)
			end
		end)
		y = y + 30
		detailFrame.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	function DataInspector:RenderReferenceTabs()
		if #tabs == 0 then return end
		local current = tabs[#tabs]
		if not detailFrame then return end
		for _, child in ipairs(detailFrame:GetChildren()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local y = 0
		local lineH = 18
		createSimple("TextLabel", {
			Parent = detailFrame,
			Position = UDim2.new(0, 4, 0, y),
			Size = UDim2.new(1, -8, 0, lineH),
			BackgroundTransparency = 1,
			Font = Enum.Font.Code,
			TextSize = 12,
			TextColor3 = Theme.Get("Accent") or Color3.fromRGB(100, 180, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "References to: " .. current.Label,
		})
		y = y + lineH + 4
		for i, ref in ipairs(current.References) do
			if i > 200 then break end
			local btn = createSimple("TextButton", {
				Parent = detailFrame,
				Position = UDim2.new(0, 4, 0, y),
				Size = UDim2.new(1, -8, 0, lineH),
				BackgroundTransparency = 0.95,
				BackgroundColor3 = Theme.Get("Row") or Color3.fromRGB(35, 35, 40),
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "  " .. ref.Path .. " -> " .. tostring(ref.Key),
			})
			btn.MouseButton1Click:Connect(function()
				DataInspector:OpenReferenceTab(ref.Holder)
			end)
			y = y + lineH
		end
		if #current.References == 0 then
			createSimple("TextLabel", {
				Parent = detailFrame,
				Position = UDim2.new(0, 4, 0, y),
				Size = UDim2.new(1, -8, 0, lineH),
				BackgroundTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = Theme.Get("Muted") or Color3.fromRGB(120,120,120),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "  (no references found)",
			})
		end
		detailFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
	end
	function DataInspector:BuildUI()
		window = Lib.Window.new()
		window:SetTitle("Data Inspector")
		window:SetSize(750, 500)
		local content = window:GetContent()
		tabBar = createSimple("Frame", {
			Name = "TabBar",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = Theme.Get("TabBar") or Color3.fromRGB(30, 30, 35),
			BorderSizePixel = 0,
		})
		local tabDefs = {
			{Name = "GC Explorer", Key = "gc"},
			{Name = "Threads", Key = "threads"},
		}
		for i, td in ipairs(tabDefs) do
			local tabBtn = createSimple("TextButton", {
				Name = "Tab_" .. td.Key,
				Parent = tabBar,
				Position = UDim2.new(0, (i-1) * 100, 0, 2),
				Size = UDim2.new(0, 96, 0, 24),
				BackgroundColor3 = activeTab == td.Key and (Theme.Get("ActiveTab") or Color3.fromRGB(60, 60, 80)) or (Theme.Get("Tab") or Color3.fromRGB(40, 40, 50)),
				Font = Enum.Font.SourceSansBold,
				TextSize = 13,
				TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
				Text = td.Name,
			})
			tabBtn.MouseButton1Click:Connect(function()
				activeTab = td.Key
				DataInspector:SwitchTab(td.Key)
			end)
		end
		filterFrame = createSimple("Frame", {
			Name = "Filters",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 30),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = Theme.Get("Panel") or Color3.fromRGB(25, 25, 30),
			BorderSizePixel = 0,
		})
		local typeBtn = createSimple("TextButton", {
			Parent = filterFrame,
			Position = UDim2.new(0, 4, 0, 2),
			Size = UDim2.new(0, 80, 0, 22),
			BackgroundColor3 = Color3.fromRGB(50, 50, 60),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			Text = "Type: all",
		})
		local typeOptions = {nil, "function", "table", "userdata", "thread"}
		local typeIdx = 1
		typeBtn.MouseButton1Click:Connect(function()
			typeIdx = (typeIdx % #typeOptions) + 1
			filterType = typeOptions[typeIdx]
			typeBtn.Text = "Type: " .. (filterType or "all")
			DataInspector:ApplyFilters()
		end)
		local srcBox = createSimple("TextBox", {
			Parent = filterFrame,
			Position = UDim2.new(0, 88, 0, 2),
			Size = UDim2.new(0, 140, 0, 22),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			PlaceholderText = "Source...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		srcBox.FocusLost:Connect(function()
			filterSource = srcBox.Text
			DataInspector:ApplyFilters()
		end)
		local nameBox = createSimple("TextBox", {
			Parent = filterFrame,
			Position = UDim2.new(0, 232, 0, 2),
			Size = UDim2.new(0, 140, 0, 22),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			PlaceholderText = "Name...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		nameBox.FocusLost:Connect(function()
			filterName = nameBox.Text
			DataInspector:ApplyFilters()
		end)
		local upvalBox = createSimple("TextBox", {
			Parent = filterFrame,
			Position = UDim2.new(0, 376, 0, 2),
			Size = UDim2.new(0, 140, 0, 22),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			PlaceholderText = "Upvalue...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		upvalBox.FocusLost:Connect(function()
			filterUpvalue = upvalBox.Text
			DataInspector:ApplyFilters()
		end)
		local refreshBtn = createSimple("TextButton", {
			Parent = filterFrame,
			Position = UDim2.new(1, -64, 0, 2),
			Size = UDim2.new(0, 60, 0, 22),
			BackgroundColor3 = Color3.fromRGB(60, 120, 60),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			Text = "Refresh",
		})
		refreshBtn.MouseButton1Click:Connect(function()
			DataInspector:RefreshGC()
		end)
		listFrame = createSimple("ScrollingFrame", {
			Name = "List",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 58),
			Size = UDim2.new(0.5, -2, 1, -58),
			BackgroundColor3 = Theme.Get("Background") or Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		listFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			scrollOffset = listFrame.CanvasPosition.Y
			DataInspector:RenderList()
		end)
		detailFrame = createSimple("ScrollingFrame", {
			Name = "Detail",
			Parent = content,
			Position = UDim2.new(0.5, 2, 0, 58),
			Size = UDim2.new(0.5, -2, 1, -58),
			BackgroundColor3 = Theme.Get("Panel") or Color3.fromRGB(25, 25, 30),
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
	end
	function DataInspector:SwitchTab(key)
		activeTab = key
		if key == "gc" then
			DataInspector:RefreshGC()
		elseif key == "threads" then
			DataInspector:ShowThreads()
		end
	end
	function DataInspector:ShowThreads()
		local threads = DataInspector:GetThreads()
		visibleRows = {}
		for _, t in ipairs(threads) do
			table.insert(visibleRows, t)
		end
		totalItems = #visibleRows
		if not listFrame then return end
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local y = 0
		for i, t in ipairs(threads) do
			local text = string.format("[%d] %s - %s", t.Index, t.Status, t.Traceback)
			createSimple("TextButton", {
				Name = "Thread_" .. i,
				Parent = listFrame,
				Position = UDim2.new(0, 0, 0, y),
				Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
				BackgroundTransparency = i % 2 == 0 and 0.95 or 1,
				BackgroundColor3 = Theme.Get("Row") or Color3.fromRGB(35, 35, 40),
				BorderSizePixel = 0,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "  " .. text,
			})
			y = y + ROW_HEIGHT
		end
		listFrame.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	function DataInspector:Init()
		DataInspector:BuildUI()
		table.insert(connections, Store.On("explore_data", function(value)
			if value then
				if type(value) == "function" then
					DataInspector:ShowFunctionDetail(value)
				else
					DataInspector:OpenReferenceTab(value)
				end
			else
				DataInspector:RefreshGC()
			end
		end))
		if hasGC() then
			DataInspector:RefreshGC()
		end
	end
	function DataInspector:Destroy()
		for _, conn in ipairs(connections) do
			if typeof(conn) == "RBXScriptConnection" then
				conn:Disconnect()
			end
		end
		connections = {}
		decompileCache = {}
		tabs = {}
		if window then
			window:Close()
		end
	end
	DataInspector:Init()
	return DataInspector
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["NetworkSpy"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main; Lib = data.Lib; Apps = data.Apps
	Settings = data.Settings; Theme = data.Theme; Store = data.Store
	Keybinds = data.Keybinds; Notifications = data.Notifications; Env = data.Env
	API = data.API; RMD = data.RMD; env = data.Env or data.env
	service = data.service; plr = data.plr; create = data.create; createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local function main()
	local NetworkSpy = {}
	local logs = {}
	local maxLogs = 2000
	local filterType = "All"
	local searchText = ""
	local connections = {}
	local paused = false
	local window, logFrame, filterBar
	local function ts() return string.format("%.3f", os.clock()) end
	local function fullPath(inst)
		if not inst then return "nil" end
		local p = {}
		local c = inst
		while c and c ~= game do p[#p+1] = c.Name; c = c.Parent end
		local r = {} for i = #p, 1, -1 do r[#r+1] = p[i] end
		return "game." .. table.concat(r, ".")
	end
	local function trunc(s, n) s = tostring(s); return #s > (n or 120) and s:sub(1, n or 120) .. "..." or s end
	local function serArgs(args)
		if not args then return "nil" end
		local p = {}
		for i, v in ipairs(args) do
			local t = typeof(v)
			if t == "Instance" then p[i] = fullPath(v)
			elseif t == "string" then p[i] = '"'..v:sub(1,80)..'"'
			else p[i] = tostring(v) end
		end
		return "{"..table.concat(p, ", ").."}"
	end
	local function matchesFilter(e)
		if filterType ~= "All" and e.Type ~= filterType then return false end
		if searchText ~= "" and not (e.Details or ""):lower():find(searchText:lower(), 1, true) then return false end
		return true
	end
	local function addLog(logType, details, data)
		if paused then return end
		logs[#logs+1] = {Timestamp = ts(), Type = logType, Details = details, Data = data, Expanded = false}
		if #logs > maxLogs then table.remove(logs, 1) end
		NetworkSpy:Render()
	end
	local function hookInbound()
		if not (Env.Capabilities and Env.Capabilities.Connections) then return end
		local function scan(container)
			for _, child in ipairs(container:GetDescendants()) do
				if child:IsA("RemoteEvent") then
					local c = child.OnClientEvent:Connect(function(...)
						addLog("Inbound", "[Event] "..fullPath(child).." "..serArgs({...}), {Instance=child, Args={...}})
					end)
					connections[#connections+1] = c
				elseif child:IsA("RemoteFunction") then
					pcall(function()
						local old = child.OnClientInvoke
						child.OnClientInvoke = function(...)
							addLog("Inbound", "[Invoke] "..fullPath(child).." "..serArgs({...}), {Instance=child, Args={...}})
							if old then return old(...) end
						end
					end)
				end
			end
		end
		pcall(function() scan(game:GetService("ReplicatedStorage")) end)
		pcall(function() scan(game:GetService("Workspace")) end)
		connections[#connections+1] = game.DescendantAdded:Connect(function(child)
			if child:IsA("RemoteEvent") then
				local c = child.OnClientEvent:Connect(function(...)
					addLog("Inbound", "[Event] "..fullPath(child).." "..serArgs({...}), {Instance=child, Args={...}})
				end)
				connections[#connections+1] = c
			end
		end)
	end
	local function hookHTTP()
		if not Env.hookfunction then return end
		pcall(function()
			local hs = service.HttpService
			local oldReq = hs.RequestAsync
			Env.hookfunction(oldReq, function(self, req)
				local url = type(req) == "table" and req.Url or tostring(req)
				local method = type(req) == "table" and req.Method or "GET"
				local ok, res = pcall(oldReq, self, req)
				local status = ok and res and res.StatusCode or "Error"
				addLog("HTTP", string.format("[%s] %s -> %s", method, trunc(url, 60), tostring(status)), {URL=url, Method=method, Response=res, Success=ok})
				if ok then return res else error(res) end
			end)
		end)
		pcall(function()
			local oldGet = game.HttpGet
			Env.hookfunction(oldGet, function(self, url, ...)
				local ok, res = pcall(oldGet, self, url, ...)
				addLog("HTTP", "[GET] "..trunc(url, 60).." -> "..trunc(ok and res or "Error", 40), {URL=url, Method="GET", Success=ok})
				if ok then return res else error(res) end
			end)
		end)
	end
	local function hookWS()
		if not (Env.Capabilities and Env.Capabilities.WebSocket and Env.hookfunction) then return end
		pcall(function()
			local WS = Env.WebSocket or WebSocket
			if not WS then return end
			local oldConnect = WS.connect or WS.Connect
			if not oldConnect then return end
			Env.hookfunction(oldConnect, function(url, ...)
				local socket = oldConnect(url, ...)
				addLog("WS", "[Connect] "..trunc(url, 80), {URL=url})
				if socket and socket.Send then
					local oldSend = socket.Send
					socket.Send = function(s, msg, ...)
						addLog("WS", "[Send] "..trunc(url, 40).." -> "..trunc(msg, 60), {Direction="out", Message=msg})
						return oldSend(s, msg, ...)
					end
				end
				return socket
			end)
		end)
	end
	function NetworkSpy:Render()
		if not logFrame then return end
		for _, c in ipairs(logFrame:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
		local y, lh = 0, 20
		for i, e in ipairs(logs) do
			if matchesFilter(e) then
				local color = e.Type == "Inbound" and Color3.fromRGB(100,200,255) or e.Type == "HTTP" and Color3.fromRGB(255,200,80) or Color3.fromRGB(150,255,150)
				local btn = createSimple("TextButton", {
					Parent = logFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,lh),
					BackgroundTransparency = i%2==0 and 0.95 or 1, BackgroundColor3 = Color3.fromRGB(35,35,35),
					BorderSizePixel = 0, Font = Enum.Font.Code, TextSize = 11,
					TextColor3 = color, TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Text = " ["..e.Timestamp.."]["..e.Type.."] "..e.Details, AutoButtonColor = true,
				})
				btn.MouseButton1Click:Connect(function()
					if Env.setclipboard then Env.setclipboard(e.Details) end
				end)
				y = y + lh
			end
		end
		logFrame.CanvasSize = UDim2.new(0,0,0,y)
	end
	function NetworkSpy:BuildUI()
		window = Lib.Window.new(); window:SetTitle("Network Spy"); window:SetSize(680, 400)
		local content = window:GetContent()
		local typeBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0,80,0,26),
			BackgroundColor3 = Color3.fromRGB(40,40,40), Font = Enum.Font.Code, TextSize = 12,
			TextColor3 = Color3.new(1,1,1), Text = "All",
		})
		typeBtn.MouseButton1Click:Connect(function()
			local t = {"All","Inbound","HTTP","WS"}
			local i = (table.find(t, filterType) or 1) % #t + 1
			filterType = t[i]; typeBtn.Text = filterType; NetworkSpy:Render()
		end)
		filterBar = createSimple("TextBox", {
			Parent = content, Position = UDim2.new(0,84,0,0), Size = UDim2.new(1,-184,0,26),
			BackgroundColor3 = Color3.fromRGB(30,30,30), Font = Enum.Font.Code, TextSize = 12,
			TextColor3 = Color3.new(1,1,1), PlaceholderText = "Search...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100), TextXAlignment = Enum.TextXAlignment.Left, Text = "",
		})
		filterBar:GetPropertyChangedSignal("Text"):Connect(function() searchText = filterBar.Text; NetworkSpy:Render() end)
		local pauseBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-96,0,0), Size = UDim2.new(0,46,0,26),
			BackgroundColor3 = Color3.fromRGB(60,60,60), Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = Color3.new(1,1,1), Text = "Pause",
		})
		pauseBtn.MouseButton1Click:Connect(function() paused = not paused; pauseBtn.Text = paused and "Resume" or "Pause" end)
		local clearBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-46,0,0), Size = UDim2.new(0,46,0,26),
			BackgroundColor3 = Color3.fromRGB(140,40,40), Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = Color3.new(1,1,1), Text = "Clear",
		})
		clearBtn.MouseButton1Click:Connect(function() logs = {}; NetworkSpy:Render() end)
		logFrame = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0,0,0,30), Size = UDim2.new(1,0,1,-30),
			BackgroundColor3 = Color3.fromRGB(18,18,18), BorderSizePixel = 0,
			ScrollBarThickness = 6, CanvasSize = UDim2.new(0,0,0,0), ScrollingDirection = Enum.ScrollingDirection.Y,
		})
	end
	function NetworkSpy:Init()
		pcall(function() if Settings.NetworkSpy then maxLogs = Settings.NetworkSpy.MaxLogs or maxLogs end end)
		NetworkSpy:BuildUI(); hookInbound(); hookHTTP(); hookWS()
	end
	function NetworkSpy:Destroy()
		for _, c in ipairs(connections) do c:Disconnect() end
		connections = {}; if window then window:Close() end
	end
	NetworkSpy:Init()
	return NetworkSpy
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["APIReference"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main; Lib = data.Lib; Apps = data.Apps
	Settings = data.Settings; Theme = data.Theme; Store = data.Store
	Keybinds = data.Keybinds; Notifications = data.Notifications; Env = data.Env
	API = data.API; RMD = data.RMD; env = data.Env or data.env
	service = data.service; plr = data.plr; create = data.create; createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local function main()
	local APIRef = {}
	local classes, enums = {}, {}
	local selectedClass, selectedEnum = nil, nil
	local searchQuery = ""
	local searchResults = {}
	local viewMode = "Classes"
	local window, classListFrame, memberFrame, enumListFrame, enumDetailFrame, searchFrame, searchBar
	local function loadData()
		if API and API.Classes then
			for name, data in pairs(API.Classes) do
				classes[#classes+1] = {Name = name, Data = data, Superclass = data.Superclass}
			end
			table.sort(classes, function(a,b) return a.Name < b.Name end)
		end
		if API and API.Enums then
			for name, data in pairs(API.Enums) do
				enums[#enums+1] = {Name = name, Items = data.Items or data}
			end
			table.sort(enums, function(a,b) return a.Name < b.Name end)
		end
	end
	local function fuzzy(q, s)
		if not q or q == "" then return true end
		q, s = q:lower(), s:lower()
		local qi = 1
		for i = 1, #s do
			if s:sub(i,i) == q:sub(qi,qi) then qi = qi+1; if qi > #q then return true end end
		end
		return false
	end
	local function getMembers(className)
		local d = API and API.Classes and API.Classes[className]
		if not d or not d.Members then return {},{},{},{} end
		local props, meths, evts, cbs = {},{},{},{}
		for _, m in ipairs(d.Members) do
			if m.MemberType == "Property" then props[#props+1] = m
			elseif m.MemberType == "Function" then meths[#meths+1] = m
			elseif m.MemberType == "Event" then evts[#evts+1] = m
			elseif m.MemberType == "Callback" then cbs[#cbs+1] = m end
		end
		return props, meths, evts, cbs
	end
	local function getTags(m)
		local t = {}
		if m.Tags then for _, tag in ipairs(m.Tags) do t[#t+1] = tag end end
		if m.Security and m.Security ~= "None" then t[#t+1] = "Security:"..tostring(m.Security) end
		return t
	end
	local function getRMDDesc(cls, mem)
		if RMD and RMD.Classes and RMD.Classes[cls] and RMD.Classes[cls].Members then
			local entry = RMD.Classes[cls].Members[mem]
			if entry then return entry.Description or "" end
		end
		return ""
	end
	local function doSearch(q)
		searchResults = {}
		if not q or q == "" then return end
		for _, cls in ipairs(classes) do
			if fuzzy(q, cls.Name) then searchResults[#searchResults+1] = {Type="Class", Name=cls.Name} end
			if cls.Data and cls.Data.Members then
				for _, m in ipairs(cls.Data.Members) do
					if fuzzy(q, m.Name) then
						searchResults[#searchResults+1] = {Type="Member", Name=m.Name, Class=cls.Name, MemberType=m.MemberType}
					end
				end
			end
			if #searchResults > 150 then break end
		end
		for _, en in ipairs(enums) do
			if fuzzy(q, en.Name) then searchResults[#searchResults+1] = {Type="Enum", Name=en.Name} end
		end
	end
	local function clear(frame)
		if not frame then return end
		for _, c in ipairs(frame:GetChildren()) do
			if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
		end
	end
	function APIRef:RenderClassList()
		if not classListFrame then return end; clear(classListFrame)
		local y, h = 0, 20
		for _, cls in ipairs(classes) do
			if fuzzy(searchQuery, cls.Name) then
				local b = createSimple("TextButton", {
					Parent = classListFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,h),
					BackgroundTransparency = selectedClass == cls.Name and 0.7 or 1,
					BackgroundColor3 = Theme.Get("Accent") or Color3.fromRGB(60,120,200),
					BorderSizePixel = 0, Font = Enum.Font.Code, TextSize = 12,
					TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
					TextXAlignment = Enum.TextXAlignment.Left, Text = " "..cls.Name, AutoButtonColor = true,
				})
				b.MouseButton1Click:Connect(function()
					selectedClass = cls.Name; APIRef:RenderClassList(); APIRef:RenderMembers(cls.Name)
				end)
				y = y + h
			end
		end
		classListFrame.CanvasSize = UDim2.new(0,0,0,y)
	end
	function APIRef:RenderMembers(className)
		if not memberFrame then return end; clear(memberFrame)
		local props, meths, evts, cbs = getMembers(className)
		local y = 0
		local super = API.Classes[className] and API.Classes[className].Superclass or ""
		createSimple("TextLabel", {
			Parent = memberFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,24),
			BackgroundTransparency = 1, Font = Enum.Font.SourceSansBold, TextSize = 15,
			TextColor3 = Theme.Get("Text") or Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left,
			Text = " "..className..(super ~= "" and (" < "..super) or ""),
		})
		y = y + 26
		local function section(title, members)
			if #members == 0 then return end
			createSimple("TextLabel", {
				Parent = memberFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,20),
				BackgroundColor3 = Color3.fromRGB(30,30,40), BackgroundTransparency = 0.5,
				BorderSizePixel = 0, Font = Enum.Font.SourceSansBold, TextSize = 12,
				TextColor3 = Theme.Get("Accent") or Color3.fromRGB(100,180,255),
				TextXAlignment = Enum.TextXAlignment.Left, Text = "  "..title.." ("..#members..")",
			})
			y = y + 22
			for _, m in ipairs(members) do
				local tags = getTags(m)
				local tagStr = #tags > 0 and " ["..table.concat(tags,", ").."]" or ""
				local typeStr = m.ValueType and (" : "..(m.ValueType.Name or tostring(m.ValueType))) or ""
				local desc = getRMDDesc(className, m.Name)
				local btn = createSimple("TextButton", {
					Parent = memberFrame, Position = UDim2.new(0,6,0,y), Size = UDim2.new(1,-10,0,16),
					BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11,
					TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
					TextXAlignment = Enum.TextXAlignment.Left, Text = m.Name..typeStr..tagStr, AutoButtonColor = true,
				})
				if m.MemberType == "Property" then
					btn.MouseButton1Click:Connect(function()
						Store.Emit("open_property", {Class=className, Property=m.Name})
					end)
				end
				y = y + 16
				if desc ~= "" then
					createSimple("TextLabel", {
						Parent = memberFrame, Position = UDim2.new(0,14,0,y), Size = UDim2.new(1,-18,0,14),
						BackgroundTransparency = 1, Font = Enum.Font.SourceSansItalic, TextSize = 10,
						TextColor3 = Theme.Get("Muted") or Color3.fromRGB(140,140,140),
						TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = desc,
					})
					y = y + 14
				end
			end
		end
		section("Properties", props); section("Methods", meths); section("Events", evts); section("Callbacks", cbs)
		memberFrame.CanvasSize = UDim2.new(0,0,0,y)
	end
	function APIRef:RenderEnumList()
		if not enumListFrame then return end; clear(enumListFrame)
		local y, h = 0, 20
		for _, en in ipairs(enums) do
			if fuzzy(searchQuery, en.Name) then
				local b = createSimple("TextButton", {
					Parent = enumListFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,h),
					BackgroundTransparency = selectedEnum == en.Name and 0.7 or 1,
					BackgroundColor3 = Theme.Get("Accent") or Color3.fromRGB(60,120,200),
					BorderSizePixel = 0, Font = Enum.Font.Code, TextSize = 12,
					TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
					TextXAlignment = Enum.TextXAlignment.Left, Text = " "..en.Name, AutoButtonColor = true,
				})
				b.MouseButton1Click:Connect(function()
					selectedEnum = en.Name; APIRef:RenderEnumList(); APIRef:RenderEnumDetail(en)
				end)
				y = y + h
			end
		end
		enumListFrame.CanvasSize = UDim2.new(0,0,0,y)
	end
	function APIRef:RenderEnumDetail(en)
		if not enumDetailFrame then return end; clear(enumDetailFrame)
		local y = 0
		createSimple("TextLabel", {
			Parent = enumDetailFrame, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,0,22),
			BackgroundTransparency = 1, Font = Enum.Font.SourceSansBold, TextSize = 14,
			TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
			TextXAlignment = Enum.TextXAlignment.Left, Text = " Enum."..en.Name,
		})
		y = 24
		if type(en.Items) == "table" then
			for name, val in pairs(en.Items) do
				local v = type(val) == "table" and tostring(val.Value or val) or tostring(val)
				createSimple("TextLabel", {
					Parent = enumDetailFrame, Position = UDim2.new(0,8,0,y), Size = UDim2.new(1,-12,0,16),
					BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11,
					TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
					TextXAlignment = Enum.TextXAlignment.Left, Text = name.." = "..v,
				})
				y = y + 16
			end
		end
		enumDetailFrame.CanvasSize = UDim2.new(0,0,0,y)
	end
	function APIRef:RenderSearch()
		if not searchFrame then return end; clear(searchFrame)
		local y, h = 0, 20
		for i, r in ipairs(searchResults) do
			if i > 150 then break end
			local text = r.Type == "Class" and "[Class] "..r.Name
				or r.Type == "Member" and "["..r.MemberType.."] "..r.Class.."."..r.Name
				or "[Enum] "..r.Name
			local b = createSimple("TextButton", {
				Parent = searchFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,h),
				BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 12,
				TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left, Text = " "..text, AutoButtonColor = true,
			})
			b.MouseButton1Click:Connect(function()
				if r.Type == "Class" or r.Type == "Member" then
					viewMode = "Classes"; selectedClass = r.Class or r.Name
					APIRef:SwitchView(); APIRef:RenderMembers(selectedClass)
				else viewMode = "Enums"; APIRef:SwitchView() end
			end)
			y = y + h
		end
		searchFrame.CanvasSize = UDim2.new(0,0,0,y)
	end
	function APIRef:SwitchView()
		if classListFrame then classListFrame.Visible = viewMode == "Classes" end
		if memberFrame then memberFrame.Visible = viewMode == "Classes" end
		if enumListFrame then enumListFrame.Visible = viewMode == "Enums" end
		if enumDetailFrame then enumDetailFrame.Visible = viewMode == "Enums" end
		if searchFrame then searchFrame.Visible = viewMode == "Search" end
		if viewMode == "Classes" then APIRef:RenderClassList()
		elseif viewMode == "Enums" then APIRef:RenderEnumList()
		else APIRef:RenderSearch() end
	end
	function APIRef:BuildUI()
		window = Lib.Window.new(); window:SetTitle("API Reference"); window:SetSize(720, 480)
		local content = window:GetContent()
		searchBar = createSimple("TextBox", {
			Parent = content, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,-140,0,26),
			BackgroundColor3 = Color3.fromRGB(30,30,30), Font = Enum.Font.Code, TextSize = 13,
			TextColor3 = Color3.new(1,1,1), PlaceholderText = "Search classes, members, enums...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100), TextXAlignment = Enum.TextXAlignment.Left, Text = "",
		})
		searchBar:GetPropertyChangedSignal("Text"):Connect(function()
			searchQuery = searchBar.Text
			if searchQuery ~= "" then viewMode = "Search"; doSearch(searchQuery) else viewMode = "Classes" end
			APIRef:SwitchView()
		end)
		local clsBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-136,0,0), Size = UDim2.new(0,66,0,26),
			BackgroundColor3 = Color3.fromRGB(50,50,70), Font = Enum.Font.Code, TextSize = 12,
			TextColor3 = Color3.new(1,1,1), Text = "Classes",
		})
		clsBtn.MouseButton1Click:Connect(function() viewMode = "Classes"; APIRef:SwitchView() end)
		local enBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-66,0,0), Size = UDim2.new(0,66,0,26),
			BackgroundColor3 = Color3.fromRGB(50,50,70), Font = Enum.Font.Code, TextSize = 12,
			TextColor3 = Color3.new(1,1,1), Text = "Enums",
		})
		enBtn.MouseButton1Click:Connect(function() viewMode = "Enums"; APIRef:SwitchView() end)
		local sf = function(name, pos, size, vis)
			return createSimple("ScrollingFrame", {
				Name = name, Parent = content, Position = pos, Size = size,
				BackgroundColor3 = Color3.fromRGB(20,20,22), BorderSizePixel = 0,
				ScrollBarThickness = 5, CanvasSize = UDim2.new(0,0,0,0),
				ScrollingDirection = Enum.ScrollingDirection.Y, Visible = vis,
			})
		end
		classListFrame = sf("ClassList", UDim2.new(0,0,0,30), UDim2.new(0.28,0,1,-30), true)
		memberFrame = sf("Members", UDim2.new(0.28,4,0,30), UDim2.new(0.72,-4,1,-30), true)
		enumListFrame = sf("EnumList", UDim2.new(0,0,0,30), UDim2.new(0.28,0,1,-30), false)
		enumDetailFrame = sf("EnumDetail", UDim2.new(0.28,4,0,30), UDim2.new(0.72,-4,1,-30), false)
		searchFrame = sf("Search", UDim2.new(0,0,0,30), UDim2.new(1,0,1,-30), false)
	end
	function APIRef:Init()
		loadData(); APIRef:BuildUI(); APIRef:RenderClassList()
	end
	function APIRef:Destroy() if window then window:Close() end end
	APIRef:Init()
	return APIRef
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["PluginAPI"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main; Lib = data.Lib; Apps = data.Apps
	Settings = data.Settings; Theme = data.Theme; Store = data.Store
	Keybinds = data.Keybinds; Notifications = data.Notifications; Env = data.Env
	API = data.API; RMD = data.RMD; env = data.Env or data.env
	service = data.service; plr = data.plr; create = data.create; createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local function main()
	local PluginAPI = {}
	local plugins = {}
	local pluginOrder = {}
	local rightClickHandlers = {}
	local searchFilterHandlers = {}
	local propertyEditors = {}
	local terminalCommands = {}
	local errorLogs = {}
	local pollThread = nil
	local lastHash = ""
	local window, pluginListFrame, errorFrame
	local function ts() return string.format("%.2f", os.clock()) end
	local function logErr(name, msg)
		errorLogs[#errorLogs+1] = {Timestamp=ts(), PluginName=name, Message=tostring(msg)}
		if #errorLogs > 200 then table.remove(errorLogs, 1) end
	end
	local function readManifest(folder)
		local path = folder.."/plugin.json"
		if Env.isfile and Env.isfile(path) and Env.readfile then
			local ok, c = pcall(Env.readfile, path)
			if ok then
				local ok2, m = pcall(function() return service.HttpService:JSONDecode(c) end)
				if ok2 then return m end
			end
		end
		return {name="Unknown", version="0.0.0", author="Unknown", permissions={}}
	end
	local function getFolders()
		if not Env.listfiles then return {} end
		local ok, files = pcall(Env.listfiles, "deux/plugins")
		if not ok then return {} end
		local out = {}
		for _, p in ipairs(files or {}) do
			if Env.isfolder and Env.isfolder(p) then out[#out+1] = p end
		end
		return out
	end
	local function makeSandbox(name, manifest)
		local sb = {}
		sb.Explorer = {
			AddRightClick = function(n, cb)
				rightClickHandlers[#rightClickHandlers+1] = {Name=n, Callback=cb, PluginName=name}
			end,
			AddSearchFilter = function(n, handler)
				searchFilterHandlers[#searchFilterHandlers+1] = {Name=n, Handler=handler, PluginName=name}
			end,
		}
		sb.Properties = {
			AddEditor = function(typeName, editorFn)
				propertyEditors[typeName] = {EditorFn=editorFn, PluginName=name}
			end,
		}
		sb.Terminal = {
			AddCommand = function(def)
				if not def or not def.Name or not def.Run then logErr(name, "Invalid command def"); return end
				def.Category = def.Category or ("Plugin:"..name)
				terminalCommands[#terminalCommands+1] = {Def=def, PluginName=name}
				if Apps and Apps.Terminal and Apps.Terminal.RegisterCommand then Apps.Terminal:RegisterCommand(def) end
			end,
		}
		sb.Window = {
			new = function(title, size)
				local w = Lib.Window.new()
				w:SetTitle("["..name.."] "..(title or "Window"))
				if size then w:SetSize(size.X or size[1] or 400, size.Y or size[2] or 300) end
				return w
			end,
		}
		sb.Notify = function(msg, sev) Notifications.Info("[" .. name .. "] " .. tostring(msg), sev or 3) end
		sb.Settings = {
			Register = function(pn, schema)
				pcall(function()
					if Settings.Plugins then
						Settings.Plugins[pn or name] = Settings.Plugins[pn or name] or {}
						if schema and schema.defaults then
							for k,v in pairs(schema.defaults) do
								if Settings.Plugins[pn or name][k] == nil then Settings.Plugins[pn or name][k] = v end
							end
						end
					end
				end)
			end,
		}
		sb.Theme = setmetatable({}, {__index = Theme, __newindex = function() logErr(name, "Theme is read-only") end})
		sb.Store = setmetatable({}, {
			__index = function(_, k)
				if k == "Get" then return function(key) return Store.Get(key) end
				elseif k == "GetSelection" then return Store.GetSelection
				elseif k == "On" or k == "Listen" then return function(ev, cb) return Store.On(ev, cb) end
				elseif k == "Subscribe" then return function(key, cb) return Store.Subscribe(key, cb) end
				end
			end,
			__newindex = function() logErr(name, "Store is read-only") end,
		})
		sb.Env = {
			setclipboard = Env.setclipboard, getclipboard = Env.getclipboard,
			readfile = Env.readfile, writefile = Env.writefile,
			isfile = Env.isfile, listfiles = Env.listfiles,
			isfolder = Env.isfolder, makefolder = Env.makefolder,
		}
		return sb
	end
	local function unloadPlugin(name)
		local entry = plugins[name]
		if not entry then return end
		for i = #rightClickHandlers, 1, -1 do if rightClickHandlers[i].PluginName == name then table.remove(rightClickHandlers, i) end end
		for i = #searchFilterHandlers, 1, -1 do if searchFilterHandlers[i].PluginName == name then table.remove(searchFilterHandlers, i) end end
		for tn, ed in pairs(propertyEditors) do if ed.PluginName == name then propertyEditors[tn] = nil end end
		for i = #terminalCommands, 1, -1 do if terminalCommands[i].PluginName == name then table.remove(terminalCommands, i) end end
		entry.Enabled = false; plugins[name] = nil
	end
	local function loadPlugin(folder)
		local manifest = readManifest(folder)
		local name = manifest.name or folder:match("([^/\\]+)$") or "Unknown"
		if plugins[name] and plugins[name].Enabled then unloadPlugin(name) end
		local initPath = folder.."/init.lua"
		if not (Env.isfile and Env.isfile(initPath)) then logErr(name, "No init.lua"); return end
		local source; pcall(function() source = Env.readfile(initPath) end)
		if not source then logErr(name, "Failed to read init.lua"); return end
		local sandbox = makeSandbox(name, manifest)
		local fn, err = Env.loadstring(source, "@plugin/"..name)
		if not fn then logErr(name, "Compile: "..tostring(err)); return end
		local pEnv = setmetatable({
			Dex = sandbox, print = function() end,
			warn = function(m) logErr(name, "[warn] "..tostring(m)) end,
			error = function(m) logErr(name, "[error] "..tostring(m)) end,
		}, {__index = getfenv and getfenv() or _G})
		if setfenv then setfenv(fn, pEnv) end
		local ok2, runErr = pcall(fn)
		if not ok2 then logErr(name, "Runtime: "..tostring(runErr)); return end
		plugins[name] = {Name=name, Folder=folder, Manifest=manifest, Sandbox=sandbox, Enabled=true, LoadedAt=os.clock()}
		if not table.find(pluginOrder, name) then pluginOrder[#pluginOrder+1] = name end
		Notifications.Info("Loaded: "..name.." v"..(manifest.version or "?"), 2)
	end
	function PluginAPI:LoadAll()
		for _, f in ipairs(getFolders()) do loadPlugin(f) end
		PluginAPI:RenderList()
	end
	function PluginAPI:Reload(name)
		local e = plugins[name]
		if e then local f = e.Folder; unloadPlugin(name); loadPlugin(f) end
		PluginAPI:RenderList()
	end
	local function startPoll()
		if pollThread then return end
		pollThread = task.spawn(function()
			while true do
				task.wait(5)
				if not (Settings.Plugins and Settings.Plugins.AutoLoad) then continue end
				local folders = getFolders()
				local hash = table.concat(folders, "|")
				if hash ~= lastHash then lastHash = hash; PluginAPI:LoadAll() end
			end
		end)
	end
	function PluginAPI:GetRightClickHandlers() return rightClickHandlers end
	function PluginAPI:GetSearchFilterHandlers() return searchFilterHandlers end
	function PluginAPI:GetPropertyEditor(tn) return propertyEditors[tn] end
	function PluginAPI:GetErrorLogs() return errorLogs end
	function PluginAPI:RenderList()
		if not pluginListFrame then return end
		for _, c in ipairs(pluginListFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
		local y, rh = 0, 34
		for _, name in ipairs(pluginOrder) do
			local entry = plugins[name]; if not entry then continue end
			local row = createSimple("Frame", {
				Parent = pluginListFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,rh),
				BackgroundColor3 = Color3.fromRGB(35,35,40), BackgroundTransparency = 0.5, BorderSizePixel = 0,
			})
			createSimple("TextLabel", {
				Parent = row, Position = UDim2.new(0,6,0,2), Size = UDim2.new(0.5,0,0,14),
				BackgroundTransparency = 1, Font = Enum.Font.SourceSansBold, TextSize = 12,
				TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left,
				Text = entry.Name.." v"..(entry.Manifest.version or "?"),
			})
			createSimple("TextLabel", {
				Parent = row, Position = UDim2.new(0,6,0,16), Size = UDim2.new(0.5,0,0,12),
				BackgroundTransparency = 1, Font = Enum.Font.SourceSans, TextSize = 10,
				TextColor3 = Color3.fromRGB(140,140,140), TextXAlignment = Enum.TextXAlignment.Left,
				Text = "by "..(entry.Manifest.author or "?"),
			})
			local tog = createSimple("TextButton", {
				Parent = row, Position = UDim2.new(0.6,0,0,7), Size = UDim2.new(0,42,0,20),
				BackgroundColor3 = entry.Enabled and Color3.fromRGB(50,160,50) or Color3.fromRGB(160,50,50),
				Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.new(1,1,1),
				Text = entry.Enabled and "ON" or "OFF",
			})
			tog.MouseButton1Click:Connect(function()
				if entry.Enabled then unloadPlugin(name) else loadPlugin(entry.Folder) end
				PluginAPI:RenderList()
			end)
			local rl = createSimple("TextButton", {
				Parent = row, Position = UDim2.new(0.78,0,0,7), Size = UDim2.new(0,46,0,20),
				BackgroundColor3 = Color3.fromRGB(60,80,140), Font = Enum.Font.Code, TextSize = 10,
				TextColor3 = Color3.new(1,1,1), Text = "Reload",
			})
			rl.MouseButton1Click:Connect(function() PluginAPI:Reload(name) end)
			y = y + rh + 2
		end
		pluginListFrame.CanvasSize = UDim2.new(0,0,0,y)
	end
	function PluginAPI:RenderErrors()
		if not errorFrame then return end
		for _, c in ipairs(errorFrame:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
		local y = 0
		for i = math.max(1, #errorLogs-50), #errorLogs do
			local e = errorLogs[i]
			if e then
				createSimple("TextLabel", {
					Parent = errorFrame, Position = UDim2.new(0,4,0,y), Size = UDim2.new(1,-8,0,14),
					BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 10,
					TextColor3 = Color3.fromRGB(255,120,120), TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Text = "["..e.Timestamp.."] "..e.PluginName..": "..e.Message,
				})
				y = y + 14
			end
		end
		errorFrame.CanvasSize = UDim2.new(0,0,0,y)
	end
	function PluginAPI:BuildUI()
		window = Lib.Window.new(); window:SetTitle("Plugin Manager"); window:SetSize(500, 360)
		local content = window:GetContent()
		local loadBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0,70,0,26),
			BackgroundColor3 = Color3.fromRGB(50,100,50), Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = Color3.new(1,1,1), Text = "Load All",
		})
		loadBtn.MouseButton1Click:Connect(function() PluginAPI:LoadAll() end)
		local errBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(0,74,0,0), Size = UDim2.new(0,60,0,26),
			BackgroundColor3 = Color3.fromRGB(100,50,50), Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = Color3.new(1,1,1), Text = "Errors",
		})
		errBtn.MouseButton1Click:Connect(function()
			pluginListFrame.Visible = not pluginListFrame.Visible
			errorFrame.Visible = not errorFrame.Visible
			PluginAPI:RenderErrors()
		end)
		pluginListFrame = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0,0,0,30), Size = UDim2.new(1,0,1,-30),
			BackgroundColor3 = Color3.fromRGB(20,20,22), BorderSizePixel = 0,
			ScrollBarThickness = 5, CanvasSize = UDim2.new(0,0,0,0),
			ScrollingDirection = Enum.ScrollingDirection.Y, Visible = true,
		})
		errorFrame = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0,0,0,30), Size = UDim2.new(1,0,1,-30),
			BackgroundColor3 = Color3.fromRGB(25,18,18), BorderSizePixel = 0,
			ScrollBarThickness = 5, CanvasSize = UDim2.new(0,0,0,0),
			ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false,
		})
	end
	function PluginAPI:Init()
		PluginAPI:BuildUI(); PluginAPI:LoadAll()
		pcall(function() if Settings.Plugins and Settings.Plugins.AutoLoad then startPoll() end end)
	end
	function PluginAPI:Destroy()
		for name in pairs(plugins) do unloadPlugin(name) end
		if pollThread then pcall(task.cancel, pollThread); pollThread = nil end
		if window then window:Close() end
	end
	PluginAPI:Init()
	return PluginAPI
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["WorkspaceTools"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main; Lib = data.Lib; Apps = data.Apps
	Settings = data.Settings; Theme = data.Theme; Store = data.Store
	Keybinds = data.Keybinds; Notifications = data.Notifications; Env = data.Env
	API = data.API; RMD = data.RMD; env = data.Env or data.env
	service = data.service; plr = data.plr; create = data.create; createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local function main()
	local WSTools = {}
	local freecamActive, noclipActive, highlightActive = false, false, false
	local highlights = {}
	local connections = {}
	local keysDown = {}
	local freecamSpeed, freecamFOV = 1, 70
	local originalFOV = nil
	local freecamConn, inputConn1, inputConn2, noclipConn = nil, nil, nil, nil
	local originalCollisions = {}
	local animTarget = nil
	local window, toolbarFrame, animPanel
	local UIS = service.UserInputService
	local RunService = service.RunService
	local Camera = workspace.CurrentCamera
	local function startFreecam()
		if freecamActive then return end
		freecamActive = true; originalFOV = Camera.FieldOfView
		pcall(function()
			if Settings.WorkspaceTools then
				freecamSpeed = Settings.WorkspaceTools.Speed or 1
				freecamFOV = Settings.WorkspaceTools.FOV or 70
			end
		end)
		Camera.CameraType = Enum.CameraType.Scriptable; Camera.FieldOfView = freecamFOV; keysDown = {}
		inputConn1 = UIS.InputBegan:Connect(function(input, gp)
			if gp then return end; if input.KeyCode then keysDown[input.KeyCode] = true end
		end); connections[#connections+1] = inputConn1
		inputConn2 = UIS.InputEnded:Connect(function(input)
			if input.KeyCode then keysDown[input.KeyCode] = nil end
		end); connections[#connections+1] = inputConn2
		freecamConn = RunService.RenderStepped:Connect(function(dt)
			if not freecamActive then return end
			local spd = freecamSpeed * 50 * dt
			local cf = Camera.CFrame; local move = Vector3.new(0,0,0)
			if keysDown[Enum.KeyCode.W] then move = move + cf.LookVector end
			if keysDown[Enum.KeyCode.S] then move = move - cf.LookVector end
			if keysDown[Enum.KeyCode.A] then move = move - cf.RightVector end
			if keysDown[Enum.KeyCode.D] then move = move + cf.RightVector end
			if keysDown[Enum.KeyCode.E] then move = move + Vector3.new(0,1,0) end
			if keysDown[Enum.KeyCode.Q] then move = move - Vector3.new(0,1,0) end
			if keysDown[Enum.KeyCode.LeftShift] then spd = spd * 3 end
			if move.Magnitude > 0 then Camera.CFrame = cf + move.Unit * spd end
			if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				local d = UIS:GetMouseDelta()
				Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(-d.Y*0.3), math.rad(-d.X*0.3), 0)
			end
		end); connections[#connections+1] = freecamConn
		if noclipActive then WSTools:EnableNoclip() end
		if Notifications then Notifications.Info("Freecam ON (WASD+QE, RMB look)", 2) end
	end
	local function stopFreecam()
		if not freecamActive then return end; freecamActive = false
		Camera.CameraType = Enum.CameraType.Custom
		if originalFOV then Camera.FieldOfView = originalFOV end
		if freecamConn then freecamConn:Disconnect(); freecamConn = nil end
		if inputConn1 then inputConn1:Disconnect(); inputConn1 = nil end
		if inputConn2 then inputConn2:Disconnect(); inputConn2 = nil end
		WSTools:DisableNoclip(); keysDown = {}
		if Notifications then Notifications.Info("Freecam OFF", 2) end
	end
	function WSTools:EnableNoclip()
		if noclipConn then return end
		noclipConn = RunService.Stepped:Connect(function()
			local char = plr and plr.Character; if not char then return end
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then
					if originalCollisions[p] == nil then originalCollisions[p] = p.CanCollide end
					p.CanCollide = false
				end
			end
		end); connections[#connections+1] = noclipConn
	end
	function WSTools:DisableNoclip()
		if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
		for p, v in pairs(originalCollisions) do if p and p.Parent then pcall(function() p.CanCollide = v end) end end
		originalCollisions = {}
	end
	local function clearHighlights()
		for _, h in ipairs(highlights) do if h and h.Parent then h:Destroy() end end
		highlights = {}
	end
	local function applyHighlights()
		clearHighlights()
		if not highlightActive then return end
		local sel = Store.GetSelection() or {}
		local accent = (Theme and Theme.Get and Theme.Get("Accent")) or Color3.fromRGB(80,160,255)
		for _, inst in ipairs(sel) do
			if inst and (inst:IsA("BasePart") or inst:IsA("Model")) then
				local ok, h = pcall(function()
					local hl = Instance.new("Highlight")
					hl.Adornee = inst; hl.FillColor = accent; hl.FillTransparency = 0.7
					hl.OutlineColor = accent; hl.OutlineTransparency = 0; hl.Parent = inst; return hl
				end)
				if ok and h then highlights[#highlights+1] = h
				else pcall(function()
					local sb = Instance.new("SelectionBox")
					sb.Adornee = inst; sb.Color3 = accent; sb.LineThickness = 0.03; sb.Parent = inst
					highlights[#highlights+1] = sb
				end) end
			end
		end
	end
	local function getSel()
		return Store.GetSelection() or {}
	end
	local function anchorSel()
		for _, i in ipairs(getSel()) do if i and i:IsA("BasePart") then pcall(function() i.Anchored = not i.Anchored end) end end
		if Notifications then Notifications.Info("Toggled Anchored", 2) end
	end
	local function makeTransp()
		for _, i in ipairs(getSel()) do if i and i:IsA("BasePart") then pcall(function() i.Transparency = 0.8 end) end end
		if Notifications then Notifications.Info("Transparency -> 0.8", 2) end
	end
	local function resetProps()
		for _, i in ipairs(getSel()) do
			if i and i:IsA("BasePart") then
				pcall(function() i.Transparency = 0; i.Anchored = false; i.CanCollide = true end)
			end
		end
		if Notifications then Notifications.Info("Reset properties", 2) end
	end
	function WSTools:RenderAnim()
		if not animPanel then return end
		for _, c in ipairs(animPanel:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
		local y, rh = 0, 22
		createSimple("TextButton", {
			Parent = animPanel, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,rh),
			BackgroundColor3 = Color3.fromRGB(40,50,60), Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			Text = "Target: "..(animTarget and animTarget.Parent and animTarget.Parent.Name or "None (click)"),
		}).MouseButton1Click:Connect(function()
			local sel = (Store.GetSelection() or {})[1]
			if sel then
				local hum = sel:FindFirstChildOfClass("Humanoid") or (sel:IsA("Humanoid") and sel)
				if hum then animTarget = hum; WSTools:RenderAnim()
				elseif Notifications then Notifications.Info("Select a model with Humanoid", 2) end
			end
		end)
		y = y + rh + 4
		local tracks = {}
		if animTarget then pcall(function()
			local animator = animTarget:FindFirstChildOfClass("Animator")
			if animator then tracks = animator:GetPlayingAnimationTracks() end
		end) end
		for i, track in ipairs(tracks) do
			local name = pcall(function() return track.Name end) and track.Name or "Track"..i
			local spd = pcall(function() return track.Speed end) and string.format("%.1f", track.Speed) or "?"
			local wt = pcall(function() return track.WeightCurrent end) and string.format("%.2f", track.WeightCurrent) or "?"
			createSimple("TextLabel", {
				Parent = animPanel, Position = UDim2.new(0,4,0,y), Size = UDim2.new(1,-8,0,18),
				BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11,
				TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left,
				Text = name.."  Spd:"..spd.." W:"..wt,
			})
			y = y + 20
		end
		if #tracks == 0 and animTarget then
			createSimple("TextLabel", {
				Parent = animPanel, Position = UDim2.new(0,4,0,y), Size = UDim2.new(1,-8,0,18),
				BackgroundTransparency = 1, Font = Enum.Font.SourceSansItalic, TextSize = 11,
				TextColor3 = Color3.fromRGB(120,120,120), TextXAlignment = Enum.TextXAlignment.Left,
				Text = "No animations playing",
			}); y = y + 20
		end
		animPanel.CanvasSize = UDim2.new(0,0,0,y)
	end
	function WSTools:BuildUI()
		window = Lib.Window.new(); window:SetTitle("Workspace Tools"); window:SetSize(420, 340)
		local content = window:GetContent()
		toolbarFrame = createSimple("Frame", {
			Parent = content, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,0,28),
			BackgroundColor3 = Color3.fromRGB(28,28,32), BorderSizePixel = 0,
		})
		local btns = {
			{"Freecam", function() if freecamActive then stopFreecam() else startFreecam() end end},
			{"Noclip", function()
				noclipActive = not noclipActive
				if freecamActive then if noclipActive then WSTools:EnableNoclip() else WSTools:DisableNoclip() end end
				if Notifications then Notifications.Info("Noclip: "..(noclipActive and "ON" or "OFF"), 2) end
			end},
			{"Highlight", function() highlightActive = not highlightActive; applyHighlights() end},
			{"Anchor", anchorSel},
			{"Transp", makeTransp},
			{"Reset", resetProps},
		}
		for i, b in ipairs(btns) do
			local btn = createSimple("TextButton", {
				Parent = toolbarFrame, Position = UDim2.new(0,(i-1)*68,0,2), Size = UDim2.new(0,66,0,24),
				BackgroundColor3 = Color3.fromRGB(45,55,70), Font = Enum.Font.Code, TextSize = 10,
				TextColor3 = Color3.new(1,1,1), Text = b[1], AutoButtonColor = true,
			})
			btn.MouseButton1Click:Connect(b[2])
		end
		animPanel = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0,0,0,32), Size = UDim2.new(1,0,1,-32),
			BackgroundColor3 = Color3.fromRGB(20,20,22), BorderSizePixel = 0,
			ScrollBarThickness = 5, CanvasSize = UDim2.new(0,0,0,0), ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		local selConn = Store.Subscribe("selection", function()
			if highlightActive then applyHighlights() end; WSTools:RenderAnim()
		end)
		if selConn then connections[#connections+1] = selConn end
	end
	function WSTools:Init() WSTools:BuildUI(); WSTools:RenderAnim() end
	function WSTools:Destroy()
		stopFreecam(); WSTools:DisableNoclip(); clearHighlights()
		for _, c in ipairs(connections) do
			if typeof(c) == "RBXScriptConnection" then
				c:Disconnect()
			elseif type(c) == "function" then
				pcall(c)
			end
		end
		connections = {}; if window then window:Close() end
	end
	WSTools:Init()
	return WSTools
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["Console"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main; Lib = data.Lib; Apps = data.Apps
	Settings = data.Settings; Theme = data.Theme; Store = data.Store
	Keybinds = data.Keybinds; Notifications = data.Notifications; Env = data.Env
	API = data.API; RMD = data.RMD; env = data.Env or data.env
	service = data.service; plr = data.plr; create = data.create; createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local function main()
	local Console = {}
	local logs = {}
	local maxLines = 1000
	local showTimestamps = true
	local filterLevel = "all"
	local searchText = ""
	local selectedLines = {}
	local connections = {}
	local originalPrint = print
	local originalWarn = warn
	local window, outputFrame, filterBar, levelBtn
	local function ts() return string.format("%.3f", os.clock()) end
	local function levelColor(level)
		if level == "warn" then return Color3.fromRGB(255,220,60)
		elseif level == "error" then return Color3.fromRGB(255,80,80) end
		return Theme.Get("Text") or Color3.new(1,1,1)
	end
	local function matchesFilter(e)
		if filterLevel == "warn" and e.Level ~= "warn" and e.Level ~= "error" then return false end
		if filterLevel == "error" and e.Level ~= "error" then return false end
		if searchText ~= "" then
			local lw = searchText:lower()
			if not e.Message:lower():find(lw, 1, true) and not (e.Source or ""):lower():find(lw, 1, true) then return false end
		end
		return true
	end
	local function getSource()
		return debug and debug.info and debug.info(4, "s") or ""
	end
	local function addLog(level, msg, src)
		logs[#logs+1] = {Timestamp=ts(), Level=level, Message=tostring(msg), Source=src or ""}
		if #logs > maxLines then table.remove(logs, 1) end
		Console:Render()
	end
	local function hookGlobals()
		print = function(...)
			local p = {}; for i=1,select("#",...) do p[i]=tostring(select(i,...)) end
			addLog("info", table.concat(p," "), getSource()); originalPrint(...)
		end
		warn = function(...)
			local p = {}; for i=1,select("#",...) do p[i]=tostring(select(i,...)) end
			addLog("warn", table.concat(p," "), getSource()); originalWarn(...)
		end
	end
	local function hookLogService()
		pcall(function()
			local capture = true
			if Settings.Console and Settings.Console.CaptureLogService ~= nil then
				capture = Settings.Console.CaptureLogService
			end
			if not capture then return end
			local LS = service.LogService
			local c = LS.MessageOut:Connect(function(msg, msgType)
				local level = "info"
				if msgType == Enum.MessageType.MessageWarning then level = "warn"
				elseif msgType == Enum.MessageType.MessageError then level = "error" end
				if #logs > 0 and logs[#logs].Message == msg then return end
				addLog(level, msg, "LogService")
			end)
			connections[#connections+1] = c
		end)
	end
	function Console:Render()
		if not outputFrame then return end
		for _, c in ipairs(outputFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		local y, lh = 0, 17
		for i, e in ipairs(logs) do
			if matchesFilter(e) then
				local text = ""
				if showTimestamps then text = "["..e.Timestamp.."] " end
				if e.Source ~= "" then text = text..e.Source..": " end
				text = text..e.Message
				local sel = selectedLines[i]
				local lbl = createSimple("TextButton", {
					Parent = outputFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,lh),
					BackgroundTransparency = sel and 0.7 or 1,
					BackgroundColor3 = sel and (Theme.Get("Accent") or Color3.fromRGB(60,120,200)) or Color3.fromRGB(20,20,20),
					BorderSizePixel = 0, Font = Enum.Font.Code, TextSize = 11,
					TextColor3 = levelColor(e.Level), TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd, Text = " "..text, AutoButtonColor = false,
				})
				local idx = i
				lbl.MouseButton1Click:Connect(function() selectedLines[idx] = not selectedLines[idx] or nil; Console:Render() end)
				y = y + lh
			end
		end
		outputFrame.CanvasSize = UDim2.new(0,0,0,y)
		outputFrame.CanvasPosition = Vector2.new(0, math.max(0, y - outputFrame.AbsoluteSize.Y))
	end
	function Console:CopyAll()
		local lines = {}
		for _, e in ipairs(logs) do
			if matchesFilter(e) then
				local l = showTimestamps and "["..e.Timestamp.."] " or ""
				lines[#lines+1] = l.."["..e.Level:upper().."] "..e.Message
			end
		end
		if Env.setclipboard then
			Env.setclipboard(table.concat(lines,"\n"))
			Notifications.Info("Copied "..#lines.." lines", 2)
		end
	end
	function Console:CopySelection()
		local lines = {}
		for i, e in ipairs(logs) do
			if selectedLines[i] then
				local l = showTimestamps and "["..e.Timestamp.."] " or ""
				lines[#lines+1] = l.."["..e.Level:upper().."] "..e.Message
			end
		end
		if #lines == 0 then Notifications.Info("Nothing selected", 2); return end
		if Env.setclipboard then
			Env.setclipboard(table.concat(lines,"\n"))
			Notifications.Info("Copied "..#lines.." selected", 2)
		end
	end
	function Console:Clear() logs = {}; selectedLines = {}; Console:Render() end
	function Console:BuildUI()
		window = Lib.Window.new(); window:SetTitle("Console"); window:SetSize(580, 320)
		local content = window:GetContent()
		levelBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0,55,0,26),
			BackgroundColor3 = Color3.fromRGB(40,40,40), Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = Color3.new(1,1,1), Text = "All",
		})
		levelBtn.MouseButton1Click:Connect(function()
			local ls = {"all","warn","error"}
			local i = (table.find(ls, filterLevel) or 1) % #ls + 1
			filterLevel = ls[i]; levelBtn.Text = filterLevel:sub(1,1):upper()..filterLevel:sub(2); Console:Render()
		end)
		filterBar = createSimple("TextBox", {
			Parent = content, Position = UDim2.new(0,59,0,0), Size = UDim2.new(1,-239,0,26),
			BackgroundColor3 = Color3.fromRGB(30,30,30), Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = Color3.new(1,1,1), PlaceholderText = "Search...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100), TextXAlignment = Enum.TextXAlignment.Left, Text = "",
		})
		filterBar:GetPropertyChangedSignal("Text"):Connect(function() searchText = filterBar.Text; Console:Render() end)
		local copyAll = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-176,0,0), Size = UDim2.new(0,56,0,26),
			BackgroundColor3 = Color3.fromRGB(50,80,120), Font = Enum.Font.Code, TextSize = 10,
			TextColor3 = Color3.new(1,1,1), Text = "CopyAll",
		})
		copyAll.MouseButton1Click:Connect(function() Console:CopyAll() end)
		local copySel = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-116,0,0), Size = UDim2.new(0,56,0,26),
			BackgroundColor3 = Color3.fromRGB(50,80,120), Font = Enum.Font.Code, TextSize = 10,
			TextColor3 = Color3.new(1,1,1), Text = "CopySel",
		})
		copySel.MouseButton1Click:Connect(function() Console:CopySelection() end)
		local clrBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-56,0,0), Size = UDim2.new(0,56,0,26),
			BackgroundColor3 = Color3.fromRGB(140,40,40), Font = Enum.Font.Code, TextSize = 10,
			TextColor3 = Color3.new(1,1,1), Text = "Clear",
		})
		clrBtn.MouseButton1Click:Connect(function() Console:Clear() end)
		outputFrame = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0,0,0,30), Size = UDim2.new(1,0,1,-30),
			BackgroundColor3 = Color3.fromRGB(16,16,16), BorderSizePixel = 0,
			ScrollBarThickness = 6, CanvasSize = UDim2.new(0,0,0,0), ScrollingDirection = Enum.ScrollingDirection.Y,
		})
	end
	function Console:Init()
		pcall(function()
			if Settings.Console then
				maxLines = Settings.Console.MaxLines or maxLines
				showTimestamps = Settings.Console.ShowTimestamps ~= false
			end
		end)
		Console:BuildUI(); hookGlobals(); hookLogService()
		addLog("info", "Console ready.", "Console")
	end
	function Console:Destroy()
		print = originalPrint; warn = originalWarn
		for _, c in ipairs(connections) do c:Disconnect() end
		connections = {}; if window then window:Close() end
	end
	function Console:GetLogs() return logs end
	Console:Init()
	return Console
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
EmbeddedModules["ThemePicker"] = function()
local Main, Lib, Apps, Settings, Theme, Store, Keybinds, Notifications, Env
local API, RMD, env, service, plr, create, createSimple
local function initDeps(data)
	Main = data.Main; Lib = data.Lib; Apps = data.Apps
	Settings = data.Settings; Theme = data.Theme; Store = data.Store
	Keybinds = data.Keybinds; Notifications = data.Notifications; Env = data.Env
	API = data.API; RMD = data.RMD; env = data.Env or data.env
	service = data.service; plr = data.plr; create = data.create; createSimple = data.createSimple
end
local function initAfterMain(appTable) end
local MANUAL_KEYS = {
	"Main1", "Main2", "Main3",
	"Outline1", "Outline2", "Outline3",
	"TextBox", "Menu", "ListSelection",
	"Button", "ButtonHover", "ButtonPress",
	"Highlight", "Text", "TextDim", "PlaceholderText",
	"Important", "Success", "Warning", "Accent",
	"ScrollBar", "ScrollBarHover", "Separator",
	"TabActive", "TabInactive",
	"Notification", "NotificationBorder",
}
local function main()
	local ThemePicker = {}
	local window
	local presetList, manualList, fontList
	local activePresetButton
	local connections = {}
	local function bg(key, fallback)
		return Theme.Get(key) or fallback
	end
	local function makeButton(parent, text, x, y, w, h, opts)
		opts = opts or {}
		return createSimple("TextButton", {
			Parent = parent, Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, h),
			BackgroundColor3 = opts.bg or bg("Button", Color3.fromRGB(60, 60, 60)),
			BorderSizePixel = 0,
			Font = opts.font or Enum.Font.Gotham, TextSize = opts.textSize or 12,
			TextColor3 = opts.textColor or bg("Text", Color3.new(1, 1, 1)),
			Text = text, AutoButtonColor = true,
		})
	end
	local function makeLabel(parent, text, x, y, w, h, opts)
		opts = opts or {}
		return createSimple("TextLabel", {
			Parent = parent, Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, h),
			BackgroundTransparency = 1,
			Font = opts.font or Enum.Font.Gotham, TextSize = opts.textSize or 12,
			TextColor3 = opts.textColor or bg("Text", Color3.new(1, 1, 1)),
			Text = text, TextXAlignment = opts.align or Enum.TextXAlignment.Left,
		})
	end
	local function presetButtonFor(name)
		local preset = Theme.Presets[name]
		if not preset then return nil end
		local swatchBg = preset.Main2 or preset.Main1 or Color3.fromRGB(45, 45, 45)
		local swatchFg = preset.Text or Color3.new(1, 1, 1)
		local swatchAccent = preset.Accent or Color3.fromRGB(0, 120, 215)
		return swatchBg, swatchFg, swatchAccent
	end
	local function renderPresets()
		if not presetList then return end
		for _, c in ipairs(presetList:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end
		local rowHeight = 28
		local y = 0
		local current = Theme.GetCurrentName()
		local smartRow = createSimple("TextButton", {
			Parent = presetList, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, -4, 0, rowHeight),
			BackgroundColor3 = bg("Button", Color3.fromRGB(60, 60, 60)),
			BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 12,
			TextColor3 = bg("Text", Color3.new(1, 1, 1)),
			Text = "  Smart  (auto from world)", TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = true,
		})
		if current == "Smart" then
			smartRow.BackgroundColor3 = bg("Accent", Color3.fromRGB(0, 120, 215))
			activePresetButton = smartRow
		end
		smartRow.MouseButton1Click:Connect(function()
			local ok = Theme.SmartFromWorld()
			if ok and Notifications then
				Notifications.Info("Smart theme applied from current world lighting", 2)
			end
			renderPresets()
		end)
		y = y + rowHeight + 4
		local order = Theme.PresetOrder or {}
		for _, name in ipairs(order) do
			local preset = Theme.Presets[name]
			if preset then
				local swatchBg, swatchFg, swatchAccent = presetButtonFor(name)
				local row = createSimple("TextButton", {
					Parent = presetList, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, -4, 0, rowHeight),
					BackgroundColor3 = bg("Button", Color3.fromRGB(60, 60, 60)),
					BorderSizePixel = 0, Text = "", AutoButtonColor = true,
				})
				createSimple("Frame", {
					Parent = row, Position = UDim2.new(0, 6, 0, 6), Size = UDim2.new(0, 12, 0, 16),
					BackgroundColor3 = swatchBg, BorderSizePixel = 0,
				})
				createSimple("Frame", {
					Parent = row, Position = UDim2.new(0, 20, 0, 6), Size = UDim2.new(0, 12, 0, 16),
					BackgroundColor3 = swatchAccent, BorderSizePixel = 0,
				})
				createSimple("Frame", {
					Parent = row, Position = UDim2.new(0, 34, 0, 6), Size = UDim2.new(0, 12, 0, 16),
					BackgroundColor3 = swatchFg, BorderSizePixel = 0,
				})
				createSimple("TextLabel", {
					Parent = row, Position = UDim2.new(0, 56, 0, 0), Size = UDim2.new(1, -64, 1, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham, TextSize = 12,
					TextColor3 = bg("Text", Color3.new(1, 1, 1)),
					Text = name, TextXAlignment = Enum.TextXAlignment.Left,
				})
				if current == name then
					row.BackgroundColor3 = bg("Accent", Color3.fromRGB(0, 120, 215))
					activePresetButton = row
				end
				row.MouseButton1Click:Connect(function()
					Theme.Apply(name)
					if Notifications then Notifications.Info("Theme: " .. name, 2) end
					renderPresets()
					ThemePicker:RenderManual()
				end)
				y = y + rowHeight + 4
			end
		end
		presetList.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	function ThemePicker:RenderManual()
		if not manualList then return end
		for _, c in ipairs(manualList:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end
		local rowHeight = 22
		local y = 0
		for _, key in ipairs(MANUAL_KEYS) do
			local current = Theme.Get(key)
			if typeof(current) == "Color3" then
				local row = createSimple("Frame", {
					Parent = manualList, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, -4, 0, rowHeight),
					BackgroundTransparency = 1, BorderSizePixel = 0,
				})
				createSimple("TextLabel", {
					Parent = row, Position = UDim2.new(0, 6, 0, 0), Size = UDim2.new(0, 130, 1, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.Code, TextSize = 11,
					TextColor3 = bg("Text", Color3.new(1, 1, 1)),
					Text = key, TextXAlignment = Enum.TextXAlignment.Left,
				})
				local swatch = createSimple("TextButton", {
					Parent = row, Position = UDim2.new(0, 140, 0, 2), Size = UDim2.new(1, -150, 0, rowHeight - 4),
					BackgroundColor3 = current, BorderSizePixel = 1,
					BorderColor3 = bg("Outline2", Color3.fromRGB(70, 70, 70)),
					Text = string.format("rgb(%d, %d, %d)",
						math.floor(current.R * 255 + 0.5),
						math.floor(current.G * 255 + 0.5),
						math.floor(current.B * 255 + 0.5)),
					Font = Enum.Font.Code, TextSize = 10,
					TextColor3 = (current.R + current.G + current.B) / 3 > 0.5
						and Color3.new(0, 0, 0) or Color3.new(1, 1, 1),
					AutoButtonColor = false,
				})
				local picker = self._picker
				if not picker then
					picker = Lib.ColorPicker.new()
					self._picker = picker
				end
				swatch.MouseButton1Click:Connect(function()
					if self._pickerConn then self._pickerConn:Disconnect() end
					self._pickerConn = picker.OnSelect:Connect(function(col)
						Theme.SetKey(key, col)
						ThemePicker:RenderManual()
					end)
					picker:SetColor(current)
					picker:Show()
				end)
				y = y + rowHeight + 2
			end
		end
		manualList.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	local function renderFonts()
		if not fontList then return end
		for _, c in ipairs(fontList:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end
		local rowHeight = 26
		local y = 0
		local currentFont = Theme.GetFontName()
		for _, name in ipairs(Theme.ListFonts()) do
			local row = createSimple("TextButton", {
				Parent = fontList, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, -4, 0, rowHeight),
				BackgroundColor3 = bg("Button", Color3.fromRGB(60, 60, 60)),
				BorderSizePixel = 0, Text = "", AutoButtonColor = true,
			})
			local fontEntry
			for _, e in ipairs(Theme.Fonts) do
				if e.Name == name then fontEntry = e break end
			end
			createSimple("TextLabel", {
				Parent = row, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(0.5, -8, 1, 0),
				BackgroundTransparency = 1,
				Font = (fontEntry and typeof(fontEntry.Font) == "EnumItem") and fontEntry.Font or Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = bg("Text", Color3.new(1, 1, 1)),
				Text = name, TextXAlignment = Enum.TextXAlignment.Left,
			})
			createSimple("TextLabel", {
				Parent = row, Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, -8, 1, 0),
				BackgroundTransparency = 1,
				Font = (fontEntry and typeof(fontEntry.Font) == "EnumItem") and fontEntry.Font or Enum.Font.Gotham,
				TextSize = 11,
				TextColor3 = bg("TextDim", Color3.fromRGB(180, 180, 180)),
				Text = "The quick brown fox", TextXAlignment = Enum.TextXAlignment.Left,
			})
			if currentFont == name then
				row.BackgroundColor3 = bg("Accent", Color3.fromRGB(0, 120, 215))
			end
			row.MouseButton1Click:Connect(function()
				Theme.SetFont(name)
				if Notifications then Notifications.Info("Font: " .. name, 2) end
				renderFonts()
			end)
			y = y + rowHeight + 2
		end
		fontList.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	local function buildCustomFontRow(parent, x, y, w)
		local row = createSimple("Frame", {
			Parent = parent, Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, 26),
			BackgroundTransparency = 1,
		})
		local nameInput = createSimple("TextBox", {
			Parent = row, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.35, -2, 1, 0),
			BackgroundColor3 = bg("TextBox", Color3.fromRGB(38, 38, 38)),
			Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = bg("Text", Color3.new(1, 1, 1)),
			PlaceholderText = "FontName", PlaceholderColor3 = bg("PlaceholderText", Color3.fromRGB(110, 110, 110)),
			Text = "", ClearTextOnFocus = false, BorderSizePixel = 0,
		})
		local idInput = createSimple("TextBox", {
			Parent = row, Position = UDim2.new(0.35, 2, 0, 0), Size = UDim2.new(0.45, -4, 1, 0),
			BackgroundColor3 = bg("TextBox", Color3.fromRGB(38, 38, 38)),
			Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = bg("Text", Color3.new(1, 1, 1)),
			PlaceholderText = "rbxassetid:// or asset id",
			PlaceholderColor3 = bg("PlaceholderText", Color3.fromRGB(110, 110, 110)),
			Text = "", ClearTextOnFocus = false, BorderSizePixel = 0,
		})
		local addBtn = createSimple("TextButton", {
			Parent = row, Position = UDim2.new(0.8, 2, 0, 0), Size = UDim2.new(0.2, -2, 1, 0),
			BackgroundColor3 = bg("Accent", Color3.fromRGB(56, 142, 235)),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold, TextSize = 11,
			TextColor3 = Color3.new(1, 1, 1), Text = "Add",
			AutoButtonColor = true,
		})
		addBtn.MouseButton1Click:Connect(function()
			local n = nameInput.Text
			local id = idInput.Text
			if not n or n == "" or not id or id == "" then
				if Notifications then Notifications.Warning("Both font name and asset id are required") end
				return
			end
			local digits = id:match("(%d+)$") or id:match("(%d+)")
			local assetId = digits or id
			local ok = Theme.RegisterFontFromAssetId(n, assetId)
			if ok then
				if Notifications then Notifications.Success("Font loaded: " .. n) end
				nameInput.Text = ""
				idInput.Text = ""
				renderFonts()
			else
				if Notifications then Notifications.Error("Failed to load font (executor may lack Font.new)") end
			end
		end)
	end
	function ThemePicker:BuildUI()
		window = Lib.Window.new()
		window:SetTitle("Themes")
		window:SetSize(560, 420)
		ThemePicker.Window = window
		local content = window:GetContent()
		local header = createSimple("Frame", {
			Parent = content, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 22),
			BackgroundColor3 = bg("Main2", Color3.fromRGB(45, 45, 45)),
			BorderSizePixel = 0,
		})
		makeLabel(header, "General Themes", 6, 0, 180, 22, {textColor = bg("TextDim", Color3.fromRGB(180,180,180)), font = Enum.Font.GothamBold})
		makeLabel(header, "Manual", 200, 0, 180, 22, {textColor = bg("TextDim", Color3.fromRGB(180,180,180)), font = Enum.Font.GothamBold})
		makeLabel(header, "Fonts", 400, 0, 140, 22, {textColor = bg("TextDim", Color3.fromRGB(180,180,180)), font = Enum.Font.GothamBold})
		presetList = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(0, 196, 1, -56),
			BackgroundColor3 = bg("Main3", Color3.fromRGB(38, 38, 38)),
			BorderSizePixel = 0, ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		manualList = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0, 200, 0, 26), Size = UDim2.new(0, 196, 1, -56),
			BackgroundColor3 = bg("Main3", Color3.fromRGB(38, 38, 38)),
			BorderSizePixel = 0, ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		fontList = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0, 400, 0, 26), Size = UDim2.new(1, -400, 1, -56),
			BackgroundColor3 = bg("Main3", Color3.fromRGB(38, 38, 38)),
			BorderSizePixel = 0, ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		local footer = createSimple("Frame", {
			Parent = content, Position = UDim2.new(0, 0, 1, -28), Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = bg("Main2", Color3.fromRGB(45, 45, 45)),
			BorderSizePixel = 0,
		})
		local resetBtn = makeButton(footer, "Reset to Dark", 6, 4, 110, 20)
		resetBtn.MouseButton1Click:Connect(function()
			Theme.Apply("Dark")
			if Notifications then Notifications.Info("Theme reset to Dark", 2) end
			renderPresets()
			ThemePicker:RenderManual()
			renderFonts()
		end)
		buildCustomFontRow(footer, 124, 1, 420)
		renderPresets()
		ThemePicker:RenderManual()
		renderFonts()
		local conn = Theme.SubscribeAll(function()
			renderPresets()
			ThemePicker:RenderManual()
			renderFonts()
		end)
		if conn then connections[#connections + 1] = conn end
	end
	function ThemePicker:Init()
		ThemePicker:BuildUI()
	end
	function ThemePicker:Destroy()
		for _, c in ipairs(connections) do
			if type(c) == "function" then pcall(c) end
		end
		connections = {}
		if self._pickerConn then self._pickerConn:Disconnect(); self._pickerConn = nil end
		if window then window:Close() end
	end
	ThemePicker:Init()
	return ThemePicker
end
return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
if _G.DeuxLoaded then return end
_G.DeuxLoaded = true
local Env, Settings, Theme, Keybinds, Notifications, Store
local Lib, API, RMD
local Explorer, Properties, ScriptEditor, Terminal, RemoteSpy
local SaveInstance, DataInspector, NetworkSpy, APIReference
local PluginAPI, WorkspaceTools, Console
local ThemePicker
local EmbeddedModules = EmbeddedModules or {}
local serviceCache = {}
local service = setmetatable({}, {
	__index = function(self, name)
		if serviceCache[name] then return serviceCache[name] end
		local s, serv = pcall(game.GetService, game, name)
		if not s or not serv then return nil end
		if Env and Env.cloneref then
			serv = Env.cloneref(serv)
		end
		serviceCache[name] = serv
		rawset(self, name, serv)
		return serv
	end
})
local plr = service.Players.LocalPlayer or service.Players.PlayerAdded:Wait()
local create = function(data)
	local insts = {}
	for i, v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end
	for _, v in pairs(data) do
		for prop, val in pairs(v[3]) do
			if type(val) == "table" then
				insts[v[1]][prop] = insts[val[1]]
			else
				insts[v[1]][prop] = val
			end
		end
	end
	return insts[1]
end
local createSimple = function(class, props)
	local inst = Instance.new(class)
	for i, v in next, props do
		inst[i] = v
	end
	return inst
end
local Main = {}
Main.Version = "2.0.0"
Main.CodeName = "Deux"
Main.Elevated = false
Main.Mouse = plr:GetMouse()
Main.Apps = {}
Main.AppControls = {}
Main.MenuApps = {}
Main.ModuleList = {
	"Lib", "Explorer", "Properties", "ScriptEditor",
	"Terminal", "RemoteSpy", "SaveInstance", "DataInspector",
	"NetworkSpy", "APIReference", "PluginAPI", "WorkspaceTools", "Console",
	"ThemePicker"
}
Main.DisplayOrders = {
	SideWindow = 8,
	Window = 10,
	Menu = 100000,
	Core = 101000
}
Main.InitEnv = function()
	if EmbeddedModules["Env"] then
		Env = EmbeddedModules["Env"]()
	else
		Env = {Capabilities = {}, MissingAPIs = {}, ExecutorName = "Unknown"}
		Env.getService = function(n) return game:GetService(n) end
		Env.getGuiParent = function()
			local s = pcall(function() return game:GetService("CoreGui"):GetFullName() end)
			if s then return game:GetService("CoreGui") end
			return plr:FindFirstChildOfClass("PlayerGui")
		end
		Env.protectGui = function() end
	end
	if Env.cloneref then
		for name, serv in pairs(serviceCache) do
			serviceCache[name] = Env.cloneref(serv)
			rawset(service, name, serviceCache[name])
		end
	end
	Main.Elevated = pcall(function() local _ = game:GetService("CoreGui"):GetFullName() end)
	Main.GuiHolder = Env.getGuiParent()
	Main.Executor = Env.ExecutorName
end
Main.InitCoreSystems = function()
	if EmbeddedModules["Settings"] then
		Settings = EmbeddedModules["Settings"]()
	else
		Settings = {Get = function() return nil end, Set = function() end, Init = function() end}
	end
	Settings.Init(Env, service)
	if EmbeddedModules["Theme"] then
		Theme = EmbeddedModules["Theme"]()
	else
		Theme = {Get = function(k) return Color3.new(0.2,0.2,0.2) end, Init = function() end, Apply = function() end}
	end
	Theme.Init(Env, Settings, service)
	if EmbeddedModules["Keybinds"] then
		Keybinds = EmbeddedModules["Keybinds"]()
	else
		Keybinds = {Init = function() end, Register = function() end}
	end
	Keybinds.Init(Settings, service)
	if EmbeddedModules["Store"] then
		Store = EmbeddedModules["Store"]()
	else
		Store = {Set = function() end, Get = function() end, Subscribe = function() return function() end end, On = function() return function() end end, Emit = function() end, SetSelection = function() end, GetSelection = function() return {} end}
	end
	if EmbeddedModules["Notifications"] then
		Notifications = EmbeddedModules["Notifications"]()
	else
		Notifications = {Init = function() end, Info = function() end, Error = function() end, Success = function() end, Warning = function() end}
	end
	Notifications.Init(Env, Theme, service)
end
Main.GetInitDeps = function()
	return {
		Main = Main,
		Lib = Lib,
		Apps = Main.Apps,
		Settings = Settings,
		Theme = Theme,
		Keybinds = Keybinds,
		Notifications = Notifications,
		Store = Store,
		API = API,
		RMD = RMD,
		Env = Env,
		env = Env,
		service = service,
		plr = plr,
		create = create,
		createSimple = createSimple,
	}
end
Main.LoadModule = function(name)
	local control
	if EmbeddedModules and EmbeddedModules[name] then
		local s, result = pcall(EmbeddedModules[name])
		if not s then
			Main.Error("Failed to load module '" .. name .. "': " .. tostring(result))
			return nil
		end
		control = result
	else
		Main.Error("Module not found: " .. name)
		return nil
	end
	if not control then return nil end
	Main.AppControls[name] = control
	if control.InitDeps then
		control.InitDeps(Main.GetInitDeps())
	end
	if control.Main then
		local moduleData = control.Main()
		Main.Apps[name] = moduleData
		return moduleData
	end
	return control
end
Main.LoadModules = function()
	for _, name in ipairs(Main.ModuleList) do
		if name ~= "Lib" then
			local s, e = pcall(Main.LoadModule, name)
			if not s then
				local msg = "FAILED LOADING " .. tostring(name) .. " CAUSE " .. tostring(e)
				Main.Error(msg)
				if Notifications then
					Notifications.Error("Module load failed: " .. name)
				end
			end
		end
	end
	Explorer = Main.Apps.Explorer
	Properties = Main.Apps.Properties
	ScriptEditor = Main.Apps.ScriptEditor
	Terminal = Main.Apps.Terminal
	RemoteSpy = Main.Apps.RemoteSpy
	SaveInstance = Main.Apps.SaveInstance
	DataInspector = Main.Apps.DataInspector
	NetworkSpy = Main.Apps.NetworkSpy
	APIReference = Main.Apps.APIReference
	PluginAPI = Main.Apps.PluginAPI
	WorkspaceTools = Main.Apps.WorkspaceTools
	Console = Main.Apps.Console
	ThemePicker = Main.Apps.ThemePicker
	local appTable = {
		Explorer = Explorer,
		Properties = Properties,
		ScriptEditor = ScriptEditor,
		Terminal = Terminal,
		RemoteSpy = RemoteSpy,
		SaveInstance = SaveInstance,
		DataInspector = DataInspector,
		NetworkSpy = NetworkSpy,
		APIReference = APIReference,
		PluginAPI = PluginAPI,
		WorkspaceTools = WorkspaceTools,
		Console = Console,
		ThemePicker = ThemePicker,
	}
	if Main.AppControls.Lib and Main.AppControls.Lib.InitAfterMain then
		Main.AppControls.Lib.InitAfterMain(appTable)
	end
	for _, name in ipairs(Main.ModuleList) do
		local control = Main.AppControls[name]
		if control and control.InitAfterMain then
			pcall(control.InitAfterMain, appTable)
		end
	end
end
Main.Error = function(str)
	local msg = "[Deux] ERROR: " .. tostring(str)
	if Env and Env.rconsoleprint then
		pcall(Env.rconsoleprint, msg .. "\n")
	end
	warn(msg)
end
Main.Warn = function(str)
	local msg = "[Deux] WARN: " .. tostring(str)
	warn(msg)
end
Main.LoadSettings = function()
	if Settings and Settings.Load then
		Settings.Load()
	end
end
Main.SetupFilesystem = function()
	if not Env.Capabilities.Filesystem then return end
	local folders = {
		"deux", "deux/saved", "deux/saved/scripts", "deux/saved/places",
		"deux/saved/bookmarks", "deux/saved/hooks", "deux/themes",
		"deux/plugins", "deux/cache"
	}
	for _, folder in ipairs(folders) do
		pcall(Env.makefolder, folder)
	end
end
Main.FetchAPI = function()
	local rawAPI
	if Main.Elevated then
		if Env.Capabilities.Filesystem then
			local s, cached = pcall(Env.readfile, "deux/cache/rbx_api.json")
			if s and cached and cached ~= "" then
				rawAPI = cached
			end
		end
		if not rawAPI then
			local version = Main.RobloxVersion
			if version then
				local s, data = pcall(game.HttpGet, game, "http://setup.roblox.com/" .. version .. "-API-Dump.json")
				if s and data then rawAPI = data end
			end
		end
	end
	if not rawAPI then
		Main.Warn("Could not fetch API dump, some features will be limited")
		return {Classes = {}, Enums = {}, CategoryOrder = {}, GetMember = function() return {} end}
	end
	Main.RawAPI = rawAPI
	if Env.Capabilities.Filesystem and not pcall(Env.isfile, "deux/cache/rbx_api.json") then
		pcall(Env.writefile, "deux/cache/rbx_api.json", rawAPI)
	end
	local s, api = pcall(service.HttpService.JSONDecode, service.HttpService, rawAPI)
	if not s then
		Main.Error("Failed to decode API JSON")
		return {Classes = {}, Enums = {}, CategoryOrder = {}, GetMember = function() return {} end}
	end
	local classes, enums = {}, {}
	local categoryOrder, seenCategories = {}, {}
	for _, class in pairs(api.Classes) do
		local newClass = {
			Name = class.Name,
			Superclass = class.Superclass,
			Properties = {},
			Functions = {},
			Events = {},
			Callbacks = {},
			Tags = {}
		}
		if class.Tags then
			for _, tag in pairs(class.Tags) do newClass.Tags[tag] = true end
		end
		for _, member in pairs(class.Members) do
			local newMember = {
				Name = member.Name,
				Class = class.Name,
				Security = member.Security,
				Tags = {}
			}
			if member.Tags then
				for _, tag in pairs(member.Tags) do newMember.Tags[tag] = true end
			end
			local mType = member.MemberType
			if mType == "Property" then
				local propCategory = (member.Category or "Other"):match("^%s*(.-)%s*$")
				if not seenCategories[propCategory] then
					categoryOrder[#categoryOrder + 1] = propCategory
					seenCategories[propCategory] = true
				end
				newMember.ValueType = member.ValueType
				newMember.Category = propCategory
				newMember.Serialization = member.Serialization
				table.insert(newClass.Properties, newMember)
			elseif mType == "Function" then
				newMember.Parameters = {}
				newMember.ReturnType = member.ReturnType and member.ReturnType.Name or "void"
				for _, param in pairs(member.Parameters) do
					table.insert(newMember.Parameters, {Name = param.Name, Type = param.Type.Name})
				end
				table.insert(newClass.Functions, newMember)
			elseif mType == "Event" then
				newMember.Parameters = {}
				for _, param in pairs(member.Parameters) do
					table.insert(newMember.Parameters, {Name = param.Name, Type = param.Type.Name})
				end
				table.insert(newClass.Events, newMember)
			elseif mType == "Callback" then
				newMember.Parameters = {}
				for _, param in pairs(member.Parameters) do
					table.insert(newMember.Parameters, {Name = param.Name, Type = param.Type.Name})
				end
				table.insert(newClass.Callbacks, newMember)
			end
		end
		classes[class.Name] = newClass
	end
	for _, class in pairs(classes) do
		class.Superclass = classes[class.Superclass]
	end
	for _, enum in pairs(api.Enums) do
		local newEnum = {Name = enum.Name, Items = {}, Tags = {}}
		if enum.Tags then
			for _, tag in pairs(enum.Tags) do newEnum.Tags[tag] = true end
		end
		for _, item in pairs(enum.Items) do
			table.insert(newEnum.Items, {Name = item.Name, Value = item.Value})
		end
		enums[enum.Name] = newEnum
	end
	categoryOrder[#categoryOrder + 1] = "Unscriptable"
	categoryOrder[#categoryOrder + 1] = "Attributes"
	local categoryOrderMap = {}
	for i = 1, #categoryOrder do
		categoryOrderMap[categoryOrder[i]] = i
	end
	local function getMember(class, member)
		if not classes[class] or not classes[class][member] then return {} end
		local result = {}
		local currentClass = classes[class]
		while currentClass do
			for _, entry in pairs(currentClass[member]) do
				result[#result + 1] = entry
			end
			currentClass = currentClass.Superclass
		end
		table.sort(result, function(a, b) return a.Name < b.Name end)
		return result
	end
	return {
		Classes = classes,
		Enums = enums,
		CategoryOrder = categoryOrderMap,
		GetMember = getMember
	}
end
Main.FetchRMD = function()
	local rawXML
	if Main.Elevated then
		if Env.Capabilities.Filesystem then
			local s, cached = pcall(Env.readfile, "deux/cache/rbx_rmd.xml")
			if s and cached and cached ~= "" then rawXML = cached end
		end
		if not rawXML then
			local s, data = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml")
			if s and data then rawXML = data end
		end
	end
	if not rawXML then
		Main.Warn("Could not fetch RMD, property descriptions unavailable")
		return {Classes = {}, Enums = {}, PropertyOrders = {}}
	end
	Main.RawRMD = rawXML
	if Env.Capabilities.Filesystem then
		pcall(Env.writefile, "deux/cache/rbx_rmd.xml", rawXML)
	end
	if Lib and Lib.ParseXML then
		return Main.ParseRMD(rawXML)
	end
	Main.RawRMDPending = rawXML
	return {Classes = {}, Enums = {}, PropertyOrders = {}}
end
Main.ParseRMD = function(rawXML)
	local parsed = Lib.ParseXML(rawXML)
	if not parsed or not parsed.children or not parsed.children[1] then
		return {Classes = {}, Enums = {}, PropertyOrders = {}}
	end
	local classList = parsed.children[1].children[1] and parsed.children[1].children[1].children or {}
	local enumList = parsed.children[1].children[2] and parsed.children[1].children[2].children or {}
	local propertyOrders = {}
	local classes, enums = {}, {}
	for _, class in pairs(classList) do
		local className = ""
		for _, child in pairs(class.children) do
			if child.tag == "Properties" then
				local data = {Properties = {}, Functions = {}}
				for _, prop in pairs(child.children) do
					if prop.attrs and prop.attrs.name then
						local name = prop.attrs.name
						name = name:sub(1,1):upper() .. name:sub(2)
						data[name] = prop.children[1] and prop.children[1].text or ""
					end
				end
				className = data.Name or ""
				classes[className] = data
			elseif child.attrs and child.attrs.class == "ReflectionMetadataProperties" then
				for _, member in pairs(child.children) do
					if member.attrs and member.attrs.class == "ReflectionMetadataMember" then
						local data = {}
						if member.children[1] and member.children[1].tag == "Properties" then
							for _, prop in pairs(member.children[1].children) do
								if prop.attrs and prop.attrs.name then
									local name = prop.attrs.name
									name = name:sub(1,1):upper() .. name:sub(2)
									data[name] = prop.children[1] and prop.children[1].text or ""
								end
							end
							if data.PropertyOrder then
								local orders = propertyOrders[className]
								if not orders then orders = {}; propertyOrders[className] = orders end
								orders[data.Name] = tonumber(data.PropertyOrder)
							end
							if classes[className] then
								classes[className].Properties[data.Name or ""] = data
							end
						end
					end
				end
			end
		end
	end
	for _, enum in pairs(enumList) do
		local enumName = ""
		for _, child in pairs(enum.children) do
			if child.tag == "Properties" then
				local data = {Items = {}}
				for _, prop in pairs(child.children) do
					if prop.attrs and prop.attrs.name then
						local name = prop.attrs.name
						name = name:sub(1,1):upper() .. name:sub(2)
						data[name] = prop.children[1] and prop.children[1].text or ""
					end
				end
				enumName = data.Name or ""
				enums[enumName] = data
			elseif child.attrs and child.attrs.class == "ReflectionMetadataEnumItem" then
				local data = {}
				if child.children[1] and child.children[1].tag == "Properties" then
					for _, prop in pairs(child.children[1].children) do
						if prop.attrs and prop.attrs.name then
							local name = prop.attrs.name
							name = name:sub(1,1):upper() .. name:sub(2)
							data[name] = prop.children[1] and prop.children[1].text or ""
						end
					end
					if enums[enumName] then
						enums[enumName].Items[data.Name or ""] = data
					end
				end
			end
		end
	end
	return {Classes = classes, Enums = enums, PropertyOrders = propertyOrders}
end
Main.ShowGui = function(gui)
	Env.protectGui(gui)
	gui.Parent = Main.GuiHolder
end
Main.CreateIntro = function(initStatus)
	local gui = create({
		{1,"ScreenGui",{IgnoreGuiInset=true,Name="DeuxIntro",ZIndexBehavior=Enum.ZIndexBehavior.Sibling}},
		{2,"Frame",{Active=true,BackgroundColor3=Color3.fromRGB(25,25,25),BorderSizePixel=0,Name="Main",Parent={1},Position=UDim2.new(0.5,-180,0.5,-105),Size=UDim2.new(0,360,0,210)}},
		{3,"UICorner",{CornerRadius=UDim.new(0,8),Parent={2}}},
		{4,"Frame",{BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0,ClipsDescendants=true,Name="Holder",Parent={2},Size=UDim2.new(1,0,1,0)}},
		{5,"UICorner",{CornerRadius=UDim.new(0,8),Parent={4}}},
		{6,"TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Name="Title",Parent={4},Position=UDim2.new(0,24,0,20),Size=UDim2.new(1,-48,0,40),Text="Deux",TextColor3=Color3.fromRGB(255,255,255),TextSize=36,TextXAlignment=Enum.TextXAlignment.Left}},
		{7,"TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Name="Desc",Parent={4},Position=UDim2.new(0,24,0,58),Size=UDim2.new(1,-48,0,20),Text="successor to dex",TextColor3=Color3.fromRGB(180,180,180),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left}},
		{8,"TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Name="StatusText",Parent={4},Position=UDim2.new(0,24,0,120),Size=UDim2.new(1,-48,0,20),Text="Initializing...",TextColor3=Color3.fromRGB(150,150,150),TextSize=12,TextXAlignment=Enum.TextXAlignment.Left}},
		{9,"Frame",{BackgroundColor3=Color3.fromRGB(40,40,40),BorderSizePixel=0,Name="ProgressBar",Parent={4},Position=UDim2.new(0,24,0,150),Size=UDim2.new(1,-48,0,4)}},
		{10,"UICorner",{CornerRadius=UDim.new(0,2),Parent={9}}},
		{11,"Frame",{BackgroundColor3=Color3.fromRGB(0,120,215),BorderSizePixel=0,Name="Bar",Parent={9},Size=UDim2.new(0,0,1,0)}},
		{12,"UICorner",{CornerRadius=UDim.new(0,2),Parent={11}}},
		{13,"TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Name="Version",Parent={4},Position=UDim2.new(1,-120,1,-28),Size=UDim2.new(0,100,0,20),Text="v"..Main.Version,TextColor3=Color3.fromRGB(100,100,100),TextSize=11,TextXAlignment=Enum.TextXAlignment.Right}},
		{14,"TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Name="Executor",Parent={4},Position=UDim2.new(0,24,1,-28),Size=UDim2.new(0,200,0,20),Text=Env.ExecutorName,TextColor3=Color3.fromRGB(80,80,80),TextSize=11,TextXAlignment=Enum.TextXAlignment.Left}},
	})
	Main.ShowGui(gui)
	local progressBar = gui.Main.Holder.ProgressBar.Bar
	local statusText = gui.Main.Holder.StatusText
	local tweenS = service.TweenService
	local progressTI = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	statusText.Text = initStatus or "Initializing..."
	local function setProgress(text, n)
		statusText.Text = text
		tweenS:Create(progressBar, progressTI, {Size = UDim2.new(n, 0, 1, 0)}):Play()
	end
	local function close()
		local fadeTI = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tweenS:Create(gui.Main, fadeTI, {BackgroundTransparency = 1}):Play()
		tweenS:Create(gui.Main.Holder, fadeTI, {BackgroundTransparency = 1}):Play()
		for _, desc in ipairs(gui.Main.Holder:GetDescendants()) do
			if desc:IsA("TextLabel") then
				tweenS:Create(desc, fadeTI, {TextTransparency = 1}):Play()
			elseif desc:IsA("Frame") then
				tweenS:Create(desc, fadeTI, {BackgroundTransparency = 1}):Play()
			end
		end
		task.delay(0.5, function() gui:Destroy() end)
	end
	return {SetProgress = setProgress, Close = close}
end
Main.CreateApp = function(data)
	if Main.MenuApps[data.Name] then return end
	local control = {}
	local app = Main.AppTemplate:Clone()
	local iconIndex = data.Icon
	if data.IconMap and iconIndex then
		if type(iconIndex) == "number" then
			data.IconMap:Display(app.Main.Icon, iconIndex)
		elseif type(iconIndex) == "string" then
			data.IconMap:DisplayByKey(app.Main.Icon, iconIndex)
		end
	elseif type(iconIndex) == "string" then
		app.Main.Icon.Image = iconIndex
	else
		app.Main.Icon.Image = ""
	end
	local function updateState()
		app.Main.BackgroundTransparency = data.Open and 0 or (Lib.CheckMouseInGui(app.Main) and 0 or 1)
		app.Main.Highlight.Visible = data.Open
	end
	local function enable(silent)
		if data.Open then return end
		data.Open = true
		updateState()
		if not silent then
			if data.Window then data.Window:Show() end
			if data.OnClick then data.OnClick(data.Open) end
		end
	end
	local function disable(silent)
		if not data.Open then return end
		data.Open = false
		updateState()
		if not silent then
			if data.Window then data.Window:Hide() end
			if data.OnClick then data.OnClick(data.Open) end
		end
	end
	updateState()
	local ySize = service.TextService:GetTextSize(data.Name, 14, Enum.Font.SourceSans, Vector2.new(62, 999999)).Y
	app.Main.Size = UDim2.new(1, 0, 0, math.clamp(46 + ySize, 60, 74))
	app.Main.AppName.Text = data.Name
	app.Main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			app.Main.BackgroundTransparency = 0
			app.Main.BackgroundColor3 = Theme.Get("ButtonHover") or Color3.fromRGB(68, 68, 68)
		end
	end)
	app.Main.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			app.Main.BackgroundTransparency = data.Open and 0 or 1
			app.Main.BackgroundColor3 = Theme.Get("Button") or Color3.fromRGB(60, 60, 60)
		end
	end)
	app.Main.MouseButton1Click:Connect(function()
		if data.Open then disable() else enable() end
	end)
	local window = data.Window
	if window then
		window.OnActivate:Connect(function() enable(true) end)
		window.OnDeactivate:Connect(function() disable(true) end)
	end
	app.Visible = true
	app.Parent = Main.AppsContainer
	Main.AppsFrame.CanvasSize = UDim2.new(0, 0, 0, Main.AppsContainerGrid.AbsoluteCellCount.Y * 82 + 8)
	control.Enable = enable
	control.Disable = disable
	Main.MenuApps[data.Name] = control
	return control
end
Main.SetMainGuiOpen = function(val)
	Main.MainGuiOpen = val
	Main.MainGui.OpenButton.Text = val and "X" or "D"
	if val then Main.MainGui.OpenButton.MainFrame.Visible = true end
	local targetSize = val and UDim2.new(0, 240, 0, 320) or UDim2.new(0, 0, 0, 0)
	service.TweenService:Create(Main.MainGui.OpenButton.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	service.TweenService:Create(Main.MainGui.OpenButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = val and 0 or 0.2}):Play()
	if Main.MainGuiMouseEvent then Main.MainGuiMouseEvent:Disconnect() end
	if not val then
		local startTime = tick()
		Main.MainGuiCloseTime = startTime
		task.delay(0.2, function()
			if not Main.MainGuiOpen and startTime == Main.MainGuiCloseTime then
				Main.MainGui.OpenButton.MainFrame.Visible = false
			end
		end)
	else
		Main.MainGuiMouseEvent = service.UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				and not Lib.CheckMouseInGui(Main.MainGui.OpenButton)
				and not Lib.CheckMouseInGui(Main.MainGui.OpenButton.MainFrame) then
				Main.SetMainGuiOpen(false)
			end
		end)
	end
end
Main.CreateMainGui = function()
	local gui = create({
		{1,"ScreenGui",{IgnoreGuiInset=true,Name="DeuxMenu",ZIndexBehavior=Enum.ZIndexBehavior.Sibling}},
		{2,"TextButton",{AnchorPoint=Vector2.new(0.5,0),AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Font=Enum.Font.GothamBold,Name="OpenButton",Parent={1},Position=UDim2.new(0.5,0,0,2),Size=UDim2.new(0,34,0,34),Text="D",TextColor3=Color3.fromRGB(255,255,255),TextSize=16,TextTransparency=0.1}},
		{3,"UICorner",{CornerRadius=UDim.new(0,6),Parent={2}}},
		{4,"Frame",{AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=Color3.fromRGB(25,25,25),ClipsDescendants=true,Name="MainFrame",Parent={2},Position=UDim2.new(0.5,0,1,-4),Size=UDim2.new(0,240,0,320)}},
		{5,"UICorner",{CornerRadius=UDim.new(0,6),Parent={4}}},
		{6,"Frame",{BackgroundColor3=Color3.fromRGB(30,30,30),Name="BottomFrame",Parent={4},Position=UDim2.new(0,0,1,-28),Size=UDim2.new(1,0,0,28)}},
		{7,"UICorner",{CornerRadius=UDim.new(0,6),Parent={6}}},
		{8,"Frame",{BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Name="CoverFrame",Parent={6},Size=UDim2.new(1,0,0,6)}},
		{9,"Frame",{BackgroundColor3=Color3.fromRGB(18,18,18),BorderSizePixel=0,Name="Line",Parent={8},Position=UDim2.new(0,0,0,-1),Size=UDim2.new(1,0,0,1)}},
		{10,"TextButton",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Name="Settings",Parent={6},Position=UDim2.new(1,-56,0,0),Size=UDim2.new(0,28,1,0),Text="⚙",TextColor3=Color3.fromRGB(200,200,200),TextSize=14}},
		{11,"TextButton",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Name="Info",Parent={6},Position=UDim2.new(1,-28,0,0),Size=UDim2.new(0,28,1,0),Text="ℹ",TextColor3=Color3.fromRGB(200,200,200),TextSize=14}},
		{12,"ScrollingFrame",{Active=true,AnchorPoint=Vector2.new(0.5,0),BackgroundTransparency=1,BorderSizePixel=0,Name="AppsFrame",Parent={4},Position=UDim2.new(0.5,0,0,0),ScrollBarImageColor3=Color3.fromRGB(60,60,60),ScrollBarThickness=3,Size=UDim2.new(1,-4,1,-29)}},
		{13,"Frame",{BackgroundTransparency=1,Name="Container",Parent={12},Position=UDim2.new(0,6,0,6),Size=UDim2.new(1,-12,0,2)}},
		{14,"UIGridLayout",{CellSize=UDim2.new(0,68,0,76),CellPadding=UDim2.new(0,4,0,4),Parent={13},SortOrder=Enum.SortOrder.LayoutOrder}},
		{15,"Frame",{BackgroundTransparency=1,Name="App",Parent={1},Size=UDim2.new(0,100,0,100),Visible=false}},
		{16,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(35,35,35),BorderSizePixel=0,Font=Enum.Font.Gotham,Name="Main",Parent={15},Size=UDim2.new(1,0,0,60),Text="",TextColor3=Color3.new(0,0,0),TextSize=14}},
		{17,"UICorner",{CornerRadius=UDim.new(0,4),Parent={16}}},
		{18,"ImageLabel",{BackgroundTransparency=1,Image="",ImageRectSize=Vector2.new(32,32),Name="Icon",Parent={16},Position=UDim2.new(0.5,-14,0,4),ScaleType=Enum.ScaleType.Crop,Size=UDim2.new(0,28,0,28)}},
		{19,"TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Name="AppName",Parent={16},Position=UDim2.new(0,2,0,34),Size=UDim2.new(1,-4,1,-36),Text="App",TextColor3=Color3.fromRGB(220,220,220),TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top}},
		{20,"Frame",{BackgroundColor3=Color3.fromRGB(0,120,215),BorderSizePixel=0,Name="Highlight",Parent={16},Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),Visible=false}},
	})
	Main.MainGui = gui
	Main.AppsFrame = gui.OpenButton.MainFrame.AppsFrame
	Main.AppsContainer = Main.AppsFrame.Container
	Main.AppsContainerGrid = Main.AppsContainer.UIGridLayout
	Main.AppTemplate = gui.App
	Main.MainGuiOpen = false
	local openButton = gui.OpenButton
	openButton.BackgroundTransparency = 0.2
	openButton.MainFrame.Size = UDim2.new(0, 0, 0, 0)
	openButton.MainFrame.Visible = false
	openButton.MouseButton1Click:Connect(function()
		Main.SetMainGuiOpen(not Main.MainGuiOpen)
	end)
	openButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			service.TweenService:Create(openButton, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
		end
	end)
	openButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			service.TweenService:Create(openButton, TweenInfo.new(0.15), {BackgroundTransparency = Main.MainGuiOpen and 0 or 0.2}):Play()
		end
	end)
	if Settings.Get("General.StealthMode") then
		openButton.Visible = false
	end
	Keybinds.Register("Main.ToggleMenu", {
		Keys = {Enum.KeyCode.RightControl, Enum.KeyCode.D},
		Category = "General",
		Description = "Toggle Deux menu",
		Callback = function()
			if Settings.Get("General.StealthMode") then
				openButton.Visible = not openButton.Visible
			end
			Main.SetMainGuiOpen(not Main.MainGuiOpen)
		end
	})
	if Explorer and Explorer.Window then
		Main.CreateApp({Name = "Explorer", IconMap = Main.LargeIcons, Icon = "Explorer", Open = true, Window = Explorer.Window})
	end
	if Properties and Properties.Window then
		Main.CreateApp({Name = "Properties", IconMap = Main.LargeIcons, Icon = "Properties", Open = true, Window = Properties.Window})
	end
	if ScriptEditor and ScriptEditor.Window then
		Main.CreateApp({Name = "Script Editor", IconMap = Main.LargeIcons, Icon = "Script_Viewer", Window = ScriptEditor.Window})
	end
	if Terminal and Terminal.Window then
		Main.CreateApp({Name = "Terminal", Icon = "", Window = Terminal.Window})
	end
	if RemoteSpy and RemoteSpy.Window then
		Main.CreateApp({Name = "Remote Spy", Icon = "", Window = RemoteSpy.Window})
	end
	if SaveInstance and SaveInstance.Window then
		Main.CreateApp({Name = "Save Instance", Icon = "", Window = SaveInstance.Window})
	end
	if DataInspector and DataInspector.Window then
		Main.CreateApp({Name = "Data Inspector", Icon = "", Window = DataInspector.Window})
	end
	if NetworkSpy and NetworkSpy.Window then
		Main.CreateApp({Name = "Network Spy", Icon = "", Window = NetworkSpy.Window})
	end
	if APIReference and APIReference.Window then
		Main.CreateApp({Name = "API Reference", Icon = "", Window = APIReference.Window})
	end
	if WorkspaceTools and WorkspaceTools.Window then
		Main.CreateApp({Name = "Workspace Tools", Icon = "", Window = WorkspaceTools.Window})
	end
	if Console and Console.Window then
		Main.CreateApp({Name = "Console", Icon = "", Window = Console.Window})
	end
	if ThemePicker and ThemePicker.Window then
		Main.CreateApp({Name = "Themes", Icon = "", Window = ThemePicker.Window})
	end
	Main.ShowGui(gui)
end
Main.Init = function()
	Main.InitEnv()
	Main.InitCoreSystems()
	Main.SetupFilesystem()
	local intro = Main.CreateIntro("Initializing Library")
	intro.SetProgress("Loading Library", 0.1)
	Lib = Main.LoadModule("Lib")
	if Lib and Lib.FastWait then Lib.FastWait() end
	intro.SetProgress("Loading Icons", 0.2)
	if Lib and Lib.IconMap then
		Main.MiscIcons = Lib.IconMap.new("rbxassetid://6511490623", 256, 256, 16, 16)
		Main.MiscIcons:SetDict({
			Reference = 0, Cut = 1, Cut_Disabled = 2, Copy = 3, Copy_Disabled = 4, Paste = 5, Paste_Disabled = 6,
			Delete = 7, Delete_Disabled = 8, Group = 9, Group_Disabled = 10, Ungroup = 11, Ungroup_Disabled = 12, TeleportTo = 13,
			Rename = 14, JumpToParent = 15, ExploreData = 16, Save = 17, CallFunction = 18, CallRemote = 19, Undo = 20,
			Undo_Disabled = 21, Redo = 22, Redo_Disabled = 23, Expand_Over = 24, Expand = 25, Collapse_Over = 26, Collapse = 27,
			SelectChildren = 28, SelectChildren_Disabled = 29, InsertObject = 30, ViewScript = 31, AddStar = 32, RemoveStar = 33,
			Script_Disabled = 34, LocalScript_Disabled = 35, Play = 36, Pause = 37, Rename_Disabled = 38
		})
		Main.LargeIcons = Lib.IconMap.new("rbxassetid://6579106223", 256, 256, 32, 32)
		Main.LargeIcons:SetDict({
			Explorer = 0, Properties = 1, Script_Viewer = 2,
		})
	end
	intro.SetProgress("Fetching Roblox Version", 0.25)
	if Main.Elevated then
		pcall(function()
			Main.RobloxVersion = game:HttpGet("http://setup.roblox.com/versionQTStudio")
		end)
	end
	intro.SetProgress("Fetching API", 0.35)
	API = Main.FetchAPI()
	if Lib and Lib.FastWait then Lib.FastWait() end
	intro.SetProgress("Fetching RMD", 0.45)
	RMD = Main.FetchRMD()
	if Main.RawRMDPending and Lib and Lib.ParseXML then
		RMD = Main.ParseRMD(Main.RawRMDPending)
		Main.RawRMDPending = nil
	end
	if Lib and Lib.FastWait then Lib.FastWait() end
	intro.SetProgress("Loading Modules", 0.55)
	if Main.AppControls.Lib and Main.AppControls.Lib.InitDeps then
		Main.AppControls.Lib.InitDeps(Main.GetInitDeps())
	end
	Main.LoadModules()
	if Lib and Lib.FastWait then Lib.FastWait() end
	intro.SetProgress("Initializing Modules", 0.8)
	local initOrder = {"Explorer", "Properties", "ScriptEditor", "Terminal", "RemoteSpy", "SaveInstance", "DataInspector", "NetworkSpy", "APIReference", "PluginAPI", "WorkspaceTools", "Console", "ThemePicker"}
	for _, name in ipairs(initOrder) do
		local app = Main.Apps[name]
		if app and app.Init then
			pcall(app.Init)
		end
	end
	if Lib and Lib.FastWait then Lib.FastWait() end
	intro.SetProgress("Complete", 1)
	task.delay(1, function() intro.Close() end)
	if Lib and Lib.Window and Lib.Window.Init then
		Lib.Window.Init()
	end
	Main.CreateMainGui()
	if Explorer and Explorer.Window then
		Explorer.Window:Show({Align = "right", Pos = 1, Size = 0.5, Silent = true})
	end
	if Properties and Properties.Window then
		Properties.Window:Show({Align = "right", Pos = 2, Size = 0.5, Silent = true})
	end
	if Lib and Lib.DeferFunc and Lib.Window and Lib.Window.ToggleSide then
		Lib.DeferFunc(function() Lib.Window.ToggleSide("right") end)
	end
	if PluginAPI and PluginAPI.LoadAll then
		pcall(PluginAPI.LoadAll)
	end
	local missing = Env.getMissingAPIs()
	if #missing > 3 then
		Notifications.Warning(#missing .. " UNC APIs unavailable on " .. Env.ExecutorName)
	end
	Notifications.Success("Deux v" .. Main.Version .. " loaded")
end
Main.Init()