local Action = require "actions/Action"
local IfElse = class(Action)

function IfElse:construct(cond, ifTrue, ifFalse)
	self.cond = cond
	self.ifTrue = ifTrue or Action()
	self.ifFalse = ifFalse or Action()

	self.type = "IfElse"
end

function IfElse:update(dt)
	if self.cond() then
		self.ifTrue:update(dt)
	else
		self.ifFalse:update(dt)
	end
end

function IfElse:setScene(scene)
	self.ifTrue:setScene(scene)
	self.ifFalse:setScene(scene)
end

function IfElse:isDone()
	return true
end

function IfElse:cleanup(scene)
	self.ifTrue:cleanup(scene)
	self.ifFalse:cleanup(scene)
end

function IfElse:reset()
	self.ifTrue:reset()
	self.ifFalse:reset()
end


return IfElse
