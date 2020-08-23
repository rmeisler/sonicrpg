local Menu = require "actions/Menu"
local Do = require "actions/Do"
local BlockPlayer = require "actions/BlockPlayer"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local MessageBox = require "actions/MessageBox"
local Action = require "actions/Action"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local While = require "actions/While"
local PlayAudio = require "actions/PlayAudio"

local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"

local EscapeLaser = class(NPC)

function EscapeLaser:construct(scene, layer, object)
    self.alignment = NPC.ALIGN_BOTLEFT
	self.action = Serial{}
	
	NPC.init(self)
	
	self.sprite.transform.sx = 0
	self.sprite.transform.sy = 1
	self.sprite.transform.ox = 0
	self.sprite.transform.oy = self.sprite.h/2
	
	self:animate()
end

function EscapeLaser:update(dt)
	if not self.scene:playerMovable() then
		return
	end

	local fx = self.scene.player.fx
	if self.scene.player.noGas then
		fx = 25
	end

	local bx = self.scene.player.bx
	if bx > 0 then
		bx = bx + 1
	end
	self.x = self.x + (fx + bx) * (dt/0.016)
	
	-- Called by more than just EscapeLaser...
	if self.action and not self.action:isDone() then
		self.action:update(dt)

		if self.action:isDone() then
			self.action:cleanup(self)
			self.action = Serial{}
		end
	end
end

function EscapeLaser:animate()
	self:run {
		Do(function()
			self.avoidCollider = self:createCollider(EscapeLaser.chanceToAvoidLaser, self.target)
		end),
		Wait(0.1),
		Animate(function()
			return SpriteNode(self.scene, self.sprite.transform, nil, "beamfire", nil, nil, "objects"), true
		end, "idle"),

		PlayAudio("sfx", "swatbotlaser", 1.0, true),
		
		Do(function()
			self.x = self.x + 12
			self.y = self.y + 30
			
			local x1, y1 = self.x, self.y
			local x2, y2 = self.target.x, self.target.y

			local dx = (x2 - x1)
			local dy = (y2 - y1)

			local dot = dx * dx
			local m1 = math.sqrt(dx*dx + dy*dy)
			local m2 = dx
			local angle = math.acos(dot / (m1 * m2))
			
			if self.y > self.target.y then
				self.sprite.transform.angle = -angle
			else
				self.sprite.transform.angle = angle
			end
			
			self.xDist = dx
			self.yDist = dy
			self.len = m1/self.sprite.w			
		end),
		
		-- Beam stretch to target and recede
		Ease(self.sprite.transform, "sx", function() return self.len end, 8),
		
		Do(function()
			self.sprite.transform.ox = self.sprite.w
			
			self.x = self.x + self.xDist
			self.y = self.y + self.yDist
			
			self.collider = self:createCollider(EscapeLaser.touchLaser)
		end),
		
		Ease(self.sprite.transform, "sx", 0, 8),
		
		Do(function()
			self.sprite.transform.ox = 0
			
			self.scene:invoke("laserfired", self)
			self.avoidCollider:remove()
			self.collider:remove()
			self:remove()
		end)
	}
end

function EscapeLaser:run(actions)
	-- Lazily evaluated actions
	if type(actions) == "function" then
		actions = actions()
	end

	-- Table is implicitly a Serial action
	if not getmetatable(actions) then
		actions = Serial(actions)
	end

	self.action:inject(self.scene, actions)
	self.action.done = false
end

function EscapeLaser:createCollider(collisionCallback, location)
	local collidable = BasicNPC(
		self.scene,
		self.layer,
		{
			name = "laserCollisionObj",
			x = location and location.x or self.x,
			y = location and location.y or self.y,
			width = 64,
			height = 64,
			properties = {}--sprite = "art/sprites/testsq.png"}
		}
	)
	self.scene:addObject(collidable)

	collidable:addHandler("collision", collisionCallback, collidable, self)
	collidable:addSceneHandler("update", EscapeLaser.update)
	return collidable
end

function EscapeLaser.fire(scene, layer, origin, target)
	local laser = EscapeLaser(
		scene,
		layer,
		{
			name = "targetObj",
			x = origin.x,
			y = origin.y,
			width = 32,
			height = 9,
			properties = {nocollision = true, sprite = "art/sprites/botbeam.png"}
		}
	)
	scene:addObject(laser)
	laser.origin = origin
	laser.target = target
	laser.sprite.sortOrderY = target.y
	return laser
end

function EscapeLaser.chanceToAvoidLaser(collidable, prevState, escapeLaser)
	local player = collidable.scene.player
	if prevState == NPC.STATE_IDLE then
		if not player.dodged and not player.hit then
			player:run(PressX(
				player,
				player,
				Serial {
					Do(function()
						player.dodged = true
					end),
					player:dodgeLaser(),
					Do(function()
						player.dodged = false
					end)
				},
				Do(function()
					
				end)
			))
		end
		collidable:removeHandler("collision", EscapeLaser.touchLaser)
		collidable:remove()
	end
end

function EscapeLaser.touchLaser(collidable, prevState, escapeLaser)
	local player = collidable.scene.player
	if prevState == NPC.STATE_IDLE then
		if not player.dodged and not player.hit then
			player.hit = true
			player:run {
				player:hitByLaser(),
				Do(function()
					player.hit = false
				end)
			}
		end
		collidable:removeHandler("collision", EscapeLaser.touchLaser)
		collidable:remove()
	end
end


return EscapeLaser
