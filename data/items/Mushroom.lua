local TargetType = require "util/TargetType"

return {
	name = "Mushroom",
	desc = "Recovers a little sp.",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_mushroom",
	cost = {
		plant = 3
	},
	battleAction = function()
		local SpHeal = require "data/items/actions/SpHeal"
		return SpHeal("sp", 5)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("sp", 5, {0, 255, 255, 255})
	end
}
