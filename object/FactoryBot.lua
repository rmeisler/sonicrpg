local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local Swatbot = require "object/Swatbot"

local FactoryBot = class(Swatbot)

function FactoryBot:construct(scene, layer, object)
	self.udflashlight:remove()
	self.lrflashlight:remove()
	
	Swatbot.init(self)
	self.collision = {}
	
	self.stepSfx = nil
end

function FactoryBot:getFlashlightOffset()
	return Transform()
end

return FactoryBot
