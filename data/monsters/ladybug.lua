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
		speed = 20,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,

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
		for i=1,15 do
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

	behavior = function (self, target)
		if self.growth < 2 then
			self.growth = self.growth + 1

			-- Grow (+5 lady bugs), each five bugs gives them +10 attack, +10 defense, -5 speed
			local newBug1 = table.remove(self.ladybugSprites)
			local newBug2 = table.remove(self.ladybugSprites)
			local newBug3 = table.remove(self.ladybugSprites)
			local newBug4 = table.remove(self.ladybugSprites)
			local newBug5 = table.remove(self.ladybugSprites)
			
			if not self.usedBugs then
				self.usedBugs = {}
			end

			local flashColor = {255,255,255,50}
			local flashActions = {}
			for _,sp in pairs(self.usedBugs) do
				table.insert(
					flashActions,
					Repeat(
						Serial {
							Parallel {
								Ease(sp.color, 1, flashColor[1], 10, "linear"),
								Ease(sp.color, 2, flashColor[2], 10, "linear"),
								Ease(sp.color, 3, flashColor[3], 10, "linear"),
								Ease(sp.color, 4, flashColor[4], 10, "linear"),
							},
							Parallel {
								Ease(sp.color, 1, sp.color[1], 10, "linear"),
								Ease(sp.color, 2, sp.color[2], 10, "linear"),
								Ease(sp.color, 3, sp.color[3], 10, "linear"),
								Ease(sp.color, 4, sp.color[4], 10, "linear"),
							}
						},
						2
					)
				)
			end

			table.insert(self.usedBugs, newBug1)
			table.insert(self.usedBugs, newBug2)
			table.insert(self.usedBugs, newBug3)
			table.insert(self.usedBugs, newBug4)
			table.insert(self.usedBugs, newBug5)

			return Serial {
				Parallel {
					Telegraph(self, "Gather", flashColor),
					Serial {
						Wait(0.5),
						Parallel(flashActions)
					}
				},
				Parallel {
					Ease(newBug1.transform, "x", function() return self.sprite.transform.x + self.sprite.w end, 3),
					Serial {
						Wait(0.25),
						Ease(newBug2.transform, "x", function() return self.sprite.transform.x - self.sprite.w end, 3)
					},
					Serial {
						Wait(0.5),
						Ease(newBug3.transform, "x", function() return self.sprite.transform.x - self.sprite.w*2 end, 3),
						Wait(0.2),
						-- hop
						Parallel {
							Ease(newBug3.transform, "x", function() return newBug3.transform.x end, 3),
							Ease(newBug3.transform, "y", function() return newBug3.transform.y - 50 end, 3)
						},
						Parallel {
							Ease(newBug3.transform, "x", function() return newBug3.transform.x + newBug3.w*2 end, 5),
							Ease(newBug3.transform, "y", function() return newBug3.transform.y + 35 end, 5)
						},
						PlayAudio("sfx", "bang", 0.5, true)
					},
					Serial {
						Wait(1),
						Ease(newBug4.transform, "x", function() return self.sprite.transform.x - self.sprite.w*2 end, 3),
						Wait(0.2),
						-- hop
						Parallel {
							Ease(newBug4.transform, "x", function() return newBug4.transform.x end, 3),
							Ease(newBug4.transform, "y", function() return newBug4.transform.y - 50 end, 3)
						},
						Parallel {
							Ease(newBug4.transform, "x", function() return newBug4.transform.x + newBug4.w end, 5),
							Ease(newBug4.transform, "y", function() return newBug4.transform.y + 35 end, 5)
						},
						PlayAudio("sfx", "bang", 0.5, true)
					},
					Serial {
						Wait(1.5),
						Ease(newBug5.transform, "x", function() return self.sprite.transform.x - self.sprite.w*3 end, 3),
						Wait(0.2),
						-- hop
						Parallel {
							Ease(newBug5.transform, "x", function() return newBug5.transform.x - newBug5.w end, 3),
							Ease(newBug5.transform, "y", function() return newBug5.transform.y - 80 end, 3)
						},
						Parallel {
							Ease(newBug5.transform, "x", function() return self.sprite.transform.x end, 5),
							Ease(newBug5.transform, "y", function() return newBug5.transform.y + 45 end, 5)
						},
						PlayAudio("sfx", "bang", 0.5, true)
					}
				},
				Do(function()
					self.stats.attack = self.stats.attack + 10
					self.stats.defense = self.stats.defense + 10
					self.stats.speed = self.stats.speed - 5
				end),
				MessageBox {message="Attack and defense increased! {p40}Speed decreased!", rect=MessageBox.HEADLINER_RECT}
			}
		else
			local flashColor = {255,255,255,50}
			local flashActions = {}
			for _,sp in pairs(self.usedBugs) do
				table.insert(
					flashActions,
					Repeat(
						Serial {
							Parallel {
								Ease(sp.color, 1, flashColor[1], 10, "linear"),
								Ease(sp.color, 2, flashColor[2], 10, "linear"),
								Ease(sp.color, 3, flashColor[3], 10, "linear"),
								Ease(sp.color, 4, flashColor[4], 10, "linear"),
							},
							Parallel {
								Ease(sp.color, 1, sp.color[1], 10, "linear"),
								Ease(sp.color, 2, sp.color[2], 10, "linear"),
								Ease(sp.color, 3, sp.color[3], 10, "linear"),
								Ease(sp.color, 4, sp.color[4], 10, "linear"),
							}
						},
						2
					)
				)
			end

			return Serial {
				Parallel {
					Telegraph(self, "Swarm", flashColor),
					Serial {
						Wait(0.5),
						Parallel(flashActions)
					}
				}
			}
		end
	end,
	
	scan = "Stop Bugs from gathering!"
}