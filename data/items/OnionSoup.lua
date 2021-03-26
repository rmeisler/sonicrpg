local TargetType = require "util/TargetType"

return {
	name = "Onion Soup",
	desc = "A rich french dish by Antoine, recovers hp.",
	target = TargetType.AllParty,
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
		return Heal("hp", 1000)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 1000, {0, 255, 0, 255})
	end
}
