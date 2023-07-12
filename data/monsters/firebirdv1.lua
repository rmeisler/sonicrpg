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
	name = "Firebird 1.0",
	altName = "Firebird 1.0",
	sprite = "sprites/phantomstandin",

	mockSprite = "sprites/firebirdv1",
	mockSpriteOffset = Transform(-210, -100),

	stats = {
		xp    = 50,
		maxhp = 3000,
		attack = 30,
		defense = 100,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "Nah.",

	onAttack = function (self, attacker)
		if self.hp <= 0 then
			return Action()
		end

		
	end,

	onUpdate = function (self, dt)
		
	end,

	behavior = function (self, target)
		-- Starting state, setup
		if self.state == "fire" then
			
		elseif self.state == "ice" then
		end
	end,
}