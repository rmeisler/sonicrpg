local Player = require "object/Player"
local NPC = require "object/NPC"

local TailsSetFlyLayer = class(NPC)

function TailsSetFlyLayer:construct(scene, layer, object)
	self.ghost = true
	self.flyLayer = self.object.properties.flyLayer
	self.flyOffsetY = self.object.properties.flyOffsetY
	self.flyLandingLayer = self.object.properties.flyLandingLayer

	NPC.init(self)
end

function TailsSetFlyLayer:whileColliding(player, prevState)
	-- Only impacts Tails
	if GameState.leader ~= "tails" or prevState == NPC.STATE_TOUCHING then
		return
	end

	-- Set fly layer
	player.flyLayer = self.flyLayer
	player.flyOffsetY = self.flyOffsetY
	player.sprite.sortOrderY = 100000
	player.dropShadow.sprite.sortOrderY = 99999
end

function TailsSetFlyLayer:notColliding(player, prevState)
	-- Only impacts Tails
	if GameState.leader ~= "tails" or
	   prevState == NPC.STATE_IDLE
	then
		return
	end

	-- Set fly layer
	player.flyLandingLayer = self.flyLandingLayer
end


return TailsSetFlyLayer
