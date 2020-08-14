local Transform = require "util/Transform"

local BasicNPC = require "object/BasicNPC"
local NPC = require "object/NPC"
local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"

local Ratbot = class(Bot)

function Ratbot:construct(scene, layer, object)
	self.udflashlight:remove()
	self.lrflashlight:remove()
	
	self.noInvestigate = true
	
	self.hotspotOffsets = {
		right_top = {x = -40, y = 100},
		right_bot = {x = -40, y = 0},
		left_top  = {x = 40, y = 100},
		left_bot  = {x = 40, y = 0}
	}
	
	--self.useObjectCollision = true
	
	Bot.init(self, true)
	self.collision = {}
	
	self.dropShadow.sprite.transform.sx = 5

	self.stepSfx = "ratstep"
end

function Ratbot:getBattleArgs()
	local args = Bot.getBattleArgs(self)
	args.color = {200,200,200,255}
	return args
end

function Ratbot:createDropShadow()
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
