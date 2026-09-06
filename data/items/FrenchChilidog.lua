local TargetType = require "util/TargetType"

return {
	name = "French Chilidog",
	desc = "Recovers 3000 hp. Only for Sonic.",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.id ~= "sonic"
	end,
	icon = "icon_item",
	battleAction = function()
		local Heal = require "data/items/actions/Heal"
		return Heal("hp", 3000)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 3000, {0, 255, 0, 255})
	end
}
