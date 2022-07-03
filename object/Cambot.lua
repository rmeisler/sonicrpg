local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"

local Cambot = class(Bot)

function Cambot:construct(scene, layer, object)
	if self:isRemoved() then
		return
	end

	self.udflashlight:remove()
	self.lrflashlight:remove()

	self.flashlightSprite = SpriteNode(
		self.scene,
		Transform(),
		nil,
		"camflashlight",
		nil,
		nil,
		"objects"
	)
	self.flashlightSprite.visible = false
	self.flashlightSprite.color[4] = 150
	
	self.flashlight = {
		up = self.flashlightSprite,
		down = self.flashlightSprite,
		right = self.flashlightSprite,
		left = self.flashlightSprite
	}
	
	self.hotspotOffsets = {
		right_top = {x = 0, y = self.sprite.h*1.5},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = self.sprite.h*1.5},
		left_bot  = {x = 0, y = 0}
	}
	
	Bot.init(self, true)
	self.collision = {}
	
	self.stepSfx = nil
	self.dropShadow:remove()
end

function Cambot:getFlashlightOffset()
	local facing = self.manualFacing
	if facing == "up" then
		return Transform(self.sprite.transform.x - self.flashlightSprite.w + 20, self.sprite.transform.y - self.sprite.h - 10, 2, 2)
	elseif facing == "down" then
		return Transform(self.sprite.transform.x - self.sprite.w*2 - 28, self.sprite.transform.y + self.sprite.h - 34, 2, 2)
	elseif facing == "right" then
		return Transform(self.sprite.transform.x, self.sprite.transform.y + 1, 2, 2)
	elseif facing == "left" then
		return Transform(self.sprite.transform.x - self.flashlightSprite.w*2 + 70, self.sprite.transform.y + 1, 2, 2)
	end
end

return Cambot
