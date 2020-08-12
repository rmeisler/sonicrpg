local NPC = require "object/NPC"

local SpawnPoint = class(NPC)

function SpawnPoint:construct(scene, layer, object)
	NPC.init(self)
end

return SpawnPoint
