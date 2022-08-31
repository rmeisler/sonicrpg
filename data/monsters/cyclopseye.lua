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
local MessageBox = require "actions/MessageBox"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Eye",
	altName = "Eye",
	sprite = "sprites/phantomstandin",
	
	hpBarOffset = Transform(550, 150),

	stats = {
		xp    = 50,
		maxhp = 1800,
		attack = 24,
		defense = 15,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	aerial = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
	
	},
	
	scan = "The eye appears to be its weak spot.",
	
	onPreInit = function(self)
		self.sprite.visible = false
	end,
	
	onInit = function(self)
		self.sprite.transform.x = 340
		self.sprite.transform.y = 130
		self.sprite.sortOrderY = -100
		self.getSprite = function(_)
			return self.body:getSprite()
		end
		
		self.turns = 0
	end,

	behavior = function (self, target)
		self.turns = self.turns + 1
		
		if self.turns % 3 == 0 and not self.boulder then
			-- Drop a boulder that we can slam into eye
			local boulder = self.scene:addMonster("boulder")
			local boulderSp = boulder:getSprite()
			boulderSp.transform.y = -100
			boulderSp.transform.x = 530
			boulder.dropShadow.transform.y = boulderSp.transform.y + boulderSp.h - 14

			-- Set ref to boulder
			self.boulder = boulder
			boulder:addHandler("dead", function() self.boulder = nil end)

			return Serial {
				PlayAudio("sfx", "openchasm", 1.0, true),
				Ease(boulder.sprite.transform, "y", 340, 4, "quad"),
				Ease(boulder.sprite.transform, "y", 335, 20, "quad"),
				Ease(boulder.sprite.transform, "y", 340, 20, "quad"),
				Ease(boulder.sprite.transform, "y", 338, 20, "quad"),
				Ease(boulder.sprite.transform, "y", 340, 20, "quad"),
				Ease(boulder.sprite.transform, "y", 338, 20, "quad"),
				Ease(boulder.sprite.transform, "y", 340, 20, "quad")
			}
		end
	
		return Action()
	end,
}