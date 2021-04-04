local TargetType = require "util/TargetType"

return {
	name = "Water Balloon",
	desc = "Mildly annoying to some, devastating to others.",
	rotor = "These are surprisingly effective against Swatbutts!",
	target = TargetType.Party,
	icon = "icon_attack",
	cost = 3,
	subtype = "craft",
	img = "blueballoon",
	usableFromMenu = false,
	usableFromBattle = true,
}
