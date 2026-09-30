local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"

local SwatHeadbot = class(Bot)

function SwatHeadbot:construct(scene, layer, object)
	if self:isRemoved() then
		return
	end

	self.udflashlight:remove()
	self.lrflashlight:remove()

	self.hotspotOffsets = {
		right_top = {x = 0, y = self.sprite.h*1.5},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = self.sprite.h*1.5},
		left_bot  = {x = 0, y = 0}
	}

	Bot.init(self, true)
	self.collision = {}
	
	self.sprite:pushOverride("idleup", "swathead_up")
	self.sprite:pushOverride("idledown", "swathead_down")
	self.sprite:pushOverride("idleleft", "swathead_left")
	self.sprite:pushOverride("idleright", "swathead_right")
	
	self.sprite:pushOverride("walkup", "swathead_up")
	self.sprite:pushOverride("walkdown", "swathead_down")
	self.sprite:pushOverride("walkleft", "swathead_left")
	self.sprite:pushOverride("walkright", "swathead_right")
	
	self.sprite:pushOverride("runup", "swathead_up")
	self.sprite:pushOverride("rundown", "swathead_down")
	self.sprite:pushOverride("runleft", "swathead_left")
	self.sprite:pushOverride("runright", "swathead_right")

	self.sprite:pushOverride("lightup", "swathead_up")
	self.sprite:pushOverride("lightdown", "swathead_down")
	self.sprite:pushOverride("lightleft", "swathead_left")
	self.sprite:pushOverride("lightright", "swathead_right")

	self.stepSfx = nil
	self.dropShadow:remove()
end


return SwatHeadbot
