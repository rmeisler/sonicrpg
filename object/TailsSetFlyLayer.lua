local Player = require "object/Player"
local NPC = require "object/NPC"

local TailsSetFlyLayer = class(NPC)

function TailsSetFlyLayer:construct(scene, layer, object)
	self.ghost = true
	self.flyLayer = self.object.properties.flyLayer
	self.flyOffsetY = self.object.properties.flyOffsetY

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
	
	print("yok, setting offset to "..tostring(self.flyOffsetY))
end

function TailsSetFlyLayer:notColliding(player, prevState)
	-- Only impacts Tails
	if GameState.leader ~= "tails" or
	   prevState == NPC.STATE_IDLE or
	   player.doingSpecialMove
	then
		return
	end

	-- Set fly layer
	player.flyLayer = 4
	player.flyOffsetY = player.defaultFlyOffsetY
	
	print("youch, setting offset to "..tostring(player.defaultFlyOffsetY))
end


return TailsSetFlyLayer
