local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local While = require "actions/While"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Telegraph = require "data/monsters/actions/Telegraph"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

return function(self, target)
	local spriteName
	if GameState:isEquipped("rotor", ItemType.Weapon, "Hammer") then
		spriteName = "hammer"
	elseif GameState:isEquipped("rotor", ItemType.Weapon, "Wrench") then
		spriteName = "wrench"
	else
		return Telegraph(self, "No weapon equipped...", {255,255,255,50})
	end
	local wrench = SpriteNode(
		self.scene,
		Transform.from(self.sprite.transform),
		{255,255,255,255},
		spriteName,
		nil,
		nil,
		"ui"
	)
	wrench.transform.ox = wrench.w/2
	wrench.transform.oy = wrench.h/2
	wrench.transform.angle = math.pi / 6
	wrench.transform.x = wrench.transform.x + 49 - wrench.w/2
	wrench.transform.y = wrench.transform.y + 42 - wrench.h/2

	local xform = Transform.from(self.sprite.transform)
	xform.x = xform.x + self.sprite.w/2
	xform.y = xform.y - self.sprite.h/2
	xform.sx = 4
	xform.sy = 4
	self.throwImg = SpriteNode(self.scene, xform, nil, "pressx", nil, nil, "ui")
	self.throwImg:setAnimation("idle")
	self.throwImg.color[4] = 0
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "prethrow"),
		Telegraph(self, "Press and hold x...", {255,255,255,50}),
		Ease(self.throwImg.color, 4, 255, 2),
		YieldUntil(function() return love.keyboard.isDown("x") end),
		Do(function() self.throwImg:setAnimation("hold") end),
		YieldUntil(function() return not love.keyboard.isDown("x") end),
		Do(function()
			self.throwImg:stopAnimation()
			self.releaseVal = self.throwImg:getFrame()
			if self.releaseVal > 14 then
				self.scene.audio:playSfx("levelup")
			elseif self.releaseVal > 9 then
				self.scene.audio:playSfx("choose")
			else
				self.scene.audio:playSfx("error")
			end
		end),
		Animate(self.sprite, "throw", true),
		-- Fade pressx button
		Spawn(Serial {
			Parallel {
				Ease(self.throwImg.transform, "sx", 5, 8),
				Ease(self.throwImg.transform, "sy", 5, 8)
			},
			Parallel {
				Ease(self.throwImg.transform, "sx", 4, 8),
				Ease(self.throwImg.transform, "sy", 4, 8),
				Ease(self.throwImg.color, 4, 0, 2)
			},
		}),
		Parallel {
			Ease(wrench.transform, "x", self.sprite.transform.x + 32 - wrench.w, 7, "linear"),
			Ease(wrench.transform, "y", self.sprite.transform.y - wrench.h, 7, "linear"),
			Ease(wrench.transform, "angle", math.pi / 2, 7, "linear")
		},
		Parallel {
			Ease(wrench.transform, "x", self.sprite.transform.x - wrench.w * 2, 7, "linear"),
			Ease(wrench.transform, "y", self.sprite.transform.y + 12 - wrench.h, 7, "linear"),
			Ease(wrench.transform, "angle", math.pi / 6, 7, "linear"),
		},
		
		Parallel {
			Ease(wrench.transform, "x", target.sprite.transform.x, 5, "linear"),
			Ease(wrench.transform, "y", target.sprite.transform.y, 5, "linear"),
			Ease(wrench.transform, "angle", -math.pi * 3.25, 5, "linear")
		},
		
		-- Smack and bounce off
		Do(function()
			local attack = self.stats.attack
			if self.releaseVal > 14 then
				attack = self.stats.attack * 2   -- good
			elseif self.releaseVal > 9 then
				attack = self.stats.attack * 1.5 -- mid
			end
			Executor(self.scene):act(target:takeDamage({attack = attack, speed = 100, luck = 0}))
		end),
		Parallel {
			Ease(wrench.transform, "x", target.sprite.transform.x + 60, 4, "linear"),
			Ease(wrench.transform, "y", target.sprite.transform.y - 60, 4, "linear"),
			Ease(wrench.transform, "sx", 3, 4, "linear"),
			Ease(wrench.transform, "sy", 3, 4, "linear"),
			Ease(wrench.transform, "angle", -math.pi * 3.25 + math.pi, 4, "linear"),
			Ease(wrench.color, 4, 0, 4, "linear"),
			Animate(self.sprite, "idle")
		},
		Do(function()
			wrench:remove()
		end),
		Wait(2)
	}
end
