local NPC = require "object/NPC"

local EscapeObstacle = class(NPC)

function EscapeObstacle:construct(scene, layer, object)
	NPC.construct(self, scene, layer, object)

	self:addHandler("collision", EscapeObstacle.killPlayer, self)
end

function EscapeObstacle:killPlayer()
	self.scene.player.fx = 0
	self.scene.player.bx = 0
	self.scene.player.extraBx = 0
	self.scene.player.fy = 0
	self.scene.player.by = 0
	self.scene.player.noGas = true
	self.scene.player.cinematic = true
	self.scene.playerDead = true
end


return EscapeObstacle
