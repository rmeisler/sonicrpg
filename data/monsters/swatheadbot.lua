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

local Throw = require "data/items/actions/Throw"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

return {
	name = "Swatbot Head",
	altName = "Swatbot Head",
	sprite = "sprites/swatbot",
	
	aerial = true,

	stats = {
		xp    = 10,
		maxhp = 300,
		attack = 40,
		defense = 25,
		speed = 5,
		focus = 0,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},
	
	scan = "You can kick their bombs back at them!",
	
	onPreInit = function(self)
		
	end,

	onInit = function(self)
		self.sprite:pushOverride("idle", "swathead_right")
		self.sprite:pushOverride("backward", "swathead_left")
		self.sprite:pushOverride("hurt", "swathead_moveright")
		self.sprite:pushOverride("throw", "swathead_moveright")
		self.sprite:setAnimation("idle")

		self.sprite.sortOrderY = self.sprite.transform.y + self.sprite.h
		self.sprite.color = {170,170,170,255}
		self.scene.bgImgColor = {170,170,170,255}
		self.scene.partyByName.sally.sprite.color = {170,170,170,255}
	end,
	
	behavior = function (self, target)
		if self.turnCount == nil then
			self.turnCount = 1
			return Serial {
				PlayAudio("sfx", "alert", 1, true),
				Telegraph(self, "Alert", {255,255,255,50}),
				Do(function()
					self.scene:addMonster("busted_juggerbot")
				end)
			}
		elseif self.turnCount == 1 then
			local origX, origY = self.sprite.transform.x, self.sprite.transform.y
			return Serial {
				Telegraph(self, "Bomb Drop", {255,255,255,50}),
				Do(function()
					self.sprite:setAnimation("throw")
				end),
				Parallel {
					Ease(self.sprite.transform, "x", target.sprite.transform.x - target.sprite.w*2 - 20, 1, "inout"),
					Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h*2 - self.sprite.h*2 + 40, 1, "inout")
				},
				Wait(1),
				Throw("mine", self.stats, true, true)(self, target),
				
				Wait(1),
				Parallel {
					Ease(self.sprite.transform, "x", origX, 1, "inout"),
					Ease(self.sprite.transform, "y", origY, 1, "inout")
				},
				Do(function()
					self.sprite:setAnimation("idle")
				end)
			}
		end
	end
}