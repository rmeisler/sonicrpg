local BasicNPC = require "object/BasicNPC"
local Action = require "actions/Action"

local NPC = require "object/NPC"

local Switch = class(NPC)

function Switch:construct(scene, layer, object)
	NPC.init(self)
	
	self.onState = object.properties.onState or "on"
	self.offState = object.properties.offState or "off"
	
	if not GameState:isFlagSet(self) then
		self:addInteract(Switch.flip)
		self.animState = self.offState
	else
		self:removeInteract(Switch.flip)
		self.animState = self.onState
	end

	self.touched = false
end

function Switch:flip()
	if self.object.properties.overrideScript then
		self.scene:run(assert(loadstring(self.object.properties.overrideScript))()(self))
	else
		self.animState = self.onState
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
		self:removeInteract(Switch.flip)
	end
end
 
function Switch:onScan()
	if self.object.properties.onScan then
		return assert(loadstring(self.object.properties.onScan))()(self)
	else
		return Action()
	end
end


return Switch
