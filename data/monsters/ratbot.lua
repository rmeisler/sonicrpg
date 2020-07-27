local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local BouncyText = require "actions/BouncyText"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"

return {
	name = "Ratbot",
	altName = "Ratbot",
	sprite = "sprites/ratbot",

	stats = {
		xp    = 10,
		maxhp = 800,
		attack = 28,
		defense = 15,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/items/GreenLeaf", count = 1, chance = 0.2},
	},

	behavior = function (self, target)
		if not self.turnCounter then
			self.turnCounter = 1
		end

		local telegraphAction = Action()
		local soundAction = Action()
		local prefix = ""
		local stats = table.clone(self.stats)
		if self.turnCounter % 3 == 0 then
			self.electricTail = true
			prefix = "electric"
			telegraphAction = Telegraph(self, "Electric Whip", {255,255,255,50})
			stats.attack = self.stats.attack * 2
			soundAction = PlayAudio("sfx", "smack2", 1.0, true)
		else
			self.electricTail = false
			telegraphAction = Telegraph(self, "Whip", {255,255,255,50})
		end
		
		self.turnCounter = self.turnCounter + 1
		
		local leap = function()
			if self == target then
				return Action()
			else
				return Serial {
					Animate(self.sprite, "crouch"),
					Wait(0.2),
					Animate(self.sprite, "leap", true),
					Parallel {
						Serial {
							Ease(self.sprite.transform, "y", target.sprite.transform.y - 100, 5, "quad"),
							Animate(self.sprite, "lunge"),
							Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 6, "quad")
						},
						Ease(self.sprite.transform, "x", target.sprite.transform.x - 150, 3, "linear")
					}
				}
			end
		end
		
		local leapBack = function()
			if self == target then
				return Action()
			else
				return Serial {
					Animate(self.sprite, "pose"),
					Animate(self.sprite, "crouch"),
					Wait(0.2),
					Animate(self.sprite, "leap", true),
					Parallel {
						Serial {
							Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h - 100, 5, "quad"),
							Ease(self.sprite.transform, "y", self.sprite.transform.y, 6, "quad")
						},
						Ease(self.sprite.transform, "x", self.sprite.transform.x, 3, "linear")
					}
				}
			end
		end
		
		return Serial {
			telegraphAction,
			leap(),
			Animate(self.sprite, prefix.."pose"),
			Parallel {
				Serial {
					Wait(0.2),
					Animate(self.sprite, prefix.."tail"),
					Animate(self.sprite, "pose")
				},
				
				PressX(
					self,
					target,
					Serial {
						PlayAudio("sfx", "pressx", 1.0, true),
						Parallel {
							Serial {
								Animate(target.sprite, "crouch"),
								Wait(0.1),
								Animate(target.sprite, "leap_dodge"),
								Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h*2, 6, "linear"),
								Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
								Animate(target.sprite, "crouch"),
								Wait(0.1),
								Animate(target.sprite, "victory"),
								Wait(0.3),
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
						soundAction,
						target:takeDamage(stats, true, self.electricTail and BattleActor.shockKnockback or nil)
					},
					0.3
				)
			},
			leapBack(),
			Animate(self.sprite, "idle"),
		}
	end,
	
	scan = "You can avoid Ratbot's attacks, if you're nimble."
}