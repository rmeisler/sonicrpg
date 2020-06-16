local Executor = class(require "object/SceneNode")

function Executor:construct(scene)
	self:addSceneHandler("update", Executor.update)
end

function Executor:act(action)
	if action then
		self.action = action
		self.action:setScene(self.scene)
	end
end

function Executor:update(dt)
	if not self.action then
		return
	end
	self.action:update(dt)
	if self.action:isDone() then
		self.action:cleanup(self.scene)
		self:remove()
	end
end

function Executor:isDone()
	return self.action and self.action:isDone()
end


return Executor
