local Transform = require "util/Transform"
local Player = require "object/Player"
local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Parallel = require "actions/Parallel"


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
	local flyingUpdateFun = function(self, dt)
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
			end

		elseif love.keyboard.isDown("left") then
			if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, -movespeed, 0) and
				self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, -movespeed, 0)
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

		self.sprite:setAnimation(self.state)
		self.sprite.sortOrderY = self.sprite.transform.y + self.flyOffsetY
	end

	-- Turn off regular update method
	player.basicUpdate = function(self, dt) end
	player:removeSceneHandler("keytriggered", Player.keytriggered)
	local stopFlyingFun
	stopFlyingFun = function(self, key)
		if self.changingCamera then
			return
		end

		if key == "x" then
			local newCamPosY = -self.flyOffsetY
			if self.scene.camPos.y == 0 then
				newCamPosY = -self.flyOffsetY
			else
				newCamPosY = 0
			end

			self.changingCamera = true
			self:run {
				Ease(self.scene.camPos, "y", newCamPosY, 2, "linear"),
				Do(function() self.changingCamera = false end)
			}
		elseif key == "lshift" then
			self.basicUpdate = function(_self, _dt) end
			self:removeSceneHandler("keytriggered", stopFlyingFun)

			-- Detect whether we (our actual self = drop shadow)
			-- are colliding with an elevation object. If so, this
			-- is our new elevation to drop to

			if self.flyLayer ~= self.flyLandingLayer then
				self.scene:swapLayer(self.flyLandingLayer)
			end
			self.sprite.sortOrderY = nil

			-- Slowly reduce elevation
			self:run {
				Parallel {
					Ease(self, "y", self.dropShadow.y - self.sprite.h + 15, 2, "linear"),
					Ease(self.scene.camPos, "y", 0, 2, "linear")
				},
				Do(function()
					self.basicUpdate = self.updateFun
					self:addSceneHandler("keytriggered", Player.keytriggered)
					self.movespeed = self.baseMoveSpeed
					self.isTouching = self.origIsTouching
					if player:isFacing("right") then
						player.state = "idleright"
					else
						player.state = "idleleft"
					end
				end)
			}
		end
	end

	player:run {
		Do(function()
			if player:isFacing("right") then
				player.sprite:setAnimation("flyright")
				player.state = "flyright"
			else
				player.sprite:setAnimation("flyleft")
				player.state = "flyleft"
			end
		end),
		-- Some flying sfx...
		-- PlayAudio("sfx", "antoinescared", 1.0, true),
		Ease(player, "y", player.y - player.defaultFlyOffsetY, 2, "linear"),
		Do(function()
			player.basicUpdate = flyingUpdateFun
			player:addSceneHandler("keytriggered", stopFlyingFun)
			player.movespeed = player.baseMoveSpeed * 2
			
			if player.flyLayer ~= player.scene.currentLayerId then
				player.scene:swapLayer(player.flyLayer)
				print("fly layer = "..tostring(player.flyLayer))
			end
		end)
	}
end
