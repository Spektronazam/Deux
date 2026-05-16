-- Theme: color presets + per-key subscribers so UI re-tints when the user swaps themes.

local Theme = {}

local Env, Settings, HttpService, Lighting
local currentTheme = {}
local subscribers = {} -- key -> {callback, ...}
local globalSubscribers = {}
local currentPresetName = "Dark"
local currentFontName = "Gotham"

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

	-- "New" Dex (the modern fork most users see today). Slightly bluer than
	-- generic Dark and accent-leaning, distinct from the original Dex grey.
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

	-- Original Dex (the LorekeeperZinnia / Moon palette). Cooler bluish greys.
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

	-- Old Dex (very early Roblox Studio explorer look: tan/beige, blue
	-- selection). Lighter than the rest by design.
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

	-- Synapse X classic (deep navy + violet accent, the "purple" feel).
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

	-- SirMeme (warm/red accent, charcoal background, distinctive).
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

-- Display order for the Themes picker (presets only; "Smart" is computed
-- dynamically and Manual lives in its own section).
Theme.PresetOrder = {"New", "Dex", "Old Dex", "Synapse X", "SirMeme", "Dark", "Darker", "Light"}

-- Font registry. Each entry maps a friendly label to either a built-in
-- Enum.Font, or a loader (filepath / loadstring URL / callback). Modules use
-- Theme.GetFont() to read the current Enum.Font value; UI components that
-- want to react can subscribe to "Font".
Theme.Fonts = {
	{Name = "Gotham", Font = Enum.Font.Gotham},
	{Name = "GothamMedium", Font = Enum.Font.GothamMedium},
	{Name = "GothamBold", Font = Enum.Font.GothamBold},
	{Name = "Code", Font = Enum.Font.Code},
	{Name = "Plex", Font = Enum.Font.RobotoMono}, -- Closest built-in match for IBM Plex
	{Name = "RobotoMono", Font = Enum.Font.RobotoMono},
	{Name = "SourceSans", Font = Enum.Font.SourceSans},
	{Name = "SourceSansBold", Font = Enum.Font.SourceSansBold},
	{Name = "Arial", Font = Enum.Font.Arial},
	{Name = "Ubuntu", Font = Enum.Font.Ubuntu},
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
	Lighting = serviceTable.Lighting or game:GetService("Lighting")

	-- Load saved theme preference
	local savedPreset = Settings and Settings.Get and Settings.Get("General.Theme")
	if savedPreset and Theme.Presets[savedPreset] then
		Theme.Apply(savedPreset, true)
	else
		Theme.Apply("Dark", true)
	end

	-- Restore font preference
	local savedFont = Settings and Settings.Get and Settings.Get("General.Font")
	if savedFont then
		Theme.SetFont(savedFont, true)
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

-- Set a single theme key (used by the Manual section of the Themes picker
-- and by Theme.SetAccent). Notifies subscribers so live UI re-tints.
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

-- Generate and apply a theme automatically derived from the world's lighting
-- (sky/ambient + clear color). Useful when the user wants the menu to blend
-- with whatever scene they happen to be in.
local function lerpColor(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end

local function relativeLuminance(c)
	-- Rough perceptual luminance; good enough for picking a contrasting text color.
	return 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B
end

local function shift(c, amount)
	return Color3.new(
		math.clamp(c.R + amount, 0, 1),
		math.clamp(c.G + amount, 0, 1),
		math.clamp(c.B + amount, 0, 1)
	)
end

-- Build a coherent palette from one seed color.
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

-- Sample lighting + camera background to pick a seed color, then build & apply.
function Theme.SmartFromWorld(silent)
	local seed
	local accentSeed
	if Lighting then
		-- Mix Ambient and OutdoorAmbient with a slight bias toward whichever
		-- is brighter, then darken so the menu stays readable.
		local amb = Lighting.Ambient
		local out = Lighting.OutdoorAmbient
		local mix = lerpColor(amb, out, 0.5)
		-- Darken to a UI-appropriate background.
		seed = shift(mix, -0.35)
		-- Accent: complementary-ish hue derived from the brighter of the two.
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

-- Font handling -------------------------------------------------------------

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

-- Switch the active font. Subscribers to the "Font" key get notified.
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

-- Register a font dynamically. The picker UI lets the user load a font from
-- a URL (loadstring-style) or a filesystem path; both flows funnel here.
-- `font` may be an Enum.Font value or the result of Font.new(assetId).
function Theme.RegisterFont(name, font)
	if type(name) ~= "string" or not font then return false end
	if findFontEntry(name) then return false end
	Theme.Fonts[#Theme.Fonts + 1] = {Name = name, Font = font, Custom = true}
	return true
end

-- Convenience for the picker: register a font from a Roblox asset ID.
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
