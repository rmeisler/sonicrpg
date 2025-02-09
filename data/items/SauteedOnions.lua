local TargetType = require "util/TargetType"

return {
	name = "Sauteed Onions",
	desc = "A rich french dish by Antoine, recovers hp and sp.",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_item",
	cost = {
		plant = 3
	},
	battleAction = function()
		local Heal = require "data/items/actions/Heal"
		local SpHeal = require "data/items/actions/SpHeal"
		local Serial = require "actions/Serial"
		return function(self, target)
			return Serial {
				Heal("hp", 1000)(self, target),
				SpHeal("sp", 20)(self, target)
			}
		end
	end,
	menuAction = function()
		local HealText = require "data/items/actions/HealText"
		local Serial = require "actions/Serial"
		local Wait = require "actions/Wait"
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
