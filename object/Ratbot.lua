local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local Swatbot = require "object/Swatbot"

local Ratbot = class(Swatbot)

function Ratbot:construct(scene, layer, object)
	self.udflashlight:remove()
	self.lrflashlight:remove()

	self.flashlightSprite = SpriteNode(
		self.scene,
		Transform(),
		nil,
		"ratboteyes",
		nil,
		nil,
		"objects"
	)
	self.flashlightSprite.visible = false
	
	self.flashlight = {
		up = self.flashlightSprite,
		down = self.flashlightSprite,
		right = self.flashlightSprite,
		left = self.flashlightSprite
	}
	
	self.hotspotOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = 0},
		left_bot  = {x = 0, y = 0}
	}
	
	Swatbot.init(self)
	self.collision = {}
	
	self.hotspotOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = 0},
		left_bot  = {x = 0, y = 0}
	}
	
	self.dropShadow.sprite.transform.sx = 5

	self.sprite.color[1] = 50
	self.sprite.color[2] = 50
	self.sprite.color[3] = 50
	
	self:addSceneHandler("update", Ratbot.updateEyes)

	self.stepSfx = nil
end

function Ratbot:updateEyes(dt)
	self.flashlightSprite.sortOrderY = 999999 --self.sprite.transform.y + self.sprite.h + 1
	
	self.flashlightSprite.transform = self:getFlashlightOffset()
	self.flashlightSprite.visible = true
	self.flashlightSprite:setAnimation(self.facing)
end

function Ratbot:updateDropShadowPos(xonly)
	self.dropShadow.x = self.x + 60
	
	if not xonly then
		self.dropShadow.y = self.y + self.sprite.h*2 - 14
	end
end

function Ratbot:getFlashlightOffset()
	if self.facing == "up" then
		return Transform(self.sprite.transform.x + self.sprite.w*1.5 + 20, self.sprite.transform.y + self.sprite.h + 10, 2, 2)
	elseif self.facing == "down" then
		return Transform(self.sprite.transform.x + self.sprite.w*1.5 + 20, self.sprite.transform.y + self.sprite.h + 10, 2, 2)
	elseif self.facing == "right" then
		return Transform(self.sprite.transform.x + self.sprite.w*1.5 + 20, self.sprite.transform.y + self.sprite.h + 10, 2, 2)
	elseif self.facing == "left" then
		return Transform(self.sprite.transform.x - self.flashlightSprite.w*2 + 50, self.sprite.transform.y + self.sprite.h + 10, 2, 2)
	end
end

return Ratbot
