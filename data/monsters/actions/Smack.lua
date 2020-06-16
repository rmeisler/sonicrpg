local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local OnHitEvent = require "data/battle/actions/OnHitEvent"

return function(self, target)
	return Serial {
		Parallel {
			-- Play smack animation
			Animate(function()
				local xform = Transform(
					target.sprite.transform.x,
					target.sprite.transform.y,
					2,
					2
				)
				return SpriteNode(self.scene, xform, nil, "smack", nil, nil, "ui"), true
			end, "idle"),

			Serial {
				Wait(0.1),
				PlayAudio("sfx", target.hurtSfx, 0.5, true),
				OnHitEvent(self, target)
			}
		}
	}
end
