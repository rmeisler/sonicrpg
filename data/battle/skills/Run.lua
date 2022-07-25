local TargetType = require "util/TargetType"

return {
	name = "Run Away",
	target = TargetType.Opponent,
	unusable = function(target)
		if target.side == TargetType.Party or
		   target.boss or
		   target.bossPart
		then
			return true
		else
			local numAlive = 0
			for _, mem in pairs(target.scene.party) do
				if mem.hp > 0 then
					numAlive = numAlive + 1
				end
			end
			return numAlive < 2
		end
	end,
	cost = 7,
	desc = "Antoine distracts opponent. Both leave battle.",
	action = require "data/battle/skills/actions/Run"
}