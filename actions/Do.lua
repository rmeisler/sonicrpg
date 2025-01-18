local Do = class(require "actions/Action")

function Do:construct(fun, passive)
	self.fun = fun
	self.done = false
	self.isPassive = passive == nil or passive
	self.type = "Do"
end

function Do:update(dt)
	self.fun(self.parentAction)
	self.done = true
end

function Do:isDone()
	return self.done
end

function Do:setScene(scene)
	self.scene = scene
end

function Do:reset()
	self.done = false
end


return Do
