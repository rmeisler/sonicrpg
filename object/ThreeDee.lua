local Ease = require "actions/Ease"
local Player = require "object/Player"
local NPC = require "object/NPC"

local ThreeDee = class(NPC)

function ThreeDee:construct(scene, layer, object)
	self.ghost = true
	self.depth = self.object.properties.depth
	self.flyLandingLayer = self.object.properties.flyLandingLayer
	self.nextFlyLandingLayer = self.object.properties.nextFlyLandingLayer
	self.nextFlyOffsetY = self.object.properties.nextFlyOffsetY
	self.priorityLayer = self.object.properties.priorityLayer
	self.landingOffsetY = self.object.properties.landingOffsetY or 30
	self.lastOnTop = false

	NPC.init(self)
end

function ThreeDee:whileColliding(player, prevState)
	if GameState.leader ~= "tails" or
	   not player.doingSpecialMove or
	   player.flyOffsetY < (self.object.height - self.landingOffsetY)
	then
		return
    end

	-- Check if our priority layer is not the current layer,
	-- if not, see if there is another object with that priority
	--[[ layer and if so, return
	if self.scene.currentLayer ~= self.priorityLayer then
		for _, other in pairs(player.threeDeeObjects) do
			if self.scene.currentLayer == other.priorityLayer then
				return
			end
		end
	end]]

    if self:onTop() then
		player.tempFlyOffsetY = -self.object.height + self.landingOffsetY
		player.flyLandingLayer = self.flyLandingLayer
		player.nextFlyLandingLayer = self.nextFlyLandingLayer
		player.nextFlyOffsetY = self.nextFlyOffsetY
		player.sprite.sortOrderY = 100000
		player.dropShadow.sprite.sortOrderY = 100000

		self.lastOnTop = true
    else
        player.tempFlyOffsetY = 0
		player.flyLandingLayer = self.nextFlyLandingLayer
		player.nextFlyLandingLayer = self.nextFlyLandingLayer
		player.nextFlyOffsetY = 0
		player.sprite.sortOrderY = nil
		player.dropShadow.sprite.sortOrderY = nil

		if self.lastOnTop and player.flyOffsetY > 500 then
			--player:run(Ease(self.scene.camPos, "y", -player.flyOffsetY, 2, "linear"))
		end

		self.lastOnTop = false
    end

	player.threeDeeObjects[tostring(self)] = self
end

function ThreeDee:land()
	-- noop
	return false
end

function ThreeDee:onTop()
	local player = self.scene.player
	local playerY = player.y + player.flyOffsetY
	local objBottomY = self.object.y + self.object.height
	return (playerY < objBottomY) and (playerY > (objBottomY - self.depth))
end

function ThreeDee:notColliding(player, prevState)
    if GameState.leader ~= "tails" or
	   not player.doingSpecialMove or
	   next(player.threeDeeObjects) == nil
	then
        return
    end

	player.threeDeeObjects[tostring(self)] = nil

	if next(player.threeDeeObjects) == nil then
		player.tempFlyOffsetY = 0
		player.flyLandingLayer = self.nextFlyLandingLayer
		player.sprite.sortOrderY = nil
		player.dropShadow.sprite.sortOrderY = nil

		if self.lastOnTop and player.flyOffsetY > 500 then
			--player:run(Ease(self.scene.camPos, "y", -player.flyOffsetY, 2, "linear"))
		end
		self.lastOnTop = false
	end
end


return ThreeDee
