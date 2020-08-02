local Transform = require "util/Transform"

local BasicNPC = require "object/BasicNPC"
local NPC = require "object/NPC"
local SpriteNode = require "object/SpriteNode"
local Swatbot = require "object/Swatbot"

local Ratbot = class(Swatbot)

function Ratbot:construct(scene, layer, object)
	self.udflashlight:remove()
	self.lrflashlight:remove()
	
	self.noInvestigate = true

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
	
	Swatbot.init(self)
	self.collision = {}
	
	self.hotspotOffsets = {
		right_top = {x = -20, y = 50},
		right_bot = {x = -20, y = 0},
		left_top  = {x = 60, y = 50},
		left_bot  = {x = 60, y = 0}
	}
	
	self.dropShadow.sprite.transform.sx = 5

	self.stepSfx = nil
end

function Swatbot:createDropShadow()
	self.dropShadow = BasicNPC(
		self.scene,
		{name = "ratshadow"},
		{name = "dropshadow", x = 0, y = 0, width = 36, height = 6,
			properties = {nocollision = true, sprite = "art/sprites/dropshadow.png", align = NPC.ALIGN_TOPLEFT}
		}
	)
	self.scene:addObject(self.dropShadow)
end

function Ratbot:updateDropShadowPos(xonly)
	self.dropShadow.x = self.x + 60
	
	if not xonly then
		self.dropShadow.y = self.y + self.sprite.h*2 - 14
	end
end

return Ratbot
