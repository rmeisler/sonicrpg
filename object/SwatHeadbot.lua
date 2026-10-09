local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"
local NPC = require "object/NPC"

local SwatHeadbot = class(Bot)

function SwatHeadbot:construct(scene, layer, object)
	if self:isRemoved() then
		return
	end

	self.udflashlight:remove()
	self.lrflashlight:remove()

	self.hotspotOffsets = {
		right_top = {x = -55, y = self.sprite.h*2 - 20},
		right_bot = {x = -55, y = -20},
		left_top  = {x = 55, y = self.sprite.h*2 - 20},
		left_bot  = {x = 55, y = -20}
	}

	Bot.init(self, true)
	self.collision = {}
	
	self.sprite:pushOverride("idle", "swathead_right")
	self.sprite:pushOverride("hurt", "swathead_right")
	self.sprite:pushOverride("hurtup", "swathead_up")
	self.sprite:pushOverride("hurtdown", "swathead_down")
	self.sprite:pushOverride("hurtleft", "swathead_left")
	self.sprite:pushOverride("hurtright", "swathead_right")
	
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
	
	self.sprite:setAnimation(self.sprite.selected)

	self.stepSfx = nil
	self.dropShadow:remove()
end

function SwatHeadbot:isTouchingPlayer()
	local cx = self.hotspots.left_top.x
	local cy = self.hotspots.left_top.y
	local cw = self.hotspots.right_top.x - cx
	local ch = self.hotspots.right_bot.y - cy
	
	local playerHotspots = self.scene.player.hotspots
	local fuzz = 5

	return (cx + cw) >= (playerHotspots.left_bot.x - fuzz) and
		cx < (playerHotspots.right_bot.x + fuzz) and
		(playerHotspots.left_bot.y + fuzz) >= cy and
		(playerHotspots.right_top.y + fuzz) <= (cy + ch)
end


return SwatHeadbot
