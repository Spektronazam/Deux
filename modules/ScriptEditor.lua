-- ScriptEditor: tabs, Luau lexer, find/replace, F5 to run, decompile.

-- Common Locals
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
	
	-- State
	local tabs = {} -- {script, source, name, modified, decompileTime, cursorLine, cursorCol}
	local activeTabIdx = 0
	local connections = {}
	
	-- UI refs
	local tabBar, codeFrame, statusBar, findBar
	local lineNumbers, codeInput, codeDisplay
	
	-- Tiny Luau lexer used to drive RichText syntax highlighting in the editor.
	-- Returns a sequence of tokens; the renderer turns each token into a coloured span.
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
			
			-- Comment (-- to end of line)
			if char == "-" and line:sub(i + 1, i + 1) == "-" then
				local rest = escapeRichText(line:sub(i))
				result[#result + 1] = colorTag(syntaxColors.Comment, rest)
				break
			end
			
			-- String (double quote)
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
			
			-- String (single quote)
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
			
			-- Number
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
			
			-- Identifier / keyword
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
					-- Check if it's a function call (followed by `(`)
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
			
			-- Operators & brackets
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
			
			-- Default
			result[#result + 1] = escapeRichText(char)
			i = i + 1
		end
		
		return table.concat(result)
	end
	
	local function highlightSource(source)
		local syntaxColors = Theme.GetCurrent().Syntax
		local lines = string.split(source, "\n")
		local highlighted = {}
		
		-- Handle multi-line comments and strings (simplified: per-line only)
		for idx, line in ipairs(lines) do
			highlighted[#highlighted + 1] = highlightLine(line, syntaxColors)
		end
		
		return table.concat(highlighted, "\n")
	end


	-- Tab management
	local function getActiveTab()
		return tabs[activeTabIdx]
	end
	
	local function addTab(scriptInst, source, name)
		-- Check if already open
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
		-- Save current cursor position
		local current = getActiveTab()
		if current and codeInput then
			current.CursorLine = ScriptEditor.GetCursorLine()
			current.ScrollY = codeFrame and codeFrame.CanvasPosition.Y or 0
		end
		activeTabIdx = idx
		ScriptEditor.RenderTabs()
		ScriptEditor.RenderCode()
	end
	
	-- Decompile
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
	
	-- Open a script (called by Explorer right-click and the "open_script" Store event).
	ScriptEditor.OpenScript = function(scriptInst)
		if not scriptInst then return end
		
		local name = ""
		pcall(function() name = scriptInst.Name end)
		
		-- Try to get source directly first (LocalScripts in studio, etc.)
		local source
		local s, src = pcall(function() return scriptInst.Source end)
		if s and src and src ~= "" then
			source = src
			addTab(scriptInst, source, name)
			return
		end
		
		-- Decompile
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
	
	-- Find / replace
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
			-- Lua pattern matching
			local start = 1
			while true do
				local s, e = string.find(searchSource, searchQuery, start)
				if not s then break end
				matches[#matches + 1] = {Start = s, End = e}
				start = e + 1
				if start > #searchSource then break end
			end
		else
			-- Plain text search
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
				-- Case-insensitive regex not natively supported; do basic
				return string.gsub(source, query, replacement)
			end
		else
			-- Plain replace
			local result = source
			if not caseSensitive then
				-- Case insensitive plain replace (rebuild)
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
	
	-- Run buffer
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
		
		-- Sandbox: provide basic game globals
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
	
	-- Cursor / line helpers
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


	-- Rendering
	ScriptEditor.RenderTabs = function()
		if not tabBar then return end
		-- Clear existing tab buttons
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
			
			-- Close button on tab
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
		
		-- Set raw source in the invisible input
		if codeInput.Text ~= tab.Source then
			codeInput.Text = tab.Source
		end
		
		-- Highlight and display
		local highlighted = highlightSource(tab.Source)
		codeDisplay.Text = highlighted
		
		-- Line numbers
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
	
	-- Init
	ScriptEditor.Init = function()
		ScriptEditor.Window = Lib.Window.new()
		ScriptEditor.Window:SetTitle("Script Editor")
		ScriptEditor.Window:SetResizable(true)
		ScriptEditor.Window:SetSize(500, 400)
		
		local content = ScriptEditor.Window:GetContentFrame()
		
		-- Tab bar
		tabBar = createSimple("Frame", {
			Name = "TabBar",
			BackgroundColor3 = Theme.Get("Main2") or Color3.fromRGB(35, 35, 35),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 24),
			ClipsDescendants = true,
			Parent = content,
		})
		
		-- Code area (scrollable)
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
		
		-- Line numbers
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
		
		-- RichText display (visible, non-interactive)
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
		
		-- Invisible TextBox for input (on top of display)
		codeInput = createSimple("TextBox", {
			Name = "CodeInput",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -44, 1, 0),
			Position = UDim2.new(0, 44, 0, 0),
			Text = "",
			TextColor3 = Color3.fromRGB(0, 0, 0), -- invisible (display shows highlighted)
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
		
		-- Input change -> update tab source + re-highlight
		codeInput:GetPropertyChangedSignal("Text"):Connect(function()
			local tab = getActiveTab()
			if not tab then return end
			if tab.Source ~= codeInput.Text then
				tab.Source = codeInput.Text
				tab.Modified = true
				ScriptEditor.RenderCode()
			end
		end)
		
		-- Cursor position tracking
		codeInput:GetPropertyChangedSignal("CursorPosition"):Connect(function()
			local tab = getActiveTab()
			if tab then
				tab.CursorLine = ScriptEditor.GetCursorLine()
				ScriptEditor.UpdateStatusBar()
			end
		end)
		
		-- Status bar
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
		
		-- Register keybinds
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
		
		-- Listen for open_script events from other modules
		Store.On("open_script", function(scriptInst)
			ScriptEditor.OpenScript(scriptInst)
			ScriptEditor.Window:Show()
		end)
	end
	
	-- Find bar
	ScriptEditor.ToggleFindBar = function()
		-- TODO: Implement find bar UI toggle
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
