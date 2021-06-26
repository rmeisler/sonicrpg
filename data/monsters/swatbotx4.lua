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

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

local Swatbot = require "data/monsters/swatbot"

return {
	name = "Swatbot",
	altName = "Swatbot",
	sprite = "sprites/swatbot",

	stats = {
		xp    = 5,
		maxhp = 100,
		attack = 12,
		defense = 15,
		speed = 5,
		focus = 0,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},
	
	scan = "Swatbots are succeptible to water damage.",

	onPreInit = function(self)
		for i=1,3 do
			self.scene:addMonster("swatbot"):onPreInit()
		end
	end,
	
	behavior = function (self, target)
		return Swatbot.behavior(self, target)
	end
}