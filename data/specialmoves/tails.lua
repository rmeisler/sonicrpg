local Transform = require "util/Transform"
local Player = require "object/Player"
local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Action = require "actions/Action"

local flyingUpdateFun

return function(player)
	-- Tails power is to fly around. What this allows him to do is fly from higher points of a map
	-- down to lower points of the map. This is useful for puzzle solving, navigation, etc.
	
	
	-- If not a layered map, Tails cannot fly
	if not player.scene.layered then
		player.scene.audio:playSfx("error")
		return
	end
	
	-- While flying, you can press X to change perspective (Tails' body to his drop spot)
	player.flyOffsetY = player.flyOffsetY or player.defaultFlyOffsetY
	player.tempFlyOffsetY = player.tempFlyOffsetY or 0
	player.dropShadowOverrideSortOrderY = nil
	player.threeDeeObjects = {}
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
		
		-- Play fly sfx
		local audio = player.scene.audio
		audio:playSfx("fly", 0.2)

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
			end
		end

		if love.keyboard.isDown("down") then
			if  self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, 0, movespeed) and
				self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, 0, movespeed)
			then
				self.y = self.y + movespeed
				self.state = "flydown"
			end

		elseif love.keyboard.isDown("up") then
			if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, 0, -movespeed) and
				self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, 0, -movespeed)
			then
				self.y = self.y - movespeed
				self.state = "flyup"
			end
		end

		-- Flytime countdown
		self.flyTime = self.flyTime - dt

		if not love.keyboard.isDown("lshift") then
			self.stopElevating = true
		end

		if self.flyTime > 0.0 and love.keyboard.isDown("lshift") and not self.stopElevating then
			-- Left shift is down the whole time? Increase elevation until you run out of fly time
			self.flyOffsetY = self.flyOffsetY + 4
			self.y = self.y - 4
			if not self.scene.noPlayerPanning then
				self.scene.camPos.y = self.scene.camPos.y - 4
			end
		elseif self.stopElevating and (love.keyboard.isDown("lshift") or self.forceDrop) and not self.stickyLShift then
			-- Do not land unless all three dee objects agree
			self.noLand = true
			self.forceDrop = false

			-- Rapidly touch ground (pressed lshift a second time)
			self:run {
				Parallel {
					Ease(self, "flyOffsetY", self.flyOffsetY - (self.flyOffsetY + self.tempFlyOffsetY), 6, "linear"),
					Ease(self, "y", self.y + (self.flyOffsetY + self.tempFlyOffsetY), 6, "linear"),
					not self.scene.noPlayerPanning and Ease(self.scene.camPos, "y", 0, 6, "linear") or Action()
				},
				Do(function()
					-- Landing logic...
					self.noLand = false
					for _, threeDee in pairs(self.threeDeeObjects) do
						if threeDee:onTop() then
							self.noLand = self.noLand or threeDee:land(self)
						end
					end
				end)
			}
			self.stickyLShift = true
			self.flyTime = 0.0
		elseif self.flyTime <= 0.0 or not love.keyboard.isDown("lshift") and not self.stickyLShift then
			-- Start falling out of the sky
			self.flyOffsetY = self.flyOffsetY - 1
			self.y = self.y + 1

			if not self.scene.noPlayerPanning then
				if self.scene.camPos.y < 0 then
					self.scene.camPos.y = self.scene.camPos.y + 1
				else
					self.scene.camPos.y = 0
				end
			end
		end

		-- Adjust camera
		if math.abs(self.flyOffsetY + self.tempFlyOffsetY + self.scene.camPos.y) > 250 and
			not self.camMove and
			not self.noFlyPan and
			not self.scene.noPlayerPanning
		then
			self.camMove = true
			self:run {
				Ease(self.scene.camPos, "y", -(self.flyOffsetY + self.tempFlyOffsetY), 2),
				Do(function()
					self.camMove = false
				end)
			}
		end

		-- Update collision layer
		if self.flyOffsetY > 1504 then
			if self.scene.currentLayerId ~= 1 then
				self.scene:swapLayer(1, true)
			end
		elseif self.flyOffsetY > 448 then
			if self.scene.currentLayerId ~= 2 then
				self.scene:swapLayer(2, true)
			end
		elseif self.flyOffsetY > 272 then
			if self.scene.currentLayerId ~= 3 then
				self.scene:swapLayer(3, true)
			end
		elseif self.flyOffsetY > 160 then
			if self.scene.currentLayerId ~= 4 then
				self.scene:swapLayer(4, true)
			end
		elseif self.flyOffsetY > 20 then
			if self.scene.currentLayerId ~= 5 then
				self.scene:swapLayer(5, true)
			end
		else
			if self.scene.currentLayerId ~= 7 then
				self.scene:swapLayer(7, true)
			end
		end

		if self.flyOffsetY + self.tempFlyOffsetY <= 0 and not self.noLand then
			self.sprite.sortOrderY = nil
			self.stopElevating = false
			self.basicUpdate = self.updateFun
			self.movespeed = self.baseMoveSpeed
			self.isTouching = self.origIsTouching

			local state_from_fly = {
				flyleft = "idleleft",
				flyright = "idleright",
				flyup = "idleup",
				flydown = "idledown"
			}

			self.state = state_from_fly[self.state] or "idledown"

			if self.flyLandingLayer == nil then
				self.flyLandingLayer = 7
			end

			if self.scene.currentLayerId ~= self.flyLandingLayer then
				self.scene:swapLayer(self.flyLandingLayer, true)

				if self.flyLandingLayer < 7 then
					self.flyOffsetY = self.nextFlyOffsetY or 0
					self.tempFlyOffsetY = -(self.flyOffsetY - 1)
					self.flyLandingLayer = self.nextFlyLandingLayer
					self.dropShadowOverrideSortOrderY = 1000000
				else
					self.flyOffsetY = 0
					self.tempFlyOffsetY = 0
					self.flyLandingLayer = self.nextFlyLandingLayer
				end
			elseif self.flyOffsetY < 0.0 then
				self.flyOffsetY = 0
			end

			if not self.scene.noPlayerPanning then
				if self.scene.camPos.y < 0 then
					self:run(Ease(self.scene.camPos, "y", 0, 2, "linear"))
				end
			end

			-- Update hotspots
			hotspots.right_top.y = hotspots.right_top.y - self.flyOffsetY
			hotspots.right_bot.y = hotspots.right_bot.y - self.flyOffsetY
			hotspots.left_top.y = hotspots.left_top.y - self.flyOffsetY
			hotspots.left_bot.y = hotspots.left_bot.y - self.flyOffsetY

			-- If we can't move after landing, reset our position to where we took off from and flicker
			if self.y > self.scene:getMapHeight() or not (
			   (self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, 0, -movespeed) and
				self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, 0, -movespeed)) or
			   (self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, 0, movespeed) and
				self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, 0, movespeed)) or
			   (self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, -movespeed, 0, nil, true) and
				self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, -movespeed, 0, nil, true)) or
			   (self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, movespeed, 0) and
				self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, movespeed, 0))
			) then
				self.x = self.takeOffX
				self.y = self.takeOffY
				self:run(
					Repeat(
						Serial {
							Ease(self.sprite.color, 4, 0, 20, "linear"),
							Ease(self.sprite.color, 4, 255, 20, "linear")
						},
						12
					)
				)
			end
		else
			self.sprite:setAnimation(self.state)
			self.sprite.sortOrderY = self.sprite.transform.y + self.flyOffsetY
		end
	end

	-- Change update method to fly, increase base move speed
	player.basicUpdate = flyingUpdateFun
	player.flyTime = 1.0

	local state_to_fly = {
		idleleft = "flyleft",
		idleright = "flyright",
		idleup = "flyup",
		idledown = "flydown",
		walkleft = "flyleft",
		walkright = "flyright",
		walkup = "flyup",
		walkdown = "flydown",
	}

	player.state = state_to_fly[player.state] or "flyright"
	player.takeOffX = player.x
	player.takeOffY = player.y
end
