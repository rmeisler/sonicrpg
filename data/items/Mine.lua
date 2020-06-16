local TargetType = require "util/TargetType"

return {
	name = "Mine",
	desc = "Throw to damage enemies",
	target = TargetType.Opponent,
	usableFromMenu = false,
	icon = "icon_item",
	battleAction = function()
		local Throw = require "data/items/actions/Throw"
		return Throw("mine", {attack = 9, speed = 0, luck = 0})
	end
}
