local TargetType = require "util/TargetType"

return {
	name = "Blue Leaf",
	desc = "Recovers sp",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_plant",
	battleAction = function()
		local SpHeal = require "data/items/actions/SpHeal"
		return SpHeal("sp", 10)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("sp", 10, {0, 255, 255, 255})
	end
}
