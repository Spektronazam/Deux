-- ThemePicker: a small Lib.Window that exposes the theme presets, a Smart
-- (auto-derived from world lighting) option, a Manual section for editing
-- individual color keys, and a font picker. Lives behind the "Themes" tile
-- in the top-middle launcher.

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

-- Theme keys exposed in the Manual section. Anything not in this list is
-- considered an internal/derived value and isn't user-editable.
local MANUAL_KEYS = {
	"Main1", "Main2", "Main3",
	"Outline1", "Outline2", "Outline3",
	"TextBox", "Menu", "ListSelection",
	"Button", "ButtonHover", "ButtonPress",
	"Highlight", "Text", "TextDim", "PlaceholderText",
	"Important", "Success", "Warning", "Accent",
	"ScrollBar", "ScrollBarHover", "Separator",
	"TabActive", "TabInactive",
	"Notification", "NotificationBorder",
}

local function main()
	local ThemePicker = {}
	local window
	local presetList, manualList, fontList -- scrolling frames per section
	local activePresetButton -- highlighted button ref for redrawing
	local connections = {}

	-- Tiny helpers ---------------------------------------------------------

	local function bg(key, fallback)
		return Theme.Get(key) or fallback
	end

	local function makeButton(parent, text, x, y, w, h, opts)
		opts = opts or {}
		return createSimple("TextButton", {
			Parent = parent, Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, h),
			BackgroundColor3 = opts.bg or bg("Button", Color3.fromRGB(60, 60, 60)),
			BorderSizePixel = 0,
			Font = opts.font or Enum.Font.Gotham, TextSize = opts.textSize or 12,
			TextColor3 = opts.textColor or bg("Text", Color3.new(1, 1, 1)),
			Text = text, AutoButtonColor = true,
		})
	end

	local function makeLabel(parent, text, x, y, w, h, opts)
		opts = opts or {}
		return createSimple("TextLabel", {
			Parent = parent, Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, h),
			BackgroundTransparency = 1,
			Font = opts.font or Enum.Font.Gotham, TextSize = opts.textSize or 12,
			TextColor3 = opts.textColor or bg("Text", Color3.new(1, 1, 1)),
			Text = text, TextXAlignment = opts.align or Enum.TextXAlignment.Left,
		})
	end

	-- Presets section ------------------------------------------------------

	local function presetButtonFor(name)
		local preset = Theme.Presets[name]
		if not preset then return nil end
		-- Use the preset's own colors for the swatch so the user can preview
		-- without applying.
		local swatchBg = preset.Main2 or preset.Main1 or Color3.fromRGB(45, 45, 45)
		local swatchFg = preset.Text or Color3.new(1, 1, 1)
		local swatchAccent = preset.Accent or Color3.fromRGB(0, 120, 215)
		return swatchBg, swatchFg, swatchAccent
	end

	local function renderPresets()
		if not presetList then return end
		for _, c in ipairs(presetList:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end

		local rowHeight = 28
		local y = 0
		local current = Theme.GetCurrentName()

		-- "Smart" entry on top -- it's not a static preset, it samples the world.
		local smartRow = createSimple("TextButton", {
			Parent = presetList, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, -4, 0, rowHeight),
			BackgroundColor3 = bg("Button", Color3.fromRGB(60, 60, 60)),
			BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 12,
			TextColor3 = bg("Text", Color3.new(1, 1, 1)),
			Text = "  Smart  (auto from world)", TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = true,
		})
		if current == "Smart" then
			smartRow.BackgroundColor3 = bg("Accent", Color3.fromRGB(0, 120, 215))
			activePresetButton = smartRow
		end
		smartRow.MouseButton1Click:Connect(function()
			local ok = Theme.SmartFromWorld()
			if ok and Notifications then
				Notifications.Info("Smart theme applied from current world lighting", 2)
			end
			renderPresets() -- redraw to update highlight
		end)
		y = y + rowHeight + 4

		-- Static presets in the order Theme.PresetOrder declares.
		local order = Theme.PresetOrder or {}
		for _, name in ipairs(order) do
			local preset = Theme.Presets[name]
			if preset then
				local swatchBg, swatchFg, swatchAccent = presetButtonFor(name)
				local row = createSimple("TextButton", {
					Parent = presetList, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, -4, 0, rowHeight),
					BackgroundColor3 = bg("Button", Color3.fromRGB(60, 60, 60)),
					BorderSizePixel = 0, Text = "", AutoButtonColor = true,
				})
				-- Three little swatches on the left so the user can recognise
				-- the palette without applying it first.
				createSimple("Frame", {
					Parent = row, Position = UDim2.new(0, 6, 0, 6), Size = UDim2.new(0, 12, 0, 16),
					BackgroundColor3 = swatchBg, BorderSizePixel = 0,
				})
				createSimple("Frame", {
					Parent = row, Position = UDim2.new(0, 20, 0, 6), Size = UDim2.new(0, 12, 0, 16),
					BackgroundColor3 = swatchAccent, BorderSizePixel = 0,
				})
				createSimple("Frame", {
					Parent = row, Position = UDim2.new(0, 34, 0, 6), Size = UDim2.new(0, 12, 0, 16),
					BackgroundColor3 = swatchFg, BorderSizePixel = 0,
				})
				createSimple("TextLabel", {
					Parent = row, Position = UDim2.new(0, 56, 0, 0), Size = UDim2.new(1, -64, 1, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham, TextSize = 12,
					TextColor3 = bg("Text", Color3.new(1, 1, 1)),
					Text = name, TextXAlignment = Enum.TextXAlignment.Left,
				})
				if current == name then
					row.BackgroundColor3 = bg("Accent", Color3.fromRGB(0, 120, 215))
					activePresetButton = row
				end
				row.MouseButton1Click:Connect(function()
					Theme.Apply(name)
					if Notifications then Notifications.Info("Theme: " .. name, 2) end
					renderPresets()
					ThemePicker:RenderManual()
				end)
				y = y + rowHeight + 4
			end
		end

		presetList.CanvasSize = UDim2.new(0, 0, 0, y)
	end

	-- Manual section -------------------------------------------------------

	function ThemePicker:RenderManual()
		if not manualList then return end
		for _, c in ipairs(manualList:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end

		local rowHeight = 22
		local y = 0
		for _, key in ipairs(MANUAL_KEYS) do
			local current = Theme.Get(key)
			if typeof(current) == "Color3" then
				local row = createSimple("Frame", {
					Parent = manualList, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, -4, 0, rowHeight),
					BackgroundTransparency = 1, BorderSizePixel = 0,
				})
				createSimple("TextLabel", {
					Parent = row, Position = UDim2.new(0, 6, 0, 0), Size = UDim2.new(0, 130, 1, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.Code, TextSize = 11,
					TextColor3 = bg("Text", Color3.new(1, 1, 1)),
					Text = key, TextXAlignment = Enum.TextXAlignment.Left,
				})
				local swatch = createSimple("TextButton", {
					Parent = row, Position = UDim2.new(0, 140, 0, 2), Size = UDim2.new(1, -150, 0, rowHeight - 4),
					BackgroundColor3 = current, BorderSizePixel = 1,
					BorderColor3 = bg("Outline2", Color3.fromRGB(70, 70, 70)),
					Text = string.format("rgb(%d, %d, %d)",
						math.floor(current.R * 255 + 0.5),
						math.floor(current.G * 255 + 0.5),
						math.floor(current.B * 255 + 0.5)),
					Font = Enum.Font.Code, TextSize = 10,
					TextColor3 = (current.R + current.G + current.B) / 3 > 0.5
						and Color3.new(0, 0, 0) or Color3.new(1, 1, 1),
					AutoButtonColor = false,
				})
				-- Lib.ColorPicker is heavy (its own Window + tweens), so we
				-- keep a single instance and rebind OnSelect each time the
				-- user clicks a swatch. Disconnecting the previous handler
				-- ensures only the most-recently-clicked key gets the value.
				local picker = self._picker
				if not picker then
					picker = Lib.ColorPicker.new()
					self._picker = picker
				end
				swatch.MouseButton1Click:Connect(function()
					if self._pickerConn then self._pickerConn:Disconnect() end
					self._pickerConn = picker.OnSelect:Connect(function(col)
						Theme.SetKey(key, col)
						ThemePicker:RenderManual()
					end)
					picker:SetColor(current)
					picker:Show()
				end)
				y = y + rowHeight + 2
			end
		end
		manualList.CanvasSize = UDim2.new(0, 0, 0, y)
	end

	-- Fonts section --------------------------------------------------------

	local function renderFonts()
		if not fontList then return end
		for _, c in ipairs(fontList:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end

		local rowHeight = 26
		local y = 0
		local currentFont = Theme.GetFontName()
		for _, name in ipairs(Theme.ListFonts()) do
			local row = createSimple("TextButton", {
				Parent = fontList, Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, -4, 0, rowHeight),
				BackgroundColor3 = bg("Button", Color3.fromRGB(60, 60, 60)),
				BorderSizePixel = 0, Text = "", AutoButtonColor = true,
			})
			-- Preview using the actual font so the user sees the result before
			-- applying.
			local fontEntry
			for _, e in ipairs(Theme.Fonts) do
				if e.Name == name then fontEntry = e break end
			end
			createSimple("TextLabel", {
				Parent = row, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(0.5, -8, 1, 0),
				BackgroundTransparency = 1,
				Font = (fontEntry and typeof(fontEntry.Font) == "EnumItem") and fontEntry.Font or Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = bg("Text", Color3.new(1, 1, 1)),
				Text = name, TextXAlignment = Enum.TextXAlignment.Left,
			})
			createSimple("TextLabel", {
				Parent = row, Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, -8, 1, 0),
				BackgroundTransparency = 1,
				Font = (fontEntry and typeof(fontEntry.Font) == "EnumItem") and fontEntry.Font or Enum.Font.Gotham,
				TextSize = 11,
				TextColor3 = bg("TextDim", Color3.fromRGB(180, 180, 180)),
				Text = "The quick brown fox", TextXAlignment = Enum.TextXAlignment.Left,
			})
			if currentFont == name then
				row.BackgroundColor3 = bg("Accent", Color3.fromRGB(0, 120, 215))
			end
			row.MouseButton1Click:Connect(function()
				Theme.SetFont(name)
				if Notifications then Notifications.Info("Font: " .. name, 2) end
				renderFonts()
			end)
			y = y + rowHeight + 2
		end
		fontList.CanvasSize = UDim2.new(0, 0, 0, y)
	end

	-- Custom font loader ---------------------------------------------------

	local function buildCustomFontRow(parent, x, y, w)
		-- A row at the bottom of the Fonts section: enter a name + asset id
		-- and click Add. Asset id can be a number, an rbxassetid:// URL, or
		-- (when the executor exposes it) the result of a remote loadstring
		-- url. The actual font object is created via Font.new on success.
		local row = createSimple("Frame", {
			Parent = parent, Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, 26),
			BackgroundTransparency = 1,
		})
		local nameInput = createSimple("TextBox", {
			Parent = row, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.35, -2, 1, 0),
			BackgroundColor3 = bg("TextBox", Color3.fromRGB(38, 38, 38)),
			Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = bg("Text", Color3.new(1, 1, 1)),
			PlaceholderText = "FontName", PlaceholderColor3 = bg("PlaceholderText", Color3.fromRGB(110, 110, 110)),
			Text = "", ClearTextOnFocus = false, BorderSizePixel = 0,
		})
		local idInput = createSimple("TextBox", {
			Parent = row, Position = UDim2.new(0.35, 2, 0, 0), Size = UDim2.new(0.45, -4, 1, 0),
			BackgroundColor3 = bg("TextBox", Color3.fromRGB(38, 38, 38)),
			Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = bg("Text", Color3.new(1, 1, 1)),
			PlaceholderText = "rbxassetid:// or asset id",
			PlaceholderColor3 = bg("PlaceholderText", Color3.fromRGB(110, 110, 110)),
			Text = "", ClearTextOnFocus = false, BorderSizePixel = 0,
		})
		local addBtn = createSimple("TextButton", {
			Parent = row, Position = UDim2.new(0.8, 2, 0, 0), Size = UDim2.new(0.2, -2, 1, 0),
			BackgroundColor3 = bg("Accent", Color3.fromRGB(56, 142, 235)),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold, TextSize = 11,
			TextColor3 = Color3.new(1, 1, 1), Text = "Add",
			AutoButtonColor = true,
		})
		addBtn.MouseButton1Click:Connect(function()
			local n = nameInput.Text
			local id = idInput.Text
			if not n or n == "" or not id or id == "" then
				if Notifications then Notifications.Warning("Both font name and asset id are required") end
				return
			end
			-- Accept "12345", "rbxassetid://12345", or a full content URL.
			local digits = id:match("(%d+)$") or id:match("(%d+)")
			local assetId = digits or id
			local ok = Theme.RegisterFontFromAssetId(n, assetId)
			if ok then
				if Notifications then Notifications.Success("Font loaded: " .. n) end
				nameInput.Text = ""
				idInput.Text = ""
				renderFonts()
			else
				if Notifications then Notifications.Error("Failed to load font (executor may lack Font.new)") end
			end
		end)
	end

	-- UI ------------------------------------------------------------------

	function ThemePicker:BuildUI()
		window = Lib.Window.new()
		window:SetTitle("Themes")
		window:SetSize(560, 420)
		ThemePicker.Window = window

		local content = window:GetContent()

		-- Three-column header bar with section labels.
		local header = createSimple("Frame", {
			Parent = content, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 22),
			BackgroundColor3 = bg("Main2", Color3.fromRGB(45, 45, 45)),
			BorderSizePixel = 0,
		})
		makeLabel(header, "General Themes", 6, 0, 180, 22, {textColor = bg("TextDim", Color3.fromRGB(180,180,180)), font = Enum.Font.GothamBold})
		makeLabel(header, "Manual", 200, 0, 180, 22, {textColor = bg("TextDim", Color3.fromRGB(180,180,180)), font = Enum.Font.GothamBold})
		makeLabel(header, "Fonts", 400, 0, 140, 22, {textColor = bg("TextDim", Color3.fromRGB(180,180,180)), font = Enum.Font.GothamBold})

		-- Three scrolling lists side by side.
		presetList = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(0, 196, 1, -56),
			BackgroundColor3 = bg("Main3", Color3.fromRGB(38, 38, 38)),
			BorderSizePixel = 0, ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		manualList = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0, 200, 0, 26), Size = UDim2.new(0, 196, 1, -56),
			BackgroundColor3 = bg("Main3", Color3.fromRGB(38, 38, 38)),
			BorderSizePixel = 0, ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		fontList = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0, 400, 0, 26), Size = UDim2.new(1, -400, 1, -56),
			BackgroundColor3 = bg("Main3", Color3.fromRGB(38, 38, 38)),
			BorderSizePixel = 0, ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})

		-- Footer: custom font loader + reset button.
		local footer = createSimple("Frame", {
			Parent = content, Position = UDim2.new(0, 0, 1, -28), Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = bg("Main2", Color3.fromRGB(45, 45, 45)),
			BorderSizePixel = 0,
		})

		-- Reset (re-apply Dark) on the left.
		local resetBtn = makeButton(footer, "Reset to Dark", 6, 4, 110, 20)
		resetBtn.MouseButton1Click:Connect(function()
			Theme.Apply("Dark")
			if Notifications then Notifications.Info("Theme reset to Dark", 2) end
			renderPresets()
			ThemePicker:RenderManual()
			renderFonts()
		end)

		-- Custom font loader fills the right side.
		buildCustomFontRow(footer, 124, 1, 420)

		renderPresets()
		ThemePicker:RenderManual()
		renderFonts()

		-- Re-render whenever someone else changes the theme (e.g. another
		-- module / a Settings restore) so highlights stay accurate.
		local conn = Theme.SubscribeAll(function()
			renderPresets()
			ThemePicker:RenderManual()
			renderFonts()
		end)
		if conn then connections[#connections + 1] = conn end
	end

	function ThemePicker:Init()
		ThemePicker:BuildUI()
	end

	function ThemePicker:Destroy()
		for _, c in ipairs(connections) do
			if type(c) == "function" then pcall(c) end
		end
		connections = {}
		if self._pickerConn then self._pickerConn:Disconnect(); self._pickerConn = nil end
		if window then window:Close() end
	end

	ThemePicker:Init()
	return ThemePicker
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
