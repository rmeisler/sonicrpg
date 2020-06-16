local Action = require "actions/Action"
local Parallel = require "actions/Parallel"
local Animate = require "actions/Animate"
local Try = require "actions/Try"
local Trigger = require "actions/Trigger"

local SpriteNode = require "object/SpriteNode"

return function(self, target, success, fail, timeout)
	return Parallel {
		-- Press X!
		Animate(function()
			return SpriteNode(self.scene, target.sprite.transform, nil, "pressx", nil, nil, "ui"), true
		end, "idle"),
		
		-- If they press x fast enough, success! Otherwise fail
		Try(
			Trigger("x", true),
			success or Action(),
			fail or Action(),
			timeout or 0.2
		)
	}
end
