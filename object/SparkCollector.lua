local Ease = require "actions/Ease"

local NPC = require "object/NPC"

local SparkCollector = class(NPC)

function SparkCollector:construct(scene, layer, object)
    self.ghost = true

	NPC.init(self)
	
	self.touched = false

	self:addHandler("collision", SparkCollector.touch, self)
end

function SparkCollector:touch(prevState)
	if not self.touched then
		self:run {
			Ease(self.scene.player.sprite.color, 2, 512, 10, "quad")
		}
		self.touched = true
		self:remove()
	end
end

return SparkCollector
