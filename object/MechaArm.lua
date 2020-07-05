local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial" 
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Move = require "actions/Move"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local BlockInput = require "actions/BlockInput"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"
local Player = require "object/Player"

local MechaArm = class(NPC)

MechaArm.NOTICE_NONE = 0
MechaArm.NOTICE_SEE = 1

function MechaArm:construct(scene, layer, object)
	self.action = Serial{}
	
	self.ghost = true
	self.alignment = NPC.ALIGN_BOTLEFT
	
	NPC.init(self, true)
	self.collision = {}

	self.facing = object.properties.facing or "right"
	self.sprite.visible = false
	
	if GameState:isFlagSet(self:getFlag()) then
		self:removeSceneHandler("update", NPC.update)
		self:remove()
		return
	end
	
	self:addSceneHandler("update", MechaArm.update)
	self.isBot = true
end

function MechaArm:distanceFromPlayerSq()
	if not self.scene.player then
		return 0
	end

	if not self.distanceFromPlayer then
		local dx = (self.scene.player.x - (self.x + self.sprite.w))
		local dy = (self.scene.player.y - (self.y + self.sprite.h))
		self.distanceFromPlayer = (dx*dx + dy*dy)
	end
	return self.distanceFromPlayer
end

function MechaArm:getFlag()
	return string.format(
		"%s.%s",
		self.scene.mapName,
		self.name
	)
end

function MechaArm:update(dt)
	self:updateAction(dt)

	-- If player close enough, leap toward him
	if self:noticePlayer() == MechaArm.NOTICE_SEE and self.sprite.visible == false then
	    self.sprite.visible = true
		
		local battleArgs = {
			initiative = self:getInitiative(),
			opponents = {self:getMonsterData()}
		}
		local npcArgs = self:getBattleArgs()
		if next(npcArgs) then
			for k, v in pairs(npcArgs) do
				battleArgs[k] = v
			end
		end
		
		self:run(Serial {
			Wait(0.5),
			Animate(self.sprite, "dive"..self.facing, true),
			Animate(self.sprite, "grabbed"..self.facing),
			
			Wait(0.2),
			Do(function()
				self.scene.player.cinematic = true
				self.scene.player.noIdle = true
				self.scene.player.sprite:setAnimation("shock")
				self.flagForDeletion = true
				
				self.scene:run(self.scene:enterBattle(battleArgs))
			end),
		})
	end
	
	self.distanceFromPlayer = nil
end

function MechaArm:noticePlayer()
	local visibleDistance = 100
	if self:distanceFromPlayerSq() < visibleDistance*visibleDistance then
		local isRightOfPlayer = (self.scene.player.x + self.scene.player.sprite.w) < (self.x + self.sprite.w)
		local isLeftOfPlayer = (self.scene.player.x + self.scene.player.sprite.w) > (self.x + self.sprite.w)
		local isAbovePlayer = (self.scene.player.y + self.scene.player.sprite.h) > (self.y + self.sprite.h)
		local isBelowPlayer = (self.scene.player.y + self.scene.player.sprite.h) < (self.y + self.sprite.h)

		if self.facing == "right" and isLeftOfPlayer then
			return MechaArm.NOTICE_SEE
		elseif self.facing == "left" and isRightOfPlayer then
			return MechaArm.NOTICE_SEE
		elseif self.facing == "up" and isBelowPlayer then
			return MechaArm.NOTICE_SEE
		elseif self.facing == "down" and isAbovePlayer then
			return MechaArm.NOTICE_SEE
		end
	end

	return MechaArm.NOTICE_NONE
end

function MechaArm:updateAction(dt)
	if not self.action:isDone() then
		self.action:update(dt)

		if self.action:isDone() then
			self.action:cleanup(self)
			self.action = Serial{}
		end
	end
	
	-- HACK
	if not self.sprite or not self.scene.player then
		return
	end
	
	-- Collide for battle, not applicable for sonic when running
	if  not (GameState.leader == "sonic" and self.scene.player.doingSpecialMove) and
		not self.scene.player.falling
	then
		local cx = self.x + 20
		local cy = self.y + self.sprite.h*2 - self.scene:getTileHeight()
		local cx2 = cx + self.scene:getTileWidth()
		if  self.scene.player:isTouching(cx, cy) or
			self.scene.player:isTouching(cx2, cy)
		then
			self.state = NPC.STATE_TOUCHING
			self:invoke("collision")
			self:onCollision()
		end
	end
end

function MechaArm:run(actions)
	-- Lazily evaluated actions
	if type(actions) == "function" then
		actions = actions()
	end

	-- Table is implicitly a Serial action
	if not getmetatable(actions) then
		actions = Serial(actions)
	end

	self.action:inject(self.scene, actions)
	self.action.done = false
end

function MechaArm:remove()
	GameState:setFlag(self:getFlag())
	self:removeSceneHandler("update", MechaArm.update)

	NPC.remove(self)
end

return MechaArm
