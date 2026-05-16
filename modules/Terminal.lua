-- Terminal: command bar with tab-complete, history, and a registry plugins can add to.

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

local function initAfterMain(appTable)
	-- Access to other modules (e.g. Explorer for find/goto)
end

local function main()
	local Terminal = {}

	-- State
	local commands = {} -- name -> commandDef
	local commandList = {} -- ordered list for iteration
	local history = {} -- command history strings
	local historyIndex = 0
	local outputLines = {} -- {Text: string, Color: Color3?, ClickData: any?}
	local MAX_OUTPUT = 2000
	local inputText = ""
	local completionCandidates = {}
	local completionIndex = 0
	local connections = {}

	-- UI refs
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

	-- Output

	local function appendOutput(text, color, clickData)
		table.insert(outputLines, {
			Text = tostring(text),
			Color = color,
			ClickData = clickData,
		})
		if #outputLines > MAX_OUTPUT then
			table.remove(outputLines, 1)
		end
		-- Render (deferred to batch)
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

	-- Command registry

	function Terminal:RegisterCommand(def)
		-- def = {Name, Aliases, Args, Description, Category, Run, Complete}
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

	-- Tab completion

	local function getCompletions(text)
		local results = {}
		local parts = text:split(" ")
		local cmdPart = parts[1] or ""
		
		if #parts <= 1 then
			-- Complete command names
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
			-- Complete arguments (instance paths)
			local argText = parts[#parts] or ""
			local cmd = commands[cmdPart:lower()]
			if cmd and cmd.Complete then
				results = cmd.Complete(argText, parts) or {}
			else
				-- Default: instance path completion
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

	-- Command execution

	local function executeCommand(raw)
		if not raw or raw:match("^%s*$") then return end

		-- Add to history
		table.insert(history, raw)
		historyIndex = #history + 1
		-- Persist history
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

	-- Built-in commands

	local function registerBuiltIns()
		-- select <path>
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

		-- goto <path>
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

		-- find <filters>
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

		-- tree <depth>
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

		-- dump <inst>
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

		-- hook <inst>.<event>
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

		-- unhook <id>
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

		-- gc filter:<type>
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

		-- loadstring <url>
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

		-- save place / save selection
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

		-- bookmark add/list/rm
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

		-- theme <name>
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

		-- settings <key> [value]
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
					-- Set
					pcall(function()
						Settings[key] = tonumber(value) or value
					end)
					printSuccess(key .. " = " .. tostring(Settings[key]))
				else
					-- Get
					local val = Settings[key]
					if val ~= nil then
						printOutput(key .. " = " .. tostring(val))
					else
						printError("Setting not found: " .. key)
					end
				end
			end,
		})

		-- clear
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

		-- help [command]
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
					-- List all by category
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

		-- exec <code>
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

		-- version
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

	-- Ui

	function Terminal:RenderOutput()
		if not outputFrame then return end
		-- Clear existing
		for _, child in ipairs(outputFrame:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		-- Render lines
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
			-- Clickable instance references
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

		-- Output ScrollingFrame
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

		-- Input bar
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

		-- Input events
		inputBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local text = inputBox.Text
				inputBox.Text = ""
				executeCommand(text)
			end
		end)

		-- Keyboard navigation (history + tab complete)
		inputBox:GetPropertyChangedSignal("Text"):Connect(function()
			inputText = inputBox.Text
			completionCandidates = {}
			completionIndex = 0
		end)

		-- Key handling via UserInputService
		local UIS = service.UserInputService
		table.insert(connections, UIS.InputBegan:Connect(function(input, gameProcessed)
			if not inputBox:IsFocused() then return end

			if input.KeyCode == Enum.KeyCode.Up then
				-- Previous history
				if #history > 0 then
					historyIndex = math.max(1, historyIndex - 1)
					inputBox.Text = history[historyIndex] or ""
				end
			elseif input.KeyCode == Enum.KeyCode.Down then
				-- Next history
				historyIndex = math.min(#history + 1, historyIndex + 1)
				inputBox.Text = history[historyIndex] or ""
			elseif input.KeyCode == Enum.KeyCode.Tab then
				-- Tab completion
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

		-- Load history from settings
		pcall(function()
			if Settings and Settings.Terminal and Settings.Terminal.History then
				history = Settings.Terminal.History
				historyIndex = #history + 1
			end
		end)
	end

	-- Lifecycle

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
