local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"

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
				Heal("hp", 400)(self, target),
				Do(function()
					target.state = target.STATE_IDLE
				end)
			}
		)
		table.insert(resetActions, Animate(target.sprite, "idle"))
	end

	local prevMusic = self.scene.audio:getCurrentMusic()
	return Serial {
		Animate(self.sprite, "victory"),
		Parallel {
			self:hop(),
			MessageBox {
				message="Baby T: We can do this!",
				rect=MessageBox.HEADLINER_RECT,
				textSpeed=8,
				closeAction=Wait(1)
			},
			Serial {
				AudioFade("music", 1.0, 0.0, 2),
				Parallel {
					PlayAudio("music", "babyt", 1.0),
					Parallel(actions)
				}
			}
		},

		Animate(self.sprite, "idle"),
		Parallel(resetActions),
		PlayAudio("music", prevMusic, 1.0, true, true),
	}
end