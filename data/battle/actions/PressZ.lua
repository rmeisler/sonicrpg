local Action = require "actions/Action"
local Parallel = require "actions/Parallel"
local Animate = require "actions/Animate"
local Try = require "actions/Try"
local Trigger = require "actions/Trigger"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

return function(self, target, success, fail)
	return Parallel {
		-- Press Z!
		Animate(function()
			local xform = Transform.from(target.sprite.transform)
			xform.x = xform.x + target.sprite.w
			return SpriteNode(self.scene, xform, nil, "pressz", nil, nil, "ui"), true
		end, "idle"),
		
		-- If they press z fast enough, reduce damage
		Try(
			Trigger("z", true),
			success or Action(),
			fail or Action(),
			0.2
		)
	}
end
