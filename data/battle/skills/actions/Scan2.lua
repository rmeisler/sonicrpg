local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local PlayAudio = require "actions/PlayAudio"

local Parallax = require "object/Parallax"

return function(self, target)
	local weaknessMessage = Action()
	if target.scan then
		weaknessMessage = MessageBox {
			message="Nicole: "..target.scan,
			rect=MessageBox.HEADLINER_RECT,
			closeAction=Wait(1.2)
		}
	end
	
	return Serial {
		Animate(self.sprite, "nichole_start"),
		Animate(self.sprite, "nichole_idle"),
		MessageBox {
			message="Nicole: Scanning Sally...",
			rect=MessageBox.HEADLINER_RECT,
			sfx="nichole",
			closeAction=Wait(0.6)
		},
		PlayAudio("sfx", "nicholescan", 1.0, true),
		-- Parallax over enemy
		Do(function()
			target:getSprite():setParallax(2, "blue")
		end),
		Wait(1.6),
		Do(function()
			target:getSprite():removeParallax()
		end),
		weaknessMessage,
		MessageBox {
			message=string.format("%s %d / %d", "Nicole: Remaining HP ", target.hp, target.maxhp),
			rect=MessageBox.HEADLINER_RECT,
			closeAction=Wait(1.2)
		},
		Animate(self.sprite, "nichole_retract"),
		Animate(self.sprite, "idle"),
	}
end