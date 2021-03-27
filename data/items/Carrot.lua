local TargetType = require "util/TargetType"

return {
	name = "Carrot",
	desc = "A tasty produce. Maybe Antoine could use this...",
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
		return Heal("hp", 100)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 100, {0, 255, 0, 255})
	end
}
