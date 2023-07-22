local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local While = require "actions/While"
local PlayAudio = require "actions/PlayAudio"

local PressZ = require "data/battle/actions/PressZ"

local HealText = require "data/items/actions/HealText"

local SpriteNode = require "object/SpriteNode"

local TargetType = require "util/TargetType"
local Transform = require "util/Transform"

return function(self, target)
	local shield = SpriteNode(
		target.scene,
		Transform.from(target.sprite.transform, Transform()),
		nil,
		"lasershield",
		nil,
		nil,
		"sprites"
	)
	if target.side == TargetType.Opponent then
		shield.transform.x = shield.transform.x + target:getSprite().w * 1.3
	else
		shield.transform.x = shield.transform.x - target.sprite.w
	end
	shield.transform.ox = shield.w/2
	shield.transform.oy = shield.h/2
	shield.color = {512,512,512,0}
	shield.transform.sy = 0
	shield.transform.sx = 2

	target.stats.prevDefense = target.stats.defense
	target.stats.defense = 999
	target.laserShield = shield

	local hitHandler
	hitHandler = function(damage, attacker)
		Executor(self.scene):act(Serial {
			PressZ(
				self,
				self,
				Serial {
					
				},
				Do(function() end)
			)
			Parallel {
				Ease(shield.color, 4, 0, 4),
				Serial {
					Ease(shield.transform, "sy", 3, 8, "quad"),
					Ease(shield.transform, "sy", 0, 8, "quad")
				}
			},
			Do(function()
				shield:remove()
				target.laserShield = nil
				target.stats.defense = target.stats.prevDefense
			end)
		})
		target:removeHandler("hit", hitHandler)
	end
	target:addHandler("hit", hitHandler)
	
	Executor(self.scene):act(
		While(
			function()
				return not shield:isRemoved()
			end,
			Repeat(
				Serial {
					Ease(shield.color, 4, 170, 8),
					Ease(shield.color, 4, 255, 8)
				}
			),
			Do(function() end)
		)
	)
	
	return Serial {
		PlayAudio("sfx", "shield", 0.4, true),
		Parallel {
			Ease(shield.color, 1, 255, 4),
			Ease(shield.color, 2, 255, 4),
			Ease(shield.color, 3, 255, 4),
			Ease(shield.color, 4, 255, 4),
			Serial {
				Ease(shield.transform, "sy", 3, 8, "quad"),
				Ease(shield.transform, "sy", 1.5, 8, "quad"),
				Ease(shield.transform, "sy", 2, 8, "quad")
			}
		}
	}
end
