local TargetType = require "util/TargetType"

return {
	name = "Maple Syrup",
	desc = "Revives a fallen ally. (+1000 hp)",
	target = TargetType.Party,
	usableFromMenu = true,
	icon = "icon_item",
	battleAction = function()
		local Revive = require "data/items/actions/Revive"
		return Revive(1000)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 1000, {0,255,0,255})
	end
}