local TargetType = require "util/TargetType"

return {
	name = "Rainbow Nectar",
	desc = "Revives all fallen allies and recovers all hp.",
	target = TargetType.AllParty,
	usableFromMenu = false,
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