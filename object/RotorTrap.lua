local Menu = require "actions/Menu"
local Do = require "actions/Do"
local BlockPlayer = require "actions/BlockPlayer"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local MessageBox = require "actions/MessageBox"
local Action = require "actions/Action"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local While = require "actions/While"
local Repeat = require "actions/Repeat"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local Savescreen = require "object/Savescreen"
local Player = require "object/Player"
local NPC = require "object/NPC"

local RotorTrap = class(NPC)

function RotorTrap:construct(scene, layer, object)
	NPC.init(self)

	self.hotspots.right_top.x = self.x + self.sprite.w / 3
	self.hotspots.right_top.y = self.y - self.sprite.h / 2
	self.hotspots.right_bot.x = self.x + self.sprite.w / 3
	self.hotspots.right_bot.y = self.y + self.sprite.h / 2
	self.hotspots.left_top.x = self.x - self.sprite.w / 3
	self.hotspots.left_top.y = self.y - self.sprite.h / 2
	self.hotspots.left_bot.x = self.x - self.sprite.w / 3
	self.hotspots.left_bot.y = self.y + self.sprite.h / 2

	self.timeToSwitch = 0.2
	self.shockedBots = {}
	self:removeSceneHandler("update")
	self:addSceneHandler("onEnterBattle")
end

function RotorTrap:update(dt)
	NPC.update(self, dt)

	self:shockBots()

	for _, bot in pairs(self.shockedBots) do
		if self.sprite and not bot:isTouching(self.x + 64, self.y + 48, 64/5, 48/5) then
			if bot.addCollisionHandler then
				bot:addCollisionHandler()
			end
			if bot.restart then
				bot:restart()
			end
			if bot.sprite then
				bot.sprite:removeInvertedColor()
			end
			self.shockedBots[tostring(bot)] = nil
			self.scene.player.chasers[tostring(bot.name)] = nil
			print("reset bot")
		end
	end

	self.timeToSwitch = self.timeToSwitch - dt
	if self.timeToSwitch <= 0 then
		for _, bot in pairs(self.shockedBots) do
			if bot.sprite and not bot.destructable then
				if bot.invert then
					bot.sprite:setInvertedColor()
					bot.invert = false
				else
					bot.sprite:removeInvertedColor()
					bot.invert = true
				end
			end
		end
		self.timeToSwitch = 0.2
	end
end

function RotorTrap:onEnterBattle()
	self.shockedBots = {}
end

function RotorTrap:shockBots()
	if self.sprite == nil then
		return
	end

	for _, obj in pairs(self.scene.map.objects) do
		if obj.shocked and not self.shockedBots[tostring(obj)] then
			obj.shocked = false
			if obj.addCollisionHandler then
				obj:addCollisionHandler()
			end
			if obj.restart then
				obj:restart()
			end
			if obj.sprite then
				obj.sprite:removeInvertedColor()
			end
		end

		if obj.isBot and
		   (not self.scene.map.properties.layered or
		   self.scene.currentLayer == obj.layer.name) and
		   --obj.disableBot and
		   not obj.destructing and
		   not obj:isRemoved() and
		   not self.shockedBots[tostring(obj)] and
		   obj:isTouching(
				self.x + self.sprite.w,
				self.y + self.sprite.h,
				self.sprite.w/5,
				self.sprite.h/5)
		then
		    print("bot is shocked")
			if obj.prevSceneMusic then
				self.scene.audio:playMusic(obj.prevSceneMusic)
			end
			if obj.onRotorTrap then
				obj:onRotorTrap()
			end
			self.shockedBots[tostring(obj)] = obj
			obj.shocked = true
			
			obj.sprite:trySetAnimation("hurtdown")
			--obj:removeCollision()
			if obj.removeCollisionHandler then
				obj:removeCollisionHandler()
			end
			if obj.removeAllUpdates then
				obj:removeAllUpdates()
			end
			self.scene.player.chasers[tostring(obj.name)] = nil
			obj.destructing = obj.destructable
			if obj.destructable then
				obj:run {
					PlayAudio("sfx", "shocked", 1.0, true),
					Repeat(Serial {
						Do(function()
							if obj.sprite then
								obj.sprite:setInvertedColor()
							end
						end),
						Wait(0.1),
						Do(function()
							if obj.sprite then
								obj.sprite:removeInvertedColor()
							end
						end),
						Wait(0.1),
					}, 3),
					Do(function()
						obj.sprite:removeInvertedColor()
					end),
					PlayAudio("sfx", "oppdeath", 1.0, true),
					Ease(obj.sprite.color, 4, 0, 1),
					Do(function() obj:permanentRemove() end)
				}
			end
		end
	end
end


return RotorTrap
