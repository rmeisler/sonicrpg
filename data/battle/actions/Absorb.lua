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
	local reducedDmgStats = table.clone(self.stats)
	reducedDmgStats.attack = reducedDmgStats.attack/2
	return PressZ(
		self,
		target,
		Serial {
			PlayAudio("sfx", "pressx", 1.0, true),
			Do(function()
				target.dodged = true
				target.sprite:pushOverride("hurt", "idle")
			end),
			Animate(function()
				local xform = Transform(
					target.sprite.transform.x - 20,
					target.sprite.transform.y,
					4,
					4
				)
				return SpriteNode(target.scene, xform, nil, "sparkle", nil, nil, "ui"), true
			end, "idle"),
			target:takeDamage(reducedDmgStats, true, BattleActor.shockKnockback),
			Do(function()
				target.sprite:popOverride("hurt")
				if target.hp <= 0 then
					target.sprite:setAnimation("dead")
				else
					target.sprite:setAnimation("idle")
				end
			end)
		},
		Do(function() end)
	)
end
