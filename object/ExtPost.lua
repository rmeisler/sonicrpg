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
	local dx = (self.scene.player.x - (self.x + self.sprite.w))
	local dy = (self.scene.player.y - (self.y + self.sprite.h))
	return (dx*dx + dy*dy)
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
	if  extenderarm.transform.x + extenderarm.w*2 > self.sprite.transform.x and
		extenderarm.transform.x <= self.sprite.transform.x + self.sprite.w*2 and
		extenderarm.transform.y + extenderarm.h*2 > self.sprite.transform.y and
		extenderarm.transform.y <= self.sprite.transform.y + self.sprite.h*2
	then
		self.scene.player.extenderArmColliding = true
	end
end

return ExtPost
