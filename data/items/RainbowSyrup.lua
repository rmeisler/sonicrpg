local TargetType = require "util/TargetType"

return {
	name = "Rainbow Syrup",
	desc = "Revives a fallen ally and recovers all hp.",
	target = TargetType.Party,
	usableFromMenu = true,
	icon = "icon_item",
	battleAction = function()
		local Revive = require "data/items/actions/Revive"
		return Revive(9999)
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		return HealText("hp", 9999, {0,255,0,255})
	end
}