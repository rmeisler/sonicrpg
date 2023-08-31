local TargetType = require "util/TargetType"

return {
	name = "White Leaf",
	desc = "Gives party member 3 turns",
	target = TargetType.Party,
	unusable = function(target)
		return target.side ~= TargetType.Party
	end,
	usableFromMenu = false,
	icon = "icon_plant",
	battleAction = function()
		local TurnInc = require "data/items/actions/TurnInc"
		return function(self, target)
			for i=1,3 do
				table.insert(self.scene.partyTurns, 1, target)
			end
			return TurnInc()(self, target)
		end
	end
}