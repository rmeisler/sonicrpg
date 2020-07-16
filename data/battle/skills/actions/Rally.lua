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
	local counter = 0
	for _, target in pairs(targets) do
		table.insert(
			actions,
			Serial {
				Wait(counter),
				Heal("hp", 50)(self, target)
			}
		)
		counter = counter + 0.3
	end

	return Serial {
		Animate(self.sprite, "victory"),
		MessageBox {
			message="Sally: Let's do it to it!",
			rect=MessageBox.HEADLINER_RECT,
			textSpeed=8,
			closeAction=Wait(0.6)
		},
		
		AudioFade("music", 1.0, 0.0, 2),
		Parallel {
			PlayAudio("music", "sallyrally", 1.0),
			Parallel(actions)
		},
		
		Animate(self.sprite, "idle"),
		PlayAudio("music", "battle", 1.0, true),
	}
end