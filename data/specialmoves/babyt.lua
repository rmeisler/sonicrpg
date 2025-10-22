local Transform = require "util/Transform"

local Player = require "object/Player"
local NPC = require "object/NPC"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Action = require "actions/Action"
local Repeat = require "actions/Repeat"

local anim_to_run = {
	idleleft = "runleft",
	walkleft = "runleft",
	runleft = "runleft",
	
	idleright = "runright",
	walkright = "runright",
	runright = "runright",
	
	idleup = "runup",
	walkup = "runup",
	runup = "runup",

	idledown = "rundown",
	walkdown = "rundown",
	rundown = "rundown",
}

local anim_to_idle = {
	runleft = "idleleft",
	runright = "idleright",
	runup = "idleup",
	rundown = "idledown",
}

return function(player)
	-- Remember basic movement controls
	player.basicUpdate = function(self, dt) end
	
	local ram = function(self, dt)
		if not love.keyboard.isDown("lshift") then
			self.charging = false
			self.basicUpdate = self.updateFun
			self.state = anim_to_idle[self.state]
		end

		-- Update drop shadow position
		self.dropShadow.x = self.x - 22
		self.dropShadow.y = self.dropShadowOverrideY or self.y + self.sprite.h - 15
		self.dropShadow.sprite.sortOrderY = self.sprite.transform.y - 1
		self.dropShadow.sprite.transform.sx = 1.3

		-- We know this is babyt
		self.dropShadow.x = self.x - 60
		self.dropShadow.sprite.transform.sx = 3

		-- Update hotspots
		local hotspots = self:updateCollisionObj()

		hotspots.right_top.x = hotspots.right_top.x + self.collisionHSOffsets.right_top.x
		hotspots.right_top.y = hotspots.right_top.y + self.collisionHSOffsets.right_top.y
		hotspots.right_bot.x = hotspots.right_bot.x + self.collisionHSOffsets.right_bot.x
		hotspots.right_bot.y = hotspots.right_bot.y + self.collisionHSOffsets.right_bot.y
		hotspots.left_top.x = hotspots.left_top.x + self.collisionHSOffsets.left_top.x
		hotspots.left_top.y = hotspots.left_top.y + self.collisionHSOffsets.left_top.y
		hotspots.left_bot.x = hotspots.left_bot.x + self.collisionHSOffsets.left_bot.x
		hotspots.left_bot.y = hotspots.left_bot.y + self.collisionHSOffsets.left_bot.y

		-- Try to move in a direction
		local movespeed = (3 * self.movespeed) * (dt/0.016)
		local ranIntoWall = false

		if self.state == "runup" then
			if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, 0, -movespeed) and
				self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, 0, -movespeed)
			then
			    self.y = self.y - movespeed
			else
				ranIntoWall = true
			end
		elseif self.state == "rundown" then
			if  self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, 0, movespeed) and
				self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, 0, movespeed)
			then
				self.y = self.y + movespeed
			else
				ranIntoWall = true
			end
		elseif self.state == "runleft" then
			if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, -movespeed, 0) and
				self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, -movespeed, 0)
			then
				self.x = self.x - movespeed
			else
				ranIntoWall = true
			end
		elseif self.state == "runright" then
			if  self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, movespeed, 0) and
			    self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, movespeed, 0)
		    then
				self.x = self.x + movespeed
			else
				ranIntoWall = true
			end
		end

		if ranIntoWall then
			self.sprite:setAnimation(anim_to_idle[self.state])
			self.basicUpdate = function(_self, dt) end
			self.charging = false

			self:run {
				PlayAudio("sfx", "cyclopsstep", 1.0, true),
				Parallel {
					self:hop(),
					self.scene:screenShake(30, 20)
				},
				Do(function()
					self.basicUpdate = self.updateFun
					self.state = anim_to_idle[self.state]
				end)
			}
		end
	end

	player.stickyLShift = true

	player:run(While(
		function()
			return love.keyboard.isDown("lshift") or not player.forceDrop
		end,
		Serial {
			Do(function()
				player.state = anim_to_run[player.state]
				player.sprite:setAnimation(player.state)
			end),

			Repeat(
				Serial {
					PlayAudio("sfx", "bang", 1.0, true, false, true),
					Wait(0.1)
				},
				4
			),

			Wait(0.1),

			-- Launch forward
			Do(function()
				player.basicUpdate = ram
				player.charging = true
			end)
		},
		Do(function()
			player.basicUpdate = player.updateFun
			player.state = anim_to_idle[player.state]
			player.charging = false
			player.forceDrop = false
		end)
	))
end