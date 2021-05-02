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

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"

return {
	name = "Juggerbot",
	altName = "Juggerbot",
	sprite = "sprites/juggerbot",

	stats = {
		xp    = 100,
		maxhp = 2000,
		attack = 20,
		defense = 30,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		{item = require "data/items/MetallicPlate", count = 2, chance = 0.8},
	},
	
	scan = "Juggerbot is succeptible to water damage.",

	behavior = function (self, target)
		-- Init state vars
		if not self.grabCount then
			self.grabCount = 0
		end
	
		-- Starting state (2x grab, 1x punch, repeat)
		if self.hp > 1000 then
			if self.grabCount < 2 then
				-- Grab
				
				self.grabCount = self.grabCount + 1
			else
				-- Punch
				
				self.grabCount = 0
			end
		-- Weakened state (2x grab, 1x pound, repeat)
		else
			if self.grabCount < 2 then
				-- Grab
				
				self.grabCount = self.grabCount + 1
			else
				-- Punch
				
				self.grabCount = 0
			end
		end
	end
}