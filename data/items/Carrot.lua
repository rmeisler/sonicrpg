local TargetType = require "util/TargetType"

return {
	name = "Carrot",
	desc = "Recovers a little hp",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_carrot",
	cost = {
		plant = 3
	},
	battleAction = function()
		local Heal = require "data/items/actions/Heal"
		return Heal("hp", 100)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 100, {0, 255, 0, 255})
	end
}
