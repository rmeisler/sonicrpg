local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"

local Telegraph = require "data/monsters/actions/Telegraph"

return function(self, target)
	target.targetOverride = self
	return Serial {
		Telegraph(self, self.name .. ": I will protect you.", {255,255,255,50}),
		Animate(target.sprite, "victory"),
		Wait(0.5),
		Animate(target.sprite, "idle"),
	}
end