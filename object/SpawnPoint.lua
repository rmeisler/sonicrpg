local NPC = require "object/NPC"
local Player = require "object/Player"
local TinyPlayer = require "object/TinyPlayer"

local SpawnPoint = class(NPC)

function SpawnPoint:construct(scene, layer, object)
	NPC.init(self)

	if scene.lastSpawnPoint == self.name then
		if object.properties.tiny then
			print("hold me closer tiny player!")
			scene.player = TinyPlayer(self.scene, self.layer, table.clone(self.object))
		else
			print("see the headlights on the highway!")
			scene.player = Player(self.scene, self.layer, table.clone(self.object))
		end
	end
end

return SpawnPoint
