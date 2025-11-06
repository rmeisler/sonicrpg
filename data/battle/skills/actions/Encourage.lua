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
local Revive = require "data/items/actions/Revive"

return function(self, target)
	return Serial {
		MessageBox {
			message="B: Hang in there...",
			rect=MessageBox.HEADLINER_RECT,
			textSpeed=8,
			closeAction=Wait(0.6)
		},
		
		Animate(self.sprite, "victory"),
		Parallel {
			MessageBox {
				message="B: You've got what it takes!",
				rect=MessageBox.HEADLINER_RECT,
				textSpeed=8,
				closeAction=Wait(0.6)
			},
			Revive(1000)(self, target)
		},
		
		Animate(self.sprite, "idle"),
	}
end