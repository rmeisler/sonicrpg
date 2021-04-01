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
	NPC.init(self)
end

function Ladder:notColliding(player)
	if player.ladders[tostring(self)] then
		print("do I get here???")
		player.ladders[tostring(self)] = nil
		player.noSpecialMove = false
		player.basicUpdate = player.origUpdate
	end
end

function Ladder:whileColliding(player)
	if player.doingSpecialMove then
		return
	end
	
	if not player.ladders[tostring(self)] then
		player.ladders[tostring(self)] = self
		player.noSpecialMove = true
		player.origUpdate = player.basicUpdate
		player.basicUpdate = function(player, dt)
			player:updateCollisionObj()
			
			local movespeed = player.movespeed * (dt/0.016)
			player.state = Player.STATE_IDLEUP --CLIMBIDLE
			player.x = self.x + self.object.width/2

			-- Update drop shadow position to be bottom of ladder
			player.dropShadow.x = player.x - 22
			player.dropShadow.y = self.y + self.object.height + player.sprite.h*2

			if love.keyboard.isDown("up") then
				player.state = Player.STATE_WALKUP --CLIMB
				player.y = player.y - movespeed
			elseif love.keyboard.isDown("down") then
				player.state = Player.STATE_WALKUP
				player.y = player.y + movespeed
			end
			
			player.sprite:setAnimation(player.state)
		end
	end
end


return Ladder
