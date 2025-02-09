local Transform = require "util/Transform"
local Player = require "object/Player"
local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Action = require "actions/Action"

local flyingUpdateFun

return function(player)
	-- Tails power is to fly around. What this allows him to do is fly from higher points of a map
	-- down to lower points of the map. This is useful for puzzle solving, navigation, etc.
	
	-- While flying, you can press X to change perspective (Tails' body to his drop spot)
	player.flyOffsetY = player.flyOffsetY or player.defaultFlyOffsetY
	player.tempFlyOffsetY = 0

	player.flyingHotspots = player.hotspots
	player.origIsTouching = player.isTouching
	player.isTouching = function(self, x, y, w, h)
		local tw = self.scene:getTileWidth()
		local th = self.scene:getTileHeight()
		w = w or tw
		h = h or th

		local fuzz = 5
		return (x + w) >= (self.flyingHotspots.left_bot.x - fuzz) and
			x < (self.flyingHotspots.right_top.x + fuzz) and
			(self.flyingHotspots.left_bot.y + fuzz) >= y and
			(self.flyingHotspots.right_top.y - fuzz) <= (y + math.max(th*2, h))
	end
	
	-- Flying is a toggle, so once you press lshift, you begin flying and stay flying until
	-- you press lshift again
	flyingUpdateFun = function(self, dt)
		if self.changingCamera then
			return
		end
		
		if 	self.cinematic or
			self.cinematicStack > 0 or
			self.blocked or
			not self.scene:playerMovable() or
			self.dontfuckingmove
		then
			return
		end

		local movespeed = self.movespeed * (dt/0.016)

		-- Update drop shadow position
		self.dropShadow.x = self.x - 22
		self.dropShadow.y = self.y + self.sprite.h - 15 + self.flyOffsetY + self.tempFlyOffsetY

		local hotspots = self:updateCollisionObj()

		self.flyingHotspots = {
		    right_top = {x = hotspots.right_top.x, y = hotspots.right_top.y + self.flyOffsetY},
			right_bot = {x = hotspots.right_bot.x, y = hotspots.right_bot.y + self.flyOffsetY},
			left_top  = {x = hotspots.left_top.x,  y = hotspots.left_top.y + self.flyOffsetY},
			left_bot  = {x = hotspots.left_bot.x,  y = hotspots.left_bot.y + self.flyOffsetY},
		}

		hotspots.right_top.x = hotspots.right_top.x + self.collisionHSOffsets.right_top.x
		hotspots.right_top.y = hotspots.right_top.y + self.collisionHSOffsets.right_top.y + self.flyOffsetY
		hotspots.right_bot.x = hotspots.right_bot.x + self.collisionHSOffsets.right_bot.x
		hotspots.right_bot.y = hotspots.right_bot.y + self.collisionHSOffsets.right_bot.y + self.flyOffsetY
		hotspots.left_top.x = hotspots.left_top.x + self.collisionHSOffsets.left_top.x
		hotspots.left_top.y = hotspots.left_top.y + self.collisionHSOffsets.left_top.y + self.flyOffsetY
		hotspots.left_bot.x = hotspots.left_bot.x + self.collisionHSOffsets.left_bot.x
		hotspots.left_bot.y = hotspots.left_bot.y + self.collisionHSOffsets.left_bot.y + self.flyOffsetY

		if love.keyboard.isDown("right") then
			if  self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, movespeed, 0) and
				self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, movespeed, 0)
			then
				self.x = self.x + movespeed
				self.state = "flyright"

				-- Going up stairs
				local _, stairs = next(self.stairs)
				if stairs then
					if stairs.direction == "up_right" then
						self.y = self.y - movespeed * 0.7
					elseif stairs.direction == "up_left" then
						self.y = self.y + movespeed * 0.7
					end
				end
			else
				print("wah 2? "..tostring(self.scene.currentLayerId))
			end

		elseif love.keyboard.isDown("left") then
			if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, -movespeed, 0, nil, true) and
				self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, -movespeed, 0, nil, true)
			then
				self.x = self.x - movespeed
				self.state = "flyleft"

				-- Going up stairs
				local _, stairs = next(self.stairs)
				if stairs then
					if stairs.direction == "up_right" then
						self.y = self.y + movespeed * 0.7
					elseif stairs.direction == "up_left" then
						self.y = self.y - movespeed * 0.7
					end
				end
			else
				print("wah? "..tostring(self.scene.currentLayerId))
			end
		end

		if love.keyboard.isDown("down") then
			if  self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, 0, movespeed) and
				self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, 0, movespeed)
			then
				self.y = self.y + movespeed
			end

		elseif love.keyboard.isDown("up") then
			if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, 0, -movespeed) and
				self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, 0, -movespeed)
			then
				self.y = self.y - movespeed
			end
		end

		-- Flytime countdown
		self.flyTime = self.flyTime - dt

		if self.flyTime > 0.0 and love.keyboard.isDown("lshift") then
			-- Left shift is down? Increase elevation
			self.flyOffsetY = self.flyOffsetY + 4
			self.y = self.y - 4
			
			if self.flyOffsetY > 200 then
				self.scene.camPos.y = self.scene.camPos.y - 4
			end
		else
			-- Start falling out of the sky
			if self.flyTime <= 0.0 then
				self.flyOffsetY = self.flyOffsetY - 8
				self.y = self.y + 8
				
				if self.scene.camPos.y < 0 then
					self.scene.camPos.y = self.scene.camPos.y + 8
				else
					self.scene.camPos.y = 0
				end
			else
				self.flyOffsetY = self.flyOffsetY - 4
				self.y = self.y + 4

				if self.scene.camPos.y < 0 then
					self.scene.camPos.y = self.scene.camPos.y + 4
				else
					self.scene.camPos.y = 0
				end
			end
		end

		-- Update collision layer
		if self.flyOffsetY > 160 then
			if self.scene.currentLayerId ~= 1 then
				print "set layer to 1"
				self.scene:swapLayer(1, true)
			end
		else
			if self.scene.currentLayerId ~= 3 then
				print "set layer to 3"
				self.scene:swapLayer(3, true)
			end
		end

		if self.flyOffsetY + self.tempFlyOffsetY <= 0 then
			self.sprite.sortOrderY = nil
			self.basicUpdate = self.updateFun
			self.movespeed = self.baseMoveSpeed
			self.isTouching = self.origIsTouching

			if self:isFacing("right") then
				self.state = "idleright"
			else
				self.state = "idleleft"
			end

			if self.scene.currentLayerId ~= self.flyLandingLayer then
				print("set layer to "..tostring(self.flyLandingLayer))
				self.scene:swapLayer(self.flyLandingLayer, true)

				if self.flyLandingLayer < 3 then
					self.sprite.sortOrderY = 100001
					self.dropShadow.sprite.sortOrderY = 100000
					self.flyOffsetY = self.nextFlyOffsetY or 0
					self.flyLandingLayer = self.nextFlyLandingLayer
				else
					self.flyOffsetY = 0
					self.flyLandingLayer = self.nextFlyLandingLayer
				end
			end

			if self.scene.camPos.y < 0 then
				self:run(Ease(self.scene.camPos, "y", 0, 2, "linear"))
			end
		else
			self.sprite:setAnimation(self.state)
			self.sprite.sortOrderY = self.sprite.transform.y + self.flyOffsetY
		end
	end

	-- Change update method to fly, increase base move speed
	player.basicUpdate = flyingUpdateFun
	player.flyTime = 2.0
	player.state = "flyright"
end
