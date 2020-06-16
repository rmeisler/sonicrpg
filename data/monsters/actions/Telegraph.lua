local MessageBox = require "actions/MessageBox"
local Repeat = require "actions/Repeat"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Wait = require "actions/Wait"

return function(self, msg, flashColor)
	return Serial {
		Wait(0.5),
		Parallel {
			MessageBox {message=msg, rect=MessageBox.HEADLINER_RECT, closeAction=Wait(0.6)},
			Repeat(Serial {
				Parallel {
					Ease(self.sprite.color, 1, flashColor[1], 10, "linear"),
					Ease(self.sprite.color, 2, flashColor[2], 10, "linear"),
					Ease(self.sprite.color, 3, flashColor[3], 10, "linear"),
					Ease(self.sprite.color, 4, flashColor[4], 10, "linear"),
				},
				Parallel {
					Ease(self.sprite.color, 1, self.sprite.color[1], 10, "linear"),
					Ease(self.sprite.color, 2, self.sprite.color[2], 10, "linear"),
					Ease(self.sprite.color, 3, self.sprite.color[3], 10, "linear"),
					Ease(self.sprite.color, 4, self.sprite.color[4], 10, "linear"),
				}
			}, 2)
		}
	}
end