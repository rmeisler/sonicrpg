local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local Player = require "object/Player"
local SceneNode = require "object/SceneNode"

local Parallax = class(SceneNode)

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
	--[[self.layer = layer
	self.w = self.layer.image:getWidth()
	self.h = self.layer.image:getHeight()

	-- Parallax images are drawn as a 3x3 tiles, stitched together by drawing the image nine times
	self.oneDraw = self.layer.draw
	self.layer.draw = function()
		local offsets = {
			Transform(),
			Transform(self.w, 0),
			Transform(-self.w, 0),
			Transform(-self.w, -self.h),
			Transform(0, self.h),
			Transform(0, -self.h),
			Transform(self.w, self.h),
			Transform(-self.w, self.h),
			Transform(self.w, -self.h),
		}
		local orig = Transform(self.layer.x, self.layer.y)
		for _,o in pairs(offsets) do
			self.layer.x = orig.x + o.x
			self.layer.y = orig.y + o.y
			self.oneDraw()
		end
		self.layer.x = (orig.x + self.dx) % (self.w)
		self.layer.y = (orig.y + self.dy) % (self.h)
		
		if not self.scene.player then
			return
		end
		
		-- Hacky way of compensating for world xform
		local dt = love.timer.getDelta()
		if  self.scene.player.x > love.graphics.getWidth()/2 and
			self.scene.player.x < (self.scene:getMapWidth() - love.graphics.getWidth()/2) and
			self.scene.player.movingX
		then
			if love.keyboard.isDown("right") then
				self.layer.x = self.layer.x - self.scene.player.movespeed * (dt/0.016)
			elseif love.keyboard.isDown("left") then
				self.layer.x = self.layer.x + self.scene.player.movespeed * (dt/0.016)
			end
		end
		
		if  self.scene.player.y > love.graphics.getHeight()/2 and
			self.scene.player.y < (self.scene:getMapHeight() - love.graphics.getHeight()/2) and
			self.scene.player.movingY
		then
			if love.keyboard.isDown("down") then
				self.layer.y = self.layer.y - self.scene.player.movespeed * (dt/0.016)
			elseif love.keyboard.isDown("up") then
				self.layer.y = self.layer.y + self.scene.player.movespeed * (dt/0.016)
			end
		end
	end
	
	self.dx = self.layer.properties.speedx or 0
	self.dy = self.layer.properties.speedy or 0
	self.sticky = true
	
	self:addSceneHandler("update", Parallax.update)]]
end

function Parallax:remove()
	--self.layer.draw = self.oneDraw
	--SceneNode.remove(self)
end

function Parallax:draw()
	-- Hack: only called from SpriteNode:draw during drawWithParallax
	--self.layer.draw()
end

function Parallax:update(dt)
	--[[if math.ceil(self.scene.player.x + love.graphics.getWidth()/2) > math.ceil(self.curLayerX + self.w*2) then
		self.curLayerX = self.curLayerX + self.w*2
		self.layer.offsetx = self.curLayerX
	end
	self.layer.x = self.layer.x + self.dx
	self.layer.y = self.layer.y + self.dy]]
end


return Parallax