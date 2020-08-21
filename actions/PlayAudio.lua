local PlayAudio = class(require "actions/Action")

function PlayAudio:construct(stype, name, volume, isPassive, loop, stopCurrent)
	self.stype = stype
	self.name = name
	self.volume = volume
	self.isPassive = isPassive or false
	self.loop = loop or false
	self.stopCurrent = stopCurrent
	self.done = false
	self.type = "PlayAudio"
end

function PlayAudio:update(dt)
	-- Noop
end

function PlayAudio:setScene(scene)
	self.scene = scene
	if scene.audio:getVolumeFor(self.stype, self.name) == 0 then
		self.done = true
	else
		scene.audio:play(self.stype, self.name, self.volume, self.stopCurrent)
		if self.loop then
			scene.audio:setLooping(self.stype, self.loop)
		else
			scene.audio:setLooping(self.stype, false)
		end
	end
end

function PlayAudio:isDone()
	if self.done or self.isPassive then
		return true
	elseif self.scene.audio:isFinished(self.stype) then
		self.done = true
		return true
	else
		return false
	end
end

function PlayAudio:reset()
	self.done = false
	self:setScene(self.scene)
end


return PlayAudio
