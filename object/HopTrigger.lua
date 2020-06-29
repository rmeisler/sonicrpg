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
	
	if self.scene.player:isFacing("up") and self.object.properties.up then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
			end),
			Ease(self.scene.player, "y", self.scene.player.y - 100, 5, "inout"),
			Ease(self.scene.player, "y", self.scene.player.y - 50, 8, "inout"),
			Do(function()
				self.scene.player.cinematic = false
			end),
		}
	elseif self.scene.player:isFacing("down") and self.object.properties.down then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
			end),
			Ease(self.scene.player, "y", self.scene.player.y - 50, 5, "inout"),
			Ease(self.scene.player, "y", self.scene.player.y + 50, 8, "inout"),
			Do(function()
				self.scene.player.cinematic = false
			end),
		}
	elseif self.scene.player:isFacing("left") and self.object.properties.left then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
			end),
			Parallel {
				Ease(self.scene.player, "x", self.scene.player.x - 50, 2, "linear"),
				Serial {
					Ease(self.scene.player, "y", self.scene.player.y - 50, 8, "inout"),
					Ease(self.scene.player, "y", self.scene.player.y, 8, "inout")
				},
			},
			Do(function()
				self.scene.player.cinematic = false
			end),
		}
	elseif self.scene.player:isFacing("right") and self.object.properties.right then
		action = Serial {
			Do(function()
				self.scene.player.cinematic = true
			end),
			Parallel {
				Ease(self.scene.player, "x", self.scene.player.x + 50, 2, "linear"),
				Serial {
					Ease(self.scene.player, "y", self.scene.player.y - 50, 8, "inout"),
					Ease(self.scene.player, "y", self.scene.player.y, 8, "inout")
				},
			},
			Do(function()
				self.scene.player.cinematic = false
			end),
		}
	end
	
	self.scene:run(action)
end


return HopTrigger
