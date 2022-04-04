local Player = require "object/Player"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local Animate = require "actions/Animate"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local Repeat = require "actions/Repeat"

local Transform = require "util/Transform"

-- Constants
local RUN_FORCE_MAGNITUDE = 25
local ORTHO_BURST_MAGNITUDE = 9
local ANIMATION_WAIT = 0.01

local SLOWDOWN_SPEED = 1
local SLOWDOWN_STOP_SPEED = 1
local RETURN_SPEED = 0.8

local RUN_DIRCHANGE_COOLDOWN = 0.2 -- Num secs to delay direction change

local EscapePlayer = class(Player)

function EscapePlayer:construct(scene, layer, object)	
	-- Play charge animation based on facing direction
	self.fx = RUN_FORCE_MAGNITUDE
	self.fy = 0
	self.bx = 0
	self.by = 0
	self.extraBx = 0
	self.state = "juiceright"

	self:removeSceneHandler("update", Player.update)
	self:removeSceneHandler("keytriggered", Player.keytriggered)
	
	scene.player = self
end

function EscapePlayer:update(dt)
	if not self.frameCounter then
		self.frameCounter = 0
	end
	
	if not self.animationStack then
		self.animationStack = {}
	end
	
	if self.blocked or not self.scene:playerMovable() or self.scene.playerDead then
		return
	end
	
	-- Snapshot current x and y
	local curX, curY = self.x, self.y
	
	-- Orthogonal movement during run
	if math.abs(self.fx) < RUN_FORCE_MAGNITUDE and not self.noGas then
		-- Rapidly increase speed in primary direction
		self.fx = math.min(RUN_FORCE_MAGNITUDE, self.fx + RETURN_SPEED)
		
		if math.abs(self.fx) > math.abs((self.fy + self.by) * 5) then
			self.state = "juiceright"
		end
		
		if self.fy > 0 then
			self.fy = math.max(0, self.fy - RETURN_SPEED)
		else
			self.fy = math.min(0, self.fy + RETURN_SPEED)
		end
		if self.scene.audio:isFinished("sfx") then
			self.scene.audio:playSfx("sonicrunturn", nil, true)
		end
	end

	if not self.cinematic then
		if love.keyboard.isDown("up") then
			self.fx = self.fxOverride or 10
			self.fy = -3.1
			self.bx = ORTHO_BURST_MAGNITUDE
			self.by = -ORTHO_BURST_MAGNITUDE
			self.bigDust = true
			
			self.state = "juiceupright"
		elseif love.keyboard.isDown("down") then
			self.fx = self.fxOverride or 10
			self.fy = 3.1
			self.bx = ORTHO_BURST_MAGNITUDE
			self.by = ORTHO_BURST_MAGNITUDE
			self.bigDust = true
			
			self.state = "juicedownright"
		end
	end
	
	-- Step forward
	self:moveForward(dt)

	-- Reduce burst force
	if self.bx < 0.1 then
		self.bx = 0
	else
		self.bx = self.bx - SLOWDOWN_SPEED
	end
	
	if self.extraBx < -1 then
		self.extraBx = self.extraBx + SLOWDOWN_SPEED
	elseif self.extraBx > 1 then
		self.extraBx = self.extraBx - SLOWDOWN_SPEED
	else
		self.extraBx = 0
	end
	
	if math.abs(self.by) < 0.1 then
		self.by = 0
	elseif self.by > 0 then
		self.by = self.by - SLOWDOWN_SPEED
	elseif self.by < 0 then
		self.by = self.by + SLOWDOWN_SPEED
	end
	
	if not self.cinematic then
		if not self.stateOverride then
			-- Set animation based on momentum
			local dx = self.x - curX
			local dy = self.y - curY
			
			if dx > 1 and math.abs(dy) < 0.5 then
				self.state = "juiceright"
			elseif dx < -1 and math.abs(dy) < 0.5 then
				self.state = "juiceleft"
			end
		end
	
		self.sprite:setAnimation(self.stateOverride or self.state)
		self.stateOverride = nil
	end
	
	if not self.noDust then
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
			dustObject.sprite.color[1] = 130
			dustObject.sprite.color[2] = 130
			dustObject.sprite.color[3] = 200
			dustObject.sprite.color[4] = 255
			
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
	end
	self.frameCounter = self.frameCounter + 1
	
	-- Update drop shadow position
	self.dropShadow.x = self.x - 35
	self.dropShadow.y = (self.origY or self.y) + self.sprite.h - 15
	
	self:updateShadows()
	self:updateKeyHint()
	
	-- Update collision position and hotspots for interactables
	self.collisionX, self.collisionY = self.scene:worldCoordToCollisionCoord(self.x, self.y)
	self.hotspots = {
		right_top = {x = self.x + 12, y = self.y + self.halfHeight + 5},
		right_bot = {x = self.x + 12, y = self.y + self.height},
		left_top  = {x = self.x - 15, y = self.y + self.halfHeight + 5},
		left_bot  = {x = self.x - 15, y = self.y + self.height}
	}
end

function EscapePlayer:moveForward(dt)
	self.x = self.x + (self.fx + self.bx + self.extraBx) * (dt/0.016)
	
	if (self.fy + self.by) ~= 0 then
		self.y = math.max(
			self.scene:getMapHeight() - 420,
			math.min(
				self.scene:getMapHeight() - self.sprite.h,
				self.y + (self.fy + self.by) * (dt/0.016)
			)
		)
	end
end

function EscapePlayer:dodgeLaser()
	return Serial {
		Do(function()
			self.cinematic = true
			self.origY = self.y
			self.sprite:setAnimation("juicecrouchright")
		end),
		PlayAudio("sfx", "pressx", 1.0, true),
		
		Wait(0.1),
		
		Do(function()
			self.noDust = true
			self.noGas = true
		end),
		Animate(self.sprite, "juicewallright", true),
		Serial {
			Ease(self, "y", function() return self.origY - self.sprite.h*3 end, 5, "linear"),
			Ease(self, "y", function() return self.origY end, 5, "quad")
		},
		Do(function()
			self.cinematic = false
			self.noDust = false
			self.noGas = false
			self.origY = nil
		end),
		Parallel {
			Do(function()
				self.bigDust = true
				self.stateOverride = "juicecrouchright"
				self.extraBx = 10
			end),
			YieldUntil(
				function()
					return self.x > self.scene.objectLookup.R.x
				end
			)
		},
		Parallel {
			Do(function()
				self.stateOverride = "juicesmileright"
			end),
			Wait(1.2)
		}
	}
end

function EscapePlayer:hitByLaser()
	return While(
		function()
			return not self.scene.playerDead
		end,
		Serial {
			Do(function()
				self.cinematic = true
				self.noDust = true
				self.noGas = true
				self.origY = self.y
			end),
			-- Shock sfx and anim
			PlayAudio("sfx", "shocked", nil, true),
			Animate(self.sprite, "ouchright"),
			
			Parallel {
				-- Blink
				Repeat(Serial {
					Do(function()
						self.sprite:setInvertedColor()
					end),
					Wait(0.1),
					Do(function()
						self.sprite:removeInvertedColor()
					end),
					Wait(0.1),
				}, 5),
				
				-- Hop
				Serial {
					Ease(self, "y", function() return self.origY - 100 end, 8, "quad"),
					Wait(0.3),
					
					Do(function()
						self.noDust = false
					end),
					Ease(self, "y", function() return self.origY end, 8, "quad"),
					Wait(0.1),
					Do(function()
						self.noDust = true
					end),
					
					Ease(self, "y", function() return self.origY - 60 end, 11, "quad"),
					Wait(0.1),
					
					Do(function()
						self.noDust = false
					end),
					Ease(self, "y", function() return self.origY end, 13, "quad"),
					Wait(0.1),				
					Do(function()
						self.noDust = true
					end),

					Ease(self, "y", function() return self.origY - 40 end, 13, "quad"),
					Wait(0.1),
					
					Do(function()
						self.noDust = false
					end),
					Ease(self, "y", function() return self.origY end, 13, "quad"),
					Wait(0.2)
				},
				
				Ease(self, "fx", 7, 0.8, "quad")
			},
			
			Do(function()
				self.by = 0
				self.fy = 0
				self.noGas = false
				self.noDust = false
				self.cinematic = false
				self.origY = nil
			end),
			Parallel {
				YieldUntil(
					function()
						return self.x > self.scene.objectLookup.R.x
					end
				),
				Do(function()
					self.bigDust = true
					self.stateOverride = "juicecrouchright"
					self.extraBx = 10
				end)
			},
			Do(function()
				self.cinematic = false
			end)
		},
		Do(function()
		end)
	)
end

function EscapePlayer:die()
	return Parallel {
		self.scene:screenShake(0, 20),
		AudioFade("music", 1.0, 0.0, 2),
		Do(function()
			self.scene.audio:stopMusic("escapelevel")
		end)
	}
end


return EscapePlayer
