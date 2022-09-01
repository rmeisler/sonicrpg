local Do = require "actions/Do"
local Wait = require "actions/Wait"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local MessageBox = require "actions/MessageBox"
local Repeat = require "actions/Repeat"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local BlockPlayer = require "actions/BlockPlayer"
local While = require "actions/While"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local TextNode = require "object/TextNode"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"

local BuzzBomber = class(NPC)

function BuzzBomber:construct(scene, layer, object)
	object.properties.align = "bottom_left"
	self.ghost = true
	self.movespeed = 7

	NPC.init(self, true)

	self.origX = self.x
	self.origY = self.y

	self:createBuzzProxy()
	self:createDropShadow()
	
	self:addSceneHandler("update", BuzzBomber.update)
	
	self.isBot = true
end

function BuzzBomber:createBuzzProxy()
	self.buzzProxy = BasicNPC(
		self.scene,
		{name = "objects"},
		{name = "buzzproxy", x = 0, y = 0, width = 110, height = 66,
			properties = {nocollision = true, sprite = "art/sprites/buzzbomber.png", align = NPC.ALIGN_BOTLEFT}
		}
	)
	self.scene:addObject(self.buzzProxy)
	self.buzzProxy.sprite.sortOrderY = 1000000
end

function BuzzBomber:createDropShadow()
	self.dropShadow = BasicNPC(
		self.scene,
		{name = "objects"},
		{name = "dropshadow", x = 0, y = 0, width = 36, height = 6,
			properties = {nocollision = true, sprite = "art/sprites/dropshadow.png", align = NPC.ALIGN_TOPLEFT}
		}
	)
	self.scene:addObject(self.dropShadow)
end

function BuzzBomber:update(dt)
	NPC.update(self, dt)
	
	-- Recalculate player distance for frame
	self.distanceFromPlayer = nil
	
	local movespeed = self.movespeed * (dt/0.016)
	local dx = math.random(movespeed) - math.random(movespeed)
	local dy = math.random(movespeed) - math.random(movespeed)
	if dx > 0 then
		dx = math.min(3, dx)
	else
		dx = math.max(-3, dx)
	end
	
	self.x = math.max(self.origX - 100, math.min(self.origX + 100, self.x + dx))
	self.y = math.max(self.origY - 100, math.min(self.origY + 100, self.y + dy))
	self.object.x = self.x + self.object.width/2
	self.object.y = self.y + self.object.height*2
	self:updateCollision()
	
	if not self.animationWait or self.animationWait <= 0 then
		self.animationWait = 60
		if dx > 0 then
			self.buzzProxy.sprite:setAnimation("idle")
		else
			self.buzzProxy.sprite:setAnimation("backward")
		end
	end
	self.animationWait = self.animationWait - (dt/0.016)
	
	self.buzzProxy.x = self.x
	self.buzzProxy.y = self.y - 300
	self.dropShadow.x = self.x + self.buzzProxy.sprite.w/2
	self.dropShadow.y = self.y + self.buzzProxy.sprite.h
	
	local maxUpdateDistance = self.maxUpdateDistance or 1500
	if self:distanceFromPlayerSq() > maxUpdateDistance*maxUpdateDistance then
		return
	end

	local maxAudibleDistance = 400
	if self:distanceFromPlayerSq() < maxAudibleDistance*maxAudibleDistance then
		self.scene.audio:playSfx("bee", 0.5)
	else
		self.scene.audio:stopSfx("bee")
	end
end

function BuzzBomber:getFlag()
	return string.format("%s.%s", self.scene.mapName, self.name)
end

function BuzzBomber:onBattleComplete(args)
	NPC.onBattleComplete(self, args)
	self.flagForDeletion = true

	self:removeSceneHandler("update")
	self.scene.audio:stopSfx("bee")
end

function BuzzBomber:onRemove()
	if GameState:isFlagSet(self) then
		self.buzzProxy:remove()
		self.dropShadow:remove()
	end
end

function BuzzBomber:getInitiative()
	return "opponent"
end


return BuzzBomber
