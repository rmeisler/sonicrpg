local TargetType = require "util/TargetType"

local Revive = require "data/items/actions/Revive"
local ReviveText = require "data/items/actions/ReviveText"

return {
	name = "Maple Syrup",
	desc = "Revives a fallen ally and recovers hp.",
	target = TargetType.Party,
	usableFromMenu = true,
	icon = "icon_item",
	battleAction = function() return Revive(1000) end,
	menuAction = function() return ReviveText(1000) end
}