local TargetType = require "util/TargetType"

return {
	name = "Gear",
	desc = "Maybe Rotor can find some use for this",
	icon = "icon_accessory",
	subtype = "junk",
	target = TargetType.Party,
	usableFromMenu = false,
	usableFromBattle = false,
}
