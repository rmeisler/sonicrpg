local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

return function(self, targets)
	local actions = {PlayAudio("music", "boring", 1.0)}
	for _, target in pairs(targets) do
		target.sweatdrop = SpriteNode(
			target.scene,
			Transform(target.sprite.transform.x + target.sprite.w/2, target.sprite.transform.y, 2, 2),
			{255, 255, 255, 0},
			"sweatdrop",
			nil,
			nil,
			"ui"
		)
		table.insert(
			actions,
			Serial {
				Wait(1.5),
				Parallel {
					Ease(target.sweatdrop.transform, "y", target.sweatdrop.transform.y + 20, 0.5, "inout"),
					Ease(target.sweatdrop.color, 4, 255, 0.5, "inout")
				},
				Wait(0.5),
				Ease(target.sweatdrop.color, 4, 0, 1, "inout"),
				Do(function()
					target.sweatdrop:remove()
					target.lostTurns = target.lostTurns + 1
					target.sprite:setAnimation("backward")
				end)
			}
		)
	end

	return Serial {
		MessageBox {
			rect=MessageBox.HEADLINER_RECT,
			message="Antoine: Ah-- the Great Maurice D'epardieu...",
			textSpeed=8,
			closeAction=Wait(0.6)
		},
		
		Animate(self.sprite, "victory"),
		Parallel {
			Serial {
				MessageBox {
					message="...yes he was my grandfather! Brave and true!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(0.6)
				},
				MessageBox {
					message="He made a fine duck confit...",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(0.6)
				},
				MessageBox {
					message="...ze favorite dish of ze Acorn family!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(0.6)
				},
			},
			Serial {
				AudioFade("music", 1.0, 0.0, 2),
				Parallel(actions)
			}
		},
		
		Animate(self.sprite, "idle"),
		PlayAudio("music", "battle", 1.0, true),
	}
end