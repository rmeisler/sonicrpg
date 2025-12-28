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

return function(self, target)
	return Serial {
		Animate(self.sprite, "victory"),
		Parallel {
			MessageBox {
				message=target.id == "babyt" and "Baby T: I gotta be strong!" or "Baby T: I'm grateful to know you!",
				rect=MessageBox.HEADLINER_RECT,
				textSpeed=8,
				closeAction=Wait(1)
			},
			Serial {
				Wait(0.5),
				Heal("hp", 400)(self, target)
			}
		},
		
		Animate(self.sprite, "idle"),
	}
end