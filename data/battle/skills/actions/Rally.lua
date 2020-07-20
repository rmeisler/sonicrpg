local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"

local Parallax = require "object/Parallax"
local Heal = require "data/items/actions/Heal"

return function(self, targets)
	local actions = {}
	local resetActions = {}
	for _, target in pairs(targets) do
		table.insert(
			actions,
			Serial {
				Animate(target.sprite, "victory"),
				Wait(0.1),
				Heal("hp", 200)(self, target)
			}
		)
		table.insert(resetActions, Animate(target.sprite, "idle"))
	end

	return Serial {
		MessageBox {
			message="Sally: We can do this guys...",
			rect=MessageBox.HEADLINER_RECT,
			textSpeed=8,
			closeAction=Wait(0.6)
		},
		
		Animate(self.sprite, "victory"),
		Parallel {
			MessageBox {
				message="Sally: Let's do it to it!",
				rect=MessageBox.HEADLINER_RECT,
				textSpeed=8,
				closeAction=Wait(0.6)
			},
			Serial {
				AudioFade("music", 1.0, 0.0, 2),
				Parallel {
					PlayAudio("music", "sallyrally", 1.0),
					Parallel(actions)
				}
			}
		},
		
		Animate(self.sprite, "idle"),
		Parallel(resetActions),
		PlayAudio("music", "battle", 1.0, true),
	}
end