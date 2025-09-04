local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local BouncyText = require "actions/BouncyText"
local Repeat = require "actions/Repeat"
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"
local Executor = require "actions/Executor"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"

local Stars = require "data/battle/actions/Stars"
local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local BattleScene = require "scene/BattleScene"

return {
	name = "Flower",
	altName = "Flower",
	sprite = "sprites/flower",

	stats = {
		xp    = 10,
		maxhp = 180,
		attack = 15,
		defense = 15,
		speed = 10,
		focus = 10,
		luck = 10,
	},

	run_chance = 1.0,
	coin = 0,
	drops = {
		{item = require "data/items/GreenLeaf", count = 1, chance = 1.0},
	},
	
	scan = "You can dodge this flower's attacks if you're nimble!",

	skipAnimation = true,
	
	onInit = function(self)
		self.bullet = SpriteNode(
			self.scene,
			Transform(0,0,2,2),
			{100,100,0,0},
			"snowball",
			nil,
			nil,
			"ui"
		)
		self.bullet.transform.ox = self.bullet.w/2
		self.bullet.transform.oy = self.bullet.h/2
		self.bullet.transform.angle = math.pi / 6
	end,
	
	onDead = function(self)
		return Do(function()
			self.scene.state = BattleScene.STATE_PLAYERWIN
			self.scene:cleanMonsters()
		end)
	end,
	
	behavior = function (self, target)
		if self.hp <= 0 then
			return Action()
		end
	
		self.bullet.transform.x = self.sprite.transform.x + 84
		self.bullet.transform.y = self.sprite.transform.y + 10
		
		local finalAction = function(damageGiver, damageTaker, bonus)
			local stats = nil
			if damageGiver then
				stats = table.clone(damageGiver.stats)
				stats.attack = stats.attack * (bonus or 1.0)
			end
			return Serial {
				Do(function()
					self.bullet.color[4] = 0
				end),
				damageTaker and
					damageTaker:takeDamage(stats) or
					Action(),
				Do(function()
					self.sprite:setAnimation("idle")
					if target.hp > 0 then
						target.sprite:setAnimation("idle")
					end
				end)
			}
		end

		return Serial {
			Telegraph(self, "Spit", {255,255,255,50}),
			Animate(self.sprite, "shoot"),
			Do(function()
				self.bullet.color[4] = 255
			end),
			Parallel {
				Serial {
					Parallel {
						Ease(self.bullet.transform, "x", target.sprite.transform.x - 30, 4, "linear"),
						Ease(self.bullet.transform, "y", target.sprite.transform.y, 4, "linear")
					},
					Do(function()
						self.bullet.color[4] = 0
					end)
				},

				PressX(
					self,
					target,
					Serial {
						Do(function()
							self.bullet.color[4] = 255
						end),
						PlayAudio("sfx", "pressx", 1.0, true),
						-- Tails blocks, bullet pops up, press z to hit back
						Animate(target.sprite, "block"),
						Parallel {
							Serial {
								Ease(self.bullet.transform, "y", function() return self.bullet.transform.y - 200 end, 4, "quad"),
								Ease(self.bullet.transform, "y", function() return self.bullet.transform.y + 200 end, 4, "quad")
							},
							Serial {
								Wait(0.2),
								PressZ(
									self,
									target,
									Serial {
										Parallel {
											Animate(target.sprite, "slap"),
											Serial {
												Wait(0.1),
												PlayAudio("sfx", "poptop", 1.0, true)
											},
											Ease(self.bullet.transform, "x", self.sprite.transform.x, 4, "quad"),
											Ease(self.bullet.transform, "y", self.sprite.transform.y, 4, "quad")
										},
										Parallel {
											Stars(target, self),
											finalAction(target, self, 1.5)
										}
									},
									finalAction()
								)
							}
						}
					},
					finalAction(self, target)
				)
			}
		}
	end
}