-- RemoteSpy: hooks remotes (FireServer, InvokeServer, __namecall, ...) and logs each call.

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
	-- Access to other modules if needed
end

local function main()
	local RemoteSpy = {}

	-- State
	local hooks = {} -- hookId -> hookDef
	local hookCounter = 0
	local logs = {} -- ordered list of log entries
	local maxLogs = 5000
	local filterText = ""
	local filterFn = nil -- compiled filter predicate
	local autoScroll = true
	local paused = false
	local connections = {}
	local originalFunctions = {} -- hookId -> original function ref

	-- UI refs
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
		-- Sandboxed predicate: has access to method, instance, args
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

	-- Logging

	local function addLogEntry(entry)
		if paused then return end
		-- Apply filter
		if not matchesFilter(entry) then return end

		table.insert(logs, entry)
		-- Cap
		if #logs > maxLogs then
			table.remove(logs, 1)
		end
		-- Update UI
		RemoteSpy:RenderLogEntry(entry, #logs)
	end

	-- Hooking engine

	function RemoteSpy:CreateHook(config)
		-- config = {Type, Target, Method, Enabled, EditArgs, EditReturn, Block, OnFire}
		if not Env.hookfunction and not Env.hookmetamethod then
			Notifications:Send("RemoteSpy", "Hook capabilities not available", 3)
			return nil
		end

		local id = generateId()
		local hookDef = {
			Id = id,
			Type = config.Type or "function", -- "function", "metamethod", "gc"
			Target = config.Target,
			Method = config.Method or "",
			Enabled = config.Enabled ~= false,
			EditArgs = config.EditArgs, -- function(args) -> newArgs
			EditReturn = config.EditReturn, -- function(ret) -> newRet
			Block = config.Block or false,
			LogArgs = config.LogArgs ~= false,
			LogReturns = config.LogReturns ~= false,
			Original = nil,
		}

		local success, err = pcall(function()
			if hookDef.Type == "metamethod" then
				-- Hook metamethod (__namecall, __index, __newindex)
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
				-- Hook a specific function (e.g. FireServer on a remote)
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
				-- Hook arbitrary closure from getgc
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
			Notifications:Send("RemoteSpy", "Hook failed: " .. tostring(err), 3)
			return nil
		end

		hooks[id] = hookDef
		RemoteSpy:RenderHookPanel()
		return id
	end

	function RemoteSpy:Unhook(id)
		local hookDef = hooks[id]
		if not hookDef then return false end
		-- Restore original where possible
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

	-- Terminal integration

	function RemoteSpy:HookFromTerminal(spec)
		-- spec = "game.ReplicatedStorage.Remote.FireServer" or "__namecall"
		if spec:match("^__") then
			-- Metamethod hook
			return self:CreateHook({
				Type = "metamethod",
				Method = spec,
			})
		else
			-- Try to resolve as instance.method
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

	-- Presets

	function RemoteSpy:ApplyPreset(name)
		if name == "default" or name == "Remote Spy" then
			-- Auto-hook FireServer + InvokeServer + __namecall
			self:CreateHook({
				Type = "metamethod",
				Method = "__namecall",
			})
			Notifications:Send("RemoteSpy", "Default preset applied (namecall hook active)", 3)
		end
	end

	-- Hook profile save/load (deux/saved/hooks/<name>.json).

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
		local json = service("HttpService"):JSONEncode(profile)
		local path = "deux/saved/hooks/" .. (name or "default") .. ".json"
		if Env.writefile then
			Env.writefile(path, json)
			Notifications:Send("RemoteSpy", "Profile saved: " .. path, 3)
		end
	end

	function RemoteSpy:LoadProfile(name)
		local path = "deux/saved/hooks/" .. (name or "default") .. ".json"
		if Env.readfile and Env.isfile and Env.isfile(path) then
			local json = Env.readfile(path)
			local profile = service("HttpService"):JSONDecode(json)
			for _, entry in ipairs(profile) do
				self:CreateHook(entry)
			end
			Notifications:Send("RemoteSpy", "Profile loaded: " .. name, 3)
		end
	end

	-- Copy as script

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
			Notifications:Send("RemoteSpy", "Copied replay script to clipboard", 2)
		end
		return script
	end

	-- Ui

	function RemoteSpy:RenderLogEntry(entry, index)
		if not logList then return end
		local yPos = (index - 1) * logEntryHeight

		local color = Theme.Colors.Text or Color3.new(1, 1, 1)
		if entry.Blocked then
			color = Theme.Colors.Error or Color3.fromRGB(255, 80, 80)
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
			BackgroundColor3 = Theme.Colors.Row or Color3.fromRGB(40, 40, 40),
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
		-- Detail popup / expand
		-- For now, copy to clipboard
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
			Notifications:Send("RemoteSpy", "Log detail copied to clipboard", 2)
		end
	end

	function RemoteSpy:RenderHookPanel()
		if not hookPanel then return end
		-- Clear
		for _, child in ipairs(hookPanel:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextButton") then
				child:Destroy()
			end
		end
		-- List hooks
		local y = 0
		for id, hookDef in pairs(hooks) do
			local row = createSimple("Frame", {
				Name = "Hook_" .. id,
				Parent = hookPanel,
				Position = UDim2.new(0, 0, 0, y),
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 0.9,
				BackgroundColor3 = Theme.Colors.Row or Color3.fromRGB(40, 40, 40),
			})
			createSimple("TextLabel", {
				Parent = row,
				Position = UDim2.new(0, 4, 0, 0),
				Size = UDim2.new(0.6, 0, 1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = hookDef.Enabled and (Theme.Colors.Text or Color3.new(1,1,1)) or (Theme.Colors.Muted or Color3.fromRGB(100,100,100)),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = hookDef.Method .. " [" .. hookDef.Type .. "]",
			})
			-- Toggle button
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
			-- Remove button
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

		-- Filter bar at top
		filterBar = createSimple("TextBox", {
			Name = "Filter",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0.7, -4, 0, 26),
			BackgroundColor3 = Theme.Colors.InputBackground or Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Font = Enum.Font.Code,
			TextSize = 13,
			TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
			PlaceholderText = "Filter: method == 'FireServer' and instance.Name:find('Remote')",
			PlaceholderColor3 = Theme.Colors.Muted or Color3.fromRGB(100,100,100),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		filterBar.FocusLost:Connect(function()
			filterText = filterBar.Text
			filterFn = compileFilter(filterText)
		end)

		-- Auto-scroll toggle
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

		-- Copy as Script button
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

		-- Log list (main area)
		logList = createSimple("ScrollingFrame", {
			Name = "LogList",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 30),
			Size = UDim2.new(0.7, 0, 1, -30),
			BackgroundColor3 = Theme.Colors.Background or Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})

		-- Hook manager panel (right side)
		hookPanel = createSimple("ScrollingFrame", {
			Name = "HookPanel",
			Parent = content,
			Position = UDim2.new(0.7, 4, 0, 30),
			Size = UDim2.new(0.3, -4, 1, -30),
			BackgroundColor3 = Theme.Colors.Panel or Color3.fromRGB(25, 25, 30),
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
	end

	-- Lifecycle

	function RemoteSpy:Init()
		-- Load settings
		pcall(function()
			if Settings.RemoteSpy and Settings.RemoteSpy.MaxLogs then
				maxLogs = Settings.RemoteSpy.MaxLogs
			end
		end)

		RemoteSpy:BuildUI()
		-- Apply default preset if configured
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
		-- Unhook all
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
