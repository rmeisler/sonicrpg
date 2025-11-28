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
	   not player.doingSpecialMove
	then
        return
    end
	
	if not player.infiniteDropObjects then
		player.infiniteDropObjects = {}
	end

	player.infiniteDropObjects[tostring(self)] = self
	player.noFlyPan = true
	player.tempFlyOffsetY = self.height
end

function TailsInfiniteDrop:notColliding(player, prevState)
	if not player.infiniteDropObjects then
		player.infiniteDropObjects = {}
	end

    if GameState.leader ~= "tails" or
	   not player.doingSpecialMove or
	   next(player.infiniteDropObjects) == nil
	then
        return
    end

	player.infiniteDropObjects[tostring(self)] = nil

	if next(player.infiniteDropObjects) == nil then
		player.tempFlyOffsetY = 0
		player.noFlyPan = false

		print("player y = "..tostring(player.y)..", object y = "..tostring(self.object.y)..", "..", object height = "..tostring(self.object.height))
		if player.y > (self.object.y + self.object.height) then
			player.forceDrop = true
		end
	end
end


return TailsInfiniteDrop
