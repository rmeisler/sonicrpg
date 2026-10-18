local TargetType = require "util/TargetType"

return {
	name = "Nutrient Sludge",
	desc = "Recovers hp... but it's gross.",
	target = TargetType.Party,
	usableFromMenu = false,
	unusable = function(target)
		return target.hp == 0
	end,
	icon = "icon_accessory",
	battleAction = function()		
		return function(self, target)
			local Serial = require "actions/Serial"
			local Wait = require "actions/Wait"
			local MessageBox = require "actions/MessageBox"
			local Repeat = require "actions/Repeat"
			local Ease = require "actions/Ease"
			local Do = require "actions/Do"
			local While = require "actions/While"
			local IfElse = require "actions/IfElse"
			local Executor = require "actions/Executor"

			local Heal = require "data/items/actions/Heal"

			local TargetType = require "util/TargetType"
			local ItemType = require "util/ItemType"

			return Serial {
				Heal("hp", 1000)(self, target),
				Wait(0.5),
				-- Can't poison someone wearing Copper Amulet
				IfElse(
					function()
						return (not target.side == TargetType.Party) or
							(not GameState:isEquipped(target.id, ItemType.Accessory, "Copper Amulet"))
					end,
					Serial {
						MessageBox{message="You're starting to feel a little sick...", rect = MessageBox.HEADLINER_RECT},
						Do(function()
							-- Can't poison someone wearing Copper Amulet
							if  target.side == TargetType.Party and
								GameState:isEquipped(target.id, ItemType.Accessory, "Copper Amulet") then
								return
							end

							target.poisoned = {}
							target.poisoned.attack = 5
							target.poisoned.speed = 100
							target.poisoned.luck = 0
							target.poisoned.nomiss = true
							target.poisoned.nonlethal = true

							-- Always fade in and out green
							target.poisonAnim = Executor(target.scene)
							target.poisonAnim:act(While(
								function()
									return target.poisoned
								end,
								Repeat(Serial {
									Ease(target.sprite.color, 2, 400, 1.5),
									Ease(target.sprite.color, 2, 300, 1.5)
								}),
								Ease(target.color, 2, 255, 1)
							))
						end)
					},
					Do(function() end)
				)
			}
		end
	end
}
