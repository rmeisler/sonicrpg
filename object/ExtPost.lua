local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"

local NPC = require "object/NPC"

local ExtPost = class(NPC)

function ExtPost:construct(scene, layer, object)
	self.alignment = NPC.ALIGN_BOTLEFT
	NPC.init(self, true)
	
	self:addSceneHandler("update")
end

function ExtPost:distanceFromPlayerSq()
	if self.sprite then
		local dx = (self.scene.player.x - (self.x + self.sprite.w))
		local dy = (self.scene.player.y - (self.y + self.sprite.h))
		return (dx*dx + dy*dy)
	else
		local dx = (self.scene.player.x - (self.x + self.object.width/2))
		local dy = (self.scene.player.y - (self.y + self.object.height/2))
		return (dx*dx + dy*dy)
	end
end

function ExtPost:update(dt)
	self.state = NPC.STATE_IDLE
	
	if not self.scene.player then
		return
	end
	
	local extenderarm = self.scene.player.extenderarm
	if not extenderarm then
		return
	end
	
	if self:distanceFromPlayerSq() <= 10000 then
		return
	end
	
	-- Check if we are colliding with Bunny's extender arm
	local x1
	local y1
	local x2
	local y2
	if self.sprite then
		x1 = self.sprite.transform.x
		y1 = self.sprite.transform.y
		x2 = x1 + self.sprite.w*2
		y2 = y1 + self.sprite.h*2
	else
		x1 = self.x
		y1 = self.y
		x2 = x1 + self.object.width
		y2 = y1 + self.object.height
	end
	
	if  extenderarm.transform.x + extenderarm.w*2 > x1 and
		extenderarm.transform.x <= x2 and
		extenderarm.transform.y + extenderarm.h*2 > y1 and
		extenderarm.transform.y <= y2
	then
		self.scene.player.extenderArmColliding = self
	end
end

return ExtPost
