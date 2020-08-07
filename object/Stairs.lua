local Player = require "object/Player"
local NPC = require "object/NPC"

local Stairs = class(NPC)

function Stairs:construct(scene, layer, object)
    self.ghost = true
	self.direction = object.properties.direction
	
	NPC.init(self, true)

	self:addSceneHandler("update", Stairs.update)
end

function Stairs:update(dt)
	local player = self.scene.player
	if self.state == NPC.STATE_TOUCHING then
		-- On first touch, update position
		if not next(player.stairs) then
			player.x = self.x + self.object.width/2
			player.y = self.y + self.object.height/2 - player.sprite.h
		end
		player.stairs[tostring(self)] = self
	else
		player.stairs[tostring(self)] = nil
	end
end


return Stairs
