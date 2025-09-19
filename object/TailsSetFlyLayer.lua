local Player = require "object/Player"
local NPC = require "object/NPC"

local TailsSetFlyLayer = class(NPC)

function TailsSetFlyLayer:construct(scene, layer, object)
	self.ghost = true
	self.flyLandingLayer = self.object.properties.flyLandingLayer
	self.nextFlyLandingLayer = self.object.properties.nextFlyLandingLayer
	self.nextFlyOffsetY = self.object.properties.nextFlyOffsetY
	self.tempFlyOffsetY = self.object.properties.tempFlyOffsetY

	NPC.init(self)
end

function TailsSetFlyLayer:whileColliding(player, prevState)
	-- Only impacts Tails
	if GameState.leader ~= "tails" or prevState == NPC.STATE_TOUCHING then
		return
	end

	player.flyLandingLayer = self.flyLandingLayer
	player.nextFlyLandingLayer = self.nextFlyLandingLayer
	player.flyOffsetY = 0
	player.nextFlyOffsetY = self.nextFlyOffsetY
	player.tempFlyOffsetY = self.tempFlyOffsetY
end


return TailsSetFlyLayer
