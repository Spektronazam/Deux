--[[
	Deux Core :: Settings
	Persistent JSON Settings with Deep-Merge & Versioned Migration
	
	Features:
	- Schema-versioned settings with automatic migration
	- Deep merge of user settings over defaults (preserves new keys on update)
	- Persistent save/load via filesystem (UNC readfile/writefile)
	- Hot-reload support (call .Load() at any time)
	- Observable: subscribe to changes per-key or globally
	- Per-place overrides (game.PlaceId scoped)
	
	Usage:
		local Settings = require("core/Settings")
		Settings.Init(Env, service) -- call once at boot
		local val = Settings.Get("Explorer.Sorting")
		Settings.Set("Explorer.Sorting", false)
		Settings.Subscribe("Theme", function(key, newVal, oldVal) ... end)
]]

local Settings = {}

------------------------------------------------------------------------
-- INTERNAL STATE
------------------------------------------------------------------------
local SCHEMA_VERSION = 2
local FILE_PATH = "deux/settings.json"
local PLACE_FILE_PATH -- set at Init based on PlaceId

local Env -- core/Env reference
local HttpService -- for JSON encode/decode

local currentData = {} -- live merged settings
local subscribers = {} -- key pattern -> {callback, ...}
local globalSubscribers = {} -- any change

------------------------------------------------------------------------
-- DEFAULT SETTINGS SCHEMA
------------------------------------------------------------------------
Settings.Defaults = {
	_SchemaVersion = SCHEMA_VERSION,
	
	General = {
		AutoUpdate = true,
		AutoUpdateChannel = "stable", -- "stable" | "beta"
		StealthMode = false, -- hide open button, use hotkey only
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
		AutoUpdateMode = 0, -- 0=Default, 1=NoTreeUpdate, 2=NoDescendantEvents, 3=Frozen
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
		ScaleType = 1, -- 0=FullName, 1=EqualHalves
		CopyFormat = "lua", -- "lua" | "display" | "json"
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
		DefaultScope = "game", -- "game" | "selection"
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
		FilterLevel = "all", -- "all" | "warn" | "error"
	},
	
	Plugins = {
		Enabled = true,
		AutoLoad = true,
		TrustedPlugins = {},
	},
}

------------------------------------------------------------------------
-- DEEP UTILITY FUNCTIONS
------------------------------------------------------------------------
local function deepCopy(t)
	if type(t) ~= "table" then return t end
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = deepCopy(v)
	end
	return copy
end

local function deepMerge(base, override)
	-- Merges override into base; base gets new keys from defaults, override wins on conflicts
	local result = deepCopy(base)
	if type(override) ~= "table" then return result end
	for k, v in pairs(override) do
		if type(v) == "table" and type(result[k]) == "table" and not v[1] then
			-- Recurse into sub-tables (but not arrays)
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

------------------------------------------------------------------------
-- MIGRATION
------------------------------------------------------------------------
local migrations = {}

-- Migration from v1 (original Dex settings) to v2
migrations[1] = function(data)
	-- Map old flat keys to new structure
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
	
	-- Theme is now in core/Theme.lua, but preserve if present
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

------------------------------------------------------------------------
-- NOTIFICATION SYSTEM
------------------------------------------------------------------------
local function notifyChange(path, newVal, oldVal)
	-- Notify specific subscribers
	for pattern, callbacks in pairs(subscribers) do
		if string.find(path, pattern, 1, true) == 1 then
			for _, cb in ipairs(callbacks) do
				task.spawn(cb, path, newVal, oldVal)
			end
		end
	end
	-- Notify global subscribers
	for _, cb in ipairs(globalSubscribers) do
		task.spawn(cb, path, newVal, oldVal)
	end
end

------------------------------------------------------------------------
-- PUBLIC API
------------------------------------------------------------------------

--- Initialize the settings system
-- @param envRef: core/Env module reference
-- @param serviceTable: service metatable from main
function Settings.Init(envRef, serviceTable)
	Env = envRef
	HttpService = serviceTable.HttpService or game:GetService("HttpService")
	
	local placeId = game.PlaceId
	if placeId and placeId ~= 0 then
		PLACE_FILE_PATH = "deux/settings_" .. tostring(placeId) .. ".json"
	end
	
	-- Ensure directories exist
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

--- Load settings from disk, merge with defaults
function Settings.Load()
	currentData = deepCopy(Settings.Defaults)
	
	if not Env or not Env.Capabilities.Filesystem then return end
	
	-- Load global settings
	local s, raw = pcall(Env.readfile, FILE_PATH)
	if s and raw and raw ~= "" then
		local s2, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
		if s2 and type(decoded) == "table" then
			decoded = migrate(decoded)
			currentData = deepMerge(Settings.Defaults, decoded)
		end
	end
	
	-- Load place-specific overrides on top
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

--- Save current settings to disk
function Settings.Save()
	if not Env or not Env.Capabilities.Filesystem then return false end
	
	local s, encoded = pcall(HttpService.JSONEncode, HttpService, currentData)
	if not s then return false end
	
	local s2 = pcall(Env.writefile, FILE_PATH, encoded)
	return s2
end

--- Save place-specific overrides
function Settings.SavePlaceOverrides(overrides)
	if not Env or not Env.Capabilities.Filesystem or not PLACE_FILE_PATH then return false end
	
	local s, encoded = pcall(HttpService.JSONEncode, HttpService, overrides)
	if not s then return false end
	
	local s2 = pcall(Env.writefile, PLACE_FILE_PATH, encoded)
	return s2
end

--- Get a setting value by dot-separated path
-- @param path: e.g. "Explorer.Sorting" or "Theme.Main1"
-- @return: the value, or nil if not found
function Settings.Get(path)
	return getNestedValue(currentData, path)
end

--- Set a setting value by dot-separated path
-- @param path: e.g. "Explorer.Sorting"
-- @param value: the new value
-- @param noSave: if true, don't auto-persist (batch mode)
function Settings.Set(path, value, noSave)
	local oldVal = getNestedValue(currentData, path)
	if oldVal == value then return end -- no change
	
	setNestedValue(currentData, path, value)
	notifyChange(path, value, oldVal)
	
	if not noSave then
		Settings.Save()
	end
end

--- Set multiple settings at once (batch), saves once at the end
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

--- Reset a category or all settings to defaults
-- @param category: optional category name (e.g. "Explorer"), or nil for all
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

--- Subscribe to changes on a settings path prefix
-- @param pathPrefix: e.g. "Explorer" to catch all Explorer.* changes, or "Explorer.Sorting" for specific
-- @param callback: function(path, newVal, oldVal)
-- @return: unsubscribe function
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

--- Subscribe to all settings changes
-- @param callback: function(path, newVal, oldVal)
-- @return: unsubscribe function
function Settings.SubscribeAll(callback)
	table.insert(globalSubscribers, callback)
	return function()
		local idx = table.find(globalSubscribers, callback)
		if idx then table.remove(globalSubscribers, idx) end
	end
end

--- Get the full settings table (read-only reference)
function Settings.GetAll()
	return currentData
end

--- Get the raw defaults table
function Settings.GetDefaults()
	return Settings.Defaults
end

--- Export settings as JSON string
function Settings.Export()
	if not HttpService then return nil end
	local s, json = pcall(HttpService.JSONEncode, HttpService, currentData)
	return s and json or nil
end

--- Import settings from JSON string
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

--- Get schema version
function Settings.GetSchemaVersion()
	return SCHEMA_VERSION
end

return Settings
