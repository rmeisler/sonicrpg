local Serial = require "actions/Serial"
local Ease = require "actions/Ease"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Repeat = require "actions/Repeat"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"

local Telegraph = require "data/monsters/actions/Telegraph"
local Block = require "data/battle/actions/Block"

return function(self, target)
	return Serial {
		Telegraph(
			self,
			target,
			"Frost Bite",
			{self.sprite.color[1], 800, 800, self.sprite.color[4]}
		),
		
		-- Play animation over target player
		Ease(target.sprite.color, 3, 1500, 2),
		Wait(1),
		Ease(target.sprite.color, 3, 255, 2),
		
		Block(self, target)
	}
end
