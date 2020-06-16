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
		Animate(self.sprite, "nichole_start"),
		Animate(self.sprite, "nichole_idle"),
		
		MessageBox {
			message="Nicole: Running program \"X\"...",
			rect=MessageBox.HEADLINER_RECT,
			sfx="nichole",
			closeAction=Wait(0.6)
		},
		
		Parallel {
			Animate(function()
				local xform = Transform(
					target.sprite.transform.x - target.sprite.w,
					target.sprite.transform.y - target.sprite.h,
					2,
					2
				)
				return SpriteNode(self.scene, xform, nil, "lightning", nil, nil, "ui"), true
			end, "idle"),
			
			Serial {
				Wait(0.2),
				PlayAudio("sfx", "shocked", 0.5, true),
			}
		},
		target:takeDamage({attack = self.stats.focus, speed = self.stats.speed, luck = self.stats.luck}),
		Animate(self.sprite, "nichole_retract"),
		Animate(self.sprite, "idle"),
	}
end