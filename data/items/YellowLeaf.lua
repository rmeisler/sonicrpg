local TargetType = require "util/TargetType"

return {
	name = "Yellow Leaf",
	desc = "Grants xp",
	target = TargetType.Party,
	usableFromMenu = true,
	usableFromBattle = false,
	icon = "icon_plant",
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("xp", 20, {255, 255, 0, 255})
	end
}
