local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"

local NPC = require "object/NPC"
local FallArea = class(NPC)

function FallArea:construct(scene, layer, object)
	self.ghost = true
	NPC.init(self)
end

function FallArea:update(dt)
	if self.scene.player.falling then
		return
	end

	NPC.update(self, dt)

	if self.state == NPC.STATE_TOUCHING and not self.scene.player.falling then
		self.scene.player.fallables[tostring(self)] = self
		
		if next(self.scene.player.platforms) == nil then
			self.scene.player.falling = true
			
			-- Fall to your doom
			local origUpdate = self.scene.player.basicUpdate
			self.scene.player.basicUpdate = function(player, dt) end
			self.scene.player.doingSpecialMove = false
			self.scene.player.cinematic = true
			
			self:run {
				Parallel {
					Animate(self.scene.player.sprite, "shock"),
					Ease(self.scene.player, "y", self.scene:getMapHeight() - self.scene.player.sprite.h*4, 1),
					Ease(self.scene.player.sprite.color, 4, 0, 1.5)
				},
				Do(function()
					-- Reposition player at last safe platform
					self.scene.player.x = self.scene.lastSafePlatform.x + self.scene.lastSafePlatform.object.width/2
					self.scene.player.y = self.scene.lastSafePlatform.y
					self.scene.player.platforms[tostring(self.scene.lastSafePlatform)] = self.scene.lastSafePlatform
					self.scene.player.basicUpdate = self.scene.player.origUpdate or origUpdate
					self.scene.player.state = "idledown"
					self.scene.player.falling = false
					self.scene.player.cinematic = false
				end),
				-- Blink transparency
				Repeat(
					Serial {
						Ease(self.scene.player.sprite.color, 4, 0, 20, "quad"),
						Ease(self.scene.player.sprite.color, 4, 255, 20, "quad")
					},
					10
				),
				Do(function()
					self.scene.player.cinematic = false
					self.scene.player.basicUpdate = self.scene.player.origUpdate
					self.scene.player.origUpdate = nil
					self.scene.player.doingChangeChar = false
					
					-- Update keyhint
					self.scene.player:removeKeyHint()
				end)
			}
		end
	else
		self.scene.player.fallables[tostring(self)] = nil
	end
end


return FallArea
