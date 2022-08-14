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

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"
local TargetType = require "util/TargetType"

return function(attribute, amount)
	return function(self, target)
		-- Double healing amount if chef's hat equipped
		if  self.side == TargetType.Party and 
			GameState:isEquipped(self.id, ItemType.Accessory, "Chef's Hat")
		then
			amount = amount * 2
		end
		local direction = (target.sprite.transform.x > love.graphics.getWidth()/2) and 1 or -1
		local bouncyTextOffset = (direction > 0) and 10 or -50
	
		local targetXform = target.sprite.transform
		local sparkleCount = 0
		return Serial {
			-- Spawn sparkles around target starting from foot and moving upward in sine-wave
			Repeat(Serial {
				Do(function()
					local sparkle = SpriteNode(
						target.scene,
						Transform(targetXform.x - sparkleCount*10, targetXform.y + target.sprite.h/2),
						{255,255,500,0},
						"sparkle",
						5,
						5,
						"ui"
					)
					Executor(target.scene):act(Parallel {
						Repeat(Animate(sparkle, "idle"), nil, false),
						Ease(sparkle.transform, "y", targetXform.y - target.sprite.h/2, 1.5),
						Ease(sparkle.color, 4, 255, 9),
						Repeat(Serial {
							Parallel {
								Ease(sparkle.transform, "x", sparkle.transform.x - target.sprite.w/2, 6),
								Ease(sparkle.transform, "sx", 2, 12),
								Ease(sparkle.transform, "sy", 2, 12),
							},
							Parallel {
								Ease(sparkle.transform, "x", sparkle.transform.x + target.sprite.w, 6),
								Ease(sparkle.transform, "sx", 1, 12),
								Ease(sparkle.transform, "sy", 1, 12),
							}
						}, 2, true),
						Serial {
							Wait(1),
							Ease(sparkle.color, 4, 0, 3)
						},
					})
					sparkleCount = sparkleCount + 1
				end),
				Wait(0.1)
			}, 4),
			
			-- Fade in and out turquois glow
			Serial {
				Do(function() target.sprite:setGlow({0,255,255,255},2) end),
				PlayAudio("sfx", "heal", 1.0, true),
				Parallel {
					Ease(target.sprite.glowColor, 4, 50, 3),
					Ease(target.sprite, "glowSize", 6, 3),
					Ease(target.sprite.color, 2, 500, 3),
					Ease(target.sprite.color, 3, 500, 3),
				},
				HealText(attribute, amount, {0,255,255,255})(
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
					Ease(target.sprite.color, 3, target.color[3], 6, "quad"),
				},
				Do(function() target.sprite:removeGlow() end)
			}
		}
	end
end
