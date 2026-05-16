-- DataInspector: GC walker, function detail (env / consts / upvals / decompile), threads.

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
	local DataInspector = {}

	-- State
	local connections = {}
	local gcCache = {} -- cached getgc results
	local gcLastRefresh = 0
	local activeTab = "gc" -- "gc", "functions", "references", "threads", "signature"
	local tabs = {} -- sub-tab stack for reference explorer

	-- Filter state
	local filterType = nil -- "function", "table", "userdata", "thread", or nil (all)
	local filterSource = ""
	local filterName = ""
	local filterUpvalue = ""

	-- Virtualized list
	local ROW_HEIGHT = 22
	local visibleRows = {}
	local scrollOffset = 0
	local totalItems = 0

	-- Selected item for detail view
	local selectedItem = nil
	local decompileCache = {} -- function -> decompiled source

	-- UI refs
	local window, contentFrame, listFrame, detailFrame
	local tabBar, filterFrame, statusLabel

	-- Capability checks

	local function hasGC()
		return Env.Capabilities and Env.Capabilities.GC and Env.getgc
	end

	local function hasDebug()
		return Env.Capabilities and Env.Capabilities.Debug
	end

	local function hasDecompile()
		return Env.decompile ~= nil
	end

	-- Gc explorer

	function DataInspector:RefreshGC()
		if not hasGC() then
			Notifications.Info("GC capability not available", 3)
			return
		end
		gcCache = Env.getgc(true) or {}
		gcLastRefresh = os.clock()
		DataInspector:ApplyFilters()
	end

	function DataInspector:ApplyFilters()
		visibleRows = {}
		for _, obj in ipairs(gcCache) do
			local objType = type(obj)
			local pass = true

			-- Type filter
			if filterType and objType ~= filterType then
				pass = false
			end

			-- Source filter (functions only)
			if pass and filterSource ~= "" and objType == "function" then
				local info = Env.getinfo and Env.getinfo(obj)
				if info then
					local src = info.source or info.short_src or ""
					if not src:lower():find(filterSource:lower(), 1, true) then
						pass = false
					end
				end
			end

			-- Name filter
			if pass and filterName ~= "" then
				local name = tostring(obj)
				if objType == "function" and Env.getinfo then
					local info = Env.getinfo(obj)
					if info and info.name then
						name = info.name
					end
				end
				if not name:lower():find(filterName:lower(), 1, true) then
					pass = false
				end
			end

			-- Upvalue content filter (functions only)
			if pass and filterUpvalue ~= "" and objType == "function" then
				local found = false
				if Env.getupvalues then
					local upvals = Env.getupvalues(obj)
					if upvals then
						for _, v in pairs(upvals) do
							if tostring(v):lower():find(filterUpvalue:lower(), 1, true) then
								found = true
								break
							end
						end
					end
				end
				if not found then pass = false end
			end

			if pass then
				table.insert(visibleRows, obj)
			end
		end
		totalItems = #visibleRows
		DataInspector:RenderList()
	end


	-- Function detail view

	function DataInspector:ShowFunctionDetail(fn)
		if type(fn) ~= "function" then return end
		selectedItem = fn

		local detail = {
			Type = "function",
			Info = nil,
			Constants = {},
			Upvalues = {},
			Source = nil,
			ScriptPath = nil,
			References = {},
		}

		-- getinfo
		if Env.getinfo then
			detail.Info = Env.getinfo(fn)
			if detail.Info then
				detail.ScriptPath = detail.Info.source or detail.Info.short_src
			end
		end

		-- getconstants
		if Env.getconstants then
			local ok, consts = pcall(Env.getconstants, fn)
			if ok then detail.Constants = consts or {} end
		end

		-- getupvalues
		if Env.getupvalues then
			local ok, upvals = pcall(Env.getupvalues, fn)
			if ok then detail.Upvalues = upvals or {} end
		end

		-- decompile (lazy, cached)
		if hasDecompile() then
			if decompileCache[fn] then
				detail.Source = decompileCache[fn]
			else
				task.spawn(function()
					local ok, src = pcall(Env.decompile, fn)
					if ok then
						decompileCache[fn] = src
						detail.Source = src
						DataInspector:RenderDetail(detail)
					end
				end)
			end
		end

		DataInspector:RenderDetail(detail)
	end

	-- Reference explorer

	function DataInspector:FindReferences(value)
		if not hasGC() then return {} end
		local refs = {}
		local seen = {}

		for _, obj in ipairs(gcCache) do
			if type(obj) == "table" and not seen[obj] then
				seen[obj] = true
				for k, v in pairs(obj) do
					if v == value then
						table.insert(refs, {
							Holder = obj,
							Key = k,
							Path = "table[" .. tostring(k) .. "]",
						})
					end
				end
			elseif type(obj) == "function" and not seen[obj] then
				seen[obj] = true
				if Env.getupvalues then
					local ok, upvals = pcall(Env.getupvalues, obj)
					if ok and upvals then
						for idx, v in pairs(upvals) do
							if v == value then
								local name = "upvalue_" .. idx
								if Env.getinfo then
									local info = Env.getinfo(obj)
									if info and info.name then
										name = info.name .. ".upval[" .. idx .. "]"
									end
								end
								table.insert(refs, {
									Holder = obj,
									Key = idx,
									Path = name,
								})
							end
						end
					end
				end
			end
		end
		return refs
	end

	function DataInspector:OpenReferenceTab(value)
		local refs = DataInspector:FindReferences(value)
		table.insert(tabs, {
			Value = value,
			References = refs,
			Label = tostring(value):sub(1, 30),
		})
		DataInspector:RenderReferenceTabs()
	end

	-- Constant-signature builder

	function DataInspector:BuildSignature(fn)
		if type(fn) ~= "function" then return nil end
		local consts = {}
		local upvals = {}

		if Env.getconstants then
			local ok, c = pcall(Env.getconstants, fn)
			if ok then consts = c or {} end
		end
		if Env.getupvalues then
			local ok, u = pcall(Env.getupvalues, fn)
			if ok then upvals = u or {} end
		end

		-- Pick stable identifiers (strings, numbers)
		local stableConsts = {}
		for i, v in ipairs(consts) do
			if type(v) == "string" and #v > 2 and #v < 100 then
				table.insert(stableConsts, {Index = i, Value = v})
			end
		end

		-- Generate findfunc snippet
		local lines = {}
		table.insert(lines, "-- Constant-Signature Finder")
		table.insert(lines, "local target = nil")
		table.insert(lines, "for _, fn in ipairs(getgc(true)) do")
		table.insert(lines, "    if type(fn) == 'function' then")
		table.insert(lines, "        local consts = getconstants(fn)")
		if #stableConsts > 0 then
			local checks = {}
			for _, sc in ipairs(stableConsts) do
				table.insert(checks, string.format("consts[%d] == %q", sc.Index, sc.Value))
			end
			table.insert(lines, "        if " .. table.concat(checks, " and ") .. " then")
		else
			table.insert(lines, "        if false then -- no stable constants found")
		end
		table.insert(lines, "            target = fn")
		table.insert(lines, "            break")
		table.insert(lines, "        end")
		table.insert(lines, "    end")
		table.insert(lines, "end")
		table.insert(lines, "return target")

		return table.concat(lines, "\n")
	end

	-- Thread browser

	function DataInspector:GetThreads()
		if not Env.getthreads then return {} end
		local ok, threads = pcall(Env.getthreads)
		if not ok then return {} end

		local results = {}
		for i, thread in ipairs(threads or {}) do
			local status = coroutine.status(thread)
			local tb = ""
			if Env.getinfo then
				pcall(function()
					local info = Env.getinfo(thread)
					if info then
						tb = (info.source or "") .. ":" .. (info.currentline or "?")
					end
				end)
			end
			table.insert(results, {
				Thread = thread,
				Status = status,
				Traceback = tb,
				Index = i,
			})
		end
		return results
	end


	-- Ui: virtualized list

	function DataInspector:RenderList()
		if not listFrame then return end
		-- Clear existing
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("Frame") then
				child:Destroy()
			end
		end

		local viewHeight = listFrame.AbsoluteSize.Y
		local startIdx = math.floor(scrollOffset / ROW_HEIGHT) + 1
		local endIdx = math.min(totalItems, startIdx + math.ceil(viewHeight / ROW_HEIGHT) + 1)

		for i = startIdx, endIdx do
			local obj = visibleRows[i]
			if not obj then break end

			local objType = type(obj)
			local displayText = "[" .. objType .. "] "
			if objType == "function" and Env.getinfo then
				local info = Env.getinfo(obj)
				if info and info.name and info.name ~= "" then
					displayText = displayText .. info.name
				elseif info and info.short_src then
					displayText = displayText .. info.short_src .. ":" .. (info.currentline or "?")
				else
					displayText = displayText .. tostring(obj)
				end
			elseif objType == "table" then
				local count = 0
				for _ in pairs(obj) do count = count + 1 if count > 10 then break end end
				displayText = displayText .. "{" .. count .. (count > 10 and "+" or "") .. " entries}"
			else
				displayText = displayText .. tostring(obj):sub(1, 60)
			end

			local yPos = (i - 1) * ROW_HEIGHT - scrollOffset
			local row = createSimple("TextButton", {
				Name = "Row_" .. i,
				Parent = listFrame,
				Position = UDim2.new(0, 0, 0, yPos),
				Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
				BackgroundTransparency = i % 2 == 0 and 0.95 or 1,
				BackgroundColor3 = Theme.Get("Row") or Color3.fromRGB(35, 35, 40),
				BorderSizePixel = 0,
				Font = Enum.Font.Code,
				TextSize = 13,
				TextColor3 = Theme.Get("Text") or Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "  " .. displayText,
				AutoButtonColor = true,
			})

			row.MouseButton1Click:Connect(function()
				if objType == "function" then
					DataInspector:ShowFunctionDetail(obj)
				elseif objType == "table" then
					DataInspector:OpenReferenceTab(obj)
				end
			end)
		end

		listFrame.CanvasSize = UDim2.new(0, 0, 0, totalItems * ROW_HEIGHT)
	end

	function DataInspector:RenderDetail(detail)
		if not detailFrame then return end
		-- Clear
		for _, child in ipairs(detailFrame:GetChildren()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then
				child:Destroy()
			end
		end

		local y = 0
		local lineH = 18

		local function addLine(text, color)
			createSimple("TextLabel", {
				Parent = detailFrame,
				Position = UDim2.new(0, 4, 0, y),
				Size = UDim2.new(1, -8, 0, lineH),
				BackgroundTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = color or Theme.Get("Text") or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = text,
				TextWrapped = true,
			})
			y = y + lineH
		end

		if not detail then
			addLine("No item selected")
			return
		end

		-- Header
		addLine("--- Function Detail ---", Theme.Get("Accent") or Color3.fromRGB(100, 180, 255))

		-- Info
		if detail.Info then
			addLine("Name: " .. (detail.Info.name or "anonymous"))
			addLine("Source: " .. (detail.ScriptPath or "unknown"))
			if detail.Info.currentline then
				addLine("Line: " .. detail.Info.currentline)
			end
			if detail.Info.numparams then
				addLine("Params: " .. detail.Info.numparams)
			end
		end

		-- Constants
		y = y + 4
		addLine("Constants (" .. #detail.Constants .. "):", Theme.Get("Accent") or Color3.fromRGB(100, 180, 255))
		for i, c in ipairs(detail.Constants) do
			if i > 50 then
				addLine("  ... (" .. (#detail.Constants - 50) .. " more)")
				break
			end
			addLine("  [" .. i .. "] " .. type(c) .. " = " .. tostring(c):sub(1, 60))
		end

		-- Upvalues
		y = y + 4
		local upvalCount = 0
		for _ in pairs(detail.Upvalues) do upvalCount = upvalCount + 1 end
		addLine("Upvalues (" .. upvalCount .. "):", Theme.Get("Accent") or Color3.fromRGB(100, 180, 255))
		local uvIdx = 0
		for k, v in pairs(detail.Upvalues) do
			uvIdx = uvIdx + 1
			if uvIdx > 50 then
				addLine("  ... (more)")
				break
			end
			addLine("  [" .. tostring(k) .. "] " .. type(v) .. " = " .. tostring(v):sub(1, 60))
		end

		-- Decompiled source
		if detail.Source then
			y = y + 4
			addLine("Decompiled Source:", Theme.Get("Accent") or Color3.fromRGB(100, 180, 255))
			for line in detail.Source:gmatch("[^\n]+") do
				addLine("  " .. line)
			end
		elseif hasDecompile() then
			addLine("(Decompiling...)", Theme.Get("Muted") or Color3.fromRGB(120,120,120))
		end

		-- Signature builder button
		y = y + 8
		local sigBtn = createSimple("TextButton", {
			Parent = detailFrame,
			Position = UDim2.new(0, 4, 0, y),
			Size = UDim2.new(0.5, -8, 0, 24),
			BackgroundColor3 = Color3.fromRGB(60, 100, 160),
			Font = Enum.Font.Code,
			TextSize = 12,
			TextColor3 = Color3.new(1,1,1),
			Text = "Copy Signature Finder",
		})
		sigBtn.MouseButton1Click:Connect(function()
			if selectedItem then
				local snippet = DataInspector:BuildSignature(selectedItem)
				if snippet and Env.setclipboard then
					Env.setclipboard(snippet)
					Notifications.Info("Signature snippet copied!", 2)
				end
			end
		end)

		-- Find references button
		local refBtn = createSimple("TextButton", {
			Parent = detailFrame,
			Position = UDim2.new(0.5, 4, 0, y),
			Size = UDim2.new(0.5, -8, 0, 24),
			BackgroundColor3 = Color3.fromRGB(100, 60, 160),
			Font = Enum.Font.Code,
			TextSize = 12,
			TextColor3 = Color3.new(1,1,1),
			Text = "Find References",
		})
		refBtn.MouseButton1Click:Connect(function()
			if selectedItem then
				DataInspector:OpenReferenceTab(selectedItem)
			end
		end)
		y = y + 30

		detailFrame.CanvasSize = UDim2.new(0, 0, 0, y)
	end

	function DataInspector:RenderReferenceTabs()
		-- Show the latest reference tab
		if #tabs == 0 then return end
		local current = tabs[#tabs]
		if not detailFrame then return end

		for _, child in ipairs(detailFrame:GetChildren()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local y = 0
		local lineH = 18

		createSimple("TextLabel", {
			Parent = detailFrame,
			Position = UDim2.new(0, 4, 0, y),
			Size = UDim2.new(1, -8, 0, lineH),
			BackgroundTransparency = 1,
			Font = Enum.Font.Code,
			TextSize = 12,
			TextColor3 = Theme.Get("Accent") or Color3.fromRGB(100, 180, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "References to: " .. current.Label,
		})
		y = y + lineH + 4

		for i, ref in ipairs(current.References) do
			if i > 200 then break end
			local btn = createSimple("TextButton", {
				Parent = detailFrame,
				Position = UDim2.new(0, 4, 0, y),
				Size = UDim2.new(1, -8, 0, lineH),
				BackgroundTransparency = 0.95,
				BackgroundColor3 = Theme.Get("Row") or Color3.fromRGB(35, 35, 40),
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "  " .. ref.Path .. " -> " .. tostring(ref.Key),
			})
			btn.MouseButton1Click:Connect(function()
				DataInspector:OpenReferenceTab(ref.Holder)
			end)
			y = y + lineH
		end

		if #current.References == 0 then
			createSimple("TextLabel", {
				Parent = detailFrame,
				Position = UDim2.new(0, 4, 0, y),
				Size = UDim2.new(1, -8, 0, lineH),
				BackgroundTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = Theme.Get("Muted") or Color3.fromRGB(120,120,120),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "  (no references found)",
			})
		end

		detailFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
	end


	-- Ui: build

	function DataInspector:BuildUI()
		window = Lib.Window.new()
		window:SetTitle("Data Inspector")
		window:SetSize(750, 500)

		local content = window:GetContent()

		-- Tab bar
		tabBar = createSimple("Frame", {
			Name = "TabBar",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = Theme.Get("TabBar") or Color3.fromRGB(30, 30, 35),
			BorderSizePixel = 0,
		})

		local tabDefs = {
			{Name = "GC Explorer", Key = "gc"},
			{Name = "Threads", Key = "threads"},
		}
		for i, td in ipairs(tabDefs) do
			local tabBtn = createSimple("TextButton", {
				Name = "Tab_" .. td.Key,
				Parent = tabBar,
				Position = UDim2.new(0, (i-1) * 100, 0, 2),
				Size = UDim2.new(0, 96, 0, 24),
				BackgroundColor3 = activeTab == td.Key and (Theme.Get("ActiveTab") or Color3.fromRGB(60, 60, 80)) or (Theme.Get("Tab") or Color3.fromRGB(40, 40, 50)),
				Font = Enum.Font.SourceSansBold,
				TextSize = 13,
				TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
				Text = td.Name,
			})
			tabBtn.MouseButton1Click:Connect(function()
				activeTab = td.Key
				DataInspector:SwitchTab(td.Key)
			end)
		end

		-- Filter bar
		filterFrame = createSimple("Frame", {
			Name = "Filters",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 30),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = Theme.Get("Panel") or Color3.fromRGB(25, 25, 30),
			BorderSizePixel = 0,
		})

		-- Type filter
		local typeBtn = createSimple("TextButton", {
			Parent = filterFrame,
			Position = UDim2.new(0, 4, 0, 2),
			Size = UDim2.new(0, 80, 0, 22),
			BackgroundColor3 = Color3.fromRGB(50, 50, 60),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			Text = "Type: all",
		})
		local typeOptions = {nil, "function", "table", "userdata", "thread"}
		local typeIdx = 1
		typeBtn.MouseButton1Click:Connect(function()
			typeIdx = (typeIdx % #typeOptions) + 1
			filterType = typeOptions[typeIdx]
			typeBtn.Text = "Type: " .. (filterType or "all")
			DataInspector:ApplyFilters()
		end)

		-- Source filter
		local srcBox = createSimple("TextBox", {
			Parent = filterFrame,
			Position = UDim2.new(0, 88, 0, 2),
			Size = UDim2.new(0, 140, 0, 22),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			PlaceholderText = "Source...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		srcBox.FocusLost:Connect(function()
			filterSource = srcBox.Text
			DataInspector:ApplyFilters()
		end)

		-- Name filter
		local nameBox = createSimple("TextBox", {
			Parent = filterFrame,
			Position = UDim2.new(0, 232, 0, 2),
			Size = UDim2.new(0, 140, 0, 22),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			PlaceholderText = "Name...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		nameBox.FocusLost:Connect(function()
			filterName = nameBox.Text
			DataInspector:ApplyFilters()
		end)

		-- Upvalue filter
		local upvalBox = createSimple("TextBox", {
			Parent = filterFrame,
			Position = UDim2.new(0, 376, 0, 2),
			Size = UDim2.new(0, 140, 0, 22),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			PlaceholderText = "Upvalue...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = "",
		})
		upvalBox.FocusLost:Connect(function()
			filterUpvalue = upvalBox.Text
			DataInspector:ApplyFilters()
		end)

		-- Refresh button
		local refreshBtn = createSimple("TextButton", {
			Parent = filterFrame,
			Position = UDim2.new(1, -64, 0, 2),
			Size = UDim2.new(0, 60, 0, 22),
			BackgroundColor3 = Color3.fromRGB(60, 120, 60),
			Font = Enum.Font.Code,
			TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			Text = "Refresh",
		})
		refreshBtn.MouseButton1Click:Connect(function()
			DataInspector:RefreshGC()
		end)

		-- Main content area: split left (list) / right (detail)
		listFrame = createSimple("ScrollingFrame", {
			Name = "List",
			Parent = content,
			Position = UDim2.new(0, 0, 0, 58),
			Size = UDim2.new(0.5, -2, 1, -58),
			BackgroundColor3 = Theme.Get("Background") or Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})

		listFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			scrollOffset = listFrame.CanvasPosition.Y
			DataInspector:RenderList()
		end)

		detailFrame = createSimple("ScrollingFrame", {
			Name = "Detail",
			Parent = content,
			Position = UDim2.new(0.5, 2, 0, 58),
			Size = UDim2.new(0.5, -2, 1, -58),
			BackgroundColor3 = Theme.Get("Panel") or Color3.fromRGB(25, 25, 30),
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
	end

	-- Tab switching

	function DataInspector:SwitchTab(key)
		activeTab = key
		if key == "gc" then
			DataInspector:RefreshGC()
		elseif key == "threads" then
			DataInspector:ShowThreads()
		end
	end

	function DataInspector:ShowThreads()
		local threads = DataInspector:GetThreads()
		visibleRows = {}
		for _, t in ipairs(threads) do
			table.insert(visibleRows, t)
		end
		totalItems = #visibleRows

		if not listFrame then return end
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local y = 0
		for i, t in ipairs(threads) do
			local text = string.format("[%d] %s - %s", t.Index, t.Status, t.Traceback)
			createSimple("TextButton", {
				Name = "Thread_" .. i,
				Parent = listFrame,
				Position = UDim2.new(0, 0, 0, y),
				Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
				BackgroundTransparency = i % 2 == 0 and 0.95 or 1,
				BackgroundColor3 = Theme.Get("Row") or Color3.fromRGB(35, 35, 40),
				BorderSizePixel = 0,
				Font = Enum.Font.Code,
				TextSize = 12,
				TextColor3 = Theme.Get("Text") or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "  " .. text,
			})
			y = y + ROW_HEIGHT
		end
		listFrame.CanvasSize = UDim2.new(0, 0, 0, y)
	end

	-- Lifecycle

	function DataInspector:Init()
		DataInspector:BuildUI()

		-- Listen for Store event
		table.insert(connections, Store.On("explore_data", function(value)
			if value then
				if type(value) == "function" then
					DataInspector:ShowFunctionDetail(value)
				else
					DataInspector:OpenReferenceTab(value)
				end
			else
				DataInspector:RefreshGC()
			end
		end))

		-- Initial refresh if capable
		if hasGC() then
			DataInspector:RefreshGC()
		end
	end

	function DataInspector:Destroy()
		for _, conn in ipairs(connections) do
			if typeof(conn) == "RBXScriptConnection" then
				conn:Disconnect()
			end
		end
		connections = {}
		decompileCache = {}
		tabs = {}
		if window then
			window:Close()
		end
	end

	DataInspector:Init()
	return DataInspector
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
