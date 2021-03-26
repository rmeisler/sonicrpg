local TargetType = require "util/TargetType"

return {
	name = "Water Balloon",
	desc = "Mildly annoying to some, devastating to others.",
	target = TargetType.Party,
	icon = "icon_item",
	usableFromMenu = false,
	usableFromBattle = true,
}
