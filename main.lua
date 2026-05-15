--[[
	Deux - The Successor Explorer
	Version 2.0.0
	
	Originally developed by Moon (New Dex)
	Continued and rewritten as Deux by Spektronazam
	
	Deux is a full debugging suite: explorer, properties, script editor,
	remote spy, data inspector, terminal, save instance, and more.
	
	Built on UNC/sUNC standards. No Synapse-specific code.
	
	Credits:
		Moon/LorekeeperZinnia - Original New Dex architecture & Lib
		Spektronazam - Deux successor rewrite
]]

-- Prevent double-execution
if _G.DeuxLoaded then return end
_G.DeuxLoaded = true

------------------------------------------------------------------------
-- CORE BOOTSTRAP
------------------------------------------------------------------------
local Env, Settings, Theme, Keybinds, Notifications, Store
local Lib, API, RMD
local Explorer, Properties, ScriptEditor, Terminal, RemoteSpy
local SaveInstance, DataInspector, NetworkSpy, APIReference
local PluginAPI, WorkspaceTools, Console

-- Module references (populated by build system)
local EmbeddedModules = EmbeddedModules or {}

-- Service accessor with cloneref hardening
local serviceCache = {}
local service = setmetatable({}, {
	__index = function(self, name)
		if serviceCache[name] then return serviceCache[name] end
		local s, serv = pcall(game.GetService, game, name)
		if not s or not serv then return nil end
		-- cloneref if available (set after Env loads)
		if Env and Env.cloneref then
			serv = Env.cloneref(serv)
		end
		serviceCache[name] = serv
		rawset(self, name, serv)
		return serv
	end
})

local plr = service.Players.LocalPlayer or service.Players.PlayerAdded:Wait()

------------------------------------------------------------------------
-- UTILITY: Instance creation (preserved from original for Lib compat)
------------------------------------------------------------------------
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

------------------------------------------------------------------------
-- MAIN CONTROLLER
------------------------------------------------------------------------
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
	"NetworkSpy", "APIReference", "PluginAPI", "WorkspaceTools", "Console"
}
Main.DisplayOrders = {
	SideWindow = 8,
	Window = 10,
	Menu = 100000,
	Core = 101000
}

------------------------------------------------------------------------
-- ENV INITIALIZATION (UNC/sUNC)
------------------------------------------------------------------------
Main.InitEnv = function()
	-- Load core/Env (embedded by build system)
	if EmbeddedModules["Env"] then
		Env = EmbeddedModules["Env"]()
	else
		-- Fallback: construct minimal env
		Env = {Capabilities = {}, MissingAPIs = {}, ExecutorName = "Unknown"}
		Env.getService = function(n) return game:GetService(n) end
		Env.getGuiParent = function()
			local s = pcall(function() return game:GetService("CoreGui"):GetFullName() end)
			if s then return game:GetService("CoreGui") end
			return plr:FindFirstChildOfClass("PlayerGui")
		end
		Env.protectGui = function() end
	end
	
	-- Refresh service cache with cloneref now available
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

------------------------------------------------------------------------
-- CORE SYSTEMS INITIALIZATION
------------------------------------------------------------------------
Main.InitCoreSystems = function()
	-- Settings
	if EmbeddedModules["Settings"] then
		Settings = EmbeddedModules["Settings"]()
	else
		Settings = {Get = function() return nil end, Set = function() end, Init = function() end}
	end
	Settings.Init(Env, service)
	
	-- Theme
	if EmbeddedModules["Theme"] then
		Theme = EmbeddedModules["Theme"]()
	else
		Theme = {Get = function(k) return Color3.new(0.2,0.2,0.2) end, Init = function() end, Apply = function() end}
	end
	Theme.Init(Env, Settings, service)
	
	-- Keybinds
	if EmbeddedModules["Keybinds"] then
		Keybinds = EmbeddedModules["Keybinds"]()
	else
		Keybinds = {Init = function() end, Register = function() end}
	end
	Keybinds.Init(Settings, service)
	
	-- Store
	if EmbeddedModules["Store"] then
		Store = EmbeddedModules["Store"]()
	else
		Store = {Set = function() end, Get = function() end, Subscribe = function() return function() end end, On = function() return function() end end, Emit = function() end, SetSelection = function() end, GetSelection = function() return {} end}
	end
	
	-- Notifications (needs GUI parent)
	if EmbeddedModules["Notifications"] then
		Notifications = EmbeddedModules["Notifications"]()
	else
		Notifications = {Init = function() end, Info = function() end, Error = function() end, Success = function() end, Warning = function() end}
	end
	Notifications.Init(Env, Theme, service)
end

------------------------------------------------------------------------
-- DEPS TABLE (passed to all modules for initialization)
------------------------------------------------------------------------
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
		env = Env, -- backward compat
		service = service,
		plr = plr,
		create = create,
		createSimple = createSimple,
	}
end


------------------------------------------------------------------------
-- MODULE LOADER
------------------------------------------------------------------------
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
		if name ~= "Lib" then -- Lib loaded separately first
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
	
	-- Assign major app references
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
	
	-- Call InitAfterMain on all modules
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

------------------------------------------------------------------------
-- ERROR HANDLING
------------------------------------------------------------------------
Main.Error = function(str)
	local msg = "[Deux] ERROR: " .. tostring(str)
	if Env and Env.rconsoleprinт then
		pcall(Env.rconsoleprinт, msg .. "\n")
	end
	warn(msg)
end

Main.Warn = function(str)
	local msg = "[Deux] WARN: " .. tostring(str)
	warn(msg)
end

------------------------------------------------------------------------
-- SETTINGS (load from disk)
------------------------------------------------------------------------
Main.LoadSettings = function()
	-- Settings.Init already handles loading; this is for compat
	if Settings and Settings.Load then
		Settings.Load()
	end
end

------------------------------------------------------------------------
-- FILESYSTEM SETUP
------------------------------------------------------------------------
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


------------------------------------------------------------------------
-- API FETCH (Roblox API Dump + RMD)
------------------------------------------------------------------------
Main.FetchAPI = function()
	local rawAPI
	
	if Main.Elevated then
		-- Try cached first
		if Env.Capabilities.Filesystem then
			local s, cached = pcall(Env.readfile, "deux/cache/rbx_api.json")
			if s and cached and cached ~= "" then
				rawAPI = cached
			end
		end
		
		-- Fetch from Roblox CDN if not cached
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
	
	-- Cache for next time
	if Env.Capabilities.Filesystem and not pcall(Env.isfile, "deux/cache/rbx_api.json") then
		pcall(Env.writefile, "deux/cache/rbx_api.json", rawAPI)
	end
	
	local s, api = pcall(service.HttpService.JSONDecode, service.HttpService, rawAPI)
	if not s then
		Main.Error("Failed to decode API JSON")
		return {Classes = {}, Enums = {}, CategoryOrder = {}, GetMember = function() return {} end}
	end
	
	-- Process API into usable format
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
	
	-- Resolve superclass references
	for _, class in pairs(classes) do
		class.Superclass = classes[class.Superclass]
	end
	
	-- Process enums
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
	
	-- Category ordering
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
		-- Try cached
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
	
	-- Cache
	if Env.Capabilities.Filesystem then
		pcall(Env.writefile, "deux/cache/rbx_rmd.xml", rawXML)
	end
	
	-- Parse (Lib.ParseXML needed — defer if Lib not loaded yet)
	if Lib and Lib.ParseXML then
		return Main.ParseRMD(rawXML)
	end
	
	-- Store raw for later parsing after Lib loads
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


------------------------------------------------------------------------
-- GUI: Show with protection
------------------------------------------------------------------------
Main.ShowGui = function(gui)
	Env.protectGui(gui)
	gui.Parent = Main.GuiHolder
end

------------------------------------------------------------------------
-- GUI: Intro / Splash Screen
------------------------------------------------------------------------
Main.CreateIntro = function(initStatus)
	local gui = create({
		{1,"ScreenGui",{IgnoreGuiInset=true,Name="DeuxIntro",ZIndexBehavior=Enum.ZIndexBehavior.Sibling}},
		{2,"Frame",{Active=true,BackgroundColor3=Color3.fromRGB(25,25,25),BorderSizePixel=0,Name="Main",Parent={1},Position=UDim2.new(0.5,-180,0.5,-105),Size=UDim2.new(0,360,0,210)}},
		{3,"UICorner",{CornerRadius=UDim.new(0,8),Parent={2}}},
		{4,"Frame",{BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0,ClipsDescendants=true,Name="Holder",Parent={2},Size=UDim2.new(1,0,1,0)}},
		{5,"UICorner",{CornerRadius=UDim.new(0,8),Parent={4}}},
		{6,"TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Name="Title",Parent={4},Position=UDim2.new(0,24,0,20),Size=UDim2.new(1,-48,0,40),Text="Deux",TextColor3=Color3.fromRGB(255,255,255),TextSize=36,TextXAlignment=Enum.TextXAlignment.Left}},
		{7,"TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Name="Desc",Parent={4},Position=UDim2.new(0,24,0,58),Size=UDim2.new(1,-48,0,20),Text="The Successor Debugging Suite",TextColor3=Color3.fromRGB(180,180,180),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left}},
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

------------------------------------------------------------------------
-- GUI: Main Menu (App Launcher)
------------------------------------------------------------------------
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
	
	-- Stealth mode: hide open button if enabled
	if Settings.Get("General.StealthMode") then
		openButton.Visible = false
	end
	
	-- Register toggle keybind
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
	
	-- Create apps for loaded modules
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
	
	Main.ShowGui(gui)
end

------------------------------------------------------------------------
-- MAIN INIT (Entry Point)
------------------------------------------------------------------------
Main.Init = function()
	-- Phase 1: Environment
	Main.InitEnv()
	
	-- Phase 2: Core systems
	Main.InitCoreSystems()
	Main.SetupFilesystem()
	
	-- Phase 3: Splash
	local intro = Main.CreateIntro("Initializing Library")
	
	-- Phase 4: Load Lib (foundation UI library)
	intro.SetProgress("Loading Library", 0.1)
	Lib = Main.LoadModule("Lib")
	if Lib and Lib.FastWait then Lib.FastWait() end
	
	-- Phase 5: Icons
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
	
	-- Phase 6: Fetch Roblox version
	intro.SetProgress("Fetching Roblox Version", 0.25)
	if Main.Elevated then
		pcall(function()
			Main.RobloxVersion = game:HttpGet("http://setup.roblox.com/versionQTStudio")
		end)
	end
	
	-- Phase 7: Fetch API + RMD
	intro.SetProgress("Fetching API", 0.35)
	API = Main.FetchAPI()
	if Lib and Lib.FastWait then Lib.FastWait() end
	
	intro.SetProgress("Fetching RMD", 0.45)
	RMD = Main.FetchRMD()
	-- If RMD was deferred, parse now that Lib is available
	if Main.RawRMDPending and Lib and Lib.ParseXML then
		RMD = Main.ParseRMD(Main.RawRMDPending)
		Main.RawRMDPending = nil
	end
	if Lib and Lib.FastWait then Lib.FastWait() end
	
	-- Phase 8: Update deps in Lib
	intro.SetProgress("Loading Modules", 0.55)
	if Main.AppControls.Lib and Main.AppControls.Lib.InitDeps then
		Main.AppControls.Lib.InitDeps(Main.GetInitDeps())
	end
	
	-- Phase 9: Load all other modules
	Main.LoadModules()
	if Lib and Lib.FastWait then Lib.FastWait() end
	
	-- Phase 10: Initialize modules
	intro.SetProgress("Initializing Modules", 0.8)
	local initOrder = {"Explorer", "Properties", "ScriptEditor", "Terminal", "RemoteSpy", "SaveInstance", "DataInspector", "NetworkSpy", "APIReference", "PluginAPI", "WorkspaceTools", "Console"}
	for _, name in ipairs(initOrder) do
		local app = Main.Apps[name]
		if app and app.Init then
			pcall(app.Init)
		end
	end
	if Lib and Lib.FastWait then Lib.FastWait() end
	
	-- Phase 11: Done
	intro.SetProgress("Complete", 1)
	task.delay(1, function() intro.Close() end)
	
	-- Phase 12: Window system + main GUI
	if Lib and Lib.Window and Lib.Window.Init then
		Lib.Window.Init()
	end
	Main.CreateMainGui()
	
	-- Show default windows
	if Explorer and Explorer.Window then
		Explorer.Window:Show({Align = "right", Pos = 1, Size = 0.5, Silent = true})
	end
	if Properties and Properties.Window then
		Properties.Window:Show({Align = "right", Pos = 2, Size = 0.5, Silent = true})
	end
	if Lib and Lib.DeferFunc and Lib.Window and Lib.Window.ToggleSide then
		Lib.DeferFunc(function() Lib.Window.ToggleSide("right") end)
	end
	
	-- Phase 13: Load plugins
	if PluginAPI and PluginAPI.LoadAll then
		pcall(PluginAPI.LoadAll)
	end
	
	-- Capability notification
	local missing = Env.getMissingAPIs()
	if #missing > 3 then
		Notifications.Warning(#missing .. " UNC APIs unavailable on " .. Env.ExecutorName)
	end
	
	Notifications.Success("Deux v" .. Main.Version .. " loaded")
end

------------------------------------------------------------------------
-- START
------------------------------------------------------------------------
Main.Init()
