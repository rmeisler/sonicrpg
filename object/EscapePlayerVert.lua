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

local EscapePlayerVert = class(Player)

function EscapePlayerVert:construct(scene, layer, object)	
	-- Play charge animation based on facing direction
	self.fx = 0
	self.fy = -RUN_FORCE_MAGNITUDE
	self.bx = 0
	self.by = 0
	self.extraBy = 0
	self.state = "juiceup"
	self.hoverbotOffset = 360

	self:removeSceneHandler("update", Player.update)
	self:removeSceneHandler("keytriggered", Player.keytriggered)
	
	scene.player = self
end

function EscapePlayerVert:update(dt)
	if not self.frameCounter then
		self.frameCounter = 0
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
	if math.abs(self.fy) > -RUN_FORCE_MAGNITUDE and not self.noGas then
		-- Rapidly increase speed in primary direction
		self.fy = math.max(-RUN_FORCE_MAGNITUDE, self.fy - RETURN_SPEED)
		
		if math.abs(self.fy) > math.abs((self.fx + self.bx) * 5) then
			self.state = "juiceup"
		end
		
		if self.fx > 0 then
			self.fx = math.max(0, self.fx - RETURN_SPEED)
		else
			self.fx = math.min(0, self.fx + RETURN_SPEED)
		end
		if self.scene.audio:isFinished("sfx") then
			self.scene.audio:playSfx("sonicrunturn", nil, true)
		end
	end

	if not self.cinematic then
		if love.keyboard.isDown("right") then
			self.fx = 3.1
			self.fy = -10
			self.bx = ORTHO_BURST_MAGNITUDE
			self.by = -ORTHO_BURST_MAGNITUDE
			self.bigDust = true
			
			self.state = "juiceupright"
		elseif love.keyboard.isDown("left") then
			self.fx = -3.1
			self.fy = -10
			self.bx = -ORTHO_BURST_MAGNITUDE
			self.by = -ORTHO_BURST_MAGNITUDE
			self.bigDust = true
			
			self.state = "juiceupleft"
		end
	end
	
	-- Step forward
	self:moveForward(dt)

	-- Reduce burst force
	if self.by < 0.1 then
		self.by = 0
	else
		self.by = self.by - SLOWDOWN_SPEED
	end
	
	if self.extraBy < 0.1 then
		self.extraBy = 0
	else
		self.extraBy = self.extraBy - SLOWDOWN_SPEED
	end
	
	if math.abs(self.bx) < 0.1 then
		self.bx = 0
	elseif self.bx > 0 then
		self.bx = self.bx - SLOWDOWN_SPEED
	elseif self.bx < 0 then
		self.bx = self.bx + SLOWDOWN_SPEED
	end
	
	if not self.cinematic then
		if not self.stateOverride then
			-- Set animation based on momentum
			local dx = self.x - curX
			local dy = self.y - curY
			
			if dy < -1 and math.abs(dx) < 0.5 then
				self.state = "juiceup"
			elseif dy > 1 and math.abs(dx) < 0.5 then
				self.state = "juicedown"
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
	
	-- Update collision position and hotspots for interactables
	self.collisionX, self.collisionY = self.scene:worldCoordToCollisionCoord(self.x, self.y)
	self.hotspots = {
		right_top = {x = self.x + 12, y = self.y + self.halfHeight + 5},
		right_bot = {x = self.x + 12, y = self.y + self.height},
		left_top  = {x = self.x - 15, y = self.y + self.halfHeight + 5},
		left_bot  = {x = self.x - 15, y = self.y + self.height}
	}
end

function EscapePlayerVert:moveForward(dt)
	self.y = self.y + (self.fy + self.by + self.extraBy) * (dt/0.016)
	
	if (self.fx + self.bx) ~= 0 then
		self.x = math.max(
			680,
			math.min(
				960,
				self.x + (self.fx + self.bx) * (dt/0.016)
			)
		)
	end
end

function EscapePlayerVert:die()
	return Parallel {
		self.scene:screenShake(30, 20),
		Serial {
			Do(function()
				self.stateOverride = "ouchright"
				self.origY = self.y
			end),
			Parallel {
				Ease(self, "x", self.x - 150, 3, "linear"),
				Serial {
					Ease(self, "y", self.y - 60, 8, "quad"),
					Wait(0.1),
					Ease(self, "y", self.y, 8, "quad")
				}
			},
			Do(function()
				self.stateOverride = "layright"
			end)
		}
	}
end


return EscapePlayerVert
