local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"
local Do = require "actions/Do"
local Spawn = require "actions/Spawn"
local BouncyText = require "actions/BouncyText"
local While = require "actions/While"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SmackPositions = {
	{-5, 0},
	{10, -5},
	{-7, 3},
	{7, -3},
	{-5, 5},
	{5, 0}
}

local KnockbackFunction = function(target)
	local targetSp = target:getSprite()
	return Serial {
		PlayAudio("sfx", "smack", nil, true),
		Ease(targetSp.transform, "x", target.origX - 20, 30, "linear"),
		Ease(targetSp.transform, "x", target.origX, 30, "linear")
	}
end

local PunchTimer = function(self, dt)
	if self.punchtime > 0 then
		self.punchtime = self.punchtime - dt
	end
end

local PummelTrigger = function(self, key, _, target)
	if key == "x" and self.punchtime <= 0 then
		self.punchtime = 0.1
		
		if not target.origX then
			target.origX = target:getSprite().transform.x
		end

		local stats = {attack=math.max(1, self.stats.attack/3), luck=self.stats.luck, speed=self.stats.speed}
		local damage = target:calculateDamage(stats)
		target.hp = math.max(0, target.hp - damage)
		
		local damageText = tostring(damage)
		local damageTextColor = {255,0,0,255}
		if stats.miss then
			damageText = "miss"
			damageTextColor = {255,255,255,255}
		end

		self.scene.audio:stopSfx()
		self.scene.audio:playSfx("smack")
		
		local targetSp = target.sprite
		self.scene:run(Spawn(Parallel {
			Animate(function()
				local xform = Transform.from(targetSp.transform)
				local offset = table.remove(SmackPositions)
				xform.x = xform.x + offset[1]
				xform.y = xform.y + offset[2]
				table.insert(SmackPositions, 1, offset) -- Rotate to the front
				return SpriteNode(target.scene, xform, nil, "smack", nil, nil, "ui"), true
			end, "idle"),
			BouncyText(
				Transform(
					target.origX + (target.mockSprite and (target.textOffset.x + target.sprite.w) or (target.textOffset.x - 50)),
					targetSp.transform.y + target.textOffset.y
				),
				damageTextColor,
				FontCache.ConsolasLarge,
				damageText,
				6,
				false,
				true -- outline
			),
			KnockbackFunction(target)
		}))
	end
end

local LeapForward = function(self, target)
	local targetSp = target.sprite
	return Serial {
		Animate(self.sprite, "leap", true),
		Parallel {
			Ease(self.sprite.transform, "x", targetSp.transform.x + math.abs(targetSp.transform.x - self.sprite.transform.x)/2, 4, "linear"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y - self.sprite.h * 2, 6, "linear"),
		},
		Parallel {
			Ease(self.sprite.transform, "x", targetSp.transform.x + targetSp.w, 4, "linear"),
			Ease(self.sprite.transform, "y", targetSp.transform.y + targetSp.h - self.sprite.h + 1, 4, "linear")
		}
	}
end

local LeapBackward = function(self, target)
	local targetSp = target.sprite
	return Serial {
		Ease(self.sprite.transform, "x", targetSp.transform.x + targetSp.w - 5, 1),
		
		-- Leap backward
		Animate(self.sprite, "leap", true),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 3),
			Serial {
				Ease(self.sprite.transform, "y", targetSp.transform.y - self.sprite.h * 2, 4),
				Ease(self.sprite.transform, "y", self.sprite.transform.y, 6)
			}
		},
			
		Animate(self.sprite, "crouch"),
		Wait(0.2),
		Animate(self.sprite, "idle", false, {}, false)
	}
end

return function(self, target)
	self.donepunching = false
	return Serial {
		LeapForward(self, target),
		
		Do(function()
			self.punchtime = 0
			self.scene:addHandler("update", PunchTimer, self)
			self.scene:addHandler("keytriggered", PummelTrigger, self, target)
			self.scene:focus("keytriggered", self) -- HACK, focus past skills + battle menu
			self.scene:focus("keytriggered", self)
			self.scene:focus("keytriggered", self)
		end),
		
		-- Punching!
		Do(function()
			self.sprite:setAnimation("pummel")
		end),
		
		Wait(0.1),

		Animate(function()
			local xform = Transform.from(self.sprite.transform)
			xform.y = xform.y - self.sprite.h
			return SpriteNode(self.scene, xform, nil, "pressx", nil, nil, "ui"), true
		end, "rapidly2"),
		
		-- Remove temporary keytriggered event
		Do(function()
			self.scene:removeHandler("update", PunchTimer, self)
			self.scene:removeHandler("keytriggered", PummelTrigger, self, target)
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
		end),
		
		Do(function()
			if target.hp <= 0 then
				Executor(self.scene):act(target:die())
			end
		end),
		Parallel {
			Ease(target:getSprite().transform, "x", target:getSprite().transform.x, 20, "quad"),
			LeapBackward(self, target)
		}
	}
end
