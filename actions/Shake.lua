local Serial = require "actions/Serial"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Repeat = require "actions/Repeat"

local Shake = class(require "actions/Action")

function Shake:construct(obj, impact, speed, rotations)
	impact = impact or 10
	self.loop = Repeat(Serial {
		Ease(obj, "x", obj.x + impact, speed, "linear"),
		Ease(obj, "x", obj.x, speed/2)
	}, rotations)
	
	self.type = "Shake"
end

function Shake:update(dt)
	if self:isDone() then
		return
	end
	self.loop:update(dt)
end

function Shake:isDone()
	return self.loop:isDone()
end

function Shake:reset()
	self.loop:reset()
end


return Shake
