local Repeat = class(require "actions/Action")

function Repeat:construct(action, times, blocking)
	self.action = action
	if type(times) == "function" then
		self.timesFn = times
	else
		self.times = times or 1000000
	end
	self.isPassive = blocking == false
	self.iteration = 0
	self.type = "Repeat"
end

function Repeat:update(dt)
	if self:isDone() and not self.isPassive then
		return
	end
	self.action:update(dt)
	if self.action:isDone() and self.iteration < self.times then
		self.iteration = self.iteration + 1
		self.action:reset()
	end
end

function Repeat:setScene(scene)
	self.action:setScene(scene)
	if self.timesFn then
		self.times = self.timesFn()
	end
end

function Repeat:reset()
	self.iteration = 0
end

function Repeat:stop()
	self.iteration = self.times
end

function Repeat:isDone()
	return self.iteration >= self.times or self.isPassive
end


return Repeat
