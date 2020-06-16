local defaultBase = {
    new = function() return {} end,
    __call = function(self, ...) return self.new(...) end
}

function class(base)
    base = base or defaultBase
    local newclass = setmetatable({}, base)
    newclass.__index = newclass
    newclass.__call = function(self, ...) return self.new(...) end
    newclass.construct = function(self, ...) end
    newclass.new = function(...)
        local inst = setmetatable(base.new(...), newclass)
        newclass.construct(inst, ...)
        return inst
    end
    newclass.istype = function(class)
		return class == newclass
	end
    newclass.super = base
	newclass.type = newclass
    return newclass
end
