local TargetType = require "util/TargetType"

return {
	name = "Megamuck Balloon",
	desc = "Prevents bot from using physical attacks.",
	target = TargetType.Party,
	icon = "icon_item",
	usableFromMenu = false,
	usableFromBattle = true,
}
