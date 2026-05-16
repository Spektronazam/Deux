-- WorkspaceTools: freecam, noclip, selection highlight, anchor/transparent toggles.

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
	local WSTools = {}
	local freecamActive, noclipActive, highlightActive = false, false, false
	local highlights = {}
	local connections = {}
	local keysDown = {}
	local freecamSpeed, freecamFOV = 1, 70
	local originalFOV = nil
	local freecamConn, inputConn1, inputConn2, noclipConn = nil, nil, nil, nil
	local originalCollisions = {}
	local animTarget = nil
	local window, toolbarFrame, animPanel

	local UIS = service.UserInputService
	local RunService = service.RunService
	local Camera = workspace.CurrentCamera

	-- Freecam
	local function startFreecam()
		if freecamActive then return end
		freecamActive = true; originalFOV = Camera.FieldOfView
		pcall(function()
			if Settings.WorkspaceTools then
				freecamSpeed = Settings.WorkspaceTools.Speed or 1
				freecamFOV = Settings.WorkspaceTools.FOV or 70
			end
		end)
		Camera.CameraType = Enum.CameraType.Scriptable; Camera.FieldOfView = freecamFOV; keysDown = {}

		inputConn1 = UIS.InputBegan:Connect(function(input, gp)
			if gp then return end; if input.KeyCode then keysDown[input.KeyCode] = true end
		end); connections[#connections+1] = inputConn1
		inputConn2 = UIS.InputEnded:Connect(function(input)
			if input.KeyCode then keysDown[input.KeyCode] = nil end
		end); connections[#connections+1] = inputConn2

		freecamConn = RunService.RenderStepped:Connect(function(dt)
			if not freecamActive then return end
			local spd = freecamSpeed * 50 * dt
			local cf = Camera.CFrame; local move = Vector3.new(0,0,0)
			if keysDown[Enum.KeyCode.W] then move = move + cf.LookVector end
			if keysDown[Enum.KeyCode.S] then move = move - cf.LookVector end
			if keysDown[Enum.KeyCode.A] then move = move - cf.RightVector end
			if keysDown[Enum.KeyCode.D] then move = move + cf.RightVector end
			if keysDown[Enum.KeyCode.E] then move = move + Vector3.new(0,1,0) end
			if keysDown[Enum.KeyCode.Q] then move = move - Vector3.new(0,1,0) end
			if keysDown[Enum.KeyCode.LeftShift] then spd = spd * 3 end
			if move.Magnitude > 0 then Camera.CFrame = cf + move.Unit * spd end
			if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				local d = UIS:GetMouseDelta()
				Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(-d.Y*0.3), math.rad(-d.X*0.3), 0)
			end
		end); connections[#connections+1] = freecamConn

		if noclipActive then WSTools:EnableNoclip() end
		if Notifications then Notifications.Info("Freecam ON (WASD+QE, RMB look)", 2) end
	end

	local function stopFreecam()
		if not freecamActive then return end; freecamActive = false
		Camera.CameraType = Enum.CameraType.Custom
		if originalFOV then Camera.FieldOfView = originalFOV end
		if freecamConn then freecamConn:Disconnect(); freecamConn = nil end
		if inputConn1 then inputConn1:Disconnect(); inputConn1 = nil end
		if inputConn2 then inputConn2:Disconnect(); inputConn2 = nil end
		WSTools:DisableNoclip(); keysDown = {}
		if Notifications then Notifications.Info("Freecam OFF", 2) end
	end

	-- Noclip
	function WSTools:EnableNoclip()
		if noclipConn then return end
		noclipConn = RunService.Stepped:Connect(function()
			local char = plr and plr.Character; if not char then return end
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then
					if originalCollisions[p] == nil then originalCollisions[p] = p.CanCollide end
					p.CanCollide = false
				end
			end
		end); connections[#connections+1] = noclipConn
	end

	function WSTools:DisableNoclip()
		if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
		for p, v in pairs(originalCollisions) do if p and p.Parent then pcall(function() p.CanCollide = v end) end end
		originalCollisions = {}
	end

	-- Highlight
	local function clearHighlights()
		for _, h in ipairs(highlights) do if h and h.Parent then h:Destroy() end end
		highlights = {}
	end

	local function applyHighlights()
		clearHighlights()
		if not highlightActive then return end
		local sel = Store.GetSelection() or {}
		local accent = (Theme and Theme.Get and Theme.Get("Accent")) or Color3.fromRGB(80,160,255)
		for _, inst in ipairs(sel) do
			if inst and (inst:IsA("BasePart") or inst:IsA("Model")) then
				local ok, h = pcall(function()
					local hl = Instance.new("Highlight")
					hl.Adornee = inst; hl.FillColor = accent; hl.FillTransparency = 0.7
					hl.OutlineColor = accent; hl.OutlineTransparency = 0; hl.Parent = inst; return hl
				end)
				if ok and h then highlights[#highlights+1] = h
				else pcall(function()
					local sb = Instance.new("SelectionBox")
					sb.Adornee = inst; sb.Color3 = accent; sb.LineThickness = 0.03; sb.Parent = inst
					highlights[#highlights+1] = sb
				end) end
			end
		end
	end

	-- Quick toggles
	local function getSel()
		return Store.GetSelection() or {}
	end

	local function anchorSel()
		for _, i in ipairs(getSel()) do if i and i:IsA("BasePart") then pcall(function() i.Anchored = not i.Anchored end) end end
		if Notifications then Notifications.Info("Toggled Anchored", 2) end
	end

	local function makeTransp()
		for _, i in ipairs(getSel()) do if i and i:IsA("BasePart") then pcall(function() i.Transparency = 0.8 end) end end
		if Notifications then Notifications.Info("Transparency -> 0.8", 2) end
	end

	local function resetProps()
		for _, i in ipairs(getSel()) do
			if i and i:IsA("BasePart") then
				pcall(function() i.Transparency = 0; i.Anchored = false; i.CanCollide = true end)
			end
		end
		if Notifications then Notifications.Info("Reset properties", 2) end
	end

	-- Animation viewer
	function WSTools:RenderAnim()
		if not animPanel then return end
		for _, c in ipairs(animPanel:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
		local y, rh = 0, 22
		createSimple("TextButton", {
			Parent = animPanel, Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,0,0,rh),
			BackgroundColor3 = Color3.fromRGB(40,50,60), Font = Enum.Font.Code, TextSize = 11,
			TextColor3 = Color3.new(1,1,1),
			Text = "Target: "..(animTarget and animTarget.Parent and animTarget.Parent.Name or "None (click)"),
		}).MouseButton1Click:Connect(function()
			local sel = (Store.GetSelection() or {})[1]
			if sel then
				local hum = sel:FindFirstChildOfClass("Humanoid") or (sel:IsA("Humanoid") and sel)
				if hum then animTarget = hum; WSTools:RenderAnim()
				elseif Notifications then Notifications.Info("Select a model with Humanoid", 2) end
			end
		end)
		y = y + rh + 4

		local tracks = {}
		if animTarget then pcall(function()
			local animator = animTarget:FindFirstChildOfClass("Animator")
			if animator then tracks = animator:GetPlayingAnimationTracks() end
		end) end

		for i, track in ipairs(tracks) do
			local name = pcall(function() return track.Name end) and track.Name or "Track"..i
			local spd = pcall(function() return track.Speed end) and string.format("%.1f", track.Speed) or "?"
			local wt = pcall(function() return track.WeightCurrent end) and string.format("%.2f", track.WeightCurrent) or "?"
			createSimple("TextLabel", {
				Parent = animPanel, Position = UDim2.new(0,4,0,y), Size = UDim2.new(1,-8,0,18),
				BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11,
				TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left,
				Text = name.."  Spd:"..spd.." W:"..wt,
			})
			y = y + 20
		end
		if #tracks == 0 and animTarget then
			createSimple("TextLabel", {
				Parent = animPanel, Position = UDim2.new(0,4,0,y), Size = UDim2.new(1,-8,0,18),
				BackgroundTransparency = 1, Font = Enum.Font.SourceSansItalic, TextSize = 11,
				TextColor3 = Color3.fromRGB(120,120,120), TextXAlignment = Enum.TextXAlignment.Left,
				Text = "No animations playing",
			}); y = y + 20
		end
		animPanel.CanvasSize = UDim2.new(0,0,0,y)
	end

	-- UI
	function WSTools:BuildUI()
		window = Lib.Window.new(); window:SetTitle("Workspace Tools"); window:SetSize(420, 340)
		local content = window:GetContent()

		toolbarFrame = createSimple("Frame", {
			Parent = content, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,0,28),
			BackgroundColor3 = Color3.fromRGB(28,28,32), BorderSizePixel = 0,
		})
		local btns = {
			{"Freecam", function() if freecamActive then stopFreecam() else startFreecam() end end},
			{"Noclip", function()
				noclipActive = not noclipActive
				if freecamActive then if noclipActive then WSTools:EnableNoclip() else WSTools:DisableNoclip() end end
				if Notifications then Notifications.Info("Noclip: "..(noclipActive and "ON" or "OFF"), 2) end
			end},
			{"Highlight", function() highlightActive = not highlightActive; applyHighlights() end},
			{"Anchor", anchorSel},
			{"Transp", makeTransp},
			{"Reset", resetProps},
		}
		for i, b in ipairs(btns) do
			local btn = createSimple("TextButton", {
				Parent = toolbarFrame, Position = UDim2.new(0,(i-1)*68,0,2), Size = UDim2.new(0,66,0,24),
				BackgroundColor3 = Color3.fromRGB(45,55,70), Font = Enum.Font.Code, TextSize = 10,
				TextColor3 = Color3.new(1,1,1), Text = b[1], AutoButtonColor = true,
			})
			btn.MouseButton1Click:Connect(b[2])
		end

		animPanel = createSimple("ScrollingFrame", {
			Parent = content, Position = UDim2.new(0,0,0,32), Size = UDim2.new(1,0,1,-32),
			BackgroundColor3 = Color3.fromRGB(20,20,22), BorderSizePixel = 0,
			ScrollBarThickness = 5, CanvasSize = UDim2.new(0,0,0,0), ScrollingDirection = Enum.ScrollingDirection.Y,
		})

		local selConn = Store.Subscribe("selection", function()
			if highlightActive then applyHighlights() end; WSTools:RenderAnim()
		end)
		if selConn then connections[#connections+1] = selConn end
	end

	function WSTools:Init() WSTools:BuildUI(); WSTools:RenderAnim() end

	function WSTools:Destroy()
		stopFreecam(); WSTools:DisableNoclip(); clearHighlights()
		for _, c in ipairs(connections) do
			if typeof(c) == "RBXScriptConnection" then
				c:Disconnect()
			elseif type(c) == "function" then
				pcall(c)
			end
		end
		connections = {}; if window then window:Close() end
	end

	WSTools:Init()
	return WSTools
end

return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
