local TargetType = require "util/TargetType"

return {
	name = "Sauteed Onions",
	desc = "A rich french dish by Antoine, recovers hp and sp.",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_item",
	cost = {
		plant = 3
	},
	battleAction = function()
		local Heal = require "data/items/actions/Heal"
		local Serial = require "actions/Serial"
		return function(self, target)
			return Serial {
				Heal("hp", 1000)(self, target),
				Heal("sp", 20)(self, target)
			}
		end
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		local Serial = require "actions/Serial"
		return function(self, target)
			return Serial {
				HealText("hp", 1000, {0, 255, 0, 255}),
				HealText("sp", 20, {0, 255, 255, 255})
			}
		end
	end
}
