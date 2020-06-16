local NPC = require "object/NPC"

local SafePlatform = class(NPC)

function SafePlatform:construct(scene, layer, object)
	self.ghost = true
	self.align = NPC.ALIGN_BOTLEFT
	NPC.init(self)
end

function SafePlatform:update(dt)
	if self.scene.dead or self.scene.player.falling then
		return
	end
	
	NPC.update(self, dt)
	
	-- Check if we are colliding with player
	if self.state == NPC.STATE_TOUCHING then
		self.scene.player.platforms[tostring(self)] = self
		self.scene.lastSafePlatform = self
	else
		self.scene.player.platforms[tostring(self)] = nil
	end
end

return SafePlatform
