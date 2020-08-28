local Wait = require "actions/Wait"
local Transform = require "util/Transform"
local SimpleMove = class(require "actions/Action")

function SimpleMove:construct(obj, dir, to)
	self.obj = obj
	self.dir = dir
	self.to = to
end

function SimpleMove:update(dt)
	if self.obj:isRemoved() then
		return 
	end
	
	if not self.obj.pauseMove then
		if self.dir == "left" then
			self.obj.x = self.obj.x - self.obj.movespeed * (dt/0.016)
		elseif self.dir == "right" then
			self.obj.x = self.obj.x + self.obj.movespeed * (dt/0.016)
		elseif self.dir == "up" then
			self.obj.y = self.obj.y - self.obj.movespeed * (dt/0.016)
		elseif self.dir == "down" then
			self.obj.y = self.obj.y + self.obj.movespeed * (dt/0.016)
		end
	end
end

function SimpleMove:reset()
	-- noop
end
 
function SimpleMove:isDone()
	if self.dir == "left" then
		return self.obj.x <= self.to
	elseif self.dir == "right" then
		return self.obj.x >= self.to
	elseif self.dir == "up" then
		return self.obj.y <= self.to
	elseif self.dir == "down" then
		return self.obj.y >= self.to
	end
end

 
return SimpleMove