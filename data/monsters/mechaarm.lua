local Serial = require "actions/Serial"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"

local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Mecha Arm",
	altName = "Mecha Arm",
	sprite = "sprites/mechaarm",

	stats = {
		xp    = 5,
		maxhp = 100,
		attack = 15,
		defense = 15,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		
	},

	behavior = function (self, target)
		return Action()
	end,
	
	onDead = function(self)
		return Action()
	end
}