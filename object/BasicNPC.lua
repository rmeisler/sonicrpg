local NPC = require "object/NPC"

local BasicNPC = class(NPC)

function BasicNPC:construct(scene, layer, object)
	NPC.init(self)
end

return BasicNPC
