local TargetType = require "util/TargetType"

return {
	name = "Laser Shield",
	desc = "Blocks all damage from a single attack.",
	rotor = "If you put one of these babies in front of you, no bot can touch you!... {p40}At least for one attack...",
	target = TargetType.Party,
	cost = 3,
	subtype = "craft",
	icon = "icon_defense",
	img = "lasershield",
	unusable = function(target)
		return target.laserShield
	end,
	usableFromMenu = false,
	usableFromBattle = true,
	battleAction = function()
		return (require "data/items/actions/LaserShield")
	end,
}
