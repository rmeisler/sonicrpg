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
local MessageBox = require "actions/MessageBox"
local While = require "actions/While"
local IfElse = require "actions/IfElse"
local Executor = require "actions/Executor"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local ItemType = require "util/ItemType"
local TargetType = require "util/TargetType"

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
		maxhp = 500,
		attack = 40,
		defense = 25,
		speed = 10,
		focus = 0,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},
	
	scan = "The Kiss of Death will kill you in 3 turns.",

	onInit = function(self)
		self.scene.bgImgColor = {170,170,170,255}
		self.scene.partyByName.sally.sprite.color = {170,170,170,255}
		self.sprite:setAnimation("poison_idle")
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
		
		if not self.usedPoison then
			local origX, origY = self.sprite.transform.x, self.sprite.transform.y
			return Serial {
				Telegraph(self, "Kiss of Death", {255,255,255,50}),
				Parallel {
					Ease(self.sprite.transform, "x", target.sprite.transform.x - 30, 3),
					Ease(self.sprite.transform, "y", target.sprite.transform.y + 1, 3),
				},
				Parallel {
					Serial {
						Animate(self.sprite, "poison_crouch"),
						Wait(0.3),
						Animate(self.sprite, "poison_attack")
					},
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
						Serial {
							Animate(target.sprite, "hurt"),
							Repeat(Serial {
								-- Why are these necessary?
								Do(function() end),
								Animate(self.sprite, "attack"),
								Do(function() end),
								Wait(0.1),
								Animate(self.sprite, "poison_attack"),
								Wait(0.1),
								Do(function() end),
							}, 5),
							Animate(self.sprite, "attack"),
							Do(function()
								self.usedPoison = true
								
								-- Can't poison someone wearing Copper Amulet
								if  target.side == TargetType.Party and
									GameState:isEquipped(target.id, ItemType.Accessory, "Copper Amulet") then
									return
								end

								target.poisoned = table.clone(self.stats)
								target.poisoned.attack = target.poisoned.attack/2
								target.poisoned.speed = 100
								target.poisoned.nomiss = true
								target.poisoned.nonlethal = false

								-- Always fade in and out green
								target.poisonAnim = Executor(self.scene)
								target.poisonAnim:act(While(
									function()
										return target.poisoned
									end,
									Repeat(Serial {
										Ease(target.sprite.color, 2, 400, 1.5),
										Ease(target.sprite.color, 2, 300, 1.5)
									}),
									Ease(target.color, 2, 170, 1)
								))
							end),
							IfElse(
								function() return target.poisoned end,
								MessageBox {message=target.name.." is poisoned!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
								MessageBox {message=target.name.." could not be poisoned!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)}
							),
							Animate(target.sprite, "idle")
						}
					)
				},
				Parallel {
					Ease(self.sprite.transform, "x", origX, 3),
					Ease(self.sprite.transform, "y", origY, 3)
				},
				Do(function() self.sprite:setAnimation("idle") end)
			}
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