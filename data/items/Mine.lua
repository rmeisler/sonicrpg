local TargetType = require "util/TargetType"

return {
	name = "Mine",
	desc = "Throw to damage enemies.",
	rotor = "It can deal damage to even the toughest bots!",
	target = TargetType.Opponent,
	usableFromMenu = false,
	icon = "icon_charge",
	cost = 3,
	subtype = "craft",
	img = "mine",
	battleAction = function()
		local Throw = require "data/items/actions/Throw"
		return Throw("mine", {attack = 9, speed = 0, luck = 0})
	end
}
