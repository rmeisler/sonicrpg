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

	self.hotspots.right_top.x = self.x + self.sprite.w / 2
	self.hotspots.right_top.y = self.y - self.sprite.h / 2
	self.hotspots.right_bot.x = self.x + self.sprite.w / 2
	self.hotspots.right_bot.y = self.y + self.sprite.h / 2
	self.hotspots.left_top.x = self.x - self.sprite.w / 2
	self.hotspots.left_top.y = self.y - self.sprite.h / 2
	self.hotspots.left_bot.x = self.x - self.sprite.w / 2
	self.hotspots.left_bot.y = self.y + self.sprite.h / 2

	self.shockedBots = {}
	self:removeSceneHandler("update")
	self:addSceneHandler("onEnterBattle")
end

function RotorTrap:update(dt)
	NPC.update(self, dt)

	self:shockBots()
end

function RotorTrap:onEnterBattle()
	self.shockedBots = {}
end

function RotorTrap:shockBots()
	if self.sprite == nil then
		return
	end
	for _, obj in pairs(self.scene.map.objects) do
		if obj.isBot and
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
			self.shockedBots[tostring(obj)] = obj
			obj.sprite:trySetAnimation("hurtdown")
			obj:removeCollision()
			if obj.removeAllUpdates then
				obj:removeAllUpdates()
			end
			self.scene.player.chasers[tostring(obj.name)] = nil
			obj.destructing = obj.destructable
			obj:run {
				PlayAudio("sfx", "shocked", 1.0, true),
				While(
					function()
						return self.sprite and obj:isTouching(
							self.x + self.sprite.w,
							self.y + self.sprite.h,
							self.sprite.w/5,
							self.sprite.h/5)
					end,
					Serial {
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
						}, obj.destructable and 3),
						obj.destructable and
							Serial {
								Do(function()
									obj.sprite:removeInvertedColor()
								end),
								PlayAudio("sfx", "oppdeath", 1.0, true),
								Ease(obj.sprite.color, 4, 0, 1),
								Do(function() obj:permanentRemove() end)
							} or
							Action()
					},
					obj.destructable and
						Serial {
							Do(function()
								obj.sprite:removeInvertedColor()
							end),
							PlayAudio("sfx", "oppdeath", 1.0, true),
							Ease(obj.sprite.color, 4, 0, 1),
							Do(function() obj:permanentRemove() end)
						} or
						Do(function()
							if obj.sprite then
								obj.sprite:removeInvertedColor()
								obj:addSceneHandler("update")
							end
						end)
				)
			}
		end
	end
end


return RotorTrap
