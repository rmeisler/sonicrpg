local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

return function(self, target)
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x - 200, 5, "linear"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y - 200, 5, "linear")
		},
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x, 5, "linear"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y, 5, "linear")
		},
		Animate(self.sprite, "crouchtinker"),
		Wait(1),
		
		-- Enter code to reduce either attack, defense, or speed
	}
end