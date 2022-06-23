 local Transform = require "util/Transform"

local Player = require "object/Player"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"

-- Constants
local RUN_FORCE_MAGNITUDE = 35
local ORTHO_BURST_MAGNITUDE = 9
local ANIMATION_WAIT = 0.01

local SLOWDOWN_SPEED = 1
local SLOWDOWN_STOP_SPEED = 1
local RETURN_SPEED = 2

local RUN_DIRCHANGE_COOLDOWN = 0.2 -- Num secs to delay direction change

local Hotspots = function(player, x, y)
	x = x or player.x
	y = y or player.y
	return {
		right_top = {x = x + 12, y = y + player.halfHeight + 5},
		right_bot = {x = x + 12, y = y + player.height},
		left_top  = {x = x - 15, y = y + player.halfHeight + 5},
		left_bot  = {x = x - 15, y = y + player.height}
	}
end

local PerPixelCollisionCheck = function(self, curX, curY)
	-- Resolve collision by sweeping hotspot checks from prev pos to next pos
	local stepX = curX > self.x and -1 or 1
	local stepY = curY > self.y and -1 or 1
	
	local collidedX = false
	local collidedY = false

	local dx = 0
	local dy = 0
	for y = curY, self.y, stepY do
		dy = dy + stepY
		dx = 0
		for x = curX, self.x, stepX do
			local hotspots = Hotspots(self, x, y)		
			
			dx = dx + stepX
			if not collidedX then
				if stepX > 0 then
					if  not self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, dx, dy) or
						not self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, dx, dy)
					then
						self.x = self.x - math.abs(x - self.x)
						collidedX = true
					end
				else
					if  not self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, dx, dy) or
						not self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, dx, dy)
					then
						self.x = self.x + math.abs(x - self.x)
						collidedX = true
					end
				end
			end
			
			if not collidedY then
				if stepY > 0 then
					if  not self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, dx, dy) or
						not self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, dx, dy)
					then
						self.y = self.y - math.abs(y - self.y)
						collidedY = true
					end
				else
					if  not self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, dx, dy) or
						not self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, dx, dy)
					then
						self.y = self.y + math.abs(y - self.y)
						collidedY = true
					end
				end
			end
		end
	end
	
	if collidedX then
		if self.fx > 0 then
			self.sbx = -12
		elseif self.fx < 0 then
			self.sbx = 12
		end
	end
	
	if collidedY then
		if self.fy > 0 then
			self.sby = -12
		elseif self.fy < 0 then
			self.sby = 12
		end
	end
	
	return collidedX, collidedY
end

local RunUpdate = function(self, dt)
	if not self.frameCounter then
		self.frameCounter = 0
		self.cooldownCounter = 0
	end
	
	if not self.animationStack then
		self.animationStack = {}
	end

	-- If we are hiding, display our sprite more darkly
	if self:inShadow() then
		self.sprite.color = {150,150,150,255}
	else
		self.sprite.color = {255,255,255,255}
	end
	
	if self.blocked or not self.scene:playerMovable() then
		return
	end
	
	-- Snapshot current x and y
	local curX, curY = self.x, self.y
	
	-- Orthogonal movement during run
	if math.abs(self.fy) > math.abs(self.fx) then
		if (not self.cinematic and not love.keyboard.isDown("lshift")) or self.forcestop then
			self.fy = self.fy + (self.fy > 0 and -SLOWDOWN_STOP_SPEED or SLOWDOWN_STOP_SPEED)
			if self.fy >= -1 and self.fy <= 1 then
				self.state = "idle"..(self:isFacing("down") and "down" or "up")
				self.scene.camPos.x = 0
				self.scene.camPos.y = 0
				self.basicUpdate = self.updateFun
				return
			end
		elseif math.abs(self.fy) < RUN_FORCE_MAGNITUDE then
			-- Rapidly increase speed in primary direction
			if self.fy > 0 then
				self.fy = math.min(RUN_FORCE_MAGNITUDE, self.fy + RETURN_SPEED)
				
				if math.abs(self.fy) > math.abs((self.fx + self.bx) * 5) then
					self.state = "juicedown"
				end
			else
				self.fy = math.max(-RUN_FORCE_MAGNITUDE, self.fy - RETURN_SPEED)
				
				if math.abs(self.fy) > math.abs((self.fx + self.bx) * 5) then
					self.state = "juiceup"
				end
			end
			
			if self.fx > 0 then
				self.fx = math.max(0, self.fx - RETURN_SPEED)
			else
				self.fx = math.min(0, self.fx + RETURN_SPEED)
			end
			if self.scene.audio:isFinished("sfx") then
				self.scene.audio:playSfx("sonicrunturn", nil, true)
				self.scene.audio:setLooping("sfx", false)
			end
		end
		
		if not self.cinematic and not self.noMoveSpecial then
			if love.keyboard.isDown("left") then
				if self.fy > 0 then
					self.state = "juicedownleft"
					self.by = ORTHO_BURST_MAGNITUDE
				else
					self.state = "juiceupleft"
					self.by = -ORTHO_BURST_MAGNITUDE
				end
				self.bx = -ORTHO_BURST_MAGNITUDE
				self.fx = -3.1
				self.fy = 0
				self.bigDust = true
			elseif love.keyboard.isDown("right") then
				if self.fy > 0 then
					self.state = "juicedownright"
					self.by = ORTHO_BURST_MAGNITUDE
				else
					self.state = "juiceupright"
					self.by = -ORTHO_BURST_MAGNITUDE
				end
				self.bx = ORTHO_BURST_MAGNITUDE
				self.fx = 3.1
				self.fy = 0
				self.bigDust = true
			elseif love.keyboard.isDown("down") and self.fy < 0 and self.cooldownCounter <= 0 and not next(self.stairs) then
				self.state = "juicedownleft"
				self.bx = -ORTHO_BURST_MAGNITUDE
				self.fx = 0
				self.fy = 3.1
				self.bigDust = true
				self.cooldownCounter = RUN_DIRCHANGE_COOLDOWN
			elseif love.keyboard.isDown("up") and self.fy > 0 and self.cooldownCounter <= 0 and not next(self.stairs) then
				self.state = "juiceupright"
				self.bx = ORTHO_BURST_MAGNITUDE
				self.fx = 0
				self.fy = -3.1
				self.bigDust = true
				self.cooldownCounter = RUN_DIRCHANGE_COOLDOWN
			end
		end
	else
		if (not self.cinematic and not love.keyboard.isDown("lshift")) or self.forcestop then
			self.fx = self.fx + (self.fx > 0 and -SLOWDOWN_STOP_SPEED or SLOWDOWN_STOP_SPEED)
			if self.fx >= -1 and self.fx <= 1 then
				self.state = "idle"..(self:isFacing("right") and "right" or "left")
				self.scene.camPos.x = 0
				self.scene.camPos.y = 0
				self.basicUpdate = self.updateFun
				return
			end
		elseif math.abs(self.fx) < RUN_FORCE_MAGNITUDE then
			-- Rapidly increase speed in primary direction
			if self.fx > 0 then
				self.fx = math.min(RUN_FORCE_MAGNITUDE, self.fx + RETURN_SPEED)
				
				if math.abs(self.fx) > math.abs((self.fy + self.by) * 5) then
					self.state = "juiceright"
				end
			else
				self.fx = math.max(-RUN_FORCE_MAGNITUDE, self.fx - RETURN_SPEED)
				
				if math.abs(self.fx) > math.abs((self.fy + self.by) * 5) then
					self.state = "juiceleft"
				end
			end
			
			if self.fy > 0 then
				self.fy = math.max(0, self.fy - RETURN_SPEED)
			else
				self.fy = math.min(0, self.fy + RETURN_SPEED)
			end
			if self.scene.audio:isFinished("sfx") then
				self.scene.audio:playSfx("sonicrunturn", nil, true)
				self.scene.audio:setLooping("sfx", false)
			end
		end
		
		if not self.cinematic and not self.noMoveSpecial then
			if love.keyboard.isDown("up") and not next(self.stairs) then
				if self.fx > 0 then
					self.state = "juiceupright"
					self.bx = ORTHO_BURST_MAGNITUDE
				else
					self.state = "juiceupleft"
					self.bx = -ORTHO_BURST_MAGNITUDE
				end
				self.fx = 0
				self.fy = -3.1
				self.bigDust = true
			elseif love.keyboard.isDown("down") and not next(self.stairs) then
				if self.fx > 0 then
					self.state = "juicedownright"
					self.bx = ORTHO_BURST_MAGNITUDE
				else
					self.state = "juicedownleft"
					self.bx = -ORTHO_BURST_MAGNITUDE
				end
				self.fx = 0
				self.fy = 3.1
				self.bigDust = true
			elseif love.keyboard.isDown("right") and self.fx < 0 and self.cooldownCounter <= 0 then
				self.state = "juiceupright"
				self.by = -ORTHO_BURST_MAGNITUDE
				self.fx = 3.1
				self.fy = 0
				self.bigDust = true
				self.cooldownCounter = RUN_DIRCHANGE_COOLDOWN
			elseif love.keyboard.isDown("left") and self.fx > 0 and self.cooldownCounter <= 0 then
				self.state = "juicedownleft"
				self.by = ORTHO_BURST_MAGNITUDE
				self.fx = -3.1
				self.fy = 0
				self.bigDust = true
				self.cooldownCounter = RUN_DIRCHANGE_COOLDOWN
			end
		end
	end
	
	local fx = self.fx
	local fy = self.fy
	
	-- Step forward
	self.x = self.x + (fx + self.bx + self.sbx) * (dt/0.016)
	self.y = self.y + (fy + self.by + self.sby) * (dt/0.016)
	
	-- Going up stairs
	local _, stairs = next(self.stairs)
	if stairs then
		if stairs.direction == "up_right" then
			if fx > 0 then
				self.y = self.y - (fx + self.bx + self.sbx) * 0.7
			else
				self.y = self.y - (fx + self.bx + self.sbx) * 0.7
			end
		elseif stairs.direction == "up_left" then
			if fx > 0 then
				self.y = self.y + (fx + self.bx + self.sbx) * 0.7
			else
				self.y = self.y + (fx + self.bx + self.sbx) * 0.7
			end
		end
	end

	-- Reduce burst force
	if math.abs(self.bx) < 0.1 then
		self.bx = 0
	elseif self.bx > 0 then
		self.bx = self.bx - SLOWDOWN_SPEED
	elseif self.bx < 0 then
		self.bx = self.bx + SLOWDOWN_SPEED
	end
	
	if math.abs(self.by) < 0.1 then
		self.by = 0
	elseif self.by > 0 then
		self.by = self.by - SLOWDOWN_SPEED
	elseif self.by < 0 then
		self.by = self.by + SLOWDOWN_SPEED
	end
	
	-- Reduce special burst force
	if math.abs(self.sbx) < 0.1 then
		self.sbx = 0
	elseif self.sbx > 0 then
		self.sbx = self.sbx - SLOWDOWN_SPEED
	elseif self.sbx < 0 then
		self.sbx = self.sbx + SLOWDOWN_SPEED
	end
	
	if math.abs(self.sby) < 0.1 then
		self.sby = 0
	elseif self.sby > 0 then
		self.sby = self.sby - SLOWDOWN_SPEED
	elseif self.sby < 0 then
		self.sby = self.sby + SLOWDOWN_SPEED
	end
	
	if not self.stateOverride and self.cooldownCounter <= RUN_DIRCHANGE_COOLDOWN/3 then
		-- Set animation based on momentum
		local dx = self.x - curX
		local dy = self.y - curY
		
		if dy > 1 and math.abs(dx) < 0.5 then
			self.state = "juicedown"
		elseif dy < -1 and math.abs(dx) < 0.5 then
			self.state = "juiceup"
		elseif dx > 1 and math.abs(dy) < 0.5 then
			self.state = "juiceright"
		elseif dx < -1 and math.abs(dy) < 0.5 then
			self.state = "juiceleft"
		end
	end

	--[[
	if math.abs(self.fx) > math.abs(self.fy) then
		if self.fx > RUN_FORCE_MAGNITUDE*0.8 then
			self.scene.camPos.x = math.max(-250, self.scene.camPos.x - 3 * (dt/0.016))
		elseif self.fx < -RUN_FORCE_MAGNITUDE*0.8 then
			self.scene.camPos.x = math.min(250, self.scene.camPos.x + 3 * (dt/0.016))
		elseif self.scene.camPos.x < 0 then
			self.scene.camPos.x = math.min(0, self.scene.camPos.x + 3 * (dt/0.016))
		elseif self.scene.camPos.x > 0 then
			self.scene.camPos.x = math.max(0, self.scene.camPos.x - 3 * (dt/0.016))
		end
		
		if self.scene.camPos.y < 0 then
			self.scene.camPos.y = math.min(0, self.scene.camPos.y + 3 * (dt/0.016))
		elseif self.scene.camPos.y > 0 then
			self.scene.camPos.y = math.max(0, self.scene.camPos.y - 3 * (dt/0.016))
		end
	else
		if self.fy > RUN_FORCE_MAGNITUDE*0.8 then
			self.scene.camPos.y = math.max(-150, self.scene.camPos.y - 3 * (dt/0.016))
		elseif self.fy < -RUN_FORCE_MAGNITUDE*0.8 then
			self.scene.camPos.y = math.min(150, self.scene.camPos.y + 3 * (dt/0.016))
		elseif self.scene.camPos.y < 0 then
			self.scene.camPos.y = math.min(0, self.scene.camPos.y + 3 * (dt/0.016))
		elseif self.scene.camPos.y > 0 then
			self.scene.camPos.y = math.max(0, self.scene.camPos.y - 3 * (dt/0.016))
		end
		
		if self.scene.camPos.x < 0 then
			self.scene.camPos.x = math.min(0, self.scene.camPos.x + 3 * (dt/0.016))
		elseif self.scene.camPos.x > 0 then
			self.scene.camPos.x = math.max(0, self.scene.camPos.x - 3 * (dt/0.016))
		end
	end]]
	
	self.sprite:setAnimation(self.stateOverride or self.state)
	self.stateOverride = nil
	
	if not self.ignoreSpecialMoveCollision then
		local collidedX, collidedY = PerPixelCollisionCheck(self, curX, curY)
		
		if (collidedX or self.specialCollidedX) and self.fx > 0 then
			if false and not self.noSonicCrash then
				self.basicUpdate = function(player, dt) end
				local yOrig = self.sprite.transform.y + self.sprite.h*2
				self.sprite.sortOrderY = yOrig
				self:run(
					While(
						function() return not self.ignoreSpecialMoveCollision end,
						Parallel {
							self.scene:screenShake(30, 20),
							Serial {
								Animate(self.sprite, "ouchright"),
								Parallel {
									While(
										function()
											local hotspots = Hotspots(self)
											return  self.scene:canMove(hotspots.left_top.x, yOrig, -5, 0) and
													self.scene:canMove(hotspots.left_bot.x, yOrig, -5, 0)
										end,
										Ease(self, "x", self.x - 150, 3, "linear"),
										Do(function()
											self.x = self.x + 5
										end)
									),
									Serial {
										Ease(self, "y", self.y - 60, 8, "quad"),
										Do(function() self.crashIntoWall = true end),
										Wait(0.1),
										Ease(self, "y", self.y, 8, "quad")
									}
								},
								Do(function()
									self.state = "idleright"
									self.scene.camPos.x = 0
									self.scene.camPos.y = 0
									self.basicUpdate = self.updateFun
									self.crashIntoWall = false
									self.specialCollidedX = false
									self.sprite.sortOrderY = nil
								end)
							},
							Do(function()
								-- Update drop shadow position
								self.dropShadow.x = self.x - 22
							end)
						},
						Do(function()
							--[[self.state = "idleright"
							self.scene.camPos.x = 0
							self.scene.camPos.y = 0
							self.basicUpdate = self.updateFun
							self.crashIntoWall = false
							self.specialCollidedX = false
							self.sprite.sortOrderY = nil]]
						end)
					)
				)
			else
				--self.state = "idleright"
				--self.basicUpdate = self.updateFun
			end
		elseif (collidedX or self.specialCollidedX) and self.fx < 0 then
			if false and not self.noSonicCrash then
				self.basicUpdate = function(player, dt) end
				local yOrig = self.sprite.transform.y + self.sprite.h*2
				self.sprite.sortOrderY = yOrig
				self:run(
					While(
						function() return not self.ignoreSpecialMoveCollision end,
						Parallel {
							self.scene:screenShake(30, 20),
							Serial {
								Animate(self.sprite, "ouchleft"),
								Parallel {
									While(
										function()
											local hotspots = Hotspots(self)
											return  self.scene:canMove(hotspots.right_top.x, yOrig, 5, 0) and
													self.scene:canMove(hotspots.right_bot.x, yOrig, 5, 0)
										end,
										Ease(self, "x", self.x + 150, 3, "linear"),
										Do(function()
											self.x = self.x - 5
										end)
									),
									Serial {
										Ease(self, "y", self.y - 60, 8, "quad"),
										Do(function() self.crashIntoWall = true end),
										Wait(0.1),
										Ease(self, "y", self.y, 8, "quad")
									}
								},
								Do(function()
									self.state = "idleleft"
									self.scene.camPos.x = 0
									self.scene.camPos.y = 0
									self.basicUpdate = self.updateFun
									self.specialCollidedX = false
									self.crashIntoWall = false
									self.sprite.sortOrderY = nil
								end)
							},
							Do(function()
								-- Update drop shadow position
								self.dropShadow.x = self.x - 22
							end)
						},
						Do(function()
						end)
					)
				)
			else
				--self.state = "idleleft"
				--self.basicUpdate = self.updateFun
			end
		elseif (collidedY or self.specialCollidedY) and self.fy > 0 then
			if false and not self.noSonicCrash then
				self.basicUpdate = function(player, dt) end
				self:run(
					While(
						function() return not self.ignoreSpecialMoveCollision end,
						Parallel {
							self.scene:screenShake(30, 20),
							Serial {
								Animate(self.sprite, "ouchdown"),
								While(
									function()
										local hotspots = Hotspots(self)
										return  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, 0, -5) and
												self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, 0, -5)
									end,
									Serial {
										Ease(self, "y", self.y - 10, 10, "quad"),
										Do(function() self.crashIntoWall = true end),
										Ease(self, "y", self.y - 130, 5, "linear"),
										Ease(self, "y", self.y - 150, 10, "quad")
									},
									Do(function()
										self.y = self.y + 5
									end)
								),
								Do(function()
									self.scene.camPos.x = 0
									self.scene.camPos.y = 0
									self.state = "idledown"
									self.basicUpdate = self.updateFun
									self.specialCollidedY = false
									self.crashIntoWall = false
								end)
							},
							Do(function()
								-- Update drop shadow position
								self.dropShadow.x = self.x - 22
								self.dropShadow.y = self.y + self.sprite.h - 15
							end)
						},
						Do(function()
						end)
					)
				)
			else
				--self.state = "idledown"
				--self.basicUpdate = self.updateFun
			end
		elseif (collidedY or self.specialCollidedY) and self.fy < 0 then
			if false and not self.noSonicCrash then
				self.basicUpdate = function(player, dt) end
				self:run(
					While(
						function() return not self.ignoreSpecialMoveCollision end,
						Parallel {
							self.scene:screenShake(30, 20),
							Serial {
								Animate(self.sprite, "ouchup"),
								While(
									function()
										local hotspots = Hotspots(self)
										return  self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, 0, 5) and
												self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, 0, 5)
									end,
									Serial {
										Ease(self, "y", self.y + 10, 10, "quad"),
										Do(function() self.crashIntoWall = true end),
										Ease(self, "y", self.y + 130, 5, "linear"),
										Ease(self, "y", self.y + 150, 10, "quad")
									},
									Do(function()
										self.y = self.y - 5
									end)
								),
								Do(function()
									self.scene.camPos.x = 0
									self.scene.camPos.y = 0
									self.state = "idleup"
									self.basicUpdate = self.updateFun
									self.specialCollidedY = false
									self.crashIntoWall = false
								end)
							},
							Do(function()
								-- Update drop shadow position
								self.dropShadow.x = self.x - 22
								self.dropShadow.y = self.y + self.sprite.h - 15
							end)
						},
						Do(function()
						end)
					)
				)
			else
				--self.state = "idleup"
				--self.basicUpdate = self.updateFun
			end
		end
		
		-- Update hotspots for object collision based on final x, y coords
		self.hotspots = {
			right_top = {x = self.x + 12, y = self.y + self.halfHeight + 5},
			right_bot = {x = self.x + 12, y = self.y + self.height},
			left_top  = {x = self.x - 15, y = self.y + self.halfHeight + 5},
			left_bot  = {x = self.x - 15, y = self.y + self.height}
		}
		
		-- Update collision position for interactables
		self.collisionX, self.collisionY = self.scene:worldCoordToCollisionCoord(self.x, self.y)
	end
	
	-- Spawn dust sprite
	if self.frameCounter % 2 == 0 then
		local dustX, dustY = self.x, self.y + self.halfHeight
		local dustAnim
		if self.fx > 0 then
			dustX = dustX - self.width * 2 - 5
			dustAnim = "right"
		elseif self.fx < 0 then
			dustX = dustX + self.halfWidth
			dustAnim = "left"
		elseif self.fy > 0 then
			dustX = self.x - self.width
			dustY = dustY - self.halfHeight
			dustAnim = "updown"
		elseif self.fy < 0 then
			dustX = self.x - self.width
			dustY = dustY + self.halfHeight
			dustAnim = "updown"
		end
		local dustObject = BasicNPC(
			self.scene,
			{name = "objects"},
			{name = "dust", x = dustX, y = dustY, width = 40, height = 36,
				properties = {nocollision = true, sprite = "art/sprites/dust.png", align = NPC.ALIGN_BOTLEFT}
			}
		)
		dustObject.sprite.color = self.dustColor
		
		if self.bigDust then
			dustObject.x = dustObject.x - dustObject.sprite.w
			dustObject.y = dustObject.y - dustObject.sprite.h*2
			dustObject.sprite.transform.sx = 4
			dustObject.sprite.transform.sy = 4
			self.bigDust = false
		end
		dustObject.sprite:setAnimation(dustAnim)
		dustObject.sprite:addSceneHandler("update", function(self, dt)
			local anim = self.animations[self.selected]
			if not anim then
				return
			end
			if anim.position == #anim.frames then
				self:remove()
			end
		end)
		self.scene:addObject(dustObject)
	end
	self.frameCounter = self.frameCounter + 1
	if self.cooldownCounter > 0 then
		self.cooldownCounter = self.cooldownCounter - dt
	end
	
	-- Update drop shadow position
	if self:isFacing("up") then
		self.dropShadow.x = self.x - 22
		self.dropShadow.y = self.y + self.sprite.h - 10
	elseif self:isFacing("down") then
		self.dropShadow.x = self.x - 22
		self.dropShadow.y = self.y + self.sprite.h - 20
	elseif self:isFacing("left") then
		self.dropShadow.x = self.x - 17
		self.dropShadow.y = self.y + self.sprite.h - 15
	elseif self:isFacing("right") then
		self.dropShadow.x = self.x - 29
		self.dropShadow.y = self.y + self.sprite.h - 15
	end
end

local ChargeLeftRight = function(player, direction)
	if player.skipChargeSpecialMove then
		player.basicUpdate = RunUpdate
		player.skipChargeSpecialMove = false
		player.sprite:setAnimation(player.state)
		return
	end

	local leg1 = SpriteNode(
		player.scene,
		Transform.from(player.sprite.transform),
		player.sprite.color,
		"sonicchargeleg1",
		nil,
		nil,
		"objects"
	)
	local leg2 = SpriteNode(
		player.scene,
		Transform.from(player.sprite.transform),
		player.sprite.color,
		"sonicchargeleg2",
		nil,
		nil,
		"objects"
	)
	local body = SpriteNode(
		player.scene,
		Transform.from(player.sprite.transform),
		player.sprite.color,
		"sonicchargebody",
		nil,
		nil,
		"objects"
	)
	local head = SpriteNode(
		player.scene,
		Transform.from(player.sprite.transform),
		player.sprite.color,
		"sprites/sonic",
		nil,
		nil,
		"objects"
	)
	
	local directionAnim = direction > 0 and "right" or "left"
	
	leg1:setAnimation(directionAnim)
	leg1.transform.ox = direction > 0 and 26 or 20
	leg1.transform.oy = 41
	leg1.transform.x = leg1.transform.x + leg1.transform.ox*2
	leg1.transform.y = leg1.transform.y + leg1.transform.oy*2
	leg1.sortOrderY = player.sprite.transform.y + player.sprite.h*2
	
	leg2:setAnimation(directionAnim)
	leg2.transform.ox = direction > 0 and 26 or 20
	leg2.transform.oy = 41
	leg2.transform.x = leg2.transform.x + leg2.transform.ox*2
	leg2.transform.y = leg2.transform.y + leg2.transform.oy*2
	leg2.sortOrderY = player.sprite.transform.y + player.sprite.h*2
	
	body:setAnimation(directionAnim)
	body.transform.ox = direction > 0 and 26 or 20
	body.transform.oy = 41
	body.transform.x = body.transform.x + body.transform.ox*2
	body.transform.y = body.transform.y + body.transform.oy*2
	body.sortOrderY = player.sprite.transform.y + player.sprite.h*2
	
	head:setAnimation("charge"..directionAnim)
	head.sortOrderY = player.sprite.transform.y
	
	player.sprite.visible = false
	
	local origBodyX = body.transform.x
	local origHeadX = head.transform.x
	local origLeg1X = leg1.transform.x
	local origLeg2X = leg2.transform.x

	local chargeSpeed = (player.chargeSpeed or 1)
	
	player:run(While(
		function()
			return love.keyboard.isDown("lshift") or player.cinematic
		end,
		Serial {
			PlayAudio("sfx", "sonicrun", 1.0, true, false, true),
			Parallel {
				--[[Do(function()
					if direction > 0 then
						player.scene.camPos.x = math.max(-250, player.scene.camPos.x - 3 * (love.timer.getDelta()/0.016))
					else
						player.scene.camPos.x = math.min(250, player.scene.camPos.x + 3 * (love.timer.getDelta()/0.016))
					end
				end),]]
				
				-- Gently rotate sprite
				Serial {
					Parallel {
						Ease(body.transform, "angle", direction * math.pi / 6, 2 / chargeSpeed),
						
						Ease(head.transform, "x", head.transform.x - direction * 60, 2 / chargeSpeed),
						Ease(body.transform, "x", body.transform.x - direction * 75, 2 / chargeSpeed),
						Ease(leg1.transform, "x", leg1.transform.x - direction * 75, 2 / chargeSpeed),
						Ease(leg2.transform, "x", leg2.transform.x - direction * 75, 2 / chargeSpeed),
						
						Ease(head.transform, "y", head.transform.y - 50, 2 / chargeSpeed),
						Ease(body.transform, "y", body.transform.y - 70, 2 / chargeSpeed),
						Ease(leg1.transform, "y", leg1.transform.y - 70, 2 / chargeSpeed),
						Ease(leg2.transform, "y", leg2.transform.y - 70, 2 / chargeSpeed),
					},
					Wait(0.20 * chargeSpeed),
					Parallel {
						Ease(body.transform, "angle", 0, 12 / chargeSpeed),
						
						Ease(head.transform, "x", head.transform.x, 12 / chargeSpeed),
						Ease(body.transform, "x", body.transform.x, 12 / chargeSpeed),
						Ease(leg1.transform, "x", leg1.transform.x, 12 / chargeSpeed),
						Ease(leg2.transform, "x", leg2.transform.x, 12 / chargeSpeed),
						
						Ease(head.transform, "y", head.transform.y, 12 / chargeSpeed),
						Ease(body.transform, "y", body.transform.y, 12 / chargeSpeed),
						Ease(leg1.transform, "y", leg1.transform.y, 12 / chargeSpeed),
						Ease(leg2.transform, "y", leg2.transform.y, 12 / chargeSpeed),
					}
				},
				-- Rapidly rotate legs
				Ease(leg1.transform, "angle", direction * 50 * math.pi, 1.4 / chargeSpeed, "quad"),
				Ease(leg2.transform, "angle", direction * 50 * math.pi, 1.4 / chargeSpeed, "quad")
			},
			Do(function()
				leg1:remove()
				leg2:remove()
				body:remove()
				head:remove()

				player.sprite:setAnimation(player.state)
				player.sprite.visible = true
				player.bigDust = true
				
				-- Update function for run
				player.basicUpdate = RunUpdate
			end)
		},
		Serial {
			Do(function() player.scene.audio:stopSfx() end),
			Parallel {
				Ease(body.transform, "angle", 0, 12 / chargeSpeed),
				
				Ease(head.transform, "x", head.transform.x, 12 / chargeSpeed),
				Ease(body.transform, "x", body.transform.x, 12 / chargeSpeed),
				Ease(leg1.transform, "x", leg1.transform.x, 12 / chargeSpeed),
				Ease(leg2.transform, "x", leg2.transform.x, 12 / chargeSpeed),
				
				Ease(head.transform, "y", head.transform.y, 12 / chargeSpeed),
				Ease(body.transform, "y", body.transform.y, 12 / chargeSpeed),
				Ease(leg1.transform, "y", leg1.transform.y, 12 / chargeSpeed),
				Ease(leg2.transform, "y", leg2.transform.y, 12 / chargeSpeed),
			},
			Do(function()
				leg1:remove()
				leg2:remove()
				body:remove()
				head:remove()

				player.state = "idle"..directionAnim
				player.sprite:setAnimation(player.state)
				player.sprite.visible = true
				
				-- Stop running
				player.basicUpdate = player.updateFun
			end)
		}
	))
end

local ChargeUpDown = function(player, direction)
	if player.skipChargeSpecialMove then
		player.basicUpdate = RunUpdate
		player.skipChargeSpecialMove = false
		player.sprite:setAnimation(player.state)
		return
	end

	local body = SpriteNode(
		player.scene,
		Transform.from(player.sprite.transform),
		player.sprite.color,
		"sonicchargebody",
		nil,
		nil,
		"objects"
	)
	local head = SpriteNode(
		player.scene,
		Transform.from(player.sprite.transform),
		player.sprite.color,
		"sprites/sonic",
		nil,
		nil,
		"objects"
	)
	local legs = SpriteNode(
		player.scene,
		Transform.from(player.sprite.transform),
		player.sprite.color,
		direction > 0 and "sonicchargeleg2" or "sonicchargeleg1",
		nil,
		nil,
		"objects"
	)
	
	local directionAnim = direction > 0 and "down" or "up"
	
	legs:setAnimation(directionAnim)
	legs.sortOrderY = player.sprite.transform.y
	
	body:setAnimation(directionAnim)
	body.sortOrderY = player.sprite.transform.y

	head:setAnimation("charge"..directionAnim)
	head.sortOrderY = player.sprite.transform.y
	
	player.sprite.visible = false
	
	local origBodyY = body.transform.y
	local origHeadY = head.transform.y
	local origLegsY = legs.transform.y
	
	local chargeSpeed = (player.chargeSpeed or 1)
	
	player:run(While(
		function()
			return love.keyboard.isDown("lshift") or player.cinematic
		end,
		Serial {
			PlayAudio("sfx", "sonicrun", 1.0, true, false, true),
			Parallel {
				Serial {
					Parallel {
						Ease(head.transform, "y", head.transform.y - (direction > 0 and 68 or 70), 2 / chargeSpeed),
						Ease(body.transform, "y", body.transform.y - (direction > 0 and 68 or 70), 2 / chargeSpeed),
						Ease(legs.transform, "y", legs.transform.y - (direction > 0 and 73 or 73), 2 / chargeSpeed),
					},
					Wait(0.20 * chargeSpeed),
					Parallel {
						Ease(head.transform, "y", head.transform.y, 12 / chargeSpeed),
						Ease(body.transform, "y", body.transform.y, 12 / chargeSpeed),
						Ease(legs.transform, "y", legs.transform.y, 12 / chargeSpeed),
					}
				}
				
				--[[Do(function()
					if direction > 0 then
						player.scene.camPos.y = math.max(-150, player.scene.camPos.y - 3 * (love.timer.getDelta()/0.016))
					else
						player.scene.camPos.y = math.min(150, player.scene.camPos.y + 3 * (love.timer.getDelta()/0.016))
					end
				end)]]
			},
			Do(function()
				legs:remove()
				body:remove()
				head:remove()

				player.sprite:setAnimation(player.state)
				player.sprite.visible = true
				player.bigDust = true
				
				-- Update function for run
				player.basicUpdate = RunUpdate
			end)
		},
		Serial {
			Do(function() player.scene.audio:stopSfx() end),
			Parallel {
				Ease(head.transform, "y", head.transform.y, 12 / chargeSpeed),
				Ease(body.transform, "y", body.transform.y, 12 / chargeSpeed),
				Ease(legs.transform, "y", legs.transform.y, 12 / chargeSpeed),
			},
			Do(function()
				legs:remove()
				body:remove()
				head:remove()

				player.state = "idle"..directionAnim
				player.sprite:setAnimation(player.state)
				player.sprite.visible = true
				
				-- Stop running
				player.basicUpdate = player.updateFun
			end)
		}
	))
end

return function(player)
	-- Remember basic movement controls
	player.basicUpdate = function(self, dt) end
	player.counterWalkSpeed = player.walkspeed
	
	-- Play charge animation based on facing direction
	player.fx = 0
	player.fy = 0
	player.bx = 0
	player.by = 0
	player.sbx = 0
	player.sby = 0
	player.state = Player.ToIdle[player.state]
	if player.state == Player.STATE_IDLEUP then
		player.fy = -RUN_FORCE_MAGNITUDE
		player.state = "juiceup"
		ChargeUpDown(player, -1)
	elseif player.state == Player.STATE_IDLEDOWN then
		player.fy = RUN_FORCE_MAGNITUDE
		player.state = "juicedown"
		ChargeUpDown(player, 1)
	elseif player.state == Player.STATE_IDLELEFT then
		player.fx = -RUN_FORCE_MAGNITUDE
		player.state = "juiceleft"
		ChargeLeftRight(player, -1)
	elseif player.state == Player.STATE_IDLERIGHT then
		player.fx = RUN_FORCE_MAGNITUDE
		player.state = "juiceright"
		ChargeLeftRight(player, 1)
	end
end