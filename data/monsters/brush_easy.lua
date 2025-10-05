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
	name = "Weed",
	altName = "Weed",
	sprite = "sprites/brush",

	stats = {
		xp    = 0,
		maxhp = 100,
		attack = 50,
		defense = 10,
		speed = 0,
		focus = 0,
		luck = 0,
	},

	transient = true,
	run_chance = 1.0,
	coin = 0,
	drops = {},
	
	scan = "This a weed, Sally",

	skipAnimation = true,
	
	onDrop = function (self, carrier, target)
		local targetSprite = target:getSprite()
		return Serial {
			Do(function()
				target.state = target.STATE_IMMOBILIZED
				target.noEscape = true
			end),

			Ease(targetSprite.transform, "x", function() return targetSprite.transform.x - 5 end, 6),
			Ease(targetSprite.transform, "x", function() return targetSprite.transform.x + 5 end, 6)
		}
	end,

	onInit = function(self)
		self.scene:addMonster("flower")
		self.scene:addMonster("brush_spawn")
	end,
	
	behavior = function (self, target)
		return Action()
	end
}