local TargetType = require "util/TargetType"

return {
	name = "Flash Grenade",
	desc = "Confuse all bots.",
	target = TargetType.Party,
	cost = 6,
	subtype = "craft",
	icon = "icon_charge",
	img = "flashgrenade",
	usableFromMenu = false,
	usableFromBattle = true,
}
