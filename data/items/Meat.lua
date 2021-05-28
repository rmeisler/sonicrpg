local TargetType = require "util/TargetType"

return {
	name = "Meat",
	desc = "Wait... what is this made of?!",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_meat",
	cost = {
		plant = 3
	},
	battleAction = function()
		local Heal = require "data/items/actions/Heal"
		return Heal("hp", 150)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 150, {0, 255, 0, 255})
	end
}
