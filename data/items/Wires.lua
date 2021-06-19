local TargetType = require "util/TargetType"

return {
	name = "Wires",
	desc = "Some scrap bot parts.",
	target = TargetType.Party,
	icon = "icon_accessory",
	subtype = "junk",
	usableFromMenu = false,
	usableFromBattle = false
}
