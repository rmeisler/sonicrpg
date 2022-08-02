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

	stats = {
		xp    = 30,
		maxhp = 1400,
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
	end,

	behavior = function (self, target)
		return Action()
	end,
}