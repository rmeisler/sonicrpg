local Animate = class(require "actions/Action")

function Animate:construct(sprite, animation, isPassive, frameActions, stopOnComplete)
	self.sprite = sprite
	self.continuousAnimation = type(self.sprite) == "table" and self.sprite.continuousAnimation or false
	self.animation = animation
	self.done = false
	self.isPassive = isPassive or self.continuousAnimation or false
	self.frameActions = frameActions or {}
	self.stopOnComplete = stopOnComplete or true
	self.tag = self.animation
	self.type = "Animate"
end

function Animate:update(dt)
	if self.continuousAnimation then
		return
	end

	local anim = self.sprite:getAnimation(self.animation)
	if not anim then
		return
	end
	local frame = anim:getCurrentFrame()
	if self.lastFrame ~= frame and (self.frameActions and self.frameActions[frame]) then
		self.scene:run(self.frameActions[frame])
	end
	self.lastFrame = frame
end

function Animate:setScene(scene)
	self.scene = scene
	
	if type(self.sprite) == "function" then
		self.sprite, self.temporary = self.sprite()
	end
	self.layerName = self.sprite.layerName
	
	self:reset()
end

function Animate:isDone()
	if self.isPassive then
		self.done = true
		if self.temporary then
			self.sprite:removeSceneNode()
		end
	end

	return self.done
end

function Animate:reset()
	self.done = false

	if self.temporary then
		self.sprite:addSceneNode(self.layerName)
	end
	self.sprite:setAnimation(self.animation)
	local anim = self.sprite:getAnimation(self.animation)
	if not anim then
		return
	end
	if not self.continuousAnimation or self.temporary then
		anim:reset()
		anim:play()
		anim.callback = function()
			self:invoke("done")
			self.done = true
			if self.stopOnComplete then
				anim:stop()
			end
			if self.temporary then
				self.sprite:removeSceneNode()
			end
			anim.callback = function() end
		end
	end
end


return Animate
