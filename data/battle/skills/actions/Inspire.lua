local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"

local Parallax = require "object/Parallax"
local Stars = require "data/battle/actions/Stars"

return function(self, targets)
	local actions = {}
	local resetActions = {}
	for _, target in pairs(targets) do
		table.insert(
			actions,
			Serial {
				Animate(target.sprite, "victory"),
				Wait(0.1),
				Do(function()
					target.sprite:setGlow({255,255,255,255},2)
					target.state = target.STATE_IDLE
					target.turnsImmobilized = false
					target.poisoned = nil
				end),
				Parallel {
					Ease(target.sprite.glowColor, 4, 50, 3),
					Ease(target.sprite, "glowSize", 6, 3),
					Ease(target.sprite.color, 1, 500, 3),
					Ease(target.sprite.color, 2, 500, 3),
					Ease(target.sprite.color, 3, 500, 3)
				},
				PlayAudio("sfx", "poptop", 1.0, true),
				Stars(self, target),
				Do(function()
					target.hp = math.max(1, target.hp)
				end),
				Parallel {
					Ease(target.sprite.glowColor, 4, 0, 6, "quad"),
					Ease(target.sprite, "glowSize", 2, 6, "quad"),
					Ease(target.sprite.color, 1, 255, 6, "quad"),
					Ease(target.sprite.color, 2, 255, 6, "quad"),
					Ease(target.sprite.color, 3, 255, 6, "quad")
				},
				Do(function()
					target.sprite:removeGlow()
				end)
			}
		)
		table.insert(resetActions, Animate(target.sprite, "idle"))
	end

	local prevMusic = self.scene.audio:getCurrentMusic()
	return Serial {
		Animate(self.sprite, "victory"),
		MessageBox {
			message="Sally: Freedom Fighters never give up!",
			rect=MessageBox.HEADLINER_RECT,
			textSpeed=8,
			closeAction=Wait(0.6)
		},
		Parallel {
			MessageBox {
				message="Sally: Let's do it to it!",
				rect=MessageBox.HEADLINER_RECT,
				textSpeed=8,
				closeAction=Wait(0.6)
			},
			Serial {
				AudioFade("music", 1.0, 0.0, 2),
				Parallel {
					PlayAudio("music", "sallyrally", 1.0),
					Parallel(actions)
				},
				MessageBox {
					message="All party members recovered!",
					rect=MessageBox.HEADLINER_RECT,
					textSpeed=8,
					closeAction=Wait(0.6)
				}
			}
		},
		
		Animate(self.sprite, "idle"),
		Parallel(resetActions),
		PlayAudio("music", prevMusic, 1.0, true, true),
	}
end