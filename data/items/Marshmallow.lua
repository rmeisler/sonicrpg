local TargetType = require "util/TargetType"

return {
	name = "Marshmallow",
	desc = "Recovers hp and sp.",
	target = TargetType.Party,
	usableFromMenu = true,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_marshmallow",
	cost = {
		plant = 10
	},
	battleAction = function()
		local Action = require "actions/Action"
		local Telegraph = require "data/monsters/actions/Telegraph"
		local Wait = require "actions/Wait"
		local MessageBox = require "actions/MessageBox"
		local Serial = require "actions/Serial"
		local Heal = require "data/items/actions/Heal"
		local SpHeal = require "data/items/actions/SpHeal"
		return function(self, target)
			local extraAction = Action()
			-- Giving marshmallow to yeti makes him happy
			if target.name == "Yeti" then
				target.turns = 3
				target.angry = false
				target.gaveMarshmallow = self.name
				GameState:setFlag("ep4_abominable_"..self.id)
				extraAction = Serial {
					Telegraph(target, "Yeti looks happy!", {255,255,255,50}),
					MessageBox {message="Yeti: F-{p60}Friend.", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)}
				}
			end
			return Serial {
				Heal("hp", 1000)(self, target),
				SpHeal("sp", 10)(self, target),
				extraAction
			}
		end
	end,
	menuAction = function()
		local Serial = require "actions/Serial"
		local HealText = require "data/items/actions/HealText"
		return function(self, transform)
			return Serial {
				HealText("hp", 1000, {0,255,0,255})(self, transform),
				HealText("sp", 10, {0,255,255,255})(self, transform),
			}
		end
	end
}
