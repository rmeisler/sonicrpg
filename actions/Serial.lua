local Serial = class(require "actions/Action")

function Serial:construct(animations)
	self.index = 1
	self.isPassive = animations.isPassive
	animations.isPassive = nil
	self.animations = animations
	self.tag = tag
	self.type = "Serial"
end

function Serial:update(dt)
	local current = self.animations[self.index]
	if not current then
		return
	end
	current:update(dt)
	if current:isDone() then
		if current.isPassive and self.index == #self.animations then
			if not self.done then
				self.done = true
			end
		else
			self:next()
		end
	end
end

function Serial:setScene(scene)
	self.scene = scene
	if self.animations == nil then
		-- Edge case, we are mid destruction, leave gracefully
		self.done = true
		return
	end
	if self.animations[self.index] then
		self.animations[self.index]:setScene(scene)
	end
end

function Serial:inject(scene, action)
	self.scene = scene
	action:setScene(scene)
	table.insert(self.animations, self.index, action)
end

function Serial:add(scene, action)
	if self.index == #self.animations then
		self.scene = scene
		action:setScene(scene)
	end
	table.insert(self.animations, action)
end

function Serial:isDone()
	if self.done then
		return true
	end
	self.done = self.index > #self.animations
	if self.done then
		self:invoke("done")
	end
	return self.done
end

function Serial:next()
	self.index = self.index + 1
	local current = self.animations[self.index]
	if current then
		current:setScene(self.scene)
	end
end

function Serial:interrupt()
	while not self:isDone() do
		self:update(100)
	end
end

function Serial:stop()
	self.done = true
end

function Serial:cleanup(scene)
	for k,v in pairs(self.animations) do
		if v.cleanup then
			v:cleanup(scene)
		end
	end
end

function Serial:reset()
	self.done = false
	self.index = 1
	for k,v in pairs(self.animations) do
		v:reset()
	end
end


return Serial
