local Player = require "object/Player"
local NPC = require "object/NPC"

local TailsSetFlyLayer = class(NPC)

function TailsSetFlyLayer:construct(scene, layer, object)
	self.ghost = true
	self.flyLayer = self.object.properties.flyLayer

	NPC.init(self)
end

function TailsSetFlyLayer:whileColliding(player, prevState)
	-- Only impacts Tails
	if GameState.leader ~= "tails" or prevState == NPC.STATE_TOUCHING then
		return
	end

	-- Set fly layer
	player.flyLayer = self.flyLayer
end


return TailsSetFlyLayer
