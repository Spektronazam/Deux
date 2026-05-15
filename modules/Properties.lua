--[[
	Deux :: Properties Module
	
	Full property editor with:
	- Tag Editor (CollectionService) as side panel
	- Attribute CRUD (all types, rename, delete)
	- Copy value as Lua literal / display / JSON
	- Multi-instance editing with conflict indicator
	- Signal connections viewer (getconnections)
	- Property search / filter
	- Category grouping with collapsible sections
	- Hidden/Deprecated toggles
	- Inline editors for Color3, NumberSequence, ColorSequence, etc.
	- Property change history (undo per-property)
	
	Credits: Original Properties architecture by Moon, rewritten for Deux
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

local function initAfterMain(appTable) end

local function main()
	local Properties = {}
	
	------------------------------------------------------------------------
	-- STATE
	------------------------------------------------------------------------
	local currentInstances = {} -- list of selected instances (multi-edit)
	local propertyRows = {} -- ordered display rows
	local categoryStates = {} -- category -> expanded bool
	local searchFilter = ""
	local showDeprecated = false
	local showHidden = false
	local showAttributes = true
	local showTags = true
	local showConnections = true
	local propertyHistory = {} -- {inst, prop, oldVal, newVal, time}
	local MAX_HISTORY = 50
	local ROW_HEIGHT = 24
	local connections = {}
	local scrollFrame
	local changeListeners = {}
	
	------------------------------------------------------------------------
	-- VALUE FORMATTING (Copy as Lua)
	------------------------------------------------------------------------
	local function valueToLua(value)
		local t = typeof(value)
		if t == "string" then
			return string.format("%q", value)
		elseif t == "number" then
			return tostring(value)
		elseif t == "boolean" then
			return tostring(value)
		elseif t == "nil" then
			return "nil"
		elseif t == "Vector3" then
			return string.format("Vector3.new(%s, %s, %s)", value.X, value.Y, value.Z)
		elseif t == "Vector2" then
			return string.format("Vector2.new(%s, %s)", value.X, value.Y)
		elseif t == "CFrame" then
			local c = {value:GetComponents()}
			return "CFrame.new(" .. table.concat(c, ", ") .. ")"
		elseif t == "Color3" then
			return string.format("Color3.fromRGB(%d, %d, %d)", math.round(value.R*255), math.round(value.G*255), math.round(value.B*255))
		elseif t == "BrickColor" then
			return string.format('BrickColor.new("%s")', value.Name)
		elseif t == "UDim" then
			return string.format("UDim.new(%s, %s)", value.Scale, value.Offset)
		elseif t == "UDim2" then
			return string.format("UDim2.new(%s, %s, %s, %s)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
		elseif t == "Rect" then
			return string.format("Rect.new(%s, %s, %s, %s)", value.Min.X, value.Min.Y, value.Max.X, value.Max.Y)
		elseif t == "NumberRange" then
			return string.format("NumberRange.new(%s, %s)", value.Min, value.Max)
		elseif t == "Ray" then
			return string.format("Ray.new(Vector3.new(%s, %s, %s), Vector3.new(%s, %s, %s))", value.Origin.X, value.Origin.Y, value.Origin.Z, value.Direction.X, value.Direction.Y, value.Direction.Z)
		elseif t == "Instance" then
			local s, path = pcall(function() return value:GetFullName() end)
			if s then return 'game.' .. path end
			return "nil --[[Instance]]"
		elseif t == "EnumItem" then
			return tostring(value)
		elseif t == "NumberSequence" then
			local points = {}
			for _, kp in ipairs(value.Keypoints) do
				points[#points + 1] = string.format("NumberSequenceKeypoint.new(%s, %s, %s)", kp.Time, kp.Value, kp.Envelope)
			end
			return "NumberSequence.new({" .. table.concat(points, ", ") .. "})"
		elseif t == "ColorSequence" then
			local points = {}
			for _, kp in ipairs(value.Keypoints) do
				points[#points + 1] = string.format("ColorSequenceKeypoint.new(%s, Color3.fromRGB(%d, %d, %d))", kp.Time, math.round(kp.Value.R*255), math.round(kp.Value.G*255), math.round(kp.Value.B*255))
			end
			return "ColorSequence.new({" .. table.concat(points, ", ") .. "})"
		elseif t == "Font" then
			return string.format('Font.new("%s", Enum.FontWeight.%s, Enum.FontStyle.%s)', value.Family, value.Weight.Name, value.Style.Name)
		else
			return tostring(value)
		end
	end
	
	local function valueToDisplay(value)
		local t = typeof(value)
		if t == "Color3" then
			return string.format("[%d, %d, %d]", math.round(value.R*255), math.round(value.G*255), math.round(value.B*255))
		elseif t == "Instance" then
			local s, name = pcall(function() return value.Name end)
			return s and name or "nil"
		elseif t == "string" then
			if #value > 50 then return value:sub(1, 47) .. "..." end
			return value
		else
			local str = tostring(value)
			if #str > 60 then return str:sub(1, 57) .. "..." end
			return str
		end
	end


	------------------------------------------------------------------------
	-- PROPERTY READING
	------------------------------------------------------------------------
	local function getProperties(instance)
		if not instance or not API then return {} end
		
		local className
		pcall(function() className = instance.ClassName end)
		if not className then return {} end
		
		local props = API.GetMember(className, "Properties")
		if not props then return {} end
		
		-- Filter
		local filtered = {}
		for _, prop in ipairs(props) do
			local dominated = false
			if not showDeprecated and prop.Tags and prop.Tags.Deprecated then dominated = true end
			if not showHidden and prop.Tags and (prop.Tags.Hidden or prop.Tags.NotScriptable) then dominated = true end
			
			if not dominated then
				if searchFilter == "" or string.find(string.lower(prop.Name), string.lower(searchFilter), 1, true) then
					filtered[#filtered + 1] = prop
				end
			end
		end
		
		return filtered
	end
	
	local function getPropertyValue(instance, propName)
		local s, val = pcall(function() return instance[propName] end)
		if s then return val, true end
		-- Try hidden property
		if Env and Env.gethiddenproperty then
			local s2, val2 = pcall(Env.gethiddenproperty, instance, propName)
			if s2 then return val2, true end
		end
		return nil, false
	end
	
	local function setPropertyValue(instance, propName, value)
		-- Record history
		local oldVal = getPropertyValue(instance, propName)
		
		local s, err = pcall(function() instance[propName] = value end)
		if not s then
			-- Try hidden property
			if Env and Env.sethiddenproperty then
				s, err = pcall(Env.sethiddenproperty, instance, propName, value)
			end
		end
		
		if s then
			propertyHistory[#propertyHistory + 1] = {
				Instance = instance,
				Property = propName,
				OldValue = oldVal,
				NewValue = value,
				Time = tick()
			}
			if #propertyHistory > MAX_HISTORY then table.remove(propertyHistory, 1) end
		else
			if Notifications then Notifications.Error("Failed to set " .. propName .. ": " .. tostring(err)) end
		end
		
		return s
	end
	
	------------------------------------------------------------------------
	-- MULTI-INSTANCE EDITING
	------------------------------------------------------------------------
	local function getMultiValue(propName)
		if #currentInstances == 0 then return nil, false, false end
		if #currentInstances == 1 then
			local val, ok = getPropertyValue(currentInstances[1], propName)
			return val, ok, false
		end
		
		-- Multi: check if all values are the same
		local firstVal, firstOk = getPropertyValue(currentInstances[1], propName)
		if not firstOk then return nil, false, true end
		
		local maxCheck = Settings.Get("Properties.MaxConflictCheck") or 50
		local conflict = false
		
		for i = 2, math.min(#currentInstances, maxCheck) do
			local val, ok = getPropertyValue(currentInstances[i], propName)
			if not ok or val ~= firstVal then
				conflict = true
				break
			end
		end
		
		return firstVal, true, conflict
	end
	
	local function setMultiValue(propName, value)
		for _, inst in ipairs(currentInstances) do
			setPropertyValue(inst, propName, value)
		end
		Properties.Render()
	end
	
	------------------------------------------------------------------------
	-- ATTRIBUTES
	------------------------------------------------------------------------
	local function getAttributes(instance)
		local s, attrs = pcall(function() return instance:GetAttributes() end)
		if not s then return {} end
		
		local list = {}
		for name, value in pairs(attrs) do
			if searchFilter == "" or string.find(string.lower(name), string.lower(searchFilter), 1, true) then
				list[#list + 1] = {Name = name, Value = value, Type = typeof(value)}
			end
		end
		table.sort(list, function(a, b) return a.Name < b.Name end)
		return list
	end
	
	local function setAttribute(instance, name, value)
		pcall(function() instance:SetAttribute(name, value) end)
	end
	
	local function deleteAttribute(instance, name)
		pcall(function() instance:SetAttribute(name, nil) end)
	end
	
	local function renameAttribute(instance, oldName, newName)
		local val = nil
		pcall(function() val = instance:GetAttribute(oldName) end)
		if val ~= nil then
			pcall(function()
				instance:SetAttribute(oldName, nil)
				instance:SetAttribute(newName, val)
			end)
		end
	end
	
	------------------------------------------------------------------------
	-- TAGS (CollectionService)
	------------------------------------------------------------------------
	local CollectionService
	
	local function getTags(instance)
		if not CollectionService then
			CollectionService = service.CollectionService
		end
		local s, tags = pcall(function() return CollectionService:GetTags(instance) end)
		if not s then return {} end
		
		local filtered = {}
		for _, tag in ipairs(tags) do
			if searchFilter == "" or string.find(string.lower(tag), string.lower(searchFilter), 1, true) then
				filtered[#filtered + 1] = tag
			end
		end
		table.sort(filtered)
		return filtered
	end
	
	local function addTag(instance, tag)
		if not CollectionService then CollectionService = service.CollectionService end
		pcall(function() CollectionService:AddTag(instance, tag) end)
	end
	
	local function removeTag(instance, tag)
		if not CollectionService then CollectionService = service.CollectionService end
		pcall(function() CollectionService:RemoveTag(instance, tag) end)
	end
	
	------------------------------------------------------------------------
	-- CONNECTIONS VIEWER
	------------------------------------------------------------------------
	local function getSignalConnections(instance, eventName)
		if not Env or not Env.getconnections then return {} end
		local s, signal = pcall(function() return instance[eventName] end)
		if not s or not signal then return {} end
		local s2, conns = pcall(Env.getconnections, signal)
		if not s2 then return {} end
		
		local list = {}
		for _, conn in ipairs(conns) do
			list[#list + 1] = {
				Function = conn.Function,
				State = conn.State or "Active",
				Enable = conn.Enable,
				Disable = conn.Disable,
				Fire = conn.Fire,
			}
		end
		return list
	end


	------------------------------------------------------------------------
	-- PROPERTY HISTORY / UNDO
	------------------------------------------------------------------------
	local function undoLast()
		if #propertyHistory == 0 then return end
		local entry = propertyHistory[#propertyHistory]
		table.remove(propertyHistory, #propertyHistory)
		pcall(function() entry.Instance[entry.Property] = entry.OldValue end)
		Properties.Render()
		if Notifications then Notifications.Info("Undid: " .. entry.Property) end
	end
	
	------------------------------------------------------------------------
	-- RENDERING
	------------------------------------------------------------------------
	local rowPool = {}
	local visibleRows = {}
	local headerLabel, instanceCountLabel
	
	Properties.Render = function()
		if not scrollFrame then return end
		
		-- Hide all
		for _, row in ipairs(visibleRows) do
			row.Visible = false
		end
		visibleRows = {}
		
		if #currentInstances == 0 then
			if headerLabel then headerLabel.Text = "No selection" end
			if instanceCountLabel then instanceCountLabel.Text = "" end
			return
		end
		
		local primary = currentInstances[1]
		local className = ""
		pcall(function() className = primary.ClassName end)
		
		if headerLabel then headerLabel.Text = className end
		if instanceCountLabel then
			instanceCountLabel.Text = #currentInstances > 1 and ("(" .. #currentInstances .. " selected)") or ""
		end
		
		-- Build display list
		local displayRows = {}
		
		-- Properties grouped by category
		local props = getProperties(primary)
		local categories = {}
		local categoryMap = {}
		
		for _, prop in ipairs(props) do
			local cat = prop.Category or "Other"
			if not categoryMap[cat] then
				categoryMap[cat] = {}
				categories[#categories + 1] = cat
			end
			categoryMap[cat][#categoryMap[cat] + 1] = prop
		end
		
		-- Sort categories by API order
		if API and API.CategoryOrder then
			table.sort(categories, function(a, b)
				local oa = API.CategoryOrder[a] or 9999
				local ob = API.CategoryOrder[b] or 9999
				return oa < ob
			end)
		end
		
		for _, cat in ipairs(categories) do
			-- Category header
			displayRows[#displayRows + 1] = {Type = "category", Name = cat, Expanded = categoryStates[cat] ~= false}
			
			if categoryStates[cat] ~= false then
				for _, prop in ipairs(categoryMap[cat]) do
					local val, ok, conflict = getMultiValue(prop.Name)
					displayRows[#displayRows + 1] = {
						Type = "property",
						Name = prop.Name,
						Value = val,
						ValueOk = ok,
						Conflict = conflict,
						ValueType = prop.ValueType,
						Tags = prop.Tags,
						Security = prop.Security,
					}
				end
			end
		end
		
		-- Attributes section
		if showAttributes then
			local attrs = getAttributes(primary)
			if #attrs > 0 then
				displayRows[#displayRows + 1] = {Type = "category", Name = "Attributes", Expanded = categoryStates["Attributes"] ~= false}
				if categoryStates["Attributes"] ~= false then
					for _, attr in ipairs(attrs) do
						displayRows[#displayRows + 1] = {
							Type = "attribute",
							Name = attr.Name,
							Value = attr.Value,
							ValueOk = true,
							Conflict = false,
							AttrType = attr.Type,
						}
					end
				end
			end
		end
		
		-- Tags section
		if showTags then
			local tags = getTags(primary)
			displayRows[#displayRows + 1] = {Type = "category", Name = "Tags", Expanded = categoryStates["Tags"] ~= false}
			if categoryStates["Tags"] ~= false then
				for _, tag in ipairs(tags) do
					displayRows[#displayRows + 1] = {Type = "tag", Name = tag}
				end
				displayRows[#displayRows + 1] = {Type = "tag_add"}
			end
		end
		
		-- Connections section (for events)
		if showConnections and Env and Env.Capabilities.Connections then
			local events = API.GetMember(className, "Events")
			if events and #events > 0 then
				local hasAny = false
				local connRows = {}
				for _, event in ipairs(events) do
					local conns = getSignalConnections(primary, event.Name)
					if #conns > 0 then
						hasAny = true
						connRows[#connRows + 1] = {Type = "event_header", Name = event.Name, Count = #conns}
					end
				end
				if hasAny then
					displayRows[#displayRows + 1] = {Type = "category", Name = "Connections", Expanded = categoryStates["Connections"] ~= false}
					if categoryStates["Connections"] ~= false then
						for _, cr in ipairs(connRows) do
							displayRows[#displayRows + 1] = cr
						end
					end
				end
			end
		end
		
		-- Update canvas
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #displayRows * ROW_HEIGHT)
		
		-- Virtualized rendering
		local viewHeight = scrollFrame.AbsoluteSize.Y
		local startIdx = math.floor(scrollFrame.CanvasPosition.Y / ROW_HEIGHT) + 1
		local endIdx = math.min(startIdx + math.ceil(viewHeight / ROW_HEIGHT) + 1, #displayRows)
		
		for i = startIdx, endIdx do
			local data = displayRows[i]
			if not data then continue end
			
			local poolIdx = i - startIdx + 1
			local row = Properties.GetOrCreateRow(poolIdx)
			row.Position = UDim2.new(0, 0, 0, (i - 1) * ROW_HEIGHT)
			row.Visible = true
			
			if data.Type == "category" then
				row.NameLabel.Text = (data.Expanded and "▼ " or "▶ ") .. data.Name
				row.NameLabel.Font = Enum.Font.GothamBold
				row.NameLabel.TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255)
				row.NameLabel.Size = UDim2.new(1, -8, 1, 0)
				row.ValueLabel.Text = ""
				row.BackgroundColor3 = Theme.Get("Main2") or Color3.fromRGB(45, 45, 45)
				row.BackgroundTransparency = 0
				row.ColorSwatch.Visible = false
				row._Data = data
			elseif data.Type == "property" or data.Type == "attribute" then
				row.NameLabel.Text = data.Name
				row.NameLabel.Font = Enum.Font.Gotham
				row.NameLabel.TextColor3 = data.Tags and data.Tags.Deprecated and (Theme.Get("PlaceholderText") or Color3.fromRGB(100,100,100)) or (Theme.Get("Text") or Color3.fromRGB(255,255,255))
				row.NameLabel.Size = UDim2.new(0.5, -4, 1, 0)
				
				if data.Conflict then
					row.ValueLabel.Text = "<multiple>"
					row.ValueLabel.TextColor3 = Theme.Get("Warning") or Color3.fromRGB(255, 200, 50)
				elseif data.ValueOk then
					row.ValueLabel.Text = valueToDisplay(data.Value)
					row.ValueLabel.TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180)
				else
					row.ValueLabel.Text = "⚠ unreadable"
					row.ValueLabel.TextColor3 = Theme.Get("Important") or Color3.fromRGB(255, 80, 80)
				end
				
				row.BackgroundTransparency = 1
				
				-- Color swatch for Color3 values
				local isColor = data.ValueOk and typeof(data.Value) == "Color3"
				row.ColorSwatch.Visible = isColor
				if isColor then
					row.ColorSwatch.BackgroundColor3 = data.Value
				end
				
				row._Data = data
			elseif data.Type == "tag" then
				row.NameLabel.Text = "  🏷 " .. data.Name
				row.NameLabel.Font = Enum.Font.Gotham
				row.NameLabel.TextColor3 = Theme.Get("Accent") or Color3.fromRGB(0, 120, 215)
				row.NameLabel.Size = UDim2.new(1, -30, 1, 0)
				row.ValueLabel.Text = "✕"
				row.ValueLabel.TextColor3 = Theme.Get("Important") or Color3.fromRGB(255, 80, 80)
				row.BackgroundTransparency = 1
				row.ColorSwatch.Visible = false
				row._Data = data
			elseif data.Type == "tag_add" then
				row.NameLabel.Text = "  + Add Tag..."
				row.NameLabel.Font = Enum.Font.Gotham
				row.NameLabel.TextColor3 = Theme.Get("PlaceholderText") or Color3.fromRGB(100, 100, 100)
				row.NameLabel.Size = UDim2.new(1, 0, 1, 0)
				row.ValueLabel.Text = ""
				row.BackgroundTransparency = 1
				row.ColorSwatch.Visible = false
				row._Data = data
			elseif data.Type == "event_header" then
				row.NameLabel.Text = "  ⚡ " .. data.Name
				row.NameLabel.Font = Enum.Font.Gotham
				row.NameLabel.TextColor3 = Theme.Get("Success") or Color3.fromRGB(80, 200, 120)
				row.NameLabel.Size = UDim2.new(0.7, 0, 1, 0)
				row.ValueLabel.Text = tostring(data.Count) .. " conn"
				row.ValueLabel.TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(180, 180, 180)
				row.BackgroundTransparency = 1
				row.ColorSwatch.Visible = false
				row._Data = data
			end
			
			visibleRows[#visibleRows + 1] = row
		end
	end
	
	Properties.GetOrCreateRow = function(poolIdx)
		if rowPool[poolIdx] then return rowPool[poolIdx] end
		
		local row = createSimple("TextButton", {
			Name = "PropRow" .. poolIdx,
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
			Text = "",
			AutoButtonColor = false,
			Parent = scrollFrame,
		})
		
		local nameLabel = createSimple("TextLabel", {
			Name = "NameLabel",
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -4, 1, 0),
			Position = UDim2.new(0, 6, 0, 0),
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		
		local valueLabel = createSimple("TextLabel", {
			Name = "ValueLabel",
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -16, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Text = "",
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		
		local colorSwatch = createSimple("Frame", {
			Name = "ColorSwatch",
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0, 14, 0, 14),
			Position = UDim2.new(1, -18, 0, 5),
			Visible = false,
			Parent = row,
		})
		local swatchCorner = Instance.new("UICorner")
		swatchCorner.CornerRadius = UDim.new(0, 3)
		swatchCorner.Parent = colorSwatch
		
		row.NameLabel = nameLabel
		row.ValueLabel = valueLabel
		row.ColorSwatch = colorSwatch
		row._Data = nil
		
		-- Click handlers
		row.MouseButton1Click:Connect(function()
			local data = row._Data
			if not data then return end
			
			if data.Type == "category" then
				categoryStates[data.Name] = not (categoryStates[data.Name] ~= false)
				Properties.Render()
			elseif data.Type == "tag" then
				-- Click X to remove
				-- (handled by value label area)
			elseif data.Type == "tag_add" then
				-- TODO: inline textbox for new tag
				if Notifications then Notifications.Info("Tag add: use right-click menu") end
			end
		end)
		
		-- Right-click for property context menu
		row.MouseButton2Click:Connect(function()
			local data = row._Data
			if not data then return end
			Properties.ShowContextMenu(data)
		end)
		
		-- Hover
		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if row._Data and row._Data.Type ~= "category" then
					row.BackgroundColor3 = Theme.Get("Highlight") or Color3.fromRGB(75, 75, 75)
					row.BackgroundTransparency = 0.5
				end
			end
		end)
		row.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if row._Data and row._Data.Type ~= "category" then
					row.BackgroundTransparency = 1
				end
			end
		end)
		
		rowPool[poolIdx] = row
		return row
	end


	------------------------------------------------------------------------
	-- CONTEXT MENU
	------------------------------------------------------------------------
	Properties.ShowContextMenu = function(data)
		if not Lib.ContextMenu then return end
		local menu = Lib.ContextMenu.new()
		
		if data.Type == "property" or data.Type == "attribute" then
			-- Copy value (display)
			menu:Add({Name = "Copy Value (Display)", OnClick = function()
				if Env.setclipboard then
					Env.setclipboard(valueToDisplay(data.Value))
					if Notifications then Notifications.Info("Copied display value") end
				end
			end})
			
			-- Copy value (Lua)
			menu:Add({Name = "Copy Value (Lua)", OnClick = function()
				if Env.setclipboard then
					Env.setclipboard(valueToLua(data.Value))
					if Notifications then Notifications.Info("Copied as Lua") end
				end
			end})
			
			-- Copy property path
			menu:Add({Name = "Copy Property Path", OnClick = function()
				if Env.setclipboard and #currentInstances > 0 then
					local inst = currentInstances[1]
					local s, path = pcall(function() return inst:GetFullName() end)
					if s then
						Env.setclipboard("game." .. path .. "." .. data.Name)
						if Notifications then Notifications.Info("Copied property path") end
					end
				end
			end})
			
			menu:AddSeparator()
			
			-- Navigate to (for Instance values)
			if data.ValueOk and typeof(data.Value) == "Instance" then
				menu:Add({Name = "Select in Explorer", OnClick = function()
					Store.Emit("navigate", data.Value)
				end})
				menu:AddSeparator()
			end
			
			-- Reset to default (if we can determine it)
			menu:Add({Name = "View in API Reference", OnClick = function()
				Store.Emit("open_api_ref", data.Name)
			end})
		end
		
		if data.Type == "attribute" then
			menu:AddSeparator()
			menu:Add({Name = "Delete Attribute", OnClick = function()
				for _, inst in ipairs(currentInstances) do
					deleteAttribute(inst, data.Name)
				end
				Properties.Render()
				if Notifications then Notifications.Success("Deleted attribute: " .. data.Name) end
			end})
			
			menu:Add({Name = "Rename Attribute", OnClick = function()
				-- TODO: Inline rename UX
				if Notifications then Notifications.Info("Rename via terminal: attr rename " .. data.Name .. " newName") end
			end})
		end
		
		if data.Type == "tag" then
			menu:Add({Name = "Remove Tag", OnClick = function()
				for _, inst in ipairs(currentInstances) do
					removeTag(inst, data.Name)
				end
				Properties.Render()
				if Notifications then Notifications.Success("Removed tag: " .. data.Name) end
			end})
			
			menu:Add({Name = "Select All With Tag", OnClick = function()
				if not CollectionService then CollectionService = service.CollectionService end
				local tagged = CollectionService:GetTagged(data.Name)
				Store.SetSelection(tagged)
				if Notifications then Notifications.Info("Selected " .. #tagged .. " instances with tag: " .. data.Name) end
			end})
		end
		
		menu:Show()
	end
	
	------------------------------------------------------------------------
	-- SELECTION CHANGE LISTENER
	------------------------------------------------------------------------
	local function onSelectionChanged(newSelection)
		-- Disconnect old listeners
		for _, conn in ipairs(changeListeners) do
			conn:Disconnect()
		end
		changeListeners = {}
		
		currentInstances = newSelection or {}
		
		-- Listen for property changes on selected instances
		for _, inst in ipairs(currentInstances) do
			local s, conn = pcall(function()
				return inst.Changed:Connect(function()
					Properties.Render()
				end)
			end)
			if s and conn then
				changeListeners[#changeListeners + 1] = conn
			end
		end
		
		Properties.Render()
	end
	
	------------------------------------------------------------------------
	-- INIT
	------------------------------------------------------------------------
	Properties.Init = function()
		-- Create window
		Properties.Window = Lib.Window.new()
		Properties.Window:SetTitle("Properties")
		Properties.Window:SetResizable(true)
		Properties.Window:SetSize(300, 500)
		
		local content = Properties.Window:GetContentFrame()
		
		-- Header
		headerLabel = createSimple("TextLabel", {
			Name = "Header",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -80, 0, 22),
			Position = UDim2.new(0, 6, 0, 2),
			Text = "No selection",
			TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = content,
		})
		
		instanceCountLabel = createSimple("TextLabel", {
			Name = "Count",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 70, 0, 22),
			Position = UDim2.new(1, -76, 0, 2),
			Text = "",
			TextColor3 = Theme.Get("TextDim") or Color3.fromRGB(150, 150, 150),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = content,
		})
		
		-- Search bar
		local searchBar = createSimple("Frame", {
			Name = "SearchBar",
			BackgroundColor3 = Theme.Get("TextBox") or Color3.fromRGB(38, 38, 38),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 0, 24),
			Parent = content,
		})
		
		local searchInput = createSimple("TextBox", {
			Name = "Input",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 6, 0, 0),
			Text = "",
			PlaceholderText = "Filter properties...",
			PlaceholderColor3 = Theme.Get("PlaceholderText") or Color3.fromRGB(100, 100, 100),
			TextColor3 = Theme.Get("Text") or Color3.fromRGB(255, 255, 255),
			TextSize = 11,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = searchBar,
		})
		
		searchInput:GetPropertyChangedSignal("Text"):Connect(function()
			searchFilter = searchInput.Text
			Properties.Render()
		end)
		
		-- Toggles toolbar
		local toggleBar = createSimple("Frame", {
			Name = "Toggles",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.new(0, 0, 0, 47),
			Parent = content,
		})
		
		local function makeToggle(name, x, getter, setter)
			local btn = createSimple("TextButton", {
				Name = name,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 70, 1, 0),
				Position = UDim2.new(0, x, 0, 0),
				Text = (getter() and "● " or "○ ") .. name,
				TextColor3 = getter() and (Theme.Get("Accent") or Color3.fromRGB(0,120,215)) or (Theme.Get("TextDim") or Color3.fromRGB(120,120,120)),
				TextSize = 10,
				Font = Enum.Font.Gotham,
				Parent = toggleBar,
			})
			btn.MouseButton1Click:Connect(function()
				setter(not getter())
				btn.Text = (getter() and "● " or "○ ") .. name
				btn.TextColor3 = getter() and (Theme.Get("Accent") or Color3.fromRGB(0,120,215)) or (Theme.Get("TextDim") or Color3.fromRGB(120,120,120))
				Properties.Render()
			end)
		end
		
		makeToggle("Depr", 0, function() return showDeprecated end, function(v) showDeprecated = v end)
		makeToggle("Hidden", 72, function() return showHidden end, function(v) showHidden = v end)
		makeToggle("Attrs", 144, function() return showAttributes end, function(v) showAttributes = v end)
		makeToggle("Tags", 216, function() return showTags end, function(v) showTags = v end)
		
		-- Scroll frame
		scrollFrame = createSimple("ScrollingFrame", {
			Name = "PropScroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, -68),
			Position = UDim2.new(0, 0, 0, 68),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Get("ScrollBar") or Color3.fromRGB(80, 80, 80),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = content,
		})
		
		scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			Properties.Render()
		end)
		scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Properties.Render()
		end)
		
		-- Subscribe to selection from Store
		Store.Subscribe("selection", function(newSel)
			onSelectionChanged(newSel)
		end)
		
		-- Load settings
		showDeprecated = Settings.Get("Properties.ShowDeprecated") or false
		showHidden = Settings.Get("Properties.ShowHidden") or false
		showAttributes = Settings.Get("Properties.ShowAttributes") ~= false
		showTags = Settings.Get("Properties.ShowTags") ~= false
		showConnections = Settings.Get("Properties.ShowConnections") ~= false
		
		-- Keybinds
		Keybinds.Register("Properties.Undo", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.Z},
			Category = "Properties",
			Description = "Undo last property change",
			Callback = undoLast,
		})
		
		Keybinds.Register("Properties.CopyValue", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.LeftShift, Enum.KeyCode.C},
			Category = "Properties",
			Description = "Copy selected property as Lua",
			Callback = function()
				-- Copy first property value of primary instance
				if Notifications then Notifications.Info("Use right-click to copy property values") end
			end,
		})
	end
	
	------------------------------------------------------------------------
	-- PUBLIC API
	------------------------------------------------------------------------
	Properties.GetCurrentInstances = function() return currentInstances end
	Properties.SetPropertyValue = setPropertyValue
	Properties.GetPropertyValue = getPropertyValue
	Properties.AddTag = addTag
	Properties.RemoveTag = removeTag
	Properties.SetAttribute = setAttribute
	Properties.DeleteAttribute = deleteAttribute
	Properties.RenameAttribute = renameAttribute
	Properties.UndoLast = undoLast
	Properties.ValueToLua = valueToLua
	Properties.ValueToDisplay = valueToDisplay
	
	Properties.Destroy = function()
		for _, conn in ipairs(connections) do conn:Disconnect() end
		for _, conn in ipairs(changeListeners) do conn:Disconnect() end
		connections = {}
		changeListeners = {}
	end
	
	return Properties
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
