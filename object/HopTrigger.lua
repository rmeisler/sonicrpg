local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"

local NPC = require "object/NPC"

local HopTrigger = class(NPC)

function HopTrigger:construct(scene, layer, object)
	NPC.init(self)
end

function HopTrigger:onCollision(prevState)
    NPC.onCollision(self, prevState)

	if self.scene.player.isHopping or self.scene.player.doingSpecialMove then
		return
	end
	
	self.scene.player.isHopping = true
	
	local action = Action()
	if  love.keyboard.isDown("up") and
		self.scene.player:isFacing("up") and
		self.object.properties.up
	then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
				self.scene.player.noIdle = true
				self.scene.player.dropShadowOverrideY = self.scene.player.y + self.scene.player.sprite.h - 15
			end),
			Animate(self.scene.player.sprite, "crouchup"),
			Wait(0.1),
			Animate(self.scene.player.sprite, "jumpup"),
			Parallel {
				Serial {
					Ease(self.scene.player, "y", self.scene.player.y - 150, 5, "inout"),
					Ease(self.scene.player, "y", self.scene.player.y - 120, 6, "inout")
				},
				Ease(self.scene.player, "dropShadowOverrideY", self.scene.player.y + self.scene.player.sprite.h - 15 - 120, 4, "inout")
			},
			Animate(self.scene.player.sprite, "crouchup"),
			Do(function()
				self.scene.player.cinematic = false
				self.scene.player.isHopping = false
				self.scene.player.noIdle = false
				self.scene.player.dropShadowOverrideY = nil
			end),
		}
	elseif  love.keyboard.isDown("down") and
			self.scene.player:isFacing("down") and
			self.object.properties.down
	then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
				self.scene.player.noIdle = true
				self.scene.player.dropShadowOverrideY = self.scene.player.y + self.scene.player.sprite.h - 15
			end),
			Animate(self.scene.player.sprite, "crouchdown"),
			Wait(0.1),
			Animate(self.scene.player.sprite, "jumpdown"),
			Parallel {
				Serial {
					Ease(self.scene.player, "y", self.scene.player.y - 20, 5, "inout"),
					Ease(self.scene.player, "y", self.scene.player.y + 110, 6, "inout")
				},
				Ease(self.scene.player, "dropShadowOverrideY", self.scene.player.y + self.scene.player.sprite.h - 15 + 110, 3, "inout")
			},
			Animate(self.scene.player.sprite, "crouchdown"),
			Do(function()
				self.scene.player.cinematic = false
				self.scene.player.isHopping = false
				self.scene.player.noIdle = false
				self.scene.player.dropShadowOverrideY = nil
			end),
		}
	elseif  love.keyboard.isDown("left") and
			self.scene.player:isFacing("left") and
			self.object.properties.left
	then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
				self.scene.player.noIdle = true
				self.scene.player.dropShadowOverrideY = self.scene.player.y + self.scene.player.sprite.h - 15
			end),
			Wait(0.1),
			Animate(self.scene.player.sprite, "jumpleft"),
			Parallel {
				Ease(self.scene.player, "x", self.scene.player.x - 120, 5, "linear"),
				Serial {
					Ease(self.scene.player, "y", self.scene.player.y - 50, 5, "inout"),
					Ease(self.scene.player, "y", self.scene.player.y, 6, "inout")
				},
			},
			Do(function()
				self.scene.player.cinematic = false
				self.scene.player.isHopping = false
				self.scene.player.noIdle = false
				self.scene.player.dropShadowOverrideY = nil
			end),
		}
	elseif  love.keyboard.isDown("right") and
			self.scene.player:isFacing("right") and
			self.object.properties.right
	then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
				self.scene.player.noIdle = true
				self.scene.player.dropShadowOverrideY = self.scene.player.y + self.scene.player.sprite.h - 15
			end),
			Wait(0.1),
			Animate(self.scene.player.sprite, "jumpright"),
			Parallel {
				Ease(self.scene.player, "x", self.scene.player.x + 120, 5, "linear"),
				Serial {
					Ease(self.scene.player, "y", self.scene.player.y - 50, 5, "inout"),
					Ease(self.scene.player, "y", self.scene.player.y, 6, "inout")
				},
			},
			Do(function()
				self.scene.player.cinematic = false
				self.scene.player.isHopping = false
				self.scene.player.noIdle = false
				self.scene.player.dropShadowOverrideY = nil
			end),
		}
	else
		self.scene.player.isHopping = false
	end
	
	self.scene.player:run(action)
end


return HopTrigger
