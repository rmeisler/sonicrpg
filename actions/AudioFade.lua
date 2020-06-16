local Ease = require "actions/Ease"

local AudioFade = class(require "actions/Action")

function AudioFade:construct(stype, from, to, speed, func)
	self.stype = stype
	self.from = from
	self.to = to
	self.current = from
	self.speed = speed
	self.func = func
	self.type = "AudioFade"
end

function AudioFade:update(dt)
	self.ease:update(dt)
	self.scene.audio:setVolume(self.stype, self.current)
end

function AudioFade:setScene(scene)
	self.scene = scene
	self.ease = Ease(self, "current", self.to, self.speed, self.func)
end

function AudioFade:isDone()
	if self.ease then
		return self.ease:isDone()
	else
		return true
	end
end

function AudioFade:reset()
	self.ease:reset()
	self.current = self.from
end


return AudioFade
