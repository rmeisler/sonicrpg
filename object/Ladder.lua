local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"

local Player = require "object/Player"
local NPC = require "object/NPC"

local Ladder = class(NPC)

function Ladder:construct(scene, layer, object)
	self.ghost = true
	self.topLayer = self.object.properties.topLayer
	self.botLayer = self.object.properties.botLayer
	NPC.init(self)
	
	self.updateFun = function(player, dt)
		player:updateCollisionObj()

		if 	player.cinematic or
			player.cinematicStack > 0 or
			player.blocked or
			not player.scene:playerMovable() or
			player.dontfuckingmove
		then
			player.sprite:setAnimation(player.state)
			return
		end
		
		local movespeed = player.movespeed * (dt/0.016)
		player.x = self.x + self.object.width/2

		-- Update drop shadow position to be bottom of ladder
		player.dropShadow.x = player.x - 22
		player.dropShadow.y = self.y + self.object.height + player.sprite.h*2

		-- HACK: Rotor is big
		if GameState.leader == "rotor" then
			player.x = self.x
			player.dropShadow.x = player.x - 10
		end
		
		if love.keyboard.isDown("up") then
			player.y = player.y - movespeed
			self.climbAnimTime = self.climbAnimTime + dt
		elseif love.keyboard.isDown("down") then
			player.y = player.y + movespeed
			self.climbAnimTime = self.climbAnimTime + dt
		end
		
		if self.climbAnimTime > 0.2 then
			if player.state == "climb_1" then
				player.state = "climb_2"
			else
				player.state = "climb_1"
			end
			self.climbAnimTime = 0
		end
		
		player.sprite:setAnimation(player.state)
	end
end

function Ladder:notColliding(player)
	if next(player.noLadder) ~= nil then
		return
	end

	if player.ladders[tostring(self)] then
		player.ladders[tostring(self)] = nil
		player.noSpecialMove = false
		player.noChangeChar = false
		player.movespeed = player.origMoveSpeed
		player.basicUpdate = player.updateFun

		if self.botLayer and love.keyboard.isDown("down") then
			self.scene:swapLayer(self.botLayer)
		end
	end
end

function Ladder:whileColliding(player)
	if next(player.noLadder) ~= nil then
		return
	end

	if player.doingSpecialMove and GameState.leader == "sonic" then
		player.basicUpdate = self.updateFun
	end

	if not player.ladders[tostring(self)] then
		player.ladders[tostring(self)] = self
		player.noSpecialMove = true
		player.noChangeChar = true
		player.state = "climb_1"
		player.origMoveSpeed = player.movespeed
		player.movespeed = player.movespeed - 1
		
		self.climbAnimTime = 0
		player.basicUpdate = self.updateFun

		if self.topLayer then
			self.scene:swapLayer(self.topLayer)
		end
	end
end


return Ladder
