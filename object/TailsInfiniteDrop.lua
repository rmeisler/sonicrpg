local Player = require "object/Player"
local NPC = require "object/NPC"

local TailsInfiniteDrop = class(NPC)

function TailsInfiniteDrop:construct(scene, layer, object)
	self.ghost = true
	self.height = object.properties.height

	NPC.init(self)
end

function TailsInfiniteDrop:whileColliding(player, prevState)
	if GameState.leader ~= "tails" or
	   not player.doingSpecialMove or
	   player.forceDrop
	then
        return
    end
	
	if player.infiniteDropObjects[tostring(self)] == nil then
		player.infiniteDropObjects[tostring(self)] = self
		player.noFlyPan = true
		player.tempFlyOffsetY = self.height
	end
	
	if player.y > (self.object.y + 256) then
		--player.forceDrop = true
	end
end

function TailsInfiniteDrop:notColliding(player, prevState)
	if player.infiniteDropObjects[tostring(self)] ~= nil then
		player.infiniteDropObjects[tostring(self)] = nil

		if next(player.infiniteDropObjects) == nil then
			player.tempFlyOffsetY = 0
			player.noFlyPan = false
		end
	end
end


return TailsInfiniteDrop
