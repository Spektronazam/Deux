--[[
	Deux :: PluginAPI Module
	Plugin system with loader, sandbox, manifest, manager UI, and hot-reload
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
	local PluginAPI = {}
	local plugins = {} -- name -> entry
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
				local ok2, m = pcall(function() return service("HttpService"):JSONDecode(c) end)
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

	-- Sandbox creation
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
		sb.Notify = function(msg, sev) Notifications:Send(name, tostring(msg), sev or 3) end
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
				if k == "Get" then return function(_, key) return Store:Get(key) end
				elseif k == "Listen" then return function(_, ev, cb) return Store:Listen(ev, cb) end end
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
		Notifications:Send("Plugins", "Loaded: "..name.." v"..(manifest.version or "?"), 2)
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

	-- Hot-reload polling
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

	-- Public accessors
	function PluginAPI:GetRightClickHandlers() return rightClickHandlers end
	function PluginAPI:GetSearchFilterHandlers() return searchFilterHandlers end
	function PluginAPI:GetPropertyEditor(tn) return propertyEditors[tn] end
	function PluginAPI:GetErrorLogs() return errorLogs end

	-- UI
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
