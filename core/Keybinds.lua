--[[
	Deux Core :: Keybinds
	Central Keybind Registry with Conflict Detection
	
	Features:
	- Register named actions with default keybinds
	- Rebindable at runtime (persisted via Settings)
	- Conflict detection and resolution
	- Combo support (Ctrl+Shift+F, etc.)
	- Category grouping for the settings UI
	
	Usage:
		local Keybinds = require("core/Keybinds")
		Keybinds.Init(Settings, service)
		Keybinds.Register("Explorer.ToggleVisibility", {
			Keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.E},
			Category = "Explorer",
			Description = "Toggle Explorer window",
			Callback = function() ... end
		})
]]

local Keybinds = {}

------------------------------------------------------------------------
-- INTERNAL STATE
------------------------------------------------------------------------
local Settings
local UserInputService
local bindings = {} -- actionName -> {Keys, Category, Description, Callback, Enabled}
local keyState = {} -- KeyCode -> bool (currently held)
local connections = {}
local enabled = true

------------------------------------------------------------------------
-- HELPERS
------------------------------------------------------------------------
local function keysMatch(required)
	for _, key in ipairs(required) do
		if not keyState[key] then return false end
	end
	return true
end

local function getModifierCount(keys)
	local count = 0
	for _, key in ipairs(keys) do
		if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.RightControl
			or key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift
			or key == Enum.KeyCode.LeftAlt or key == Enum.KeyCode.RightAlt then
			count = count + 1
		end
	end
	return count
end

local function keysToString(keys)
	local names = {}
	local order = {
		[Enum.KeyCode.LeftControl] = 1, [Enum.KeyCode.RightControl] = 1,
		[Enum.KeyCode.LeftShift] = 2, [Enum.KeyCode.RightShift] = 2,
		[Enum.KeyCode.LeftAlt] = 3, [Enum.KeyCode.RightAlt] = 3,
	}
	
	table.sort(keys, function(a, b)
		local oa, ob = order[a] or 99, order[b] or 99
		if oa ~= ob then return oa < ob end
		return a.Value < b.Value
	end)
	
	for _, key in ipairs(keys) do
		local name = key.Name
		name = name:gsub("Left", ""):gsub("Right", "")
		names[#names + 1] = name
	end
	return table.concat(names, "+")
end

------------------------------------------------------------------------
-- INPUT HANDLING
------------------------------------------------------------------------
local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	if not enabled then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	
	keyState[input.KeyCode] = true
	
	-- Check all bindings (prioritize those with more modifiers)
	local candidates = {}
	for name, binding in pairs(bindings) do
		if binding.Enabled and keysMatch(binding.Keys) then
			candidates[#candidates + 1] = binding
		end
	end
	
	-- Sort by specificity (more keys = higher priority)
	table.sort(candidates, function(a, b) return #a.Keys > #b.Keys end)
	
	if candidates[1] then
		task.spawn(candidates[1].Callback)
	end
end

local function onInputEnded(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	keyState[input.KeyCode] = false
end

------------------------------------------------------------------------
-- PUBLIC API
------------------------------------------------------------------------

function Keybinds.Init(settingsRef, serviceTable)
	Settings = settingsRef
	UserInputService = serviceTable.UserInputService or game:GetService("UserInputService")
	
	connections[#connections + 1] = UserInputService.InputBegan:Connect(onInputBegan)
	connections[#connections + 1] = UserInputService.InputEnded:Connect(onInputEnded)
	
	-- Load saved rebinds from settings
	local savedBinds = Settings and Settings.Get and Settings.Get("Keybinds")
	if type(savedBinds) == "table" then
		for name, keys in pairs(savedBinds) do
			if bindings[name] then
				-- Convert saved key names back to KeyCode enums
				local resolved = {}
				for _, keyName in ipairs(keys) do
					local s, kc = pcall(function() return Enum.KeyCode[keyName] end)
					if s and kc then resolved[#resolved + 1] = kc end
				end
				if #resolved > 0 then
					bindings[name].Keys = resolved
				end
			end
		end
	end
end

--- Register a keybind action
-- @param name: unique action identifier (e.g. "Explorer.Toggle")
-- @param data: {Keys, Category, Description, Callback}
function Keybinds.Register(name, data)
	bindings[name] = {
		Name = name,
		Keys = data.Keys or {},
		Category = data.Category or "General",
		Description = data.Description or name,
		Callback = data.Callback or function() end,
		Enabled = data.Enabled ~= false,
	}
end

--- Unregister a keybind
function Keybinds.Unregister(name)
	bindings[name] = nil
end

--- Rebind an action to new keys
-- @return: true if successful, false + conflict name if conflict detected
function Keybinds.Rebind(name, newKeys)
	-- Check for conflicts
	for otherName, other in pairs(bindings) do
		if otherName ~= name and other.Enabled then
			-- Conflict if keys are identical
			if #other.Keys == #newKeys then
				local match = true
				for i, k in ipairs(newKeys) do
					if other.Keys[i] ~= k then match = false; break end
				end
				if match then
					return false, otherName
				end
			end
		end
	end
	
	local binding = bindings[name]
	if not binding then return false, "NOT_FOUND" end
	
	binding.Keys = newKeys
	
	-- Persist
	Keybinds.Save()
	return true
end

--- Force rebind (override conflicts)
function Keybinds.ForceRebind(name, newKeys)
	local binding = bindings[name]
	if not binding then return false end
	binding.Keys = newKeys
	Keybinds.Save()
	return true
end

--- Enable/disable a specific binding
function Keybinds.SetEnabled(name, state)
	if bindings[name] then
		bindings[name].Enabled = state
	end
end

--- Enable/disable entire keybind system
function Keybinds.SetGlobalEnabled(state)
	enabled = state
end

--- Get binding info
function Keybinds.GetBinding(name)
	return bindings[name]
end

--- Get all bindings grouped by category
function Keybinds.GetAll()
	local categories = {}
	for name, binding in pairs(bindings) do
		local cat = binding.Category
		if not categories[cat] then categories[cat] = {} end
		categories[cat][#categories[cat] + 1] = {
			Name = name,
			Keys = binding.Keys,
			KeyString = keysToString(binding.Keys),
			Description = binding.Description,
			Enabled = binding.Enabled,
		}
	end
	-- Sort within categories
	for _, list in pairs(categories) do
		table.sort(list, function(a, b) return a.Description < b.Description end)
	end
	return categories
end

--- Get display string for a keybind
function Keybinds.GetKeyString(name)
	local binding = bindings[name]
	if not binding then return "" end
	return keysToString(binding.Keys)
end

--- Find conflicts for a set of keys
function Keybinds.FindConflicts(keys, excludeName)
	local conflicts = {}
	for name, binding in pairs(bindings) do
		if name ~= excludeName and binding.Enabled and #binding.Keys == #keys then
			local match = true
			for i, k in ipairs(keys) do
				if binding.Keys[i] ~= k then match = false; break end
			end
			if match then
				conflicts[#conflicts + 1] = name
			end
		end
	end
	return conflicts
end

--- Save all bindings to settings
function Keybinds.Save()
	if not Settings then return end
	local serialized = {}
	for name, binding in pairs(bindings) do
		local keyNames = {}
		for _, key in ipairs(binding.Keys) do
			keyNames[#keyNames + 1] = key.Name
		end
		serialized[name] = keyNames
	end
	Settings.Set("Keybinds", serialized, false)
end

--- Reset all bindings to defaults (requires re-registration)
function Keybinds.ResetAll()
	-- Clear saved
	if Settings then
		Settings.Set("Keybinds", nil, false)
	end
end

--- Cleanup
function Keybinds.Destroy()
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}
	keyState = {}
end

return Keybinds
