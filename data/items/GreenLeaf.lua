local TargetType = require "util/TargetType"

return {
	name = "Green Leaf",
	desc = "Recovers hp",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_plant",
	battleAction = function()
		local Heal = require "data/items/actions/Heal"
		return Heal("hp", 400)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 400)
	end
}
