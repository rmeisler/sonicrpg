local Transform = require "util/Transform"

local DrawableNode = class(require "object/SceneNode")

function DrawableNode:construct(scene, transform, color)
	self.transform = transform or Transform()
	self.color = color or {255,255,255,255}
end


return DrawableNode