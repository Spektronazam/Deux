--[[
	Deux Core :: Store
	Pub/Sub State Store for Cross-Module Communication
	
	Features:
	- Central state container shared across all modules
	- Publish/subscribe with key-pattern matching
	- Selection bus (Explorer, Properties, ScriptEditor all share "currentSelection")
	- Event system for one-off signals (e.g. "navigate_to_instance")
	- State history for undo support
	
	Usage:
		local Store = require("core/Store")
		Store.Set("selection", {instance1, instance2})
		Store.Subscribe("selection", function(newVal, oldVal) ... end)
		Store.On("navigate", function(target) Explorer.ScrollTo(target) end)
		Store.Emit("navigate", someInstance)
]]

local Store = {}

------------------------------------------------------------------------
-- INTERNAL STATE
------------------------------------------------------------------------
local state = {}
local stateSubscribers = {} -- key -> {callback, ...}
local wildcardSubscribers = {} -- any state change
local eventHandlers = {} -- eventName -> {callback, ...}
local history = {} -- {key, oldVal, newVal, timestamp}
local MAX_HISTORY = 100

------------------------------------------------------------------------
-- STATE MANAGEMENT
------------------------------------------------------------------------

--- Set a state value
-- @param key: state key (e.g. "selection", "activeScript", "hoveredInstance")
-- @param value: any value
-- @param silent: if true, don't notify subscribers
function Store.Set(key, value, silent)
	local old = state[key]
	if old == value then return end -- no change
	
	state[key] = value
	
	-- Record history
	history[#history + 1] = {
		Key = key,
		OldValue = old,
		NewValue = value,
		Time = tick(),
	}
	if #history > MAX_HISTORY then
		table.remove(history, 1)
	end
	
	if silent then return end
	
	-- Notify key-specific subscribers
	local subs = stateSubscribers[key]
	if subs then
		for _, cb in ipairs(subs) do
			task.spawn(cb, value, old, key)
		end
	end
	
	-- Notify wildcard subscribers
	for _, cb in ipairs(wildcardSubscribers) do
		task.spawn(cb, key, value, old)
	end
end

--- Get a state value
function Store.Get(key)
	return state[key]
end

--- Get multiple state values
function Store.GetMany(...)
	local results = {}
	for _, key in ipairs({...}) do
		results[#results + 1] = state[key]
	end
	return unpack(results)
end

--- Check if a key exists
function Store.Has(key)
	return state[key] ~= nil
end

--- Delete a state key
function Store.Delete(key)
	Store.Set(key, nil)
end

--- Subscribe to state changes for a specific key
-- @param key: the state key to watch
-- @param callback: function(newValue, oldValue, key)
-- @return: unsubscribe function
function Store.Subscribe(key, callback)
	if not stateSubscribers[key] then
		stateSubscribers[key] = {}
	end
	table.insert(stateSubscribers[key], callback)
	
	return function()
		local list = stateSubscribers[key]
		if list then
			local idx = table.find(list, callback)
			if idx then table.remove(list, idx) end
		end
	end
end

--- Subscribe to all state changes
-- @param callback: function(key, newValue, oldValue)
-- @return: unsubscribe function
function Store.SubscribeAll(callback)
	table.insert(wildcardSubscribers, callback)
	return function()
		local idx = table.find(wildcardSubscribers, callback)
		if idx then table.remove(wildcardSubscribers, idx) end
	end
end

------------------------------------------------------------------------
-- EVENT SYSTEM (fire-and-forget signals between modules)
------------------------------------------------------------------------

--- Register a handler for a named event
-- @param event: event name (e.g. "navigate", "open_script", "show_properties")
-- @param callback: function(...args)
-- @return: unsubscribe function
function Store.On(event, callback)
	if not eventHandlers[event] then
		eventHandlers[event] = {}
	end
	table.insert(eventHandlers[event], callback)
	
	return function()
		local list = eventHandlers[event]
		if list then
			local idx = table.find(list, callback)
			if idx then table.remove(list, idx) end
		end
	end
end

--- Emit a named event to all handlers
-- @param event: event name
-- @param ...: arguments passed to all handlers
function Store.Emit(event, ...)
	local handlers = eventHandlers[event]
	if not handlers then return end
	
	local args = {...}
	for _, cb in ipairs(handlers) do
		task.spawn(function()
			cb(unpack(args))
		end)
	end
end

--- Emit and wait for first response (request-reply pattern)
-- @param event: event name
-- @param ...: arguments
-- @return: first non-nil return value from handlers
function Store.Request(event, ...)
	local handlers = eventHandlers[event]
	if not handlers then return nil end
	
	for _, cb in ipairs(handlers) do
		local result = cb(...)
		if result ~= nil then return result end
	end
	return nil
end

------------------------------------------------------------------------
-- SELECTION BUS (convenience for the most common cross-module state)
------------------------------------------------------------------------

--- Set the current selection (list of instances)
function Store.SetSelection(instances)
	if type(instances) ~= "table" then
		instances = {instances}
	end
	Store.Set("selection", instances)
end

--- Get current selection
function Store.GetSelection()
	return state.selection or {}
end

--- Add to selection
function Store.AddToSelection(instance)
	local sel = Store.GetSelection()
	if not table.find(sel, instance) then
		local newSel = {unpack(sel)}
		newSel[#newSel + 1] = instance
		Store.Set("selection", newSel)
	end
end

--- Remove from selection
function Store.RemoveFromSelection(instance)
	local sel = Store.GetSelection()
	local idx = table.find(sel, instance)
	if idx then
		local newSel = {unpack(sel)}
		table.remove(newSel, idx)
		Store.Set("selection", newSel)
	end
end

--- Clear selection
function Store.ClearSelection()
	Store.Set("selection", {})
end

--- Toggle instance in selection
function Store.ToggleSelection(instance)
	local sel = Store.GetSelection()
	if table.find(sel, instance) then
		Store.RemoveFromSelection(instance)
	else
		Store.AddToSelection(instance)
	end
end

------------------------------------------------------------------------
-- HISTORY / UNDO
------------------------------------------------------------------------

--- Get state change history
function Store.GetHistory(key, limit)
	limit = limit or 20
	local filtered = {}
	for i = #history, 1, -1 do
		if not key or history[i].Key == key then
			filtered[#filtered + 1] = history[i]
			if #filtered >= limit then break end
		end
	end
	return filtered
end

--- Undo the last state change for a key
function Store.Undo(key)
	for i = #history, 1, -1 do
		if history[i].Key == key then
			Store.Set(key, history[i].OldValue)
			table.remove(history, i)
			return true
		end
	end
	return false
end

------------------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------------------

function Store.Reset()
	state = {}
	history = {}
end

function Store.Destroy()
	state = {}
	stateSubscribers = {}
	wildcardSubscribers = {}
	eventHandlers = {}
	history = {}
end

return Store
