local TargetType = require "util/TargetType"

local Revive = require "data/items/actions/Revive"
local ReviveText = require "data/items/actions/ReviveText"

return {
	name = "Rainbow Syrup",
	desc = "Revives a fallen ally and recovers all hp.",
	target = TargetType.Party,
	usableFromMenu = true,
	battleAction = function() return Revive(10000) end,
	menuAction = function() return ReviveText(10000) end
}
