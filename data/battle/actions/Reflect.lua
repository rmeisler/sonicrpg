local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local Do = require "actions/Do"
local Action = require "actions/Action"
local BouncyText = require "actions/BouncyText"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"
local SpriteNode = require "object/SpriteNode"

local PressZ = require "data/battle/actions/PressZ"

return function(self, target)
	if not self.beamSprite and not self.beamSpriteLeft and not self.beamSpriteRight then
		return Action()
	end
	
	local reflectAction = Action()
	if self.beamSprite then
		reflectAction = Serial {
			Ease(self.beamSprite.transform, "sx", function() return self.len end, 8),
			Animate(target.sprite, "idle"),
			Do(function()
				self.beamSprite.transform.ox = 0
				
				self.beamSprite.transform.x = self.beamSprite.transform.x - self.xDist
				self.beamSprite.transform.y = self.beamSprite.transform.y - self.yDist
			end),
			Ease(self.beamSprite.transform, "sx", 0, 8)
		}
	elseif self.beamSpriteLeft and self.beamSpriteRight then
		reflectAction = Serial {
			Parallel {
				Ease(self.beamSpriteLeft.transform, "sx", function() return self.len end, 8),
				Ease(self.beamSpriteRight.transform, "sx", function() return self.len end, 8)
			},
			Animate(target.sprite, "idle"),
			Do(function()
				self.beamSpriteLeft.transform.ox = 0
				self.beamSpriteRight.transform.ox = 0
				
				self.beamSpriteLeft.transform.x = self.beamSpriteLeft.transform.x - self.xDist
				self.beamSpriteLeft.transform.y = self.beamSpriteLeft.transform.y - self.yDist
				self.beamSpriteRight.transform.x = self.beamSpriteRight.transform.x - self.xDist
				self.beamSpriteRight.transform.y = self.beamSpriteRight.transform.y - self.yDist
			end),
			Parallel {
				Ease(self.beamSpriteLeft.transform, "sx", 0, 8),
				Ease(self.beamSpriteRight.transform, "sx", 0, 8)
			}
		}
	end
	
	return PressZ(
		self,
		target,
		Serial {
			PlayAudio("sfx", "pressx", 1.0, true),
			Do(function()
				target.dodged = true
			end),
			Animate(target.sprite, "block"),
			Animate(function()
				local xform = Transform(
					target.sprite.transform.x - 20,
					target.sprite.transform.y,
					4,
					4
				)
				return SpriteNode(target.scene, xform, nil, "sparkle", nil, nil, "ui"), true
			end, "idle"),

			reflectAction,

			self.hasShield and
				self.shieldAction(self, target) or
				self:takeDamage({attack=self.stats.attack, speed=100, luck=self.stats.luck}, true, BattleActor.shockKnockback)
		},
		Serial {
			Do(function() end)
		}
	)
end
