local Fun = require "util/EasingFunctions"
local Ease = class(require "actions/Action")

APPROX_CONST = 0.99

function Ease:construct(obj, prop, to, speed, func, test)
	self.obj = obj
	self.prop = prop
	self.to = to or 0
	self.speed = speed or 1
	self.t = 0
	self.func = Fun[func or "inout"]
	self.test = test
	self.type = "Ease"
end

function Ease:update(dt)
	if self.obj == nil then
		self.t = 1.0
		return
	end
	if self.t == 0 then
		self.from = self.obj[self.prop]
	end

	self.t = self.t + dt * self.speed
	self.t = self.t >= APPROX_CONST and 1 or self.t

	local t = self.func(self.t)
	self.obj[self.prop] = (1 - t) * self.from + t * self.to
end

function Ease:setScene(scene)
	if type(self.to) == "function" then
		self.to = self.to()
	end
end

function Ease:reset()
	self.t = 0
end

function Ease:isDone()
	return self.t >= 1.0
end


return Ease
