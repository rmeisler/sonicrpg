local TargetType = require "util/TargetType"

return {
	name = "Attack",
	target = TargetType.Opponent,
	unusable = function(target, self)
		local ItemType = require "util/ItemType"
		return target.side == TargetType.Party or (target.aerial and not GameState:isEquipped("sally", ItemType.Legs, "Adventurer Boots"))
	end,
	action = require "data/battle/actions/Kick"
}