-- Theme: color presets + per-key subscribers so UI re-tints when the user swaps themes.

local Theme = {}

local Env, Settings, HttpService
local currentTheme = {}
local subscribers = {} -- key -> {callback, ...}
local globalSubscribers = {}
local currentPresetName = "Dark"

-- Color helper
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

-- Built-in presets
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
}

-- Notification
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
	
	-- Load saved theme preference
	local savedPreset = Settings and Settings.Get and Settings.Get("General.Theme")
	if savedPreset and Theme.Presets[savedPreset] then
		Theme.Apply(savedPreset, true)
	else
		Theme.Apply("Dark", true)
	end
end

-- Apply a preset by name
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

-- Apply a custom theme table (e.g. loaded from JSON)
function Theme.ApplyCustom(themeTable, silent)
	if type(themeTable) ~= "table" then return false end
	
	-- Merge with Dark as base so missing keys don't break UI
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

-- Get a theme color by key
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

-- Get the full current theme table
function Theme.GetCurrent()
	return currentTheme
end

-- Get current preset name
function Theme.GetCurrentName()
	return currentPresetName
end

function Theme.SetAccent(color)
	local old = currentTheme.Accent
	currentTheme.Accent = color
	notifyKey("Accent", color, old)
end

-- Watch one key (e.g. "Main1", "Syntax.Keyword", "Accent"). Returns unsubscribe.
function Theme.Subscribe(key, callback)
	if not subscribers[key] then
		subscribers[key] = {}
	end
	table.insert(subscribers[key], callback)
	
	-- Immediately call with current value
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

-- Subscribe to all theme changes
function Theme.SubscribeAll(callback)
	table.insert(globalSubscribers, callback)
	return function()
		local idx = table.find(globalSubscribers, callback)
		if idx then table.remove(globalSubscribers, idx) end
	end
end

-- List available presets
function Theme.ListPresets()
	local names = {}
	for name in pairs(Theme.Presets) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end

-- Export current theme as JSON
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

-- Import theme from JSON string
function Theme.Import(jsonStr)
	if not HttpService then return false end
	local s, decoded = pcall(HttpService.JSONDecode, HttpService, jsonStr)
	if not s or type(decoded) ~= "table" then return false end
	
	-- Convert color arrays back to Color3
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

-- Save current theme to filesystem
function Theme.SaveToFile(filename)
	if not Env or not Env.Capabilities.Filesystem then return false end
	local json = Theme.Export()
	if not json then return false end
	local path = "deux/themes/" .. (filename or currentPresetName) .. ".json"
	local s = pcall(Env.writefile, path, json)
	return s
end

-- Load theme from filesystem
function Theme.LoadFromFile(filename)
	if not Env or not Env.Capabilities.Filesystem then return false end
	local path = "deux/themes/" .. filename .. ".json"
	local s, raw = pcall(Env.readfile, path)
	if not s or not raw then return false end
	return Theme.Import(raw)
end

-- List saved theme files
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

return Theme
