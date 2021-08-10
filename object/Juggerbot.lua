local Transform = require "util/Transform"

local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local Wait = require "actions/Wait"

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
	
	--self:addSceneHandler("update", Juggerbot.moveEffects)
	
	self.stepSfx = "juggerbotstep"
	self.walkspeed = 2
end

function Juggerbot:faceLeft()
	self.sprite.transform.sx = -1
	self.head.transform.sx = -1
	self.leftarm.transform.sx = -1
	self.rightarm.transform.sx = -1
	self.head.transform = Transform.relative(self.sprite.transform, Transform(-89, 15))
	self.leftarm.transform = Transform.relative(self.sprite.transform, Transform(-30, 30))
	self.rightarm.transform = Transform.relative(self.sprite.transform, Transform(10, 30))
	self.facingleft = true
end

function Juggerbot:updateDropShadowPos(xonly)
	if self.facingleft then
		self.dropShadow.x = self.x - self.sprite.w*2 - 8
	else
		self.dropShadow.x = self.x + 8
	end
	
	if not xonly then
		self.dropShadow.y = self.y + self.sprite.h*2 - 16
	end
end

function Juggerbot:moveAnim(dir)
	return Serial {
		Parallel {
			Ease(self, "x", function() return self.x + (dir == "left" and -50 or 50) end, 2, "linear"),
			Animate(self.leftarm, "walkright_step1"),
			Animate(self.rightarm, "walkright_step1"),
			Animate(self.sprite, "walkright_step1")
		},
		PlayAudio("sfx", "juggerbotstep", 1.0, true),
		self.scene:screenShake(30,40),
		Wait(1),
		Parallel {
			Ease(self, "x", function() return self.x + (dir == "left" and -50 or 50) end, 2, "linear"),
			Animate(self.leftarm, "walkright_step2"),
			Animate(self.rightarm, "walkright_step2"),
			Animate(self.sprite, "walkright_step2")
		},
		PlayAudio("sfx", "juggerbotstep", 1.0, true),
		self.scene:screenShake(30,40),
		Wait(1)
	}
end

function Juggerbot:hurtAnim()
	-- Shake
	-- Red
	-- Sound
	-- 
end

function Juggerbot:slicedAnim()
	-- Sound
	-- Separate
	-- Blink
	-- Behind juggerbot is Leon
end

function Juggerbot:moveEffects(dt)
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

function Juggerbot:remove()
	Bot.remove(self)
	
	self.head:remove()
	self.leftarm:remove()
	self.rightarm:remove()
end


return Juggerbot
