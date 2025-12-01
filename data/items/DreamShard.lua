local TargetType = require "util/TargetType"

return {
	name = "Dream Shard",
	desc = "Recovers hp and sp, and revives when fallen.",
	target = TargetType.Party,
	usableFromMenu = true,
	icon = "icon_conk",
	battleAction = function()
		local Serial = require "actions/Serial"
		local Heal = require "data/items/actions/Heal"
		local SpHeal = require "data/items/actions/SpHeal"
		return Serial {
			Heal("hp", 200),
			SpHeal("sp", 5)
		}
	end,
	menuAction = function()
		local Serial = require "actions/Serial"
		local HealText = require "data/items/actions/HealText"
		return Serial {
			HealText("hp", 200, {0, 255, 0, 255}),
			HealText("sp", 5, {0, 255, 255, 255})
		}
	end
}
