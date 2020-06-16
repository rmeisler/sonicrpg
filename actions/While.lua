local Action = require "actions/Action"
local While = class(Action)

function While:construct(cond, doWhile, earlyEnd)
	self.cond = cond
	self.doWhile = doWhile or Action()
	self.earlyEnd = earlyEnd or Action()
	
	self.action = self.doWhile
	self.curCond = self.cond
	self.type = "While"
end

function While:update(dt)
	if self.curCond() then
		self.action:update(dt)
	else
		self.action = self.earlyEnd
		self.curCond = function() return true end
	end
end

function While:setScene(scene)
	self.doWhile:setScene(scene)
	self.earlyEnd:setScene(scene)
end

function While:isDone()
	return self.action:isDone()
end

function While:cleanup(scene)
	self.doWhile:cleanup(scene)
	self.earlyEnd:cleanup(scene)
end

function While:reset()
	self.doWhile:reset()
	self.earlyEnd:reset()
	self.action = self.doWhile
	self.curCond = self.cond
end


return While
