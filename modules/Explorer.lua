-- Explorer: instance tree, selection, search, bookmarks, right-click menu.

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
	-- References to other apps if needed
end

local function main()
	local Explorer = {}
	
	-- State
	local tree = {} -- node list (flat, ordered for display)
	local nodeMap = {} -- instance -> node
	local selection = {} -- ordered list of selected instances
	local expanded = {} -- instance -> bool
	local bookmarks = {} -- ordered list of bookmarked instances
	local nilInstances = {} -- list of nil-parented instances
	local selectionHistory = {} -- {past = {}, future = {}}
	local searchQuery = ""
	local searchResults = {}
	local searchActive = false
	
	-- Config
	local ROW_HEIGHT = 20
	local INDENT_WIDTH = 18
	local ICON_SIZE = 16
	local MAX_VISIBLE_ROWS = 50
	local BATCH_INTERVAL = 0 -- deferred (1 frame)
	
	-- Connections
	local connections = {}
	local descendantAddedBatch
	local descendantRemovedBatch
	
	-- Node class
	local Node = {}
	Node.__index = Node
	
	function Node.new(instance, parent, depth)
		local self = setmetatable({}, Node)
		self.Instance = instance
		self.Parent = parent
		self.Depth = depth or 0
		self.Children = {}
		self.Expanded = false
		self.Visible = true
		self.Selected = false
		self.Bookmarked = false
		self.GuiRow = nil -- recycled row reference
		self.ClassName = ""
		self.Name = ""
		
		-- Safe property reads
		pcall(function()
			self.ClassName = instance.ClassName
			self.Name = instance.Name
		end)
		
		return self
	end
	
	function Node:Refresh()
		pcall(function()
			self.ClassName = self.Instance.ClassName
			self.Name = self.Instance.Name
		end)
	end
	
	function Node:GetIcon()
		-- Returns icon index from the class icon map
		if Main.MiscIcons then
			-- Use API class data for icon lookup
			return nil -- placeholder; icon map display handled in render
		end
		return nil
	end
	
	-- Tree management
	local function buildNode(instance, parentNode, depth)
		if nodeMap[instance] then return nodeMap[instance] end
		
		local node = Node.new(instance, parentNode, depth)
		nodeMap[instance] = node
		
		if parentNode then
			parentNode.Children[#parentNode.Children + 1] = node
		end
		
		return node
	end
	
	local function removeNode(instance)
		local node = nodeMap[instance]
		if not node then return end
		
		-- Remove from parent's children
		if node.Parent then
			local children = node.Parent.Children
			for i = #children, 1, -1 do
				if children[i] == node then
					table.remove(children, i)
					break
				end
			end
		end
		
		-- Remove all descendants from nodeMap
		local function removeRecursive(n)
			for _, child in ipairs(n.Children) do
				removeRecursive(child)
			end
			nodeMap[n.Instance] = nil
		end
		removeRecursive(node)
	end
	
	local function buildTree()
		tree = {}
		nodeMap = {}
		
		-- Root services
		local rootServices = {
			game:GetService("Workspace"),
			game:GetService("Players"),
			game:GetService("Lighting"),
			game:GetService("ReplicatedFirst"),
			game:GetService("ReplicatedStorage"),
			game:GetService("ServerScriptService"),
			game:GetService("ServerStorage"),
			game:GetService("StarterGui"),
			game:GetService("StarterPack"),
			game:GetService("StarterPlayer"),
			game:GetService("SoundService"),
			game:GetService("Chat"),
			game:GetService("LocalizationService"),
			game:GetService("TestService"),
		}
		
		local rootNode = Node.new(game, nil, 0)
		rootNode.Name = "game"
		rootNode.ClassName = "DataModel"
		rootNode.Expanded = true
		nodeMap[game] = rootNode
		
		for _, svc in ipairs(rootServices) do
			if svc then
				local svcNode = buildNode(svc, rootNode, 1)
				svcNode.Expanded = false
			end
		end
	end
	
	local function expandNode(node)
		if node.Expanded then return end
		node.Expanded = true
		expanded[node.Instance] = true
		
		-- Load children
		local s, children = pcall(function() return node.Instance:GetChildren() end)
		if not s then return end
		
		-- Clear existing children (in case of refresh)
		node.Children = {}
		
		for _, child in ipairs(children) do
			buildNode(child, node, node.Depth + 1)
		end
		
		-- Sort children
		table.sort(node.Children, function(a, b)
			if a.ClassName == b.ClassName then
				return a.Name < b.Name
			end
			return a.ClassName < b.ClassName
		end)
	end
	
	local function collapseNode(node)
		node.Expanded = false
		expanded[node.Instance] = nil
	end
	
	local function toggleNode(node)
		if node.Expanded then
			collapseNode(node)
		else
			expandNode(node)
		end
		Explorer.Render()
	end
	
	-- Flatten the tree into the visible row list. Virtualised renderer reads from this.
	local flatList = {}
	
	local function buildFlatList()
		flatList = {}
		
		local function recurse(node)
			if not node.Visible then return end
			flatList[#flatList + 1] = node
			
			if node.Expanded then
				for _, child in ipairs(node.Children) do
					recurse(child)
				end
			end
		end
		
		local rootNode = nodeMap[game]
		if rootNode then
			for _, child in ipairs(rootNode.Children) do
				recurse(child)
			end
		end
	end


	-- Selection
	local function clearSelection()
		for _, inst in ipairs(selection) do
			local node = nodeMap[inst]
			if node then node.Selected = false end
		end
		selection = {}
		Store.SetSelection({})
	end
	
	local function selectNode(node, additive, range)
		if not node then return end
		
		if not additive and not range then
			clearSelection()
		end
		
		if range and #selection > 0 then
			-- Range select: select all between last selected and this node
			local lastIdx, thisIdx
			for i, n in ipairs(flatList) do
				if n.Instance == selection[#selection] then lastIdx = i end
				if n == node then thisIdx = i end
			end
			if lastIdx and thisIdx then
				local startIdx = math.min(lastIdx, thisIdx)
				local endIdx = math.max(lastIdx, thisIdx)
				for i = startIdx, endIdx do
					local n = flatList[i]
					if n and not n.Selected then
						n.Selected = true
						selection[#selection + 1] = n.Instance
					end
				end
			end
		else
			if additive and node.Selected then
				-- Deselect
				node.Selected = false
				for i, inst in ipairs(selection) do
					if inst == node.Instance then
						table.remove(selection, i)
						break
					end
				end
			else
				node.Selected = true
				selection[#selection + 1] = node.Instance
			end
		end
		
		-- Push to store
		Store.SetSelection(selection)
		
		-- Record history
		selectionHistory[#selectionHistory + 1] = {unpack(selection)}
		
		Explorer.Render()
	end
	
	local function selectInstance(instance)
		local node = nodeMap[instance]
		if not node then
			-- Expand parents to reveal
			local ancestry = {}
			local current = instance
			pcall(function()
				while current and current ~= game do
					current = current.Parent
					if current then ancestry[#ancestry + 1] = current end
				end
			end)
			-- Expand from root down
			for i = #ancestry, 1, -1 do
				local ancestorNode = nodeMap[ancestry[i]]
				if ancestorNode then
					expandNode(ancestorNode)
				end
			end
			node = nodeMap[instance]
		end
		if node then
			clearSelection()
			selectNode(node)
			Explorer.ScrollToNode(node)
		end
	end
	
	-- Bookmarks
	local function addBookmark(instance)
		if table.find(bookmarks, instance) then return end
		bookmarks[#bookmarks + 1] = instance
		local node = nodeMap[instance]
		if node then node.Bookmarked = true end
		Explorer.SaveBookmarks()
		if Notifications then Notifications.Info("Bookmarked: " .. tostring(instance)) end
	end
	
	local function removeBookmark(instance)
		local idx = table.find(bookmarks, instance)
		if idx then
			table.remove(bookmarks, idx)
			local node = nodeMap[instance]
			if node then node.Bookmarked = false end
			Explorer.SaveBookmarks()
		end
	end
	
	local function toggleBookmark(instance)
		if table.find(bookmarks, instance) then
			removeBookmark(instance)
		else
			addBookmark(instance)
		end
	end
	
	Explorer.SaveBookmarks = function()
		if not Env or not Env.Capabilities.Filesystem then return end
		local paths = {}
		for _, inst in ipairs(bookmarks) do
			pcall(function() paths[#paths + 1] = inst:GetFullName() end)
		end
		local json = service.HttpService:JSONEncode(paths)
		pcall(Env.writefile, "deux/saved/bookmarks/" .. tostring(game.PlaceId) .. ".json", json)
	end
	
	Explorer.LoadBookmarks = function()
		if not Env or not Env.Capabilities.Filesystem then return end
		local s, raw = pcall(Env.readfile, "deux/saved/bookmarks/" .. tostring(game.PlaceId) .. ".json")
		if not s or not raw then return end
		local s2, paths = pcall(service.HttpService.JSONDecode, service.HttpService, raw)
		if not s2 or type(paths) ~= "table" then return end
		-- Resolve paths (best effort)
		for _, path in ipairs(paths) do
			local parts = string.split(path, ".")
			local current = game
			for i = 2, #parts do -- skip "game"
				local s3, child = pcall(function() return current:FindFirstChild(parts[i]) end)
				if s3 and child then
					current = child
				else
					current = nil
					break
				end
			end
			if current and current ~= game then
				bookmarks[#bookmarks + 1] = current
				local node = nodeMap[current]
				if node then node.Bookmarked = true end
			end
		end
	end
	
	-- Search engine
	local SearchFilters = {}
	
	SearchFilters.class = function(inst, value)
		local s, cn = pcall(function() return inst.ClassName end)
		if not s then return false end
		return string.lower(cn) == string.lower(value) or inst:IsA(value)
	end
	
	SearchFilters.name = function(inst, value)
		local s, name = pcall(function() return inst.Name end)
		if not s then return false end
		-- Support regex patterns
		local s2, match = pcall(string.find, string.lower(name), string.lower(value))
		return s2 and match ~= nil
	end
	
	SearchFilters.tag = function(inst, value)
		local s, tags = pcall(function() return game:GetService("CollectionService"):GetTags(inst) end)
		if not s then return false end
		for _, tag in ipairs(tags) do
			if string.lower(tag) == string.lower(value) then return true end
		end
		return false
	end
	
	SearchFilters.prop = function(inst, value)
		-- Format: PropertyName=Value or PropertyName~=Value
		local propName, propVal = string.match(value, "^(.-)=(.+)$")
		if not propName then return false end
		local s, actualVal = pcall(function() return inst[propName] end)
		if not s then return false end
		return tostring(actualVal) == propVal
	end
	
	SearchFilters["nil"] = function(inst, value)
		local s, parent = pcall(function() return inst.Parent end)
		return s and parent == nil
	end
	
	SearchFilters.service = function(inst, value)
		local s, fullName = pcall(function() return inst:GetFullName() end)
		if not s then return false end
		local parts = string.split(fullName, ".")
		return parts[2] and string.lower(parts[2]) == string.lower(value)
	end
	
	local function parseSearchQuery(query)
		local filters = {}
		-- Parse structured filters: key:value
		for key, value in string.gmatch(query, "(%w+):([^%s]+)") do
			filters[#filters + 1] = {Type = key, Value = value}
		end
		-- Remaining text is name filter
		local remaining = string.gsub(query, "%w+:[^%s]+", ""):match("^%s*(.-)%s*$")
		if remaining and remaining ~= "" then
			filters[#filters + 1] = {Type = "name", Value = remaining}
		end
		return filters
	end
	
	local function matchesSearch(instance, filters)
		for _, filter in ipairs(filters) do
			local handler = SearchFilters[filter.Type]
			if handler then
				if not handler(instance, filter.Value) then
					return false
				end
			end
		end
		return true
	end
	
	local function performSearch(query)
		searchQuery = query
		if not query or query == "" then
			searchActive = false
			searchResults = {}
			Explorer.Render()
			return
		end
		
		searchActive = true
		local filters = parseSearchQuery(query)
		searchResults = {}
		
		local maxResults = Settings.Get("Explorer.MaxSearchResults") or 500
		
		local function searchIn(parent)
			if #searchResults >= maxResults then return end
			local s, children = pcall(function() return parent:GetDescendants() end)
			if not s then return end
			for _, desc in ipairs(children) do
				if #searchResults >= maxResults then break end
				if matchesSearch(desc, filters) then
					searchResults[#searchResults + 1] = desc
				end
			end
		end
		
		searchIn(game)
		Explorer.Render()
	end


	-- Click-to-select for 3D parts (mouse hit) and GUI elements (screen-space hit-test).
	local clickToSelectEnabled = true
	local selectionBox = nil
	local guiSelectionOutline = nil
	
	local function setupClickToSelect()
		if not Settings.Get("Explorer.ClickToSelect3D") then return end
		
		local mouse = Main.Mouse
		local uis = service.UserInputService
		
		-- 3D Click-to-select
		connections[#connections + 1] = uis.InputBegan:Connect(function(input, processed)
			if processed then return end
			if not clickToSelectEnabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			
			-- Check if Ctrl+Click (click-to-select mode)
			if not uis:IsKeyDown(Enum.KeyCode.LeftAlt) then return end
			
			local target = mouse.Target
			if not target then return end
			
			local additive = uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl)
			
			-- Ensure target is in tree
			local node = nodeMap[target]
			if not node then
				-- Expand parents
				selectInstance(target)
			else
				selectNode(node, additive)
			end
			
			-- Show selection box
			if Settings.Get("Explorer.PartSelectionBox") and target:IsA("BasePart") then
				if selectionBox then selectionBox:Destroy() end
				selectionBox = Instance.new("SelectionBox")
				selectionBox.Adornee = target
				selectionBox.Color3 = Theme.Get("Accent") or Color3.fromRGB(0, 120, 215)
				selectionBox.LineThickness = 0.03
				selectionBox.SurfaceTransparency = 0.8
				selectionBox.Parent = Env.getGuiParent()
				
				-- Auto-remove after deselect
				Store.Subscribe("selection", function(newSel)
					if not table.find(newSel, target) then
						if selectionBox then selectionBox:Destroy(); selectionBox = nil end
					end
				end)
			end
		end)
		
		-- GUI click-to-select: Alt+LMB on a GUI object selects it.
		connections[#connections + 1] = uis.InputBegan:Connect(function(input, processed)
			if processed then return end
			if not clickToSelectEnabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			if not uis:IsKeyDown(Enum.KeyCode.LeftAlt) then return end
			if not Settings.Get("Explorer.ClickToSelectGUI") then return end
			
			-- Find GUI objects at mouse position
			local mousePos = uis:GetMouseLocation()
			local guis = plr.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
			
			if #guis > 0 then
				local topGui = guis[1]
				local additive = uis:IsKeyDown(Enum.KeyCode.LeftControl)
				selectInstance(topGui)
			end
		end)
	end
	
	-- Nil instances
	local function refreshNilInstances()
		if not Env or not Env.getnilinstances then
			nilInstances = {}
			return
		end
		local s, insts = pcall(Env.getnilinstances)
		if s and type(insts) == "table" then
			nilInstances = insts
		end
	end
	
	-- Deferred-event-safe listeners
	local function setupDescendantListeners()
		-- Use BatchProcessor for deferred-safe updates
		descendantAddedBatch = Lib.BatchProcessor.new(function(batch)
			for _, instance in ipairs(batch) do
				local parentNode = nodeMap[instance.Parent]
				if parentNode and parentNode.Expanded then
					buildNode(instance, parentNode, parentNode.Depth + 1)
				end
			end
			if #batch > 0 then
				Explorer.Render()
			end
		end)
		
		descendantRemovedBatch = Lib.BatchProcessor.new(function(batch)
			for _, instance in ipairs(batch) do
				removeNode(instance)
				-- Remove from selection if selected
				for i = #selection, 1, -1 do
					if selection[i] == instance then
						table.remove(selection, i)
					end
				end
			end
			if #batch > 0 then
				Store.SetSelection(selection)
				Explorer.Render()
			end
		end)
		
		connections[#connections + 1] = game.DescendantAdded:Connect(function(instance)
			descendantAddedBatch:Add(instance)
		end)
		
		connections[#connections + 1] = game.DescendantRemoving:Connect(function(instance)
			descendantRemovedBatch:Add(instance)
		end)
	end
	
	-- Context menu
	local function createContextMenu(node)
		if not Lib.ContextMenu then return end
		
		local inst = node.Instance
		local menu = Lib.ContextMenu.new()
		
		-- Copy path
		menu:Add({Name = "Copy Path", OnClick = function()
			local s, path = pcall(function() return inst:GetFullName() end)
			if s and Env.setclipboard then
				Env.setclipboard('game.' .. path)
				if Notifications then Notifications.Info("Path copied") end
			end
		end})
		
		-- Copy as Lua reference
		menu:Add({Name = "Copy as Lua", OnClick = function()
			local s, path = pcall(function() return inst:GetFullName() end)
			if s and Env.setclipboard then
				local parts = string.split(path, ".")
				local lua = 'game:GetService("' .. parts[2] .. '")'
				for i = 3, #parts do
					lua = lua .. ':FindFirstChild("' .. parts[i] .. '")'
				end
				Env.setclipboard(lua)
				if Notifications then Notifications.Info("Lua path copied") end
			end
		end})
		
		menu:AddSeparator()
		
		-- Teleport to (for BaseParts)
		local s1, isPart = pcall(function() return inst:IsA("BasePart") end)
		if s1 and isPart then
			menu:Add({Name = "Teleport To", OnClick = function()
				pcall(function()
					local char = plr.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						char.HumanoidRootPart.CFrame = inst.CFrame + Vector3.new(0, 5, 0)
					end
				end)
			end})
		end
		
		-- View Script
		local s2, isScript = pcall(function() return inst:IsA("LuaSourceContainer") end)
		if s2 and isScript then
			menu:Add({Name = "View Script", OnClick = function()
				Store.Emit("open_script", inst)
			end})
		end
		
		menu:AddSeparator()
		
		-- Bookmark
		local isBookmarked = table.find(bookmarks, inst) ~= nil
		menu:Add({Name = isBookmarked and "Remove Bookmark" or "Add Bookmark", OnClick = function()
			toggleBookmark(inst)
		end})
		
		-- Select Children
		menu:Add({Name = "Select Children", OnClick = function()
			local s3, children = pcall(function() return inst:GetChildren() end)
			if s3 then
				for _, child in ipairs(children) do
					local childNode = nodeMap[child]
					if childNode then selectNode(childNode, true) end
				end
			end
		end})
		
		menu:AddSeparator()
		
		-- Delete
		menu:Add({Name = "Delete", OnClick = function()
			pcall(function() inst:Destroy() end)
		end})
		
		-- Clone
		menu:Add({Name = "Clone", OnClick = function()
			pcall(function()
				local clone = inst:Clone()
				if clone then clone.Parent = inst.Parent end
			end)
		end})
		
		-- Rename (inline)
		menu:Add({Name = "Rename", OnClick = function()
			Explorer.StartRename(node)
		end})
		
		menu:AddSeparator()
		
		-- Save Instance
		menu:Add({Name = "Save Instance", OnClick = function()
			Store.Emit("save_instance", inst)
		end})
		
		-- Explore Data
		menu:Add({Name = "Explore Data", OnClick = function()
			Store.Emit("explore_data", inst)
		end})
		
		return menu
	end
	
	-- Virtualised rendering: keep a fixed pool of row frames, recycle into the visible window.
	local scrollFrame
	local rowPool = {}
	local visibleRows = {}
	local scrollOffset = 0
	
	Explorer.Render = function()
		if not scrollFrame then return end
		
		buildFlatList()
		
		local displayList = searchActive and searchResults or flatList
		local totalRows = #displayList
		
		-- Update canvas size
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalRows * ROW_HEIGHT)
		
		-- Calculate visible range
		local viewHeight = scrollFrame.AbsoluteSize.Y
		local startIdx = math.floor(scrollFrame.CanvasPosition.Y / ROW_HEIGHT) + 1
		local endIdx = math.min(startIdx + math.ceil(viewHeight / ROW_HEIGHT) + 1, totalRows)
		
		-- Hide all existing visible rows
		for _, row in ipairs(visibleRows) do
			row.Visible = false
		end
		visibleRows = {}
		
		-- Render visible rows
		for i = startIdx, endIdx do
			local item = displayList[i]
			if not item then continue end
			
			local row = Explorer.GetOrCreateRow(i - startIdx + 1)
			local instance = searchActive and item or item.Instance
			local node = searchActive and nodeMap[item] or item
			local depth = node and node.Depth or 0
			local isSelected = node and node.Selected or false
			local isBookmarked = node and node.Bookmarked or false
			
			-- Position
			row.Position = UDim2.new(0, 0, 0, (i - 1) * ROW_HEIGHT)
			row.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
			row.Visible = true
			
			-- Indent
			local indent = depth * INDENT_WIDTH
			row.NameLabel.Position = UDim2.new(0, indent + ICON_SIZE + 4, 0, 0)
			
			-- Name & class
			local name, className = "", ""
			pcall(function()
				name = instance.Name
				className = instance.ClassName
			end)
			row.NameLabel.Text = name
			row.ClassLabel.Text = className
			row.ClassLabel.Position = UDim2.new(0, indent + ICON_SIZE + 4 + row.NameLabel.TextBounds.X + 6, 0, 0)
			
			-- Selection highlight
			local bgColor = isSelected and (Theme.Get("ListSelection") or Color3.fromRGB(11, 90, 175)) or Color3.fromRGB(0, 0, 0)
			row.BackgroundColor3 = bgColor
			row.BackgroundTransparency = isSelected and 0 or 1
			
			-- Bookmark indicator
			if row.BookmarkDot then
				row.BookmarkDot.Visible = isBookmarked
			end
			
			-- Expand arrow
			local hasChildren = false
			if node then
				pcall(function() hasChildren = #instance:GetChildren() > 0 end)
			end
			if row.Arrow then
				row.Arrow.Visible = hasChildren
				row.Arrow.Rotation = (node and node.Expanded) and 90 or 0
				row.Arrow.Position = UDim2.new(0, indent, 0, 2)
			end
			
			-- Store reference
			row._Node = node
			row._Instance = instance
			
			visibleRows[#visibleRows + 1] = row
		end
	end
	
	Explorer.GetOrCreateRow = function(poolIdx)
		if rowPool[poolIdx] then return rowPool[poolIdx] end
		
		local row = createSimple("TextButton", {
			Name = "Row" .. poolIdx,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
			Text = "",
			AutoButtonColor = false,
			Parent = scrollFrame,
		})
		
		local arrow = createSimple("TextLabel", {
			Name = "Arrow",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 0, 0, 2),
			Text = "▶",
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextSize = 8,
			Font = Enum.Font.Gotham,
			Parent = row,
		})
		
		local nameLabel = createSimple("TextLabel", {
			Name = "NameLabel",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -60, 1, 0),
			Position = UDim2.new(0, 20, 0, 0),
			Text = "",
			TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255),
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		
		local classLabel = createSimple("TextLabel", {
			Name = "ClassLabel",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 100, 1, 0),
			Position = UDim2.new(0, 120, 0, 0),
			Text = "",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(120, 120, 120),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		
		local bookmarkDot = createSimple("Frame", {
			Name = "BookmarkDot",
			BackgroundColor3 = Color3.fromRGB(255, 200, 50),
			Size = UDim2.new(0, 4, 0, 4),
			Position = UDim2.new(1, -8, 0.5, -2),
			Visible = false,
			Parent = row,
		})
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = bookmarkDot
		
		row.Arrow = arrow
		row.NameLabel = nameLabel
		row.ClassLabel = classLabel
		row.BookmarkDot = bookmarkDot
		
		-- Click handler
		row.MouseButton1Click:Connect(function()
			local node = row._Node
			if not node then return end
			local uis = service.UserInputService
			local shift = uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift)
			local ctrl = uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl)
			selectNode(node, ctrl, shift)
		end)
		
		-- Double click to expand
		row.MouseButton1Down:Connect(function()
			-- Handled via ClickSystem if available
		end)
		
		-- Right click
		row.MouseButton2Click:Connect(function()
			local node = row._Node
			if not node then return end
			if not node.Selected then selectNode(node) end
			local menu = createContextMenu(node)
			if menu then menu:Show() end
		end)
		
		-- Arrow click to toggle expand
		arrow.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local node = row._Node
				if node then toggleNode(node) end
			end
		end)
		
		rowPool[poolIdx] = row
		return row
	end
	
	Explorer.ScrollToNode = function(node)
		if not scrollFrame then return end
		buildFlatList()
		for i, n in ipairs(flatList) do
			if n == node then
				local targetY = (i - 1) * ROW_HEIGHT
				scrollFrame.CanvasPosition = Vector2.new(0, math.max(0, targetY - scrollFrame.AbsoluteSize.Y / 2))
				break
			end
		end
	end
	
	Explorer.StartRename = function(node)
		-- Inline rename (simplified - shows input box over the name)
		if not node or not node.GuiRow then return end
		-- TODO: Full inline rename UX
		if Notifications then Notifications.Info("Rename not yet implemented in-line") end
	end


	-- Window & ui setup
	Explorer.Init = function()
		-- Create window
		Explorer.Window = Lib.Window.new()
		Explorer.Window:SetTitle("Explorer")
		Explorer.Window:SetResizable(true)
		Explorer.Window:SetSize(300, 500)
		
		local content = Explorer.Window:GetContentFrame()
		
		-- Search bar
		local searchBar = createSimple("Frame", {
			Name = "SearchBar",
			BackgroundColor3 = Theme.Get("TextBox") or Color3.fromRGB(38, 38, 38),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 26),
			Parent = content,
		})
		local searchCorner = Instance.new("UICorner")
		searchCorner.CornerRadius = UDim.new(0, 4)
		searchCorner.Parent = searchBar
		
		local searchInput = createSimple("TextBox", {
			Name = "Input",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			Text = "",
			PlaceholderText = "Search... (class:Part name:Door tag:NPC)",
			PlaceholderColor3 = Theme.Get("PlaceholderText") or Color3.fromRGB(100, 100, 100),
			TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = searchBar,
		})
		
		-- Search on text change
		local searchDebounce
		searchInput:GetPropertyChangedSignal("Text"):Connect(function()
			if searchDebounce then task.cancel(searchDebounce) end
			searchDebounce = task.delay(0.3, function()
				performSearch(searchInput.Text)
			end)
		end)
		
		-- Toolbar
		local toolbar = createSimple("Frame", {
			Name = "Toolbar",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 0, 28),
			Parent = content,
		})
		
		local bookmarkBtn = createSimple("TextButton", {
			Name = "Bookmarks",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 60, 1, 0),
			Text = "★ Pins",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			Parent = toolbar,
		})
		
		local nilBtn = createSimple("TextButton", {
			Name = "NilInstances",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 80, 1, 0),
			Position = UDim2.new(0, 62, 0, 0),
			Text = "∅ Nil Insts",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			Parent = toolbar,
		})
		
		local refreshBtn = createSimple("TextButton", {
			Name = "Refresh",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 50, 1, 0),
			Position = UDim2.new(1, -50, 0, 0),
			Text = "⟳",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180),
			TextSize = 14,
			Font = Enum.Font.Gotham,
			Parent = toolbar,
		})
		
		-- Scroll frame for tree
		scrollFrame = createSimple("ScrollingFrame", {
			Name = "TreeScroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, -52),
			Position = UDim2.new(0, 0, 0, 52),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Get("ScrollBar") or Color3.fromRGB(80, 80, 80),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			Parent = content,
		})
		
		-- Scroll handler for virtualization
		scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			Explorer.Render()
		end)
		scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Explorer.Render()
		end)
		
		-- Button handlers
		bookmarkBtn.MouseButton1Click:Connect(function()
			-- Show bookmarks in search results
			searchActive = true
			searchResults = bookmarks
			Explorer.Render()
		end)
		
		nilBtn.MouseButton1Click:Connect(function()
			refreshNilInstances()
			searchActive = true
			searchResults = nilInstances
			Explorer.Render()
		end)
		
		refreshBtn.MouseButton1Click:Connect(function()
			buildTree()
			Explorer.Render()
			if Notifications then Notifications.Info("Explorer refreshed") end
		end)
		
		-- Build initial tree
		buildTree()
		
		-- Expand workspace and players by default
		local wsNode = nodeMap[game:GetService("Workspace")]
		if wsNode then expandNode(wsNode) end
		local plrNode = nodeMap[game:GetService("Players")]
		if plrNode then expandNode(plrNode) end
		
		-- Setup listeners
		setupDescendantListeners()
		setupClickToSelect()
		Explorer.LoadBookmarks()
		
		-- Register keybinds
		Keybinds.Register("Explorer.Delete", {
			Keys = {Enum.KeyCode.Delete},
			Category = "Explorer",
			Description = "Delete selected instances",
			Callback = function()
				for _, inst in ipairs(selection) do
					pcall(function() inst:Destroy() end)
				end
				clearSelection()
			end
		})
		
		Keybinds.Register("Explorer.CopyPath", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.C},
			Category = "Explorer",
			Description = "Copy path of selected instance",
			Callback = function()
				if #selection > 0 and Env.setclipboard then
					local s, path = pcall(function() return selection[1]:GetFullName() end)
					if s then Env.setclipboard("game." .. path) end
				end
			end
		})
		
		Keybinds.Register("Explorer.Bookmark", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.B},
			Category = "Explorer",
			Description = "Toggle bookmark on selected",
			Callback = function()
				for _, inst in ipairs(selection) do
					toggleBookmark(inst)
				end
			end
		})
		
		-- Listen for navigate events from other modules
		Store.On("navigate", function(instance)
			if instance then selectInstance(instance) end
		end)
		
		-- Initial render
		Explorer.Render()
	end
	
	Explorer.GetSelection = function() return selection end
	Explorer.SetSelection = function(insts) 
		clearSelection()
		for _, inst in ipairs(insts) do
			local node = nodeMap[inst]
			if node then selectNode(node, true) end
		end
	end
	Explorer.SelectInstance = selectInstance
	Explorer.PerformSearch = performSearch
	Explorer.GetBookmarks = function() return bookmarks end
	Explorer.AddBookmark = addBookmark
	Explorer.RemoveBookmark = removeBookmark
	Explorer.GetNilInstances = function() return nilInstances end
	Explorer.RefreshNilInstances = refreshNilInstances
	Explorer.RegisterSearchFilter = function(name, handler)
		SearchFilters[name] = handler
	end
	
	-- Cleanup
	Explorer.Destroy = function()
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		connections = {}
		if selectionBox then selectionBox:Destroy() end
	end
	
	return Explorer
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
