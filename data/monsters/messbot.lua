local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"
local Animate = require "actions/Animate"
local Try = require "actions/Try"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local BouncyText = require "actions/BouncyText"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local Throw = require "data/items/actions/Throw"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

return {
	name = "Mess",
	altName = "Mess",
	sprite = "sprites/messbot",

	stats = {
		xp    = 10,
		maxhp = 250,
		attack = 50,
		defense = 25,
		speed = 10,
		focus = 0,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},
	
	scan = "Look out for their grapple!",

	onInit = function(self)
		self.scene.bgImgColor = {170,170,170,255}
		self.scene.partyByName.sally.sprite.color = {170,170,170,255}
	end,
	
	behavior = function (self, target)
		if self.noPower then
			return Action()
		end
		
		local sallyCounterAction = Action()
		local sallyCounter = false
		if target.id == "sally" and GameState:isEquipped(target.id, ItemType.Legs, "Adventurer Boots") then
			sallyCounter = true
			sallyCounterAction = PressX(
				self,
				target,
				Serial {
					PlayAudio("sfx", "pressx", 1.0, true),
					Parallel {
						Serial {
							Animate(target.sprite, "leap_dodge"),
							Ease(target.sprite.transform, "y", target.sprite.transform.y - 100, 5, "linear"),
							PressZ(
								self,
								target,
								Serial {
									PlayAudio("sfx", "pressx", 1.0, true, false, true),
									Animate(target.sprite, "counter_flip"),
									Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h, 8, "quad"),
									Parallel {
										Animate(target.sprite, "counter_land"),
										Ease(target.sprite.transform, "y", target.sprite.transform.y, 12, "quad")
									},
									self:takeDamage(target.stats),
									Animate(target.sprite, "idle")
								},
								Parallel {
									BouncyText(
										Transform(
											target.sprite.transform.x + 10 + (target.textOffset.x),
											target.sprite.transform.y + (target.textOffset.y)),
										{255,255,255,255},
										FontCache.ConsolasLarge,
										"miss",
										6,
										false,
										true -- outline
									),
									Serial {
										Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
										Animate(target.sprite, "crouch"),
										Wait(0.1),
										Animate(target.sprite, "victory"),
										Wait(0.8),
										Animate(target.sprite, "idle"),
									}
								}
							)
						}
					}
				},
				target:takeDamage(self.stats, true, BattleActor.shockKnockback)
			)
		end

		local origX, origY = self.sprite.transform.x, self.sprite.transform.y
		return Serial {
			Telegraph(self, "Grapple", {255,255,255,50}),
			Parallel {
				Ease(self.sprite.transform, "x", target.sprite.transform.x - 30, 3),
				Ease(self.sprite.transform, "y", target.sprite.transform.y + 1, 3),
			},
			Parallel {
				Serial {
					Animate(self.sprite, "crouch"),
					Wait(0.5),
					Animate(self.sprite, "attack")
				},
				Serial {
					Wait(0.2),
					sallyCounter and sallyCounterAction or
					PressX(
						self,
						target,
						Serial {
							PlayAudio("sfx", "pressx", 1.0, true),
							Parallel {
								Serial {
									Animate(target.sprite, "leap_dodge"),
									Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h*2, 8, "linear"),
									Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
									Animate(target.sprite, "crouch"),
									Wait(0.1),
									Animate(target.sprite, "victory"),
									Wait(0.8),
									Animate(target.sprite, "idle"),
								},
								BouncyText(
									Transform(
										target.sprite.transform.x + 10 + (target.textOffset.x),
										target.sprite.transform.y + (target.textOffset.y)),
									{255,255,255,255},
									FontCache.ConsolasLarge,
									"miss",
									6,
									false,
									true -- outline
								),
							}
						},
						target:takeDamage(self.stats, true, BattleActor.shockKnockback)
					)
				}
			},
			Parallel {
				Ease(self.sprite.transform, "x", origX, 3),
				Ease(self.sprite.transform, "y", origY, 3)
			},
			Do(function() self.sprite:setAnimation("idle") end)
		}
	end
}