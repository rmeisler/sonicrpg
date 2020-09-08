local Serial = require "actions/Serial"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"

local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Cambot",
	altName = "Cambot",
	sprite = "sprites/cambot",

	stats = {
		xp    = 5,
		maxhp = 60,
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
		if not self.firstTurnOver or #self.scene.opponents == 3 then
			self.firstTurnOver = true
			self.scene.audio:playSfx("cambotpic", 1.0)
			return Telegraph(self, "Cambot is focusing its lens...", {255,255,255,50})
		-- If there's less than 3 opponents (cambot + 2 swatbots), spawn another swatbot
		else
			return Serial {
				Telegraph(self, "Intruder alert!", {255,255,255,50}),
				Do(function()
					self.scene:addMonster("swatbot")
				end)
			}
		end
	end
}