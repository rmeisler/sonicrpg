local NPC = require "object/NPC"

local TouchTrigger = class(NPC)

function TouchTrigger:construct(scene, layer, object)
    self.ghost = true
	
	NPC.init(self)
	
	local scriptPath = (object.properties.script):match("(actions/[%w%d_]+)%.lua")
	self.fun = require("maps/"..scriptPath)
	self.touched = false

	self:addHandler("collision", TouchTrigger.touch, self)
end

function TouchTrigger:touch(prevState)
	if not self.touched then
		self.scene:run(self.fun(self.scene))
		
		self.touched = true
	end
end


return TouchTrigger
