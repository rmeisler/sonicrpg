local Action = require "actions/Action"
local IfElse = class(Action)

function IfElse:construct(cond, ifTrue, ifFalse)
	self.cond = cond
	self.ifTrue = ifTrue or Action()
	self.ifFalse = ifFalse or Action()
	self.choseAction = nil

	self.type = "IfElse"
end

function IfElse:update(dt)
	if not self.choseAction then
		if self.cond() then
			self.choseAction = self.ifTrue
		else
			self.choseAction = self.ifFalse
		end
	end
	
	if self.choseAction then
		self.choseAction:update(dt)
	end
end

function IfElse:setScene(scene)
	self.ifTrue:setScene(scene)
	self.ifFalse:setScene(scene)
end

function IfElse:isDone()
	return self.choseAction and self.choseAction:isDone()
end

function IfElse:cleanup(scene)
	self.ifTrue:cleanup(scene)
	self.ifFalse:cleanup(scene)
end

function IfElse:reset()
	self.ifTrue:reset()
	self.ifFalse:reset()
	self.choseAction = nil
end


return IfElse
