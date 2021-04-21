local Transform = class()

-- Helpers for Transform.relative
local mul = function(a, b) return a*b end
local add = function(a, b) return a+b end
local op = {x=add, y=add, sx=mul, sy=mul, angle=add, ox=add, oy=add, shx=mul, shy=mul}

function Transform:construct(x, y, sx, sy, angle)
	self.x = x or 0
	self.y = y or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.angle = angle or 0
	self.shx = 0
	self.shy = 0
	self.ox = 0
	self.oy = 0
end

-- Transform for viewspace (no add) vs transform from sprite space
-- (add translate 400,300, scale 2,2)

function Transform.from(xform)
	return Transform(xform.x, xform.y, xform.sx, xform.sy, xform.angle)
end

function Transform.relative(transform, offset)
    return setmetatable({},
		{
			-- Setter, appends offset
		    __newindex = function(t, k, v)
			    transform[k] = v - offset[k]
			end,
			-- Getter, appends offset
		    __index = function(t, k)
			    return op[k](transform[k], offset[k])
			end
		}
	)
end


return Transform