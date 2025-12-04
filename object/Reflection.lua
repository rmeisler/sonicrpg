local SceneNode = require "object/SceneNode"
local Player = require "object/Player"
local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

local Reflection = class(SceneNode)

function Reflection:construct(scene, layer, object)
    self.collisionX = 0
	self.collisionY = 0
	self.baseMoveSpeed = 4
	self.movespeed = self.baseMoveSpeed
	self.layer = layer
	self.object = object
	
	self.x = object.x
	self.y = object.y
	self.color = {255,255,255,255}
	self.state = object.properties.orientation and "idle"..object.properties.orientation or Player.STATE_IDLEDOWN
	
	self:updateSprite()

	self.hotspotOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = 0},
		left_bot  = {x = 0, y = 0}
	}

	self:addSceneHandler("update", Reflection.update)
end

function Reflection:update(dt)
	self.x = self.scene.player.x - self.sprite.w

	local hotspots = self.scene.player:updateCollisionObj()
	local collisionHSOffsets = self.scene.player.collisionHSOffsets
	hotspots.right_top.x = hotspots.right_top.x + collisionHSOffsets.right_top.x
	hotspots.right_top.y = hotspots.right_top.y + collisionHSOffsets.right_top.y
	hotspots.right_bot.x = hotspots.right_bot.x + collisionHSOffsets.right_bot.x
	hotspots.right_bot.y = hotspots.right_bot.y + collisionHSOffsets.right_bot.y
	hotspots.left_top.x = hotspots.left_top.x + collisionHSOffsets.left_top.x
	hotspots.left_top.y = hotspots.left_top.y + collisionHSOffsets.left_top.y
	hotspots.left_bot.x = hotspots.left_bot.x + collisionHSOffsets.left_bot.x
	hotspots.left_bot.y = hotspots.left_bot.y + collisionHSOffsets.left_bot.y

	local prevState = self.state
	self.state = Player.ToIdle[self.state] or self.state

	local baseMoveSpeed = self.movespeed
	local movespeed = baseMoveSpeed * (dt/0.016)

	local moving = false
	local movingX = false
	local movingY = false
    if love.keyboard.isDown("right") then
		if  self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, movespeed, 0) and
			self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, movespeed, 0)
		then
			self.x = self.x + movespeed
			self.state = Player.STATE_WALKRIGHT

			moving = true
			movingX = true
		elseif not moving then
			self.state = Player.STATE_IDLERIGHT
		end

    elseif love.keyboard.isDown("left") then
		if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, -movespeed, 0) and
			self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, -movespeed, 0)
		then
			self.x = self.x - movespeed
			self.state = Player.STATE_WALKLEFT

			moving = true
			movingX = true
		elseif not moving then
			self.state = Player.STATE_IDLELEFT
		end
    end

    if love.keyboard.isDown("down") then
		if  self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, 0, movespeed) and
			self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, 0, movespeed)
		then
			self.y = self.y - movespeed
			self.state = Player.STATE_WALKUP
			
			moving = true
			movingY = true
		elseif not moving then
			self.state = Player.STATE_IDLEUP
		end

    elseif love.keyboard.isDown("up") then
		if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, 0, -movespeed) and
			self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, 0, -movespeed)
		then
			self.y = self.y + movespeed
			self.state = Player.STATE_WALKDOWN
			
			moving = true
			movingY = true
		elseif not moving then
			self.state = Player.STATE_IDLEDOWN
		end
    end

	self.moving = moving
	self.movingX = movingX
	self.movingY = movingY

	if prevState ~= self.state then
		self.sprite.animations[self.state]:reset()
	end
	
	self.sprite:setAnimation(self.state)
end

function Reflection:updateSprite()
	if not GameState.leader then
		return
	end
	if self.sprite then
		self.sprite:remove()
	end
	local spriteName = GameState.party[GameState.leader].sprite
	self.transform = Transform(0, 0, 2, 2)
	self.sprite = SpriteNode(
		self.scene,
		self.transform,
		self.color,
		spriteName,
		nil,
		nil,
		self.layer.name
	)

	local spriteWidth, spriteHeight = self.sprite.w,self.sprite.h
	self.transform.x = love.graphics.getWidth()/2 - spriteWidth
	self.transform.y = love.graphics.getHeight()/2 - spriteHeight
	self.transform.sx = 2
	self.transform.sy = 2

	self.width,self.height = spriteWidth, spriteHeight
	self.halfWidth,self.halfHeight = math.floor(spriteWidth/2), math.floor(spriteHeight/2)
end


return Reflection
