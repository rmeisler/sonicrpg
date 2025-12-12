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
		return function(self, target)
			return Serial {
				Heal("hp", 200)(self, target),
				SpHeal("sp", 5)(self, target)
			}
		end
	end,
	menuAction = function()
		local Serial = require "actions/Serial"
		local Wait = require "actions/Wait"
		local HealText = require "data/items/actions/HealText"
		local Transform = require "util/Transform"
		return function(target, xform)
			return Serial {
				HealText("hp", 1000, {0, 255, 0, 255})(target, Transform.from(xform)),
				Wait(0.2),
				HealText("sp", 20, {0, 255, 255, 255})(target, Transform.fromoffset(xform, Transform(0, -30)))
			}
		end
	end
}
