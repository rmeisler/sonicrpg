local NPC = require "object/NPC"
local Player = require "object/Player"

local SpawnPoint = class(NPC)

function SpawnPoint:construct(scene, layer, object)
	NPC.init(self)

	if scene.lastSpawnPoint == self.name then
		scene.player = Player(self.scene, self.layer, table.clone(self.object))
	end
end

return SpawnPoint
