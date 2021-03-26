local TargetType = require "util/TargetType"

return {
	name = "Flash Grenade",
	desc = "Confuse all bots.",
	target = TargetType.Party,
	icon = "icon_item",
	usableFromMenu = false,
	usableFromBattle = true,
}
