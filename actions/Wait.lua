local Wait = class(require "actions/Action")

function Wait:construct(sec)
	self.sec = tonumber(sec)
	self.elapsed = 0
	self.type = "Wait"
end

function Wait:update(dt)
	self.elapsed = self.elapsed + dt
end

function Wait:isDone()
	return self.elapsed >= self.sec
end

function Wait:reset()
	self.elapsed = 0
end


return Wait
