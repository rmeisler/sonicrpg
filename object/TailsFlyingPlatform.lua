local Player = require "object/Player"
local NPC = require "object/NPC"

local TailsFlyingPlatform = class(NPC)

function TailsFlyingPlatform:construct(scene, layer, object)
	self.ghost = true
	self.distanceFromGround = self.object.properties.distanceFromGround
	self.flyLandingLayer = self.object.properties.flyLandingLayer

	NPC.init(self)
end

function TailsFlyingPlatform:notColliding(player, prevState)
	-- Only impacts Tails when flying
	if GameState.leader ~= "tails" or
	  not player.doingSpecialMove or
	  prevState == NPC.STATE_IDLE
	then
		return
	end

	-- If not colliding with this platform after you were previously colliding,
	-- set dropshadow to defined distance from ground and ensure that this is unset
	-- as your "landing zone"
	player.flyOffsetY = self.distanceFromGround
	player.flyLandingLayer = self.flyLandingLayer
end

function TailsFlyingPlatform:whileColliding(player, prevState)
	-- Only impacts Tails when flying
	if GameState.leader ~= "tails" or
	   not player.doingSpecialMove or
	   prevState == NPC.STATE_TOUCHING
	then
		return
	end

	-- If colliding with this platform after you were previously not colliding,
	-- set dropshadow to be on this platform and ensure that this is set as
	-- your "landing zone"
	player.flyLandingLayer = self.scene.currentLayerId
end


return TailsFlyingPlatform
