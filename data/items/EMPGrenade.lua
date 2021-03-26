local TargetType = require "util/TargetType"

return {
	name = "EMP Grenade",
	desc = "Bots lose a couple turns.",
	target = TargetType.Party,
	icon = "icon_item",
	usableFromMenu = false,
	usableFromBattle = true,
}
