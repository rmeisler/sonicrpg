local NPC = require "object/NPC"

local HidingSpot = class(NPC)

function HidingSpot:construct(scene, layer, object)
	self.ghost = true
	NPC.init(self)
end

function HidingSpot:update(dt)
	NPC.update(self, dt)
	
	if not self.scene.player then
		return
	end

	if self.state == NPC.STATE_IDLE then
		self.scene.player.shadows[tostring(self)] = nil
	elseif self.state == NPC.STATE_TOUCHING then
		self.scene.player.shadows[tostring(self)] = true
	end
end

return HidingSpot
