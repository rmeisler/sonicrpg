local NPC = require "object/NPC"

local TouchTrigger = class(NPC)

function TouchTrigger:construct(scene, layer, object)
    self.ghost = true
	
	NPC.init(self)

	self.atMostOnce = object.properties.atMostOnce

	self:addHandler("collision", TouchTrigger.touch, self)
end

function TouchTrigger:touch(prevState)
	if not self.atMostOnce or not GameState:isFlagSet(self:getFlag()) then
		self.scene:run(assert(loadstring(self.object.properties.script))()(self))
		GameState:setFlag(self:getFlag())
	end
end

return TouchTrigger
