local ItemType = require "util/ItemType"
local TargetType = require "util/TargetType"
local Transform = require "util/Transform"

local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Executor = require "actions/Executor"
local Smack = require "data/monsters/actions/Smack"

local SpriteNode = require "object/SpriteNode"

return {
	name = "Boomerang",
	desc = "Used to fend off flying creatures.",
	type = ItemType.Accessory,
	stats = {},
	onAttackFlying = function(self, target)
		local boomerang = SpriteNode(
			self.scene,
			Transform(
				self.sprite.transform.x + self.sprite.w-15,
				self.sprite.transform.y + self.sprite.h/2
			),
			{255,255,255,0},
			"boomerang"
		)
		boomerang.transform.ox = boomerang.w/2
		boomerang.transform.oy = boomerang.h/2

		return Serial {
			Do(function()
				boomerang.color[4] = 255
				Executor(self.scene):act(
					Parallel {
						PlayAudio("sfx", "boomerang", 0.5, true),
						Ease(boomerang.transform, "angle", math.pi*10, 0.5, "linear")
					},
					Do(function() self.scene.audio:stopSfx() end)
				)
			end),

			Parallel {
				Ease(boomerang.transform, "x", target.sprite.transform.x+target.sprite.w, 1),
				-- Bend it like Beckham
				Serial {
					Ease(boomerang.transform, "y", target.sprite.transform.y-self.sprite.h/4, 2, "linear"),
					Ease(boomerang.transform, "y", target.sprite.transform.y+target.sprite.h/2, 2, "linear"),
				}
			},
			Parallel {
				Smack(self, target),

				Serial {
					Parallel {
						Ease(boomerang.transform, "x", boomerang.transform.x, 1),
						-- Bend it like Beckham
						Serial {
							Ease(boomerang.transform, "y", boomerang.transform.y+self.sprite.h/4, 2, "linear"),
							Ease(boomerang.transform, "y", boomerang.transform.y, 2, "linear"),
						},
					},
					Do(function() boomerang:remove() end)
				}
			}
		}
	end
}
