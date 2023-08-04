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
end

function RotorTrap:update(dt)
	NPC.update(self, dt)

	self:shockBots()
end

function RotorTrap:shockBots()
	if self.sprite == nil then
		return
	end
	for _, obj in pairs(self.scene.map.objects) do
		if obj.isBot and
		   obj.disableBot and
		   not obj:isRemoved() and
		   not self.shockedBots[tostring(obj)] and
		   obj:isTouching(
				self.x - self.sprite.w/4,
				self.y + self.sprite.w/4,
				self.sprite.w / 2,
				self.sprite.h / 2)
		then
			self.shockedBots[tostring(obj)] = obj
			obj:disableBot()
			obj:run {
				Do(function()
					obj.sprite:setAnimation("hurtdown")
				end),
				PlayAudio("sfx", "shocked", 1.0, true),
				While(
					function()
						return obj:isTouching(self.x, self.y, self.object.width, self.object.height)
					end,
					Repeat(Serial {
						Do(function()
							obj.sprite:setInvertedColor()
						end),
						Wait(0.1),
						Do(function()
							obj.sprite:removeInvertedColor()
						end),
						Wait(0.1),
					}),
					Do(function()
						obj:enabledBot()
					end)
				)
			}
		end
	end
end


return RotorTrap
