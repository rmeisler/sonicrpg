local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"
local Spawn = require "actions/Spawn"
local Action = require "actions/Action"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local LeapBackward = function(self, target)
	return Serial {
		-- Bounce off target
		Parallel {
			Ease(self.sprite.transform, "y", target.sprite.transform.y - self.sprite.h*2.5, 4, "linear"),
			Ease(self.sprite.transform, "x", target.sprite.transform.x + self.sprite.w*2, 4, "linear"),
		},
		Parallel {
			Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 4, "linear"),
			Ease(self.sprite.transform, "x", target.sprite.transform.x + self.sprite.w*3, 4, "linear")
		},
		
		-- Land on ground
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "idle"),
		Wait(0.2),
		
		-- Leap backward
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 3),
			Serial {
				Ease(self.sprite.transform, "y", self.sprite.transform.y - math.abs(target.sprite.transform.y - self.sprite.transform.y) - self.sprite.h, 4),
				Ease(self.sprite.transform, "y", self.sprite.transform.y, 6)
			}
		},
		
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "idle"),
	}
end

local ChargeSpin = function(self, key)
	if key == "x" then
		self.spinCharge = self.spinCharge + 1
		self.scene.audio:stopSfx()
		self.scene.audio:playSfx("spincharge")
		self.sprite:setAnimation("spincharge")
		Executor(self.scene):act(
			Animate(function()
				local xform = Transform.from(self.sprite.transform)
				xform.y = xform.y + self.sprite.h
				local sprite = SpriteNode(self.scene, xform, nil, "spindust", nil, nil, "ui")
				sprite.transform.y = sprite.transform.y - sprite.h*2
				return sprite, true
			end, "idle")
		)
	end
end

local SawSpark = function(self, angle, xOffset, yOffset)
	return Animate(function()
		local xform = Transform.from(self.sprite.transform)
		xform.angle = angle
		xform.ox = 8
		xform.oy = 0
		xform.x = xform.x + xOffset
		xform.y = xform.y + yOffset
		return SpriteNode(self.scene, xform, nil, "spark", nil, nil, "ui"), true
	end, "idle")
end

return function(self, target)
	return Serial {
		-- Setup temporary keytriggered event
		Animate(self.sprite, "crouch", true),
		Do(function()
			self.spinCharge = 0
			self.scene:addHandler("keytriggered", ChargeSpin, self)
			self.scene:focus("keytriggered", self) -- HACK, focus past skills + battle menu
			self.scene:focus("keytriggered", self)
			self.scene:focus("keytriggered", self)
		end),

		Parallel {
			Animate(function()
				local xform = Transform.from(self.sprite.transform)
				xform.x = xform.x + self.sprite.w
				return SpriteNode(self.scene, xform, nil, "pressx", nil, nil, "ui"), true
			end, "rapidly"),
			
			Wait(1.5),
		},

		-- Remove temporary keytriggered event
		Do(function()
			self.scene:removeHandler("keytriggered", ChargeSpin, self)
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
		end),

		Do(function()
			-- Temp storage
			self.sprite.transform.tx = self.sprite.transform.ox
			self.sprite.transform.ty = self.sprite.transform.oy
			
			self.sprite.transform.ox = self.sprite.w/2 - 1
			self.sprite.transform.oy = self.sprite.h/2 + 11
		end),

		Animate(self.sprite, "spin", true),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w, 4, "linear"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y, 6, "linear"),
		},
		
		Parallel {
			PlayAudio("sfx", "saw", 1.0, true),
			
			Ease(self.sprite.transform, "angle", -20 * 2 * math.pi, 0.5, "linear"),
			
			-- Create sparks from center of saw area and spiral outwards
			Repeat(Serial {
				SawSpark(self, -math.pi/2 + math.pi/8, -10, -30),
				SawSpark(self, math.pi/4, -15, 40),
				SawSpark(self, -math.pi/4, -10, -30),
				SawSpark(self, math.pi/4 + math.pi/8, -10, 40),
				SawSpark(self, math.pi/2 - math.pi/8, -20, 40),
				SawSpark(self, -math.pi/4 - math.pi/8, -10, -30),
			}, 4),
			
			Repeat(Serial {
				Ease(target:getSprite().transform, "x", target:getSprite().transform.x + 5, 30, "quad"),
				Ease(target:getSprite().transform, "x", target:getSprite().transform.x - 5, 30, "quad"),
			}, 25),
			
			Serial {
				Wait(0.8),
				Do(function()
					Executor(self.scene):act(
						target:takeDamage(
							{attack=math.min(self.stats.focus * self.spinCharge, 20), speed=50, luck=0},
							false,
							function(_self, _impact, _direction) return Action() end
						)
					)
				end)
			}
		},
		
		Do(function()
			self.sprite.transform.ox = self.sprite.transform.tx
			self.sprite.transform.oy = self.sprite.transform.ty
			self.sprite.transform.angle = 0
		end),
		
		Ease(target:getSprite().transform, "x", target:getSprite().transform.x, 30),

		LeapBackward(self, target),
	}
end
