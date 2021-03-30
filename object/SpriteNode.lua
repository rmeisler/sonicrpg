local Animation = require "util/AnAL"
local shine = require "lib/shine"

local SpriteNode = class(require "object/DrawableNode")

function SpriteNode:construct(scene, transform, color, imgsrc, w, h, layer)
	self.locationOffsets = {}
	if type(imgsrc) == "string" then
		self.imgsrc = imgsrc
		self.img = scene.images[imgsrc]
		self.animations = {}
		
		-- Add animations
		local meta = scene.animations[imgsrc]
		if not meta then
			meta = {w=self.img:getWidth(), h=self.img:getHeight(), animations={idle={frames={{0,0}}}}, starting="idle"}
		end
		self.w = meta.w --Ignore passed in w/h
		self.h = meta.h
		for anikey,anival in pairs(meta.animations) do
			self:addAnimation(anikey, anival.frames, anival.speed or 0, anival.clip or {0, 0, self.w, self.h})
			self.locationOffsets[anikey] = anival.locationoffsets
		end
		
		-- Set starting animation
		self:setAnimation(meta.starting)
	else
		self.img = imgsrc
		self.w = w or self.img:getWidth()
		self.h = h or self.img:getHeight()
		self.animations = {}
		self:addAnimation("default", {{0,0}}, 1, {0, 0, self.w, self.h})
	end
	
	self.drawWithParallax = false
	self.drawWithGlow = false
	self.glowColor = {0,0,0,0}
	self.layer = layer
	self.visible = true
	
	if self.layer ~= false then
		self:addSceneNode(self.layer or "sprites")
	end
	self:addSceneHandler("update", SpriteNode.update)
end

function SpriteNode:addAnimation(name, colrows, speed, clip)
    local cx,cy,cw,ch = unpack(clip)
    local animation = Animation.new(self.img, self.w, self.h, speed)
    for _, pair in pairs(colrows) do
		if type(pair) ~= "table" then
			print(self.name)
			print(self.imgsrc)
		end
	    local col, row = unpack(pair)
        animation:addFrame((col*self.w)+cx, (row*self.h)+cy, cw, ch, speed)
    end
	self.selected = name
    self.animations[self.selected] = animation
end

function SpriteNode:add(name, ani)
	self.selected = name
    self.animations[self.selected] = ani
end

function SpriteNode:trySetAnimation(name)
	if self.animations[name] then
		self.selected = name
	end
end

function SpriteNode:setAnimation(name)
    self.selected = name
end

function SpriteNode:setFrame(position)
	self.animations[self.selected].position = position
end

function SpriteNode:onAnimationComplete(callback)
	self.animations[self.selected].callback = callback
end

function SpriteNode:playAnimation()
	self.animations[self.selected]:play()
end

function SpriteNode:stopAnimation()
	self.animations[self.selected]:stop()
end

function SpriteNode:update(dt)
	if self.scene.playerMovable and not self.scene:playerMovable() then
		return
	end

	if not self.animations[self.selected] then
		return
	end
	
	if self.drawWithParallax then
		self.t = self.t + dt * self.parallaxSpeed
		SpriteNode.scanShader:send("time", self.t)
	end
	
    self.animations[self.selected]:update(dt)
end

function SpriteNode:getLocationOffset(location)
	local anim = self.animations[self.selected]
	if  self.locationOffsets[self.selected] and
		self.locationOffsets[self.selected][location] and
		self.locationOffsets[self.selected][location][anim.position]
	then
		return self.locationOffsets[self.selected][location][anim.position]
	else
		return {x=0,y=0}
	end
end

function SpriteNode:setGlow(color, size)
	self.drawWithGlow = true
	self.glowColor[1] = color[1]
	self.glowColor[2] = color[2]
	self.glowColor[3] = color[3]
	self.glowColor[4] = color[4]
	self.glowSize = size
	
	if not SpriteNode.glowMap then
		SpriteNode.glowMap = love.graphics.newCanvas()
		SpriteNode.blurx = love.graphics.newShader("art/shaders/blurx.glsl")
		SpriteNode.blurx:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
	end
end

function SpriteNode:removeGlow()
	self.drawWithGlow = false
end

function SpriteNode:setParallax(speed)
	self.drawWithParallax = true
	self.t = 0
	self.parallaxSpeed = speed or 1.0
	
	if not SpriteNode.parallaxMap then
		SpriteNode.parallaxMap = love.graphics.newCanvas()
		SpriteNode.scanShader = love.graphics.newShader [[
			extern number time;
			vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
			{
				if (time < 1.0) {
					if (tc.y < time) {
						return vec4(0,1,0,0) + Texel(tex, tc);
					} else {
						return Texel(tex, tc);
					}
				} else {
					if ((tc.y + 1.0) < time) {
						return Texel(tex, tc);
					} else {
						return vec4(0,1,0,0) + Texel(tex, tc);
					}
				}
			}
		]]
		SpriteNode.scanShader:send("time", 0)
	end
end

function SpriteNode:removeParallax()
	self.drawWithParallax = false
end

function SpriteNode:setInvertedColor()
	self.drawWithInvertedColor = true
	if not SpriteNode.invertedColorShader then
		SpriteNode.invertedColorShader = love.graphics.newShader [[
			vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
			{
				vec4 fullColour = colour * Texel(tex, tc);
				fullColour.rgb = 1. - fullColour.rgb;
				return fullColour;
			}
		]]
	end
end

function SpriteNode:removeInvertedColor()
	self.drawWithInvertedColor = false
end

function SpriteNode:draw(override)
	if not self.visible then
		return
	end

	local xform = override or self.transform
	local sprite = self.animations[self.selected]
	
	local drawSprite = function()
		if not sprite then
			return
		end
		sprite:draw(xform.x, xform.y, xform.angle, xform.sx, xform.sy, xform.ox, xform.oy, xform.shx, xform.shy)
	end
	
	if self.drawWithGlow then
		local prevShader = love.graphics.getShader()
		SpriteNode.blurx:send("steps", self.glowSize * 5)

		SpriteNode.glowMap:renderTo(function()
			love.graphics.clear()
			love.graphics.setShader(SpriteNode.blurx)
			SpriteNode.blurx:send("glowColor", {255,300,255}) --self.glowColor[1], self.glowColor[2], self.glowColor[3]})
			drawSprite()
		end)
		
		love.graphics.setColor(255, 255, 255, self.glowColor[4])
		
		love.graphics.setBlendMode("add")
		SpriteNode.blurx:send("glowColor", {0,0,0,0})
		love.graphics.draw(SpriteNode.glowMap, 0, 0)

		love.graphics.setBlendMode("alpha")
		love.graphics.setShader(prevShader)
		
		love.graphics.setColor(self.color)
		drawSprite()

	elseif self.drawWithInvertedColor then
		local prevShader = love.graphics.getShader()
		love.graphics.setShader(SpriteNode.invertedColorShader)
		
		drawSprite()
		
		love.graphics.setShader(prevShader)
	elseif self.drawWithParallax then
		local prevShader = love.graphics.getShader()
		
		love.graphics.setShader(SpriteNode.scanShader)
		
		drawSprite()
		
		love.graphics.setShader(prevShader)
	else
		love.graphics.setColor(self.color)
		drawSprite()
	end
end


return SpriteNode