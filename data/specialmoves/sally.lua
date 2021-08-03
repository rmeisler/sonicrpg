local Serial = require "actions/Serial"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"

local Transform = require "util/Transform"
local Player = require "object/Player"
local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

return function(player)
	if player.disableScan then
		return
	end

	-- Pause controls
	local origUpdate = player.basicUpdate
	
	player.state = Player.ToIdle[player.state]
	if player.state == Player.STATE_IDLEUP then
		player.sprite:setAnimation("nicholeup")
	elseif player.state == Player.STATE_IDLEDOWN then
		player.sprite:setAnimation("nicholedown")
	elseif player.state == Player.STATE_IDLELEFT then
		player.sprite:setAnimation("nicholeleft")
	elseif player.state == Player.STATE_IDLERIGHT then
		player.sprite:setAnimation("nicholeright")
	end
	
	player.scene.audio:playSfx("nichole", 1.0)
		
	player.scan = function(self, target)
		if self.scanning then
			return
		end

		self.hidekeyhints[tostring(target)] = target

		self.cinematic = true
		self.cinematicStack = self.cinematicStack + 1
		self.scanning = true

		self:run {
			PlayAudio("sfx", "nicholescan", 1.0, true),

			Do(function()
				target.sprite:setParallax(4)
			end),
			
			Wait(0.7),
			
			Do(function()
				target.sprite:removeParallax()
			end),
			
			target.onScan and target:onScan() or Action(),
			
			Do(function()
				self.doingSpecialMove = false
				self.scanning = false
				self.cinematic = false
				
				print("cinematicstack - 1")
				self.cinematicStack = self.cinematicStack - 1
				self.basicUpdate = origUpdate

				-- Refresh keyhint
				self.hidekeyhints[tostring(target)] = nil
			end)
		}
	end
	
	player.basicUpdate = function(self, dt)
		if not love.keyboard.isDown("lshift") and not self.scanning then
			self.cinematic = false
			self.doingSpecialMove = false
			self.basicUpdate = origUpdate
		end
	end
end