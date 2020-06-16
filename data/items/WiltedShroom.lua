local TargetType = require "util/TargetType"

local Heal = require "data/items/actions/Heal"
local HealText = require "data/items/actions/HealText"

return {
	name = "Wilted Shroom",
	desc = "Recovers hp",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	battleAction = function() return Heal(math.random(150, 300)) end,
	menuAction = function() return HealText(math.random(150, 300)) end
}
