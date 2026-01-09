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
		
		-- This is multiple targets
		local targets
		if target[1] then
			targets = target
		else
			targets = {target}
		end

		local actions = {}
		for _,t in pairs(targets) do
			local direction = (t.sprite.transform.x > love.graphics.getWidth()/2) and 1 or -1
			local bouncyTextOffset = (direction > 0) and 10 or -50
			
			-- Double healing amount if chef's hat equipped
			if GameState:isEquipped(self.id, ItemType.Accessory, "Chef's Hat") then
				amount = amount * 2
			end

			local targetXform = t.sprite.transform
			local sparkleCount = 0
			table.insert(
				actions,
				Serial {
					Do(function() t.sprite:setGlow({0,255,0,0},2) end),
					PlayAudio("sfx", "heal", 1.0, true),
					Parallel {
						Ease(t.sprite.glowColor, 4, 50, 3),
						Ease(t.sprite, "glowSize", 6, 3),
						Ease(t.sprite.color, 2, 500, 3),
					},
					HealText("hp", amount, {0,255,0,255})(
						t,
						Transform(
							t.sprite.transform.x + bouncyTextOffset + t.textOffset.x,
							t.sprite.transform.y + t.textOffset.y
						)
					),
					Parallel {
						Ease(t.sprite.glowColor, 4, 0, 6, "quad"),
						Ease(t.sprite, "glowSize", 2, 6, "quad"),
						Ease(t.sprite.color, 2, t.color[2], 6, "quad"),
					},
					Do(function()
						t.sprite:removeGlow()
						t.state = BattleActor.STATE_IDLE
						t.sprite:setAnimation("idle")
					end)
				}
			)
		end

		return Serial(actions)
	end
end
