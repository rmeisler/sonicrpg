local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"
local BasicNPC = require "object/BasicNPC"
local Player = require "object/Player"

local Juggerbot = class(Bot)

function Juggerbot:construct(scene, layer, object)
	if self:isRemoved() then
		return
	end
	
	Bot.init(self, true)
	
	self.collision = {}
	
	self.hotspotOffsets = {
		right_top = {x = -20, y = self.sprite.h + 30},
		right_bot = {x = -20, y = 0},
		left_top  = {x = 20, y = self.sprite.h + 30},
		left_bot  = {x = 20, y = 0}
	}
	
	-- Create follow parts
	self.head = SpriteNode(
		scene,
		Transform.relative(self.sprite.transform, Transform(89, 15)),
		nil,
		"juggerbothead",
		nil,
		nil,
		"objects"
	)
	self.leftarm = SpriteNode(
		scene,
		Transform.relative(self.sprite.transform, Transform(30, 30)),
		nil,
		"juggerbotleftarm",
		nil,
		nil,
		"objects"
	)
	self.rightarm = SpriteNode(
		scene,
		Transform.relative(self.sprite.transform, Transform(-10, 30)),
		nil,
		"juggerbotrightarm",
		nil,
		nil,
		"objects"
	)
	
	self.head.sortOrderY = 10000
	self.rightarm.sortOrderY = 10000
	self.leftarm.sortOrderY = 0
	
	self.dropShadow.sprite.transform.sx = 4
	
	self:addSceneHandler("update", Juggerbot.moveArms)
	
	self.stepSfx = "juggerbotstep"
	self.walkspeed = 2
end

function Juggerbot:updateDropShadowPos(xonly)
	self.dropShadow.x = self.x + 8
	
	if not xonly then
		self.dropShadow.y = self.y + self.sprite.h*2 - 16
	end
end

function Juggerbot:moveArms(dt)
	if self.sprite.selected == "walkright" then
		self.rightarm:setAnimation("walkright")
		self.leftarm:setAnimation("walkright")
		self.head:setAnimation("walkright")
		
		if  self.head:getFrame() == 3 or
			self.head:getFrame() == 1
		then
			self.scene:run(self.scene:screenShake(30,40))
		end
	else
		self.rightarm:setAnimation("idleright")
		self.leftarm:setAnimation("idleright")
		self.head:setAnimation("idleright")
	end
end


return Juggerbot
