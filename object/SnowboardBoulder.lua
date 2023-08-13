local Serial = require "actions/Serial"
local Repeat = require "actions/Repeat"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Wait = require "actions/Wait"

local EscapeObstacle = require "object/EscapeObstacle"
local NPC = require "object/NPC"

local BOULDER_SPEED = 15

local SnowboardBoulder = class(EscapeObstacle)

function SnowboardBoulder:construct(scene, layer, object)
	self:addSceneHandler("update", SnowboardBoulder.move)
	self.sprite.transform.ox = self.sprite.w/2
	self.sprite.transform.oy = self.sprite.h/2
end

function SnowboardBoulder:move(dt)
	local vel = BOULDER_SPEED * (dt/0.016)
	self.x = self.x + vel
	self.y = self.y + (vel / 2)
	self.sprite.transform.angle = self.sprite.transform.angle + dt * 20
	
	NPC.updateCollision(self)
end


return SnowboardBoulder
