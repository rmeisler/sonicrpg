local Serial = require "actions/Serial"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local Ease = require "actions/Ease"
local Try = require "actions/Try"
local YieldUntil = require "actions/YieldUntil"
local Animate = require "actions/Animate"
local IfElse = require "actions/IfElse"
local BouncyText = require "actions/BouncyText"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"
local Transform = require "util/Transform"

local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Legacy Cambot",
	altName = "Legacy Cambot",
	sprite = "sprites/cambot2",

	stats = {
		xp    = 40,
		maxhp = 800,
		attack = 30,
		defense = 10,
		speed = 10,
		focus = 5,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/items/Microchip", count = 1, chance = 0.2},
	},
	
	onInit = function(self)
		-- Setup beam sprite
		self.shockSprite = SpriteNode(self.scene, Transform(), nil, "shockball", nil, nil, "ui")
		self.shockSprite.transform.sx = 2
		self.shockSprite.transform.sy = 2
		self.shockSprite.color[4] = 0
		self.shockSprite:setAnimation("idle")

		-- Setup target sprite
		self.targetSprite = SpriteNode(self.scene, Transform(0, 0, 2, 2), nil, "target", nil, nil, "ui")
		self.targetSprite.transform.ox = self.targetSprite.w/2
		self.targetSprite.transform.oy = self.targetSprite.h/2
		self.targetSprite.color[4] = 0
		
		-- Cambot gets initiative unless you sneak up
		if self.scene.initiative ~= "player" then
			self.scene.initiative = "opponent"
		end
	end,

	behavior = function (self, target)
		if not self.firstMove and #self.scene.opponents < 3 then
			self.firstMove = true
			return Serial {
				Parallel {
					PlayAudio("sfx", "alert", 1.0),
					Repeat(Parallel {
						Serial {
							Ease(self.scene.bgColor, 1, 510, 5, "quad"),
							Ease(self.scene.bgColor, 1, 255, 5, "quad"),
						},
						Do(function() 
							ScreenShader:sendColor("multColor", self.scene.bgColor)
						end)
					}, 5),
					Telegraph(self, "Intruder alert!", {255,255,255,50})
				},
				Do(function()
					local opp1 = self.scene:addMonster("legacyswatbot")
					opp1:onInit()
					local opp2 = self.scene:addMonster("legacyswatbot")
					opp2:onInit()
				end)
			}
		end
	
		if math.random() < 0.3 then
			if #self.scene.opponents >= 3 then
				if math.random() < 0.1 then
					return Serial {
						Parallel {
							PlayAudio("sfx", "cambotpic", 1.0),
							Telegraph(self, "Cambot is focusing its lens...", {255,255,255,50})
						}
					}
				else
					local sapActions = {
						Serial {
							Ease(self.sprite.color, 1, 255, 3),
							Ease(self.sprite.color, 2, 255, 3),
							Ease(self.sprite.color, 3, 255, 3)
						}
					}
					local spLoss = 5
					for _, mem in pairs(self.scene.party) do
						if mem.state ~= BattleActor.STATE_DEAD then
							mem.sp = math.max(0, mem.sp - spLoss)
							table.insert(sapActions, Serial {
								Animate(mem.sprite, "hurt"),
								Wait(1),
								Animate(mem.sprite, "idle")
							})
						end
					end
					
					return Serial {
						Telegraph(self, "Stare", {255,255,255,50}),
						Animate(self.sprite, "hurt"),
						Parallel {
							Ease(self.sprite.color, 1, 512, 1),
							Ease(self.sprite.color, 2, 512, 1),
							Ease(self.sprite.color, 3, 512, 1)
						},
						PlayAudio("sfx", "stare", 1.0, true),
						Repeat(Parallel {
							Serial {
								Parallel {
									Ease(self.scene.bgColor, 1, 512, 8, "quad"),
									Ease(self.scene.bgColor, 2, 512, 8, "quad"),
									Ease(self.scene.bgColor, 3, 512, 8, "quad")
								},
								Parallel {
									Ease(self.scene.bgColor, 1, 255, 8, "quad"),
									Ease(self.scene.bgColor, 2, 255, 8, "quad"),
									Ease(self.scene.bgColor, 3, 255, 8, "quad")
								}
							},
							Do(function() 
								ScreenShader:sendColor("multColor", self.scene.bgColor)
							end)
						}, 2),
						Parallel(sapActions),
						Do(function() self.sprite:setAnimation("idle") end),
						MessageBox {
							message="All party members lost "..tostring(spLoss).." sp!",
							rect=MessageBox.HEADLINER_RECT,
							closeAction=Wait(1)
						}
					}
				end
			else
				return Serial {
					Parallel {
						PlayAudio("sfx", "alert", 1.0),
						Repeat(Parallel {
							Serial {
								Ease(self.scene.bgColor, 1, 510, 5, "quad"),
								Ease(self.scene.bgColor, 1, 255, 5, "quad"),
							},
							Do(function() 
								ScreenShader:sendColor("multColor", self.scene.bgColor)
							end)
						}, 5),
						Telegraph(self, "Intruder alert!", {255,255,255,50})
					},
					Do(function()
						local opp = self.scene:addMonster("legacyswatbot")
						opp:onInit()
					end)
				}
			end
		elseif math.random() < 0.4 then
			target = self.scene.opponents[math.random(1, #self.scene.opponents)]
			return Serial {
				Telegraph(self, "Repair", {255,255,255,50}),
				Ease(self.sprite.color, 2, 512, 1),
				Heal("hp", 500)(self, target),
				Ease(self.sprite.color, 2, 255, 1)
			}
		else
			return Serial {
				Telegraph(self, "Spark", {255,255,255,50}),
				Animate(self.sprite, "hurt"),
				Parallel {
					Ease(self.sprite.color, 1, 512, 1),
					Ease(self.sprite.color, 2, 512, 1),
					Ease(self.sprite.color, 3, 512, 1)
				},
				
				PlayAudio("sfx", "shocked", 1.0, true),
				Do(function()
					self.shockSprite.transform.x = self.sprite.transform.x - self.sprite.w/2
					self.shockSprite.transform.y = self.sprite.transform.y - self.sprite.h/2
				end),
				Parallel {
					target.defenseEvent and
						target.defenseEvent(self, target) or
						Action(),
					Serial {
						Ease(self.shockSprite.color, 4, 255, 5),
						Wait(0.5),
						Ease(self.shockSprite.color, 4, 0, 5)
					},
					Ease(self.shockSprite.transform, "x", target.sprite.transform.x - target.sprite.w/2, 1),
					Ease(self.shockSprite.transform, "y", target.sprite.transform.y - target.sprite.h/2, 1)
				},
				Parallel {
					Try(
						YieldUntil(
							function()
								return target.dodged
							end
						),
						Do(function()
							target.dodged = false
						end),
						target:takeDamage(self.stats, true, BattleActor.shockKnockback)
					),
					Ease(self.sprite.color, 1, 255, 1),
					Ease(self.sprite.color, 2, 255, 1),
					Ease(self.sprite.color, 3, 255, 1)
				},
				IfElse(
					function()
						return  not target.laserShield and
								target.hp > 0
					end,
					Serial {
						Telegraph(target, target.name.." is stunned!", {255,255,255,50}),
						Do(function()
							target.state = BattleActor.STATE_IMMOBILIZED
							target.turnsImmobilized = 2
							target.sprite:setAnimation("dead")
						end)
					},
					Do(function() end)
				),
				Do(function() self.sprite:setAnimation("idle") end)
			}
		end
	end
}
