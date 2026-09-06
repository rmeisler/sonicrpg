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
	unusable = function(targets)
		for _,v in pairs(targets) do
			if v.is_boss then
				return true
			end
		end
		return false
	end,
	battleAction = function()
		local Serial = require "actions/Serial"
		local Do = require "actions/Do"
		return function(targets)
			local actions = {}
			for _,v in pairs(targets) do
				table.insert(actions, Do(function()
					target.hp = 0
					target.state = target.STATE_DEAD
					targetSp:remove()
					target:invoke("dead")
				end))
			end
			return Serial(actions)
		end
	end,
}
