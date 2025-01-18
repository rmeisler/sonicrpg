local Do = require "actions/Do"
local Parallel = class(require "actions/Action")

function Parallel:construct(animations, tag)
	self.animations = animations
	self.done = false
	self.tag = tag
	self.type = "Parallel"
end

function Parallel:update(dt)
	for k,v in pairs(self.animations) do
		if self.scene and not v.scene then
			v:setScene(self.scene)
			v.scene = self.scene
			v.parentAction = self
		end

		if not v:isDone() or v.isPassive then
			v:update(dt)
		end
	end
	
	self.scene = nil
end

function Parallel:setScene(scene)
	self.scene = scene
end

function Parallel:inject(scene, action)
	action:setScene(scene)
	table.insert(self.animations, action)
end

function Parallel:add(scene, action)
	action:setScene(scene)
	table.insert(self.animations, action)
end

function Parallel:reset()
	for k,v in pairs(self.animations) do
		v:reset()
	end
	self.done = false
end

function Parallel:cleanup(scene)
	for k,v in pairs(self.animations) do
		v:cleanup(scene)
	end
end

function Parallel:isDone()
	if self.done then
		return true
	end
	local done = true
	for k,v in pairs(self.animations) do
		done = done and v:isDone()
	end
	self.done = done
	if self.done then
		self:invoke("done")
	end
	return self.done
end


return Parallel
