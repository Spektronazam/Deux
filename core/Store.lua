-- Store: shared state + pub/sub bus that lets modules talk without depending on each other.

local Store = {}

local state = {}
local stateSubscribers = {} -- key -> {callback, ...}
local wildcardSubscribers = {} -- any state change
local eventHandlers = {} -- eventName -> {callback, ...}
local history = {} -- {key, oldVal, newVal, timestamp}
local MAX_HISTORY = 100

-- Set state. Pass silent=true to skip subscriber notification (initial sync, etc.).
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

function Store.Get(key)
	return state[key]
end

function Store.GetMany(...)
	local results = {}
	for _, key in ipairs({...}) do
		results[#results + 1] = state[key]
	end
	return unpack(results)
end

function Store.Has(key)
	return state[key] ~= nil
end

function Store.Delete(key)
	Store.Set(key, nil)
end

-- Watch a single key. Returns an unsubscribe function.
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

-- Watch every key.
function Store.SubscribeAll(callback)
	table.insert(wildcardSubscribers, callback)
	return function()
		local idx = table.find(wildcardSubscribers, callback)
		if idx then table.remove(wildcardSubscribers, idx) end
	end
end

-- Events: fire-and-forget signals between modules.

-- Listen for a named event. Returns an unsubscribe function.
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

-- Fire an event. Args go to every listener.
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

-- Request/reply: returns the first non-nil value any handler produces.
function Store.Request(event, ...)
	local handlers = eventHandlers[event]
	if not handlers then return nil end
	
	for _, cb in ipairs(handlers) do
		local result = cb(...)
		if result ~= nil then return result end
	end
	return nil
end

-- Selection bus: shorthand for the most-shared piece of state.

function Store.SetSelection(instances)
	if type(instances) ~= "table" then
		instances = {instances}
	end
	Store.Set("selection", instances)
end

function Store.GetSelection()
	return state.selection or {}
end

function Store.AddToSelection(instance)
	local sel = Store.GetSelection()
	if not table.find(sel, instance) then
		local newSel = {unpack(sel)}
		newSel[#newSel + 1] = instance
		Store.Set("selection", newSel)
	end
end

function Store.RemoveFromSelection(instance)
	local sel = Store.GetSelection()
	local idx = table.find(sel, instance)
	if idx then
		local newSel = {unpack(sel)}
		table.remove(newSel, idx)
		Store.Set("selection", newSel)
	end
end

function Store.ClearSelection()
	Store.Set("selection", {})
end

function Store.ToggleSelection(instance)
	local sel = Store.GetSelection()
	if table.find(sel, instance) then
		Store.RemoveFromSelection(instance)
	else
		Store.AddToSelection(instance)
	end
end

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

-- Undo the last state change for a key
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

-- Cleanup

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
