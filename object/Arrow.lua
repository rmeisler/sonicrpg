local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"
local DrawableNode = require "object/DrawableNode"

local Arrow = class(DrawableNode)

function Arrow:construct(scene, transform, color)
	self:addSceneNode("ui")

	self.crossedout = SpriteNode(
		self.scene,
		Transform(transform.x - 8, transform.y + 17),
		{self.color[1], self.color[2], self.color[3],0},
		"crossedout",
		nil,
		nil,
		"ui"
	)
end

function Arrow:crossOut()
	self.crossedout.color[4] = 255
end

function Arrow:unCrossOut()
	self.crossedout.color[4] = 0
end

function Arrow:updateXForm()
	self.crossedout.transform.x = self.transform.x - 8
	self.crossedout.transform.y = self.transform.y + 17
end

function Arrow:remove()
	DrawableNode.remove(self)
	self.crossedout:remove()
end

function Arrow:draw()
	love.graphics.setColor(self.color)
	local verts = {
		self.transform.x + 5 * self.transform.sx,
		self.transform.y + 10 * self.transform.sy,
		self.transform.x,
		self.transform.y + 15 * self.transform.sy,
		self.transform.x - 5 * self.transform.sx,
		self.transform.y + 10 * self.transform.sy
	}
	love.graphics.polygon("fill", verts)
end


return Arrow
