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
	target.lostTurns = 1
	target.lostTurnType = "interrupt"
	return Serial {
		Animate(self.sprite, "nichole_start"),
		Animate(self.sprite, "nichole_idle"),
		
		MessageBox {
			message="Nicole: Executing hardware interrupt for "..target.name.."...",
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
		target:takeDamage({attack = 10, speed = 0, luck = 0}),
		
		MessageBox {
			message=target.name.." can't move!",
			rect=MessageBox.HEADLINER_RECT,
			closeAction=Wait(0.6)
		},
		
		Animate(self.sprite, "nichole_retract"),
		Animate(self.sprite, "idle"),
	}
end