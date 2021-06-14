local TargetType = require "util/TargetType"

return {
	name = "Laser Shield",
	desc = "Blocks all laser damage from a single attack.",
	target = TargetType.Party,
	cost = 6,
	subtype = "craft",
	icon = "icon_defense",
	img = "lasershield",
	usableFromMenu = false,
	usableFromBattle = true,
	battleAction = function()
		return (require "data/items/actions/LaserShield")
	end,
}
