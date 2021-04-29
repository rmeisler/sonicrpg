local TargetType = require "util/TargetType"

return {
	name = "Power Ring",
	desc = "A powerful item that only Sonic can use...",
	target = TargetType.Party,
	usableFromMenu = false,
	usableFromBattle = false,
	unusable = function(target)
		return target.id ~= "sonic"
	end,
	icon = "icon_ring",
	battleAction = function()
		local Heal = require "data/items/actions/Heal"
		return Heal("hp", 100)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 100, {0, 255, 0, 255})
	end
}
