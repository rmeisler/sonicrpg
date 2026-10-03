local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

return function(self, target)
	if not self.stats.miss then
		target.noPower = true
	end

	return Serial {
		Animate(self.sprite, "nichole_start"),
		Animate(self.sprite, "nichole_idle"),
		
		MessageBox {
			message="Nicole: Draining power from "..target.name.."...",
			rect=MessageBox.HEADLINER_RECT,
			sfx="nichole",
			closeAction=Wait(0.6)
		},
		
		PlayAudio("sfx", "nicholescan", 1.0, true),
		-- Parallax over enemy
		Do(function()
			target:getSprite():setParallax(2)
		end),
		Wait(1.6),
		Do(function()
			target:getSprite():removeParallax()
		end),
		
		target.onDrain and target:onDrain() or Action(),
		
		self.stats.miss and
			MessageBox{
				message=target.name.." is unaffected.",
				rect=MessageBox.HEADLINER_RECT,
				closeAction=Wait(0.6)
			} or
			MessageBox {
				message=target.name.." is out of juice!",
				rect=MessageBox.HEADLINER_RECT,
				closeAction=Wait(0.6)
			},
		
		Animate(self.sprite, "nichole_retract"),
		Animate(self.sprite, "idle"),
	}
end