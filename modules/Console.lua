-- Console: catches print/warn/error and LogService output, with a filter and search.

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

	-- Global hooks
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

	-- UI
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
