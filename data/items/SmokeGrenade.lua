local TargetType = require "util/TargetType"

return {
	name = "Smoke Grenade",
	desc = "Escape battle, only for non-boss.",
	target = TargetType.AllOpponents,
	cost = 6,
	subtype = "craft",
	icon = "icon_charge",
	usableFromMenu = false,
	usableFromBattle = true,
	unusable = function(target)
		return target.boss
	end,
	battleAction = function()
		local Serial = require "actions/Serial"
		local Parallel = require "actions/Parallel"
		local Do = require "actions/Do"
		local Ease = require "actions/Ease"
		return function(self, targets)
			local actions = {}
			for _,target in pairs(targets) do
				table.insert(actions, Serial {
				Ease(target:getSprite().color, 4, 0, 1),
				Do(function()
					target.hp = 0
					target.state = target.STATE_DEAD
					target:invoke("dead")
				end)
			})
			end
			return Parallel(actions)
		end
	end,
}
