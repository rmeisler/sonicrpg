local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

return function(self, target)
	target.malfunctioningTurns = 3
	return Serial {
		Animate(self.sprite, "nichole_start"),
		Animate(self.sprite, "nichole_idle"),
		
		MessageBox {
			message="Nicole: Uploading bugs into "..target.name.."'s software...",
			rect=MessageBox.HEADLINER_RECT,
			sfx="nichole",
			closeAction=Wait(0.6)
		},
		
		PlayAudio("sfx", "nicholescan", 1.0, true),
		-- Parallax over enemy
		Do(function()
			target:getSprite():setParallax(2)
		end),
		Wait(1.6),
		Do(function()
			target:getSprite():removeParallax()
		end),
		
		Parallel {
			Animate(function()
				local xform = Transform(
					target.sprite.transform.x - 50,
					target.sprite.transform.y - 50,
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
		target:takeDamage({attack = self.stats.focus, speed = 100, luck = 0}),
		
		MessageBox {
			message=target.name.." is malfunctioning!",
			rect=MessageBox.HEADLINER_RECT,
			closeAction=Wait(0.6)
		},
		
		Animate(self.sprite, "nichole_retract"),
		Animate(self.sprite, "idle"),
	}
end