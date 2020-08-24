local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"

local FactoryBot = class(Bot)

function FactoryBot:construct(scene, layer, object)
	if self:isRemoved() then
		return
	end
	
	self.udflashlight:remove()
	self.lrflashlight:remove()
	
	Bot.init(self, true)
	self.collision = {}
	
	self.stepSfx = nil
end

function FactoryBot:getFlashlightOffset()
	return Transform()
end

return FactoryBot
