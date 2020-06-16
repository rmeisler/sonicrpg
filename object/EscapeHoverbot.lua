local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local While = require "actions/While"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local Serial = require "actions/Serial"
local PlayAudio = require "actions/PlayAudio"
local Animate = require "actions/Animate"
local Action = require "actions/Action"
local Parallel = require "actions/Parallel"
local Try = require "actions/Try"
local YieldUntil = require "actions/YieldUntil"
local Ease = require "actions/Ease"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

local EscapeTarget = require "object/EscapeTarget"

local NPC = require "object/NPC"

local EscapeHoverbot = class(NPC)

-- TODO:
---------------------
-- Get screen coordinates for player x,y and use that for target icon and beam
-- If beam hits Sonic, do fallback animation with bright blink

function EscapeHoverbot:construct(scene, layer, object)
	self.ghost = true
	self.object.properties.nocollision = true
	
	NPC.init(self)
	
	self.offsetX = 0
	self:removeSceneHandler("update")
end

function EscapeHoverbot:startDrift(offset)
	--[[ Move left and right casually
	self:run {
		Wait(offset),
		Repeat(
			Serial {
				Wait(2),
				Do(function()
					self.offsetX = 1
				end),
				Wait(2),
				Do(function()
					self.offsetX = -1
				end)
			}
		)
	}]]
end

function EscapeHoverbot:fire(location, fast)
	EscapeTarget.place(
		self.scene,
		self.layer,
		self,
		Transform(140, 0),
		location,
		fast
	)
	
	if fast then
		local laserFiredFun
		laserFiredFun = function(laser)
			self.followPlayerY = true
			self.scene:removeHandler("laserfired", fun)
		end
		self.followPlayerY = false
		self.scene:addHandler("laserfired", laserFiredFun)
	end
end

function EscapeHoverbot:update(dt)
	if not self.scene:playerMovable() or self.stopMoving then
		return
	end
	
	local fx = self.scene.player.fx
	if self.scene.player.noGas then
		fx = 25
	end

	local bx = self.scene.player.bx
	if bx > 0 then
		bx = bx + 1
	end
	self.x = self.x + (fx + bx + self.offsetX) * (dt/0.016)
	
	if self.followPlayerY then
		if self.y + self.sprite.h > self.scene.player.y + 10 then
			self.y = self.y - 2*(dt/0.016)
		elseif self.y + self.sprite.h < self.scene.player.y - 10 then
			self.y = self.y + 2*(dt/0.016)
		end
	end
end

return EscapeHoverbot
