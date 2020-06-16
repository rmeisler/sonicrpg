local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Wait = require "actions/Wait"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

return function(self, target)
	return Serial {
		Animate(self.sprite, "nichole_start"),
		Animate(self.sprite, "nichole_idle"),
		
		MessageBox {
			message="Sally: Nicole, Laser!",
			rect=MessageBox.HEADLINER_RECT,
			sfx="nichole",
			closeAction=Wait(0.3)
		},
	
		Animate(function()
			local xform = Transform.from(self.sprite.transform)
			xform.x = xform.x + 14 * 2
			xform.y = xform.y + 33 * 2
			return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
		end, "idle"),
		
		PlayAudio("sfx", "lasersweep", 1.0, true),
		
		Do(function()
			self.beamSprite.transform.x = self.sprite.transform.x + 14 * 2
			self.beamSprite.transform.y = self.sprite.transform.y + 33 * 2
			self.beamSprite.transform.angle = -math.pi/6
		end),
		
		Ease(self.beamSprite.transform, "sx", 20.0, 12, "linear"),
		Ease(self.beamSprite.transform, "angle", math.pi/6, 1, "linear"),
		
		-- Hide beam sprite
		Do(function()
			self.beamSprite.transform.sx = 0
			self.beamSprite.transform.angle = 0
		end),
		
		Parallel(dmgAllPartyMembers)
	}
end