local Serial = require "actions/Serial"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local IfElse = require "actions/IfElse"
local BouncyText = require "actions/BouncyText"
local YieldUntil = require "actions/YieldUntil"
local Executor = require "actions/Executor"
local While = require "actions/While"
local Spawn = require "actions/Spawn"
local Try = require "actions/Try"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local TargetType = require "util/TargetType"
local ItemType = require "util/ItemType"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local BattleActor = require "object/BattleActor"

local Buzz = require "data/monsters/buzzbomber"

return {
	name = "Buzz Bomber",
	altName = "Buzz Bomber",
	sprite = "sprites/buzzbomber",

	stats = {
		xp    = 20,
		maxhp = 600,
		attack = 35,
		defense = 10,
		speed = 15,
		focus = 5,
		luck = 2,
	},
	
	aerial = true,
	
	hasDropShadow = true,

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/items/RainbowSyrup", count = 1, chance = 0.2},
	},
	
	scan = "Buzz Bomber can't fly if stunned.",
	
	onPreInit = function(self)
		self.scene:addMonster("buzzbomber"):onPreInit()
	end,
	
	onInit = function(self)
		Buzz.onInit(self)
		
		-- Move us forward slightly
		self.sprite.transform.x = self.sprite.transform.x + 100
		self.slot.x = self.slot.x + 100
	end,

	behavior = function (self, target)
		return Buzz.behavior(self, target)
	end
}
