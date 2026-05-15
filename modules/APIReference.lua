-- APIReference: searchable docs from the Roblox API dump and ReflectionMetadata.

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
	local APIRef = {}
	local classes, enums = {}, {}
	local selectedClass, selectedEnum = nil, nil
	local searchQuery = ""
	local searchResults = {}
	local viewMode = "Classes"
	local window, classListFrame, memberFrame, enumListFrame, enumDetailFrame, searchFrame, searchBar

	local function loadData()
		if API and API.Classes then
			for name, data in pairs(API.Classes) do
				classes[#classes+1] = {Name = name, Data = data, Superclass = data.Superclass}
			end
			table.sort(classes, function(a,b) return a.Name < b.Name end)
		end
		if API and API.Enums then
			for name, data in pairs(API.Enums) do
				enums[#enums+1] = {Name = name, Items = data.Items or data}
			end
			table.sort(enums, function(a,b) return a.Name < b.Name end)
		end
	end

	local function fuzzy(q, s)
		if not q or q == "" then return true end
		q, s = q:lower(), s:lower()
		local qi = 1
		for i = 1, #s do
			if s:sub(i,i) == q:sub(qi,qi) then qi = qi+1; if qi > #q then return true end end
		end
		return false
	end

	local function getMembers(className)
		local d = API and API.Classes and API.Classes[className]
		if not d or not d.Members then return {},{},{},{} end
		local props, meths, evts, cbs = {},{},{},{}
		for _, m in ipairs(d.Members) do
			if m.MemberType == "Property" then props[#props+1] = m
			elseif m.MemberType == "Function" then meths[#meths+1] = m
			elseif m.MemberType == "Event" then evts[#evts+1] = m
			elseif m.MemberType == "Callback" then cbs[#cbs+1] = m end
		end
		return props, meths, evts, cbs
	end

	local function getTags(m)
		local t = {}
		if m.Tags then for _, tag in ipairs(m.Tags) do t[#t+1] = tag end end
		if m.Security and m.Security ~= "None" then t[#t+1] = "Security:"..tostring(m.Security) end
		return t
	end

	local function getRMDDesc(cls, mem)
		if RMD and RMD.Classes and RMD.Classes[cls] and RMD.Classes[cls].Members then
			local entry = RMD.Classes[cls].Members[mem]
			if entry then return entry.Description or "" end
		end
		return ""
	end

	local function doSearch(q)
		searchResults = {}
		if not q or q == "" then return end
		for _, cls in ipairs(classes) do
			if fuzzy(q, cls.Name) then searchResults[#searchResults+1] = {Type="Class", Name=cls.Name} end
			if cls.Data and cls.Data.Members then
				for _, m in ipairs(cls.Data.Members) do
					if fuzzy(q, m.Name) then
						searchResults[#searchResults+1] = {Type="Member", Name=m.Name, Class=cls.Name, MemberType=m.MemberType}
					end
				end
			end
			if #searchResults > 150 then break end
		end
		for _, en in ipairs(enums) do
			if fuzzy(q, en.Name) then searchResults[#searchResults+1] = {Type="Enum", Name=en.Name} end
		end
	end

	local function clear(frame)
		if not frame then return end
		for _, c in ipairs(frame:GetChildren()) do
			if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
		end
	end

	function APIRef:RenderClassList()
		if not classListFrame then return end; clear(classListFrame)
		local y, h = 0, 20
		for _, cls in ipairs(classes) do
			if fuzzy(searchQuery, cls.Name) then
				local b = createSimple("TextButton", {
					Parent = classListFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,h),
					BackgroundTransparency = selectedClass == cls.Name and 0.7 or 1,
					BackgroundColor3 = Theme.Colors.Accent or Color3.fromRGB(60,120,200),
					BorderSizePixel = 0, Font = Enum.Font.Code, TextSize = 12,
					TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
					TextXAlignment = Enum.TextXAlignment.Left, Text = " "..cls.Name, AutoButtonColor = true,
				})
				b.MouseButton1Click:Connect(function()
					selectedClass = cls.Name; APIRef:RenderClassList(); APIRef:RenderMembers(cls.Name)
				end)
				y = y + h
			end
		end
		classListFrame.CanvasSize = UDim2.new(0,0,0,y)
	end

	function APIRef:RenderMembers(className)
		if not memberFrame then return end; clear(memberFrame)
		local props, meths, evts, cbs = getMembers(className)
		local y = 0
		local super = API.Classes[className] and API.Classes[className].Superclass or ""
		createSimple("TextLabel", {
			Parent = memberFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,24),
			BackgroundTransparency = 1, Font = Enum.Font.SourceSansBold, TextSize = 15,
			TextColor3 = Theme.Colors.Text or Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left,
			Text = " "..className..(super ~= "" and (" < "..super) or ""),
		})
		y = y + 26

		local function section(title, members)
			if #members == 0 then return end
			createSimple("TextLabel", {
				Parent = memberFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,20),
				BackgroundColor3 = Color3.fromRGB(30,30,40), BackgroundTransparency = 0.5,
				BorderSizePixel = 0, Font = Enum.Font.SourceSansBold, TextSize = 12,
				TextColor3 = Theme.Colors.Accent or Color3.fromRGB(100,180,255),
				TextXAlignment = Enum.TextXAlignment.Left, Text = "  "..title.." ("..#members..")",
			})
			y = y + 22
			for _, m in ipairs(members) do
				local tags = getTags(m)
				local tagStr = #tags > 0 and " ["..table.concat(tags,", ").."]" or ""
				local typeStr = m.ValueType and (" : "..(m.ValueType.Name or tostring(m.ValueType))) or ""
				local desc = getRMDDesc(className, m.Name)
				local btn = createSimple("TextButton", {
					Parent = memberFrame, Position = UDim2.new(0,6,0,y), Size = UDim2.new(1,-10,0,16),
					BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11,
					TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
					TextXAlignment = Enum.TextXAlignment.Left, Text = m.Name..typeStr..tagStr, AutoButtonColor = true,
				})
				if m.MemberType == "Property" then
					btn.MouseButton1Click:Connect(function()
						Store:Fire("open_property", {Class=className, Property=m.Name})
					end)
				end
				y = y + 16
				if desc ~= "" then
					createSimple("TextLabel", {
						Parent = memberFrame, Position = UDim2.new(0,14,0,y), Size = UDim2.new(1,-18,0,14),
						BackgroundTransparency = 1, Font = Enum.Font.SourceSansItalic, TextSize = 10,
						TextColor3 = Theme.Colors.Muted or Color3.fromRGB(140,140,140),
						TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = desc,
					})
					y = y + 14
				end
			end
		end

		section("Properties", props); section("Methods", meths); section("Events", evts); section("Callbacks", cbs)
		memberFrame.CanvasSize = UDim2.new(0,0,0,y)
	end

	function APIRef:RenderEnumList()
		if not enumListFrame then return end; clear(enumListFrame)
		local y, h = 0, 20
		for _, en in ipairs(enums) do
			if fuzzy(searchQuery, en.Name) then
				local b = createSimple("TextButton", {
					Parent = enumListFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,h),
					BackgroundTransparency = selectedEnum == en.Name and 0.7 or 1,
					BackgroundColor3 = Theme.Colors.Accent or Color3.fromRGB(60,120,200),
					BorderSizePixel = 0, Font = Enum.Font.Code, TextSize = 12,
					TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
					TextXAlignment = Enum.TextXAlignment.Left, Text = " "..en.Name, AutoButtonColor = true,
				})
				b.MouseButton1Click:Connect(function()
					selectedEnum = en.Name; APIRef:RenderEnumList(); APIRef:RenderEnumDetail(en)
				end)
				y = y + h
			end
		end
		enumListFrame.CanvasSize = UDim2.new(0,0,0,y)
	end

	function APIRef:RenderEnumDetail(en)
		if not enumDetailFrame then return end; clear(enumDetailFrame)
		local y = 0
		createSimple("TextLabel", {
			Parent = enumDetailFrame, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,0,22),
			BackgroundTransparency = 1, Font = Enum.Font.SourceSansBold, TextSize = 14,
			TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
			TextXAlignment = Enum.TextXAlignment.Left, Text = " Enum."..en.Name,
		})
		y = 24
		if type(en.Items) == "table" then
			for name, val in pairs(en.Items) do
				local v = type(val) == "table" and tostring(val.Value or val) or tostring(val)
				createSimple("TextLabel", {
					Parent = enumDetailFrame, Position = UDim2.new(0,8,0,y), Size = UDim2.new(1,-12,0,16),
					BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11,
					TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
					TextXAlignment = Enum.TextXAlignment.Left, Text = name.." = "..v,
				})
				y = y + 16
			end
		end
		enumDetailFrame.CanvasSize = UDim2.new(0,0,0,y)
	end

	function APIRef:RenderSearch()
		if not searchFrame then return end; clear(searchFrame)
		local y, h = 0, 20
		for i, r in ipairs(searchResults) do
			if i > 150 then break end
			local text = r.Type == "Class" and "[Class] "..r.Name
				or r.Type == "Member" and "["..r.MemberType.."] "..r.Class.."."..r.Name
				or "[Enum] "..r.Name
			local b = createSimple("TextButton", {
				Parent = searchFrame, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,h),
				BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 12,
				TextColor3 = Theme.Colors.Text or Color3.new(1,1,1),
				TextXAlignment = Enum.TextXAlignment.Left, Text = " "..text, AutoButtonColor = true,
			})
			b.MouseButton1Click:Connect(function()
				if r.Type == "Class" or r.Type == "Member" then
					viewMode = "Classes"; selectedClass = r.Class or r.Name
					APIRef:SwitchView(); APIRef:RenderMembers(selectedClass)
				else viewMode = "Enums"; APIRef:SwitchView() end
			end)
			y = y + h
		end
		searchFrame.CanvasSize = UDim2.new(0,0,0,y)
	end

	function APIRef:SwitchView()
		if classListFrame then classListFrame.Visible = viewMode == "Classes" end
		if memberFrame then memberFrame.Visible = viewMode == "Classes" end
		if enumListFrame then enumListFrame.Visible = viewMode == "Enums" end
		if enumDetailFrame then enumDetailFrame.Visible = viewMode == "Enums" end
		if searchFrame then searchFrame.Visible = viewMode == "Search" end
		if viewMode == "Classes" then APIRef:RenderClassList()
		elseif viewMode == "Enums" then APIRef:RenderEnumList()
		else APIRef:RenderSearch() end
	end

	function APIRef:BuildUI()
		window = Lib.Window.new(); window:SetTitle("API Reference"); window:SetSize(720, 480)
		local content = window:GetContent()

		searchBar = createSimple("TextBox", {
			Parent = content, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,-140,0,26),
			BackgroundColor3 = Color3.fromRGB(30,30,30), Font = Enum.Font.Code, TextSize = 13,
			TextColor3 = Color3.new(1,1,1), PlaceholderText = "Search classes, members, enums...",
			PlaceholderColor3 = Color3.fromRGB(100,100,100), TextXAlignment = Enum.TextXAlignment.Left, Text = "",
		})
		searchBar:GetPropertyChangedSignal("Text"):Connect(function()
			searchQuery = searchBar.Text
			if searchQuery ~= "" then viewMode = "Search"; doSearch(searchQuery) else viewMode = "Classes" end
			APIRef:SwitchView()
		end)

		local clsBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-136,0,0), Size = UDim2.new(0,66,0,26),
			BackgroundColor3 = Color3.fromRGB(50,50,70), Font = Enum.Font.Code, TextSize = 12,
			TextColor3 = Color3.new(1,1,1), Text = "Classes",
		})
		clsBtn.MouseButton1Click:Connect(function() viewMode = "Classes"; APIRef:SwitchView() end)

		local enBtn = createSimple("TextButton", {
			Parent = content, Position = UDim2.new(1,-66,0,0), Size = UDim2.new(0,66,0,26),
			BackgroundColor3 = Color3.fromRGB(50,50,70), Font = Enum.Font.Code, TextSize = 12,
			TextColor3 = Color3.new(1,1,1), Text = "Enums",
		})
		enBtn.MouseButton1Click:Connect(function() viewMode = "Enums"; APIRef:SwitchView() end)

		local sf = function(name, pos, size, vis)
			return createSimple("ScrollingFrame", {
				Name = name, Parent = content, Position = pos, Size = size,
				BackgroundColor3 = Color3.fromRGB(20,20,22), BorderSizePixel = 0,
				ScrollBarThickness = 5, CanvasSize = UDim2.new(0,0,0,0),
				ScrollingDirection = Enum.ScrollingDirection.Y, Visible = vis,
			})
		end
		classListFrame = sf("ClassList", UDim2.new(0,0,0,30), UDim2.new(0.28,0,1,-30), true)
		memberFrame = sf("Members", UDim2.new(0.28,4,0,30), UDim2.new(0.72,-4,1,-30), true)
		enumListFrame = sf("EnumList", UDim2.new(0,0,0,30), UDim2.new(0.28,0,1,-30), false)
		enumDetailFrame = sf("EnumDetail", UDim2.new(0.28,4,0,30), UDim2.new(0.72,-4,1,-30), false)
		searchFrame = sf("Search", UDim2.new(0,0,0,30), UDim2.new(1,0,1,-30), false)
	end

	function APIRef:Init()
		loadData(); APIRef:BuildUI(); APIRef:RenderClassList()
	end

	function APIRef:Destroy() if window then window:Close() end end

	APIRef:Init()
	return APIRef
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
