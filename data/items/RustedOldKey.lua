local TargetType = require "util/TargetType"

return {
	name = "Rusty Old Key",
	desc = "This must open some door in Iron Lock...",
	target = TargetType.Party,
	icon = "icon_key",
	usableFromMenu = false,
	usableFromBattle = false
}
