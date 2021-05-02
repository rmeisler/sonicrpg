local TargetType = require "util/TargetType"

return {
	name = "Scrap Metal",
	desc = "Maybe Rotor can find a use for this...",
	target = TargetType.Party,
	icon = "icon_accessory",
	subtype = "junk",
	usableFromMenu = false,
	usableFromBattle = false,
}
