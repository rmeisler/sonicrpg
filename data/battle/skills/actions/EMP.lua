local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

return function(self, targets)
	local actions = {}
	for _, target in pairs(targets) do
		table.insert(
			actions,
			Serial {
				Animate(target:getSprite(), "hurt"),
				Wait(0.1),
				Animate(function()
					local xform = Transform.from(target:getSprite().transform)
					xform.x = xform.x - 50
					xform.y = xform.y - 50
					return SpriteNode(self.scene, xform, nil, "lightning", nil, nil, "ui"), true
				end, "idle"),
				Do(function()
					target.state = target.STATE_IMMOBILIZED
				end),
				Wait(1),
				Animate(target:getSprite(), "idle")
			}
		)
	end

	local prevMusic = self.scene.audio:getCurrentMusic()
	return Serial {
		Animate(self.sprite, "focus"),
		Wait(1),
		Parallel(actions),
		PlayAudio("sfx", "shocked", 1, true),
		Animate(self.sprite, "idle"),
	}
end