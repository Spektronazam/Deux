--[[
	Deux :: NetworkSpy Module
	Inbound network viewer + HTTP spy + WebSocket panel
]]

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

	-- Inbound hooks
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

	-- HTTP hooks
	local function hookHTTP()
		if not Env.hookfunction then return end
		pcall(function()
			local hs = service("HttpService")
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

	-- WebSocket hooks
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

	-- UI
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
