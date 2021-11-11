local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local Parallax = class(require "object/SceneNode")

function Parallax.ForBattle(scene, imgsrc, speedx, speedy)
	local layer = {}
	layer.image = scene.images[imgsrc]
	layer.x = 0
	layer.y = 0
	layer.properties = {speedx = speedx, speedy = speedy}
	layer.draw = function()
		love.graphics.draw(layer.image, layer.x, layer.y)
	end
	return Parallax(scene, layer)
end

function Parallax:construct(scene, layer)
	self.layer = layer
	self.w = self.layer.image:getWidth()
	self.h = self.layer.image:getHeight()
	self.curLayerX = self.layer.x

	-- Parallax images are drawn as a 4x4 tile, stitched together by drawing the
	-- image four times, at (0,0), (-screenwidth,0), (-screenwidth,-screenheight), and (0,-screenheight)
	local oneDraw = self.layer.draw
	self.layer.draw = function()
		local offsets = {
			Transform(),
			Transform(self.w, 0),
			Transform(-self.w, 0),
			Transform(-self.w, -self.h),
			Transform(0, self.h),
			Transform(0, -self.h),
			Transform(self.w, self.h),
		}
		local orig = Transform(self.layer.x, self.layer.y)
		for _,o in pairs(offsets) do
			self.layer.x = orig.x + o.x
			self.layer.y = orig.y + o.y
			oneDraw()
		end
		self.layer.x = orig.x
		self.layer.y = orig.y
	end
	
	self.dx = self.layer.properties.speedx or 0
	self.dy = self.layer.properties.speedy or 0
	self.sticky = true
	
	self:addSceneHandler("update", Parallax.update)
end

function Parallax:draw()
	-- Hack: only called from SpriteNode:draw during drawWithParallax
	self.layer.draw()
end

function Parallax:update(dt)
	if math.ceil(self.scene.player.x + love.graphics.getWidth()/2) > math.ceil(self.curLayerX + self.w*2) then
		self.curLayerX = self.curLayerX + self.w*2
		self.layer.offsetx = self.curLayerX
	end
end


return Parallax