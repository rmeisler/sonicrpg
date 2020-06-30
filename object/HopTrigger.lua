local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Action = require "actions/Action"

local NPC = require "object/NPC"

local HopTrigger = class(NPC)

function HopTrigger:construct(scene, layer, object)
	NPC.init(self)
	
	self:addInteract(HopTrigger.hop)
end

function HopTrigger:hop()
	local action = Action()
	
	if self.scene.player.isHopping then
		return
	end
	
	self.scene.player.isHopping = true
	
	if self.scene.player:isFacing("up") and self.object.properties.up then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
			end),
			Ease(self.scene.player, "y", self.scene.player.y - 150, 5, "inout"),
			Ease(self.scene.player, "y", self.scene.player.y - 120, 6, "inout"),
			Do(function()
				self.scene.player.cinematic = false
				self.scene.player.isHopping = false
			end),
		}
	elseif self.scene.player:isFacing("down") and self.object.properties.down then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
			end),
			Ease(self.scene.player, "y", self.scene.player.y - 20, 5, "inout"),
			Ease(self.scene.player, "y", self.scene.player.y + 110, 6, "inout"),
			Do(function()
				self.scene.player.cinematic = false
				self.scene.player.isHopping = false
			end),
		}
	elseif self.scene.player:isFacing("left") and self.object.properties.left then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
			end),
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
			end),
		}
	elseif self.scene.player:isFacing("right") and self.object.properties.right then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
			end),
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
			end),
		}
	else
		self.scene.player.isHopping = false
	end
	
	self.scene:run(action)
end


return HopTrigger
