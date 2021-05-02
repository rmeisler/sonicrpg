local TargetType = require "util/TargetType"

return {
	name = "Mushroom Bordelaise",
	desc = "A rich french dish by Antoine, recovers sp.",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_item",
	cost = {
		plant = 3
	},
	battleAction = function()
		local SpHeal = require "data/items/actions/SpHeal"
		return SpHeal("sp", 20)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("sp", 20, {0, 255, 255, 255})
	end
}
