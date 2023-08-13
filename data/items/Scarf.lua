local TargetType = require "util/TargetType"

return {
	name = "Scarf",
	desc = "I hope Sonic isn't too cold without this scarf...",
	target = TargetType.Party,
	icon = "icon_scarf",
	--cost = 3,
	--subtype = "craft",
	usableFromMenu = false,
	usableFromBattle = false,
}
