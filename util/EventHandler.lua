local EventHandler = class()

function EventHandler:construct()
	self.handlers = {}
	self.focusStack = {}
	self.children = {}
end

function EventHandler:addHandler(type, func, obj, ...)
    if not self.handlers[type] then
        self.handlers[type] = {}
    end
    local index = tostring(obj)..tostring(func)
    self.handlers[type][index] = {func,obj,{...}}
end

function EventHandler:removeHandler(type, func, obj)
    if not self.handlers[type] then
        return
    end
    local index = tostring(obj)..tostring(func)
    self.handlers[type][index] = nil
end

function EventHandler:addChild(child)
	self.children[tostring(child)] = child
	child.parent = self
end

function EventHandler:removeChild(child)
    self.children[tostring(child)].parent = nil
    self.children[tostring(child)] = nil
end

function EventHandler:focus(type, obj)
	if not self.focusStack[type] then
		self.focusStack[type] = {}
	end
    table.insert(self.focusStack[type], 1, obj)
end

function EventHandler:unfocus(type)
	table.remove(self.focusStack[type], 1)
end

function EventHandler:invoke(type, ...)
    if not self.handlers[type] then
        return
    end

	-- Capture the state of the focus stack before invocation
	local focused = table.clone(self.focusStack[type] or {})
	local outside = {...}
	local handlers = table.clone(self.handlers[type])
    for index, tuple in pairs(handlers) do
        local func, obj, args = unpack(tuple)
		local argsCopy = table.clone(args)
		-- Add outside args to bound args
		for k,v in pairs(outside) do
			table.insert(argsCopy, 1, v)
		end
		
        -- Skip over non-focused handlers
        if next(focused) == nil or focused[1] == obj or (obj and focused[1] == obj.parent) then
			local result
			if obj then
				result = func(obj,unpack(argsCopy))
			else
				result = func(unpack(argsCopy))
			end
			
			if result then
				return
			end
        end
    end
end


return EventHandler
