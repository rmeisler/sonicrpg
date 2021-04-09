local TargetType = require "util/TargetType"

return {
	name = "Laser Shield",
	desc = "Can block laser fire in battle.",
	target = TargetType.None,
	cost = 6,
	subtype = "craft",
	icon = "icon_defense",
	img = "lasershield",
	usableFromMenu = false,
	usableFromBattle = true,
}
