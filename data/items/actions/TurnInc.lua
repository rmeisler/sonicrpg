local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"
local Action = require "actions/Action"
local BouncyText = require "actions/BouncyText"

local HealText = require "data/items/actions/HealText"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

return function()
	return function(self, target)
		local direction = (target.sprite.transform.x > love.graphics.getWidth()/2) and 1 or -1
		local bouncyTextOffset = (direction > 0) and -10 or -30
	
		local targetXform = target.sprite.transform
		local sparkleCount = 0
		return Serial {
			-- Spawn sparkles around target starting from foot and moving upward in sine-wave
			Repeat(Serial {
				Do(function()
					local sparkle = SpriteNode(
						target.scene,
						Transform(targetXform.x - sparkleCount*10, targetXform.y + target.sprite.h/2),
						{500,500,500,0},
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
			
			-- Fade in and out white glow
			Serial {
				Do(function() target.sprite:setGlow({255,255,255,255},2) end),
				PlayAudio("sfx", "heal", 1.0, true),
				Parallel {
					Ease(target.sprite.glowColor, 4, 50, 3),
					Ease(target.sprite, "glowSize", 6, 3),
					Ease(target.sprite.color, 1, 500, 3),
					Ease(target.sprite.color, 2, 500, 3),
					Ease(target.sprite.color, 3, 500, 3),
				},
				BouncyText(
					Transform(
						target.sprite.transform.x + bouncyTextOffset + target.textOffset.x,
						target.sprite.transform.y + target.textOffset.y
					),
					{255, 255, 255, 255},
					FontCache.Consolas,
					"+3 turns",
					10,
					false,
					true
				),
				Parallel {
					Ease(target.sprite.glowColor, 4, 0, 6, "quad"),
					Ease(target.sprite, "glowSize", 2, 6, "quad"),
					Ease(target.sprite.color, 1, target.color[1], 6, "quad"),
					Ease(target.sprite.color, 2, target.color[2], 6, "quad"),
					Ease(target.sprite.color, 3, target.color[3], 6, "quad"),
				},
				Do(function() target.sprite:removeGlow() end)
			}
		}
	end
end
