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
local IfElse = require "actions/IfElse"
local Repeat = require "actions/Repeat"

local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

return {
	name = "Bug",
	altName = "Bug",
	sprite = "sprites/ladybug",

	stats = {
		xp    = 10,
		maxhp = 500,
		attack = 10,
		defense = 10,
		speed = 30,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,
	
	weakness = "focus",

	coin = 0,

	drops = {
		{item = require "data/items/GreenLeaf", count = 1, chance = 0.2},
	},
	
	onInit = function(self)
		self.scene.bgImgColor = {170,170,170,255}
		self.scene.partyByName.sally.sprite.color = {170,170,170,255}
		self.sprite.color = {170,170,170,255}

		self.growth = 0

		self.ladybugSprites = {}
		for i=1,10 do
			local sp = SpriteNode(
				self.scene,
				Transform(-100, self.sprite.transform.y, 2, 2),
				{170,170,170,255},
				"ladybug",
				nil,
				nil,
				"sprites"
			)
			sp.transform.ox = self.sprite.w/2
			sp.transform.oy = self.sprite.h/2
			table.insert(self.ladybugSprites, sp)
		end
	end,
	
	onAttack = function(self, attacker)
		if self.growth == 2 and self.hp < 400 then
			return Serial {
				
			}
		elseif self.growth == 1 and self.hp < 300 then
			return Serial {
				
			}
		else
			return Serial {
			}
		end
	end,

	behavior = function (self, target)
		if self.growth == 0 then
			self.growth = self.growth + 1

			local newBug1 = table.remove(self.ladybugSprites)
			local newBug2 = table.remove(self.ladybugSprites)
			local newBug3 = table.remove(self.ladybugSprites)
			local newBug4 = table.remove(self.ladybugSprites)
			local newBug5 = table.remove(self.ladybugSprites)

			return Serial {
				Telegraph(self, "Gather", {255,255,255,50}),
				Parallel {
					Ease(newBug1.transform, "x", self.sprite.transform.x, 3),
					Serial {
						Wait(0.2),
						Ease(newBug2.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.4),
						Ease(newBug3.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.6),
						Ease(newBug4.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.8),
						Ease(newBug5.transform, "x", self.sprite.transform.x, 3)
					},
					--[[
					Serial {
						Wait(0.5),
						Repeat(Serial {
							Animate(self.sprite, "idle"),
							Wait(0.2),
							Animate(self.sprite, "level2_idle"),
							Wait(0.2)
						}, 5)
					}]]
				},
				Animate(self.sprite, "level2_idle"),
				Do(function()
					self.stats.attack = self.stats.attack + 20
					self.stats.defense = self.stats.defense + 20
					self.stats.speed = self.stats.speed - 10
					
					self.sprite:pushOverride("idle", "level2_idle")
					self.sprite:pushOverride("move", "level2_move")
					self.sprite:pushOverride("hurt", "level2_hurt")

					newBug1.transform.x = -200
					newBug2.transform.x = -200
					newBug3.transform.x = -200
					newBug4.transform.x = -200
					newBug5.transform.x = -200
					table.insert(self.ladybugSprites, newBug1)
					table.insert(self.ladybugSprites, newBug2)
					table.insert(self.ladybugSprites, newBug3)
					table.insert(self.ladybugSprites, newBug4)
					table.insert(self.ladybugSprites, newBug5)
				end),
				MessageBox {message="Defense increased! {p40}Speed decreased!", rect=MessageBox.HEADLINER_RECT}
			}
		end
		
		local chance = math.random()
		if chance > 0.6 and self.growth == 1 then
			self.growth = self.growth + 1

			local newBug1 = table.remove(self.ladybugSprites)
			local newBug2 = table.remove(self.ladybugSprites)
			local newBug3 = table.remove(self.ladybugSprites)
			local newBug4 = table.remove(self.ladybugSprites)
			local newBug5 = table.remove(self.ladybugSprites)
			local newBug6 = table.remove(self.ladybugSprites)
			local newBug7 = table.remove(self.ladybugSprites)
			local newBug8 = table.remove(self.ladybugSprites)
			local newBug9 = table.remove(self.ladybugSprites)
			local newBug10 = table.remove(self.ladybugSprites)

			return Serial {
				Telegraph(self, "Gather", {255,255,255,50}),
				Parallel {
					Ease(newBug1.transform, "x", self.sprite.transform.x, 3),
					Serial {
						Wait(0.2),
						Ease(newBug2.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.4),
						Ease(newBug3.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.6),
						Ease(newBug4.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.8),
						Ease(newBug5.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1),
						Ease(newBug6.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1.2),
						Ease(newBug7.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1.4),
						Ease(newBug8.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1.6),
						Ease(newBug9.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1.8),
						Ease(newBug10.transform, "x", self.sprite.transform.x, 3)
					},
					--[[
					Serial {
						Wait(1.2),
						Repeat(Serial {
							Animate(self.sprite, "idle"),
							Wait(0.2),
							Animate(self.sprite, "level2_idle"),
							Wait(0.2)
						}, 5)
					}]]
				},
				Animate(self.sprite, "level3_idle"),
				Do(function()
					self.stats.defense = self.stats.defense + 20
					self.stats.speed = self.stats.speed - 10
					
					self.sprite:pushOverride("idle", "level3_idle")
					self.sprite:pushOverride("move", "level3_move")
					self.sprite:pushOverride("hurt", "level3_hurt")
					
					newBug1.transform.x = -200
					newBug2.transform.x = -200
					newBug3.transform.x = -200
					newBug4.transform.x = -200
					newBug5.transform.x = -200
					newBug6.transform.x = -200
					newBug7.transform.x = -200
					newBug8.transform.x = -200
					newBug9.transform.x = -200
					newBug10.transform.x = -200
					table.insert(self.ladybugSprites, newBug1)
					table.insert(self.ladybugSprites, newBug2)
					table.insert(self.ladybugSprites, newBug3)
					table.insert(self.ladybugSprites, newBug4)
					table.insert(self.ladybugSprites, newBug5)
					table.insert(self.ladybugSprites, newBug6)
					table.insert(self.ladybugSprites, newBug7)
					table.insert(self.ladybugSprites, newBug8)
					table.insert(self.ladybugSprites, newBug9)
					table.insert(self.ladybugSprites, newBug10)
				end),
				MessageBox {message="Defense increased! {p40}Speed decreased!", rect=MessageBox.HEADLINER_RECT}
			}
		else
			local origX, origY = self.sprite.transform.x, self.sprite.transform.y
			return Serial {
				Telegraph(self, "Swarm", {255,255,255,50}),
				Animate(target.sprite, "shock"),
				Parallel {
					Ease(self.sprite.transform, "x", target.sprite.transform.x, 3),
					Ease(self.sprite.transform, "y", target.sprite.transform.y + 1, 3)
				},
				Do(function()
					self.sprite.sortOrderY = self.sprite.transform.y + 1
				end),
				MessageBox {message="Rapidly press x to shake off bugs!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(0.5)},

				-- Do repeated little amounts of damage until player shakes them off
				Parallel {
					Repeat(Serial {
						Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - 20 end, 10),
						Ease(self.sprite.transform, "y", function() return self.sprite.transform.y + 20 end, 10)
					}, 8),
					Serial {
						Wait(0.5),
						target:takeDamage(self.stats)
					}
				},
				Do(function()
					self.sprite.sortOrderY = nil
				end),
				Parallel {
					Ease(self.sprite.transform, "x", origX, 3),
					Ease(self.sprite.transform, "y", origY, 3)
				},
				Do(function()
					if target.hp > 0 then
						target.sprite:setAnimation("idle")
					end
				end)
			}
		end
	end,
	
	scan = "Stop Bugs from gathering!"
}