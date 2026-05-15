--[[
	Deux :: SaveInstance Module
	
	Save instance UI with:
	- Wraps Env.saveinstance (capability gated)
	- Options dialog: scope, include script source, optimize meshes,
	  scrub player data, file format (rbxlx/rbxl)
	- Progress indicator ("Saving..." status)
	- Right-click integration: listens for Store "save_instance" event
	- Output path: deux/saved/places/<PlaceId>_<timestamp>.rbxlx
	- Also supports "Save as Model" for subtrees (rbxmx)
	- Notification on complete with file path
	- Settings integration for defaults
	- Window with Lib.Window.new()
]]

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
	-- References to other modules if needed
end

local function main()
	local SaveInstance = {}

	------------------------------------------------------------------------
	-- STATE
	------------------------------------------------------------------------
	local isSaving = false
	local connections = {}

	-- Default options
	local options = {
		Scope = "place", -- "place", "selection", "nil"
		IncludeScriptSource = true,
		OptimizeMeshes = true,
		ScrubPlayerData = true,
		FileFormat = "rbxlx", -- "rbxlx", "rbxl"
		ModelFormat = "rbxmx", -- for subtree saves
	}

	-- UI refs
	local window, optionsFrame, statusLabel, saveButton

	------------------------------------------------------------------------
	-- HELPERS
	------------------------------------------------------------------------

	local function getTimestamp()
		return os.date("%Y%m%d_%H%M%S")
	end

	local function getPlaceId()
		return tostring(game.PlaceId or "0")
	end

	local function getOutputPath(format)
		format = format or options.FileFormat
		return "deux/saved/places/" .. getPlaceId() .. "_" .. getTimestamp() .. "." .. format
	end

	local function getModelOutputPath(name, format)
		format = format or options.ModelFormat
		name = name or "model"
		-- Sanitize name
		name = name:gsub("[^%w_%-]", "_")
		return "deux/saved/places/" .. name .. "_" .. getTimestamp() .. "." .. format
	end

	local function setStatus(text)
		if statusLabel then
			statusLabel.Text = text
		end
	end

	local function ensureDirectory()
		if Env.makefolder and not Env.isfolder("deux/saved/places") then
			pcall(function()
				Env.makefolder("deux")
				Env.makefolder("deux/saved")
				Env.makefolder("deux/saved/places")
			end)
		end
	end

	------------------------------------------------------------------------
	-- SAVE LOGIC
	------------------------------------------------------------------------

	function SaveInstance:SavePlace(overrideOptions)
		if isSaving then
			Notifications:Send("SaveInstance", "Already saving, please wait...", 3)
			return
		end
		if not Env.saveinstance then
			Notifications:Send("SaveInstance", "saveinstance not available in this executor", 3)
			return
		end

		isSaving = true
		setStatus("Saving place...")

		local opts = {}
		for k, v in pairs(options) do opts[k] = v end
		if overrideOptions then
			for k, v in pairs(overrideOptions) do opts[k] = v end
		end

		ensureDirectory()
		local path = getOutputPath(opts.FileFormat)

		task.spawn(function()
			local ok, err = pcall(function()
				local saveOpts = {
					FilePath = path,
					ExtraInstances = {},
					DecompileScripts = opts.IncludeScriptSource,
					NilInstances = opts.Scope == "nil",
					RemovePlayerCharacters = opts.ScrubPlayerData,
					SavePlayers = not opts.ScrubPlayerData,
				}
				Env.saveinstance(saveOpts)
			end)

			isSaving = false
			if ok then
				setStatus("Saved!")
				Notifications:Send("SaveInstance", "Place saved: " .. path, 5)
			else
				setStatus("Failed: " .. tostring(err))
				Notifications:Send("SaveInstance", "Save failed: " .. tostring(err), 5)
			end

			-- Reset status after delay
			task.delay(3, function()
				setStatus("Ready")
			end)
		end)
	end

	function SaveInstance:SaveModel(instance, overrideOptions)
		if isSaving then
			Notifications:Send("SaveInstance", "Already saving, please wait...", 3)
			return
		end
		if not instance then
			Notifications:Send("SaveInstance", "No instance provided", 3)
			return
		end
		if not Env.saveinstance then
			Notifications:Send("SaveInstance", "saveinstance not available in this executor", 3)
			return
		end

		isSaving = true
		setStatus("Saving model: " .. instance.Name .. "...")

		local opts = {}
		for k, v in pairs(options) do opts[k] = v end
		if overrideOptions then
			for k, v in pairs(overrideOptions) do opts[k] = v end
		end

		ensureDirectory()
		local path = getModelOutputPath(instance.Name, opts.ModelFormat)

		task.spawn(function()
			local ok, err = pcall(function()
				local saveOpts = {
					FilePath = path,
					ExtraInstances = {instance},
					DecompileScripts = opts.IncludeScriptSource,
					Mode = "model",
				}
				Env.saveinstance(saveOpts)
			end)

			isSaving = false
			if ok then
				setStatus("Saved!")
				Notifications:Send("SaveInstance", "Model saved: " .. path, 5)
			else
				setStatus("Failed: " .. tostring(err))
				Notifications:Send("SaveInstance", "Save failed: " .. tostring(err), 5)
			end

			task.delay(3, function()
				setStatus("Ready")
			end)
		end)
	end

	------------------------------------------------------------------------
	-- UI
	------------------------------------------------------------------------

	function SaveInstance:BuildUI()
		window = Lib.Window.new()
		window:SetTitle("Save Instance")
		window:SetSize(400, 340)

		local content = window:GetContent()
		local yOffset = 0
		local rowHeight = 28
		local padding = 4

		-- Helper: create option row
		local function addOptionRow(label, optionKey, values)
			local row = createSimple("Frame", {
				Name = "Row_" .. optionKey,
				Parent = content,
				Position = UDim2.new(0, 0, 0, yOffset),
				Size = UDim2.new(1, 0, 0, rowHeight),
				BackgroundTransparency = 1,
			})
			createSimple("TextLabel", {
				Parent = row,
				Position = UDim2.new(0, 8, 0, 0),
				Size = UDim2.new(0.5, -8, 1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextSize = 14,
				TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = label,
			})
			if values then
				-- Dropdown-style button
				local btn = createSimple("TextButton", {
					Parent = row,
					Position = UDim2.new(0.5, 4, 0, 2),
					Size = UDim2.new(0.5, -12, 0, rowHeight - 4),
					BackgroundColor3 = Theme.Colors.InputBackground or Color3.fromRGB(40, 40, 40),
					Font = Enum.Font.Code,
					TextSize = 13,
					TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
					Text = tostring(options[optionKey]),
				})
				btn.MouseButton1Click:Connect(function()
					-- Cycle through values
					local currentIdx = 1
					for i, v in ipairs(values) do
						if tostring(options[optionKey]) == tostring(v) then
							currentIdx = i
							break
						end
					end
					currentIdx = (currentIdx % #values) + 1
					options[optionKey] = values[currentIdx]
					btn.Text = tostring(options[optionKey])
				end)
			else
				-- Boolean toggle
				local btn = createSimple("TextButton", {
					Parent = row,
					Position = UDim2.new(0.5, 4, 0, 2),
					Size = UDim2.new(0.5, -12, 0, rowHeight - 4),
					BackgroundColor3 = options[optionKey] and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60),
					Font = Enum.Font.Code,
					TextSize = 13,
					TextColor3 = Color3.new(1,1,1),
					Text = options[optionKey] and "ON" or "OFF",
				})
				btn.MouseButton1Click:Connect(function()
					options[optionKey] = not options[optionKey]
					btn.Text = options[optionKey] and "ON" or "OFF"
					btn.BackgroundColor3 = options[optionKey] and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
				end)
			end
			yOffset = yOffset + rowHeight + padding
		end

		-- Options
		addOptionRow("Scope", "Scope", {"place", "selection", "nil"})
		addOptionRow("Include Script Source", "IncludeScriptSource")
		addOptionRow("Optimize Meshes", "OptimizeMeshes")
		addOptionRow("Scrub Player Data", "ScrubPlayerData")
		addOptionRow("File Format", "FileFormat", {"rbxlx", "rbxl"})
		addOptionRow("Model Format", "ModelFormat", {"rbxmx", "rbxm"})

		yOffset = yOffset + 10

		-- Status label
		statusLabel = createSimple("TextLabel", {
			Name = "Status",
			Parent = content,
			Position = UDim2.new(0, 8, 0, yOffset),
			Size = UDim2.new(1, -16, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansItalic,
			TextSize = 14,
			TextColor3 = Theme.Colors.Muted or Color3.fromRGB(160, 160, 160),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Ready",
		})
		yOffset = yOffset + 30

		-- Save Place button
		saveButton = createSimple("TextButton", {
			Name = "SavePlace",
			Parent = content,
			Position = UDim2.new(0, 8, 0, yOffset),
			Size = UDim2.new(0.45, -8, 0, 32),
			BackgroundColor3 = Color3.fromRGB(50, 120, 200),
			Font = Enum.Font.SourceSansBold,
			TextSize = 15,
			TextColor3 = Color3.new(1,1,1),
			Text = "Save Place",
		})
		saveButton.MouseButton1Click:Connect(function()
			SaveInstance:SavePlace()
		end)

		-- Save Selection button
		local saveSelBtn = createSimple("TextButton", {
			Name = "SaveSelection",
			Parent = content,
			Position = UDim2.new(0.5, 4, 0, yOffset),
			Size = UDim2.new(0.45, -8, 0, 32),
			BackgroundColor3 = Color3.fromRGB(50, 160, 100),
			Font = Enum.Font.SourceSansBold,
			TextSize = 15,
			TextColor3 = Color3.new(1,1,1),
			Text = "Save Selection",
		})
		saveSelBtn.MouseButton1Click:Connect(function()
			local sel = Store:Get("selected_instance")
			if sel then
				SaveInstance:SaveModel(sel)
			else
				Notifications:Send("SaveInstance", "No instance selected", 3)
			end
		end)
	end

	------------------------------------------------------------------------
	-- LIFECYCLE
	------------------------------------------------------------------------

	function SaveInstance:Init()
		-- Load defaults from settings
		pcall(function()
			if Settings.SaveInstance then
				for k, v in pairs(Settings.SaveInstance) do
					if options[k] ~= nil then
						options[k] = v
					end
				end
			end
		end)

		SaveInstance:BuildUI()

		-- Listen for Store event (right-click integration)
		table.insert(connections, Store:On("save_instance", function(instance)
			if instance then
				SaveInstance:SaveModel(instance)
			else
				SaveInstance:SavePlace()
			end
		end))
	end

	function SaveInstance:GetOptions()
		return options
	end

	function SaveInstance:SetOption(key, value)
		if options[key] ~= nil then
			options[key] = value
		end
	end

	function SaveInstance:Destroy()
		for _, conn in ipairs(connections) do
			if typeof(conn) == "RBXScriptConnection" then
				conn:Disconnect()
			end
		end
		connections = {}
		if window then
			window:Close()
		end
	end

	SaveInstance:Init()
	return SaveInstance
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
