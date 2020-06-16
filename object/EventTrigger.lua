local NPC = require "object/NPC"

local Switch = class(NPC)

function Switch:construct(scene, layer, object)
	self.ghost = true
	self:addHandler("collision", Switch.collision, self)
end

function Switch:collision()
	if not self.runscript then
		self.scene:run(
			love.filesystem.load("maps/"..self.object.properties.script)()(self.scene)
		)
		self.runscript = true
	end
end


return Switch
