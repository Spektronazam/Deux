--[[
	Deux Core :: Notifications
	Toast Notification System
	
	Features:
	- Severity levels: Info, Success, Warning, Error
	- Auto-dismiss with configurable duration
	- Click-to-dismiss
	- Stacking with smooth animations
	- Queue system to prevent overflow
	- Themed via core/Theme
	
	Usage:
		local Notifications = require("core/Notifications")
		Notifications.Init(Env, Theme, service)
		Notifications.Info("Settings saved")
		Notifications.Error("Decompile failed: timeout")
		Notifications.Success("Hook applied to RemoteEvent.FireServer")
		Notifications.Warning("Missing UNC API: hookmetamethod")
]]

local Notifications = {}

------------------------------------------------------------------------
-- INTERNAL STATE
------------------------------------------------------------------------
local Env, Theme
local TweenService, RunService
local guiParent
local notificationFrame
local activeNotifications = {} -- ordered list of visible notifications
local queue = {} -- overflow queue

local MAX_VISIBLE = 5
local DEFAULT_DURATION = 4
local ANIMATION_TIME = 0.25
local NOTIFICATION_HEIGHT = 48
local NOTIFICATION_WIDTH = 320
local NOTIFICATION_PADDING = 6
local CORNER_RADIUS = 6

------------------------------------------------------------------------
-- SEVERITY CONFIG
------------------------------------------------------------------------
local Severity = {
	Info = {Icon = "ℹ", ColorKey = "Accent"},
	Success = {Icon = "✓", ColorKey = "Success"},
	Warning = {Icon = "⚠", ColorKey = "Warning"},
	Error = {Icon = "✕", ColorKey = "Important"},
}

------------------------------------------------------------------------
-- UI CREATION
------------------------------------------------------------------------
local function createNotificationGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DeuxNotifications"
	screenGui.DisplayOrder = 999999
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	Env.protectGui(screenGui)
	
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.BackgroundTransparency = 1
	container.AnchorPoint = Vector2.new(1, 0)
	container.Position = UDim2.new(1, -12, 0, 48)
	container.Size = UDim2.new(0, NOTIFICATION_WIDTH, 1, -60)
	container.ClipsDescendants = false
	container.Parent = screenGui
	
	notificationFrame = container
	screenGui.Parent = guiParent
	return screenGui
end

local function createToast(message, severity, duration)
	local sevConfig = Severity[severity] or Severity.Info
	local accentColor = Theme and Theme.Get(sevConfig.ColorKey) or Color3.fromRGB(0, 120, 215)
	local bgColor = Theme and Theme.Get("Notification") or Color3.fromRGB(45, 45, 45)
	local borderColor = Theme and Theme.Get("NotificationBorder") or Color3.fromRGB(70, 70, 70)
	local textColor = Theme and Theme.Get("Text") or Color3.fromRGB(255, 255, 255)
	
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.BackgroundColor3 = bgColor
	toast.BorderSizePixel = 0
	toast.Size = UDim2.new(1, 0, 0, NOTIFICATION_HEIGHT)
	toast.AnchorPoint = Vector2.new(1, 0)
	toast.Position = UDim2.new(1, NOTIFICATION_WIDTH, 0, 0) -- start offscreen right
	toast.ClipsDescendants = true
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, CORNER_RADIUS)
	corner.Parent = toast
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = borderColor
	stroke.Thickness = 1
	stroke.Parent = toast
	
	-- Accent bar on left
	local accentBar = Instance.new("Frame")
	accentBar.Name = "Accent"
	accentBar.BackgroundColor3 = accentColor
	accentBar.BorderSizePixel = 0
	accentBar.Size = UDim2.new(0, 3, 1, 0)
	accentBar.Parent = toast
	
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, CORNER_RADIUS)
	accentCorner.Parent = accentBar
	
	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.new(0, 10, 0, 0)
	icon.Size = UDim2.new(0, 24, 1, 0)
	icon.Font = Enum.Font.GothamBold
	icon.Text = sevConfig.Icon
	icon.TextColor3 = accentColor
	icon.TextSize = 18
	icon.Parent = toast
	
	-- Message
	local label = Instance.new("TextLabel")
	label.Name = "Message"
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 36, 0, 0)
	label.Size = UDim2.new(1, -48, 1, 0)
	label.Font = Enum.Font.Gotham
	label.Text = message
	label.TextColor3 = textColor
	label.TextSize = 13
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = toast
	
	return toast
end

------------------------------------------------------------------------
-- LAYOUT & ANIMATION
------------------------------------------------------------------------
local function repositionAll()
	for i, notif in ipairs(activeNotifications) do
		local targetY = (i - 1) * (NOTIFICATION_HEIGHT + NOTIFICATION_PADDING)
		local tween = TweenService:Create(notif.Frame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, targetY)
		})
		tween:Play()
	end
end

local function slideIn(frame)
	frame.Position = UDim2.new(1, NOTIFICATION_WIDTH, 0, (#activeNotifications - 1) * (NOTIFICATION_HEIGHT + NOTIFICATION_PADDING))
	local targetPos = UDim2.new(0, 0, 0, (#activeNotifications - 1) * (NOTIFICATION_HEIGHT + NOTIFICATION_PADDING))
	local tween = TweenService:Create(frame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = targetPos
	})
	tween:Play()
end

local function slideOut(notifData, callback)
	local frame = notifData.Frame
	local tween = TweenService:Create(frame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(1, NOTIFICATION_WIDTH, 0, frame.Position.Y.Offset)
	})
	tween:Play()
	tween.Completed:Connect(function()
		frame:Destroy()
		if callback then callback() end
	end)
end

local function dismiss(notifData)
	local idx = table.find(activeNotifications, notifData)
	if not idx then return end
	table.remove(activeNotifications, idx)
	
	slideOut(notifData, function()
		repositionAll()
		-- Process queue
		if #queue > 0 and #activeNotifications < MAX_VISIBLE then
			local queued = table.remove(queue, 1)
			Notifications.Show(queued.Message, queued.Severity, queued.Duration)
		end
	end)
end

------------------------------------------------------------------------
-- PUBLIC API
------------------------------------------------------------------------

function Notifications.Init(envRef, themeRef, serviceTable)
	Env = envRef
	Theme = themeRef
	TweenService = serviceTable.TweenService or game:GetService("TweenService")
	RunService = serviceTable.RunService or game:GetService("RunService")
	guiParent = Env.getGuiParent()
	
	if guiParent then
		createNotificationGui()
	end
	
	-- Subscribe to theme changes for future notifications
	if Theme and Theme.SubscribeAll then
		Theme.SubscribeAll(function() end) -- placeholder for dynamic recolor if needed
	end
end

--- Show a notification
-- @param message: text to display
-- @param severity: "Info" | "Success" | "Warning" | "Error"
-- @param duration: seconds before auto-dismiss (default 4)
function Notifications.Show(message, severity, duration)
	if not notificationFrame then return end
	
	severity = severity or "Info"
	duration = duration or DEFAULT_DURATION
	
	-- Queue if at capacity
	if #activeNotifications >= MAX_VISIBLE then
		queue[#queue + 1] = {Message = message, Severity = severity, Duration = duration}
		return
	end
	
	local frame = createToast(message, severity, duration)
	frame.Parent = notificationFrame
	
	local notifData = {
		Frame = frame,
		Message = message,
		Severity = severity,
		CreatedAt = tick(),
	}
	
	activeNotifications[#activeNotifications + 1] = notifData
	slideIn(frame)
	
	-- Click to dismiss
	local button = Instance.new("TextButton")
	button.Name = "DismissHit"
	button.BackgroundTransparency = 1
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Text = ""
	button.ZIndex = 10
	button.Parent = frame
	button.MouseButton1Click:Connect(function()
		dismiss(notifData)
	end)
	
	-- Auto-dismiss
	task.delay(duration, function()
		if table.find(activeNotifications, notifData) then
			dismiss(notifData)
		end
	end)
end

--- Convenience methods
function Notifications.Info(msg, duration)
	Notifications.Show(msg, "Info", duration)
end

function Notifications.Success(msg, duration)
	Notifications.Show(msg, "Success", duration)
end

function Notifications.Warning(msg, duration)
	Notifications.Show(msg, "Warning", duration)
end

function Notifications.Error(msg, duration)
	Notifications.Show(msg, "Error", duration or 6)
end

--- Clear all notifications
function Notifications.Clear()
	for _, notif in ipairs(activeNotifications) do
		notif.Frame:Destroy()
	end
	activeNotifications = {}
	queue = {}
end

--- Get count of active + queued
function Notifications.GetCount()
	return #activeNotifications + #queue
end

return Notifications
