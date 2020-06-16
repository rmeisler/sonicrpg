local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"

local Switch = class(NPC)

function Switch:construct(scene, layer, object)
	NPC.init(self)
	
	if not GameState:isFlagSet(self) then
		self:addInteract(Switch.flip)
		self.animState = "off"
	else
		self.animState = "on"
	end
end

function Switch:flip()
	self.animState = "on"
	self.sprite:setAnimation(self.animState)
	self.scene.objectLookup[self.object.properties.subject]:use()
	
	GameState:setFlag(self)
end


return Switch
