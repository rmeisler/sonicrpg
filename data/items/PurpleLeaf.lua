local TargetType = require "util/TargetType"

return {
	name = "Purple Leaf",
	desc = "Cures poison.",
	target = TargetType.Party,
	usableFromMenu = false,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_plant",
	battleAction = function()
		local PoisonHeal = require "data/items/actions/PoisonHeal"
		return function(self, target)
			target.poisoned = false
			target.sprite.color[2] = 255
			return PoisonHeal()(self, target)
		end
	end
}
