local Serial = require "actions/Serial"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"

local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Factory Bot",
	altName = "Factory Bot",
	sprite = "sprites/factorybot",

	stats = {
		xp    = 5,
		maxhp = 300,
		attack = 15,
		defense = 15,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/items/GreenLeaf", count = 1, chance = 0.2},
	},

	behavior = function (self, target)
		-- If there's less than 3 opponents (cambot + 2 swatbots), spawn another swatbot
		if #self.scene.opponents < 3 then
			return Serial {
				Telegraph(self, "Intruder alert!", {255,255,255,50}),
				Do(function()
					self.scene:addMonster("swatbot")
				end)
			}
		end
	end
}