local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local Ease = require "actions/Ease"

return function(self, targets)
	local afraidActions = {
		Animate(self.sprite, "roar"),
		self.scene:screenShake(20, 30, 15)
	}
	for _, target in pairs(targets) do
		table.insert(
			afraidActions,
			Serial {
				Animate(target.sprite, "hurt"),
				Repeat(Serial {
					Ease(target.sprite.transform, "x", function() return target.sprite.transform.x - 3 end, 8),
					Ease(target.sprite.transform, "x", function() return target.sprite.transform.x + 3 end, 8)
				}, 4),
				Do(function()
					local targetDebuffStats = table.clone(target.stats)
					targetDebuffStats.defense = target.stats.defense * 0.5
					target:pushStats(targetDebuffStats)
					target.state = target.STATE_IDLE
					target.sprite:setAnimation("idle")
				end)
			}
		)
	end

	return Serial {
		PlayAudio("sfx", "babytroar", 1.0, true),
		Parallel(afraidActions),

		MessageBox {
			message="Opponents are afraid! Defense reduced by 50%!",
			rect=MessageBox.HEADLINER_RECT,
			textSpeed=8,
			closeAction=Wait(0.6)
		},
		Do(function()
			self.sprite:setAnimation("idle")
		end),
	}
end