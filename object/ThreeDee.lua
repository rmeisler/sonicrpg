local Player = require "object/Player"
local NPC = require "object/NPC"

local ThreeDee = class(NPC)

function ThreeDee:construct(scene, layer, object)
	self.ghost = true
	self.depth = self.object.properties.depth
	self.flyLandingLayer = self.object.properties.flyLandingLayer

	NPC.init(self)
end

function ThreeDee:whileColliding(player, prevState)
	if GameState.leader ~= "tails" or
	   not player.doingSpecialMove or
	   player.flyOffsetY < self.object.height
	then
        return
    end

    local playerY = player.y + player.flyOffsetY
	local objBottomY = self.object.y + self.object.height
    local onTop = (playerY < objBottomY) and (playerY > (objBottomY - self.depth))

    if onTop then
        player.tempFlyOffsetY = -self.object.height + 20
		player.dropShadow.sprite.sortOrderY = 1000000
		player.flyLandingLayer = self.flyLandingLayer
    else
		player.dropShadow.sprite.sortOrderY = nil
        player.tempFlyOffsetY = 0
		player.flyLandingLayer = 4
    end
end

function ThreeDee:notColliding(player, prevState)
    if GameState.leader ~= "tails" or
	   not player.doingSpecialMove or
	   prevState == NPC.STATE_IDLE
	then
        return
    end

	player.dropShadow.sprite.sortOrderY = nil
    player.tempFlyOffsetY = 0
	player.flyLandingLayer = 4
end


return ThreeDee
