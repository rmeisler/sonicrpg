local TargetType = require "util/TargetType"

return {
	name = "Metallic Plate",
	desc = "Can block laser fire in battle",
	target = TargetType.None,
	icon = "icon_item",
	usableFromMenu = false,
	usableFromBattle = true,
}
