local TargetType = require "util/TargetType"

return {
	name = "Power Ring",
	desc = "Increases Sonic's stats for a single battle.",
	target = TargetType.Party,
	usableFromMenu = false,
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
