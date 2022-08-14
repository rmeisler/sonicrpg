local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"

local HealText = require "data/items/actions/HealText"

local BattleActor = require "object/BattleActor"
local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"
local TargetType = require "util/TargetType"

return function(amount)
	return function(self, target)
		-- Double healing amount if chef's hat equipped
		if  self.side == TargetType.Party and 
			GameState:isEquipped(self.id, ItemType.Accessory, "Chef's Hat")
		then
			amount = amount * 2
		end
		local direction = (target.sprite.transform.x > love.graphics.getWidth()/2) and 1 or -1
		local bouncyTextOffset = (direction > 0) and 10 or -50
		
		-- Double healing amount if chef's hat equipped
		if GameState:isEquipped(self.id, ItemType.Accessory, "Chef's Hat") then
			amount = amount * 2
		end

		local targetXform = target.sprite.transform
		local sparkleCount = 0
		return Serial {
			-- Fade in and out green glow
			Serial {
				Do(function() target.sprite:setGlow({0,255,0,0},2) end),
				PlayAudio("sfx", "heal", 1.0, true),
				Parallel {
					Ease(target.sprite.glowColor, 4, 50, 3),
					Ease(target.sprite, "glowSize", 6, 3),
					Ease(target.sprite.color, 2, 500, 3),
				},
				HealText("hp", amount, {0,255,0,255})(
					target,
					Transform(
						target.sprite.transform.x + bouncyTextOffset + target.textOffset.x,
						target.sprite.transform.y + target.textOffset.y
					)
				),
				Parallel {
					Ease(target.sprite.glowColor, 4, 0, 6, "quad"),
					Ease(target.sprite, "glowSize", 2, 6, "quad"),
					Ease(target.sprite.color, 2, target.color[2], 6, "quad"),
				},
				Do(function()
					target.sprite:removeGlow()
					target.state = BattleActor.STATE_IDLE
					target.sprite:setAnimation("idle")
				end)
			}
		}
	end
end
