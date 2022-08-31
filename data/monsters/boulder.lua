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

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Boulder",
	altName = "Boulder",
	sprite = "sprites/boulder",

	stats = {
		xp    = 0,
		maxhp = 100,
		attack = 40,
		defense = 10,
		speed = 0,
		focus = 0,
		luck = 0,
	},
	
	run_chance = 1.0,
	coin = 0,
	drops = {},
	
	scan = "This a boulder, Sally",
	
	hasDropShadow = true,
	skipAnimation = true,
	
	behavior = function (self, target)
		return Action()
	end
}