local TargetType = require "util/TargetType"

return {
	name = "Spicy Curry",
	desc = "Recovers sp and cures poison.",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_mushroom",
	cost = {
		plant = 3
	},
	battleAction = function()
		local Serial = require "actions/Serial"
		local SpHeal = require "data/items/actions/SpHeal"
		local PoisonHeal = require "data/items/actions/PoisonHeal"
		return function(self, target)
			target.poisoned = false
			target.sprite.color[2] = 255
			return Serial {
				PoisonHeal()(self, target),
				SpHeal("sp", 99)
			}
		end
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("sp", 99, {0, 255, 255, 255})
	end
}
