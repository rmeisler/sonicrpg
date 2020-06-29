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

	self.touched = false
end

function Switch:flip()
	self.animState = "on"
	self.sprite:trySetAnimation(self.animState)
	if self.object.properties.subject then
		local subjects = pack((self.object.properties.subject):split(','))
		for _, subject in pairs(subjects) do
			self.scene.objectLookup[subject]:use()
		end
	end
	
	if self.object.properties.script and not self.touched then
		self.scene:run(assert(loadstring(self.object.properties.script))()(self))
		self.touched = true
	end
	
	GameState:setFlag(self)
end


return Switch
