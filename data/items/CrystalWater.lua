local TargetType = require "util/TargetType"

return {
	name = "Crystal Water",
	desc = "Revives a fallen ally.",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp > 0
	end,
	icon = "icon_plant",
	cost = {
		plant = 5
	},
	battleAction = function()
		local Revive = require "data/items/actions/Revive"
		return Revive(400)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 400, {0,255,0,255})
	end
}
