local TargetType = require "util/TargetType"

return {
	name = "EMP Grenade",
	desc = "Bots lose a couple turns.",
	target = TargetType.Party,
	cost = 9,
	subtype = "craft",
	icon = "icon_charge",
	img = "empgrenade",
	usableFromMenu = false,
	usableFromBattle = true,
}
