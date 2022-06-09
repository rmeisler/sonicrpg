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

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Cyclops",
	altName = "Cyclops",
	sprite = "sprites/cyclops",

	stats = {
		xp    = 30,
		maxhp = 1000,
		attack = 24,
		defense = 20,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		{item = require "data/items/CrystalWater", count = 1, chance = 0.8},
	},
	
	scan = "Don't attack rover when standing.",

	onPreInit = function(self)
		self.sprite.transform = Transform(-60, 50, 2, 2)
		--self.sprite.transform.x = 0
		--self.sprite.transform.y = self.sprite.transform.y - self.sprite.h/1.5
	end,
	
	onInit = function(self)
		
	end,
	
	behavior = function (self, target)
		return Do(function() end)
	end,
	
	getIdleAnim = function(self)
		if self.state == "upright" or self.state == "transition_to_upright" then
			return "upright"
		else
			return "idle"
		end
	end,
	
	getBackwardAnim = function(self)
		if self.state == "upright" or self.state == "transition_to_upright" then
			return "uprightbackward"
		else
			return "backward"
		end
	end
}