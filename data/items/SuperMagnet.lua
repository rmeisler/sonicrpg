local TargetType = require "util/TargetType"

return {
	name = "Super Magnet",
	desc = "All bots are paralyzed for entire battle.",
	target = TargetType.Party,
	cost = 9,
	subtype = "craft",
	icon = "icon_charge",
	img = "supermagnet",
	usableFromMenu = false,
	usableFromBattle = true,
}
