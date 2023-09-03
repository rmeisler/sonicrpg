local Spawn = class(require "actions/Action")

local Executor = require "actions/Executor"

function Spawn:construct(action, passive)
	self.action = action
	self.done = false
	self.isPassive = passive == nil or passive
	self.type = "Spawn"
end

function Spawn:update(dt)
	-- Important to call in update
	if type(self.action) == "function" then
		self.action = self.action()
	end
	Executor(self.scene):act(self.action)
	self.done = true
end

function Spawn:setScene(scene)
	self.scene = scene
end

function Spawn:reset()
	self.done = false
end

function Spawn:isDone()
	return self.done
end


return Spawn
