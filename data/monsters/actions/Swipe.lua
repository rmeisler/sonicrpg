local Serial = require "actions/Serial"
local Ease = require "actions/Ease"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Repeat = require "actions/Repeat"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

return function(self, target)
	return Serial {
		-- Play smack animation
		Animate(function()
			local xform = Transform.from(target.sprite.transform)
			xform.x = xform.x + target.sprite.w - 30
			xform.y = xform.y + target.sprite.h/2
			return SpriteNode(self.scene, xform, nil, "claw"), true
		end, "idle"),

		-- Take damage
		target:takeDamage(self.stats),
	}
end
