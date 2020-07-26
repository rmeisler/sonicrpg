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
		player.stairs[tostring(self)] = self
	else
		player.stairs[tostring(self)] = nil
	end
end


return Stairs
