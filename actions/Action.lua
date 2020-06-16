local Action = class(require "util/EventHandler")

function Action:construct()
	self.type = "Action"
end

function Action:update(dt)
	
end

function Action:isDone()
	return true
end

function Action:setScene(scene)
	self.scene = scene
end

function Action:cleanup(scene)

end

function Action:reset()
	self.done = false
end


return Action
