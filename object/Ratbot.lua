local Transform = require "util/Transform"

local BasicNPC = require "object/BasicNPC"
local NPC = require "object/NPC"
local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"

local Ratbot = class(Bot)

function Ratbot:construct(scene, layer, object)
	if self:isRemoved() then
		return
	end

	self.udflashlight:remove()
	self.lrflashlight:remove()
	
	self.hotspotOffsets = {
		right_top = {x = -40, y = 100},
		right_bot = {x = -40, y = 0},
		left_top  = {x = 40, y = 100},
		left_bot  = {x = 40, y = 0}
	}
	
	Bot.init(self, true)
	self.collision = {}
	
	self.dropShadow.sprite.transform.sx = 5

	--self.stepSfx = "ratstep"
end

function Ratbot:getBattleArgs()
	local args = Bot.getBattleArgs(self)
	args.color = {200,200,200,255}
	return args
end

function Ratbot:noticePlayer(ignoreShadow)
	local audibleDistance = self.audibleDist or self.noticeDist or 250
	
	if self.forceSee then
		return Bot.NOTICE_SEE
	end
	
	if self.ignorePlayer then
		return Bot.NOTICE_NONE
	end

	local isRightOfPlayer = (self.scene.player.x + self.scene.player.sprite.w) < (self.x + self.sprite.w)
	local isLeftOfPlayer = (self.scene.player.x + self.scene.player.sprite.w) > (self.x + self.sprite.w)
	local isAbovePlayer = (self.scene.player.y + self.scene.player.sprite.h*2) > (self.y + self.sprite.h*2)
	local isBelowPlayer = (self.scene.player.y + self.scene.player.sprite.h*2) < (self.y + self.sprite.h*2)
	
	if  self.facing == "right" and isLeftOfPlayer and not self.scene.player:isHiding("left") and
		not ((isAbovePlayer and self.scene.player:isHiding("up")) or
			 (isBelowPlayer and self.scene.player:isHiding("down"))) and
			self.facingTime > 0.3 and
			self.visualColliders.right:isTouchingObj(self.scene.player)
	then
		return Bot.NOTICE_SEE
	elseif  self.facing == "left" and isRightOfPlayer and not self.scene.player:isHiding("right") and
			not ((isAbovePlayer and self.scene.player:isHiding("up")) or
				 (isBelowPlayer and self.scene.player:isHiding("down"))) and
			self.facingTime > 0.3 and
			self.visualColliders.left:isTouchingObj(self.scene.player)
	then
		return Bot.NOTICE_SEE
	elseif  self.facing == "up" and isBelowPlayer and not self.scene.player:isHiding("down") and
			not ((isLeftOfPlayer and self.scene.player:isHiding("left")) or
				 (isRightOfPlayer and self.scene.player:isHiding("right"))) and
			self.facingTime > 0.3 and
			self.visualColliders.up:isTouchingObj(self.scene.player)
	then
		return Bot.NOTICE_SEE
	elseif  self.facing == "down" and isAbovePlayer and not self.scene.player:isHiding("up") and
			not ((isLeftOfPlayer and self.scene.player:isHiding("left")) or
				 (isRightOfPlayer and self.scene.player:isHiding("right"))) and
			self.facingTime > 0.3 and
			self.visualColliders.down:isTouchingObj(self.scene.player)
	then
		return Bot.NOTICE_SEE
	end
	
	if self:distanceFromPlayerSq() < audibleDistance*audibleDistance and (self.hearWithoutMovement or self.scene.player:isMoving()) then
		return Bot.NOTICE_HEAR
	end

	return Bot.NOTICE_NONE
end

function Ratbot:createDropShadow()
	self.dropShadow = BasicNPC(
		self.scene,
		{name = "ratshadow"},
		{name = "dropshadow", x = 0, y = 0, width = 36, height = 6,
			properties = {nocollision = true, sprite = "art/sprites/dropshadow.png", align = NPC.ALIGN_TOPLEFT}
		}
	)
	self.scene:addObject(self.dropShadow)
end

function Ratbot:updateDropShadowPos(xonly)
	self.dropShadow.x = self.x + 60
	
	if not xonly then
		self.dropShadow.y = self.y + self.sprite.h*2 - 14
	end
end

return Ratbot
