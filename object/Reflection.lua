local NPC = require "object/NPC"
local Player = require "object/Player"
local BasicNPC = require "object/BasicNPC"
local SpriteNode = require "object/SpriteNode"

local BlockPlayer = require "actions/BlockPlayer"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local WaitForFrame = require "actions/WaitForFrame"
local While = require "actions/While"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Action = require "actions/Action"
local Executor = require "actions/Executor"
local Ease = require "actions/Ease"

local Transform = require "util/Transform"

local Reflection = class(NPC)

function Reflection:construct(scene, layer, object)
    self.collisionX = 0
	self.collisionY = 0
	self.baseMoveSpeed = 4
	self.movespeed = self.baseMoveSpeed
	self.layer = layer
	self.object = object
	
	self.x = object.x
	self.y = object.y
	self.color = {255,255,255,255}
	self.state = object.properties.orientation and "idle"..object.properties.orientation or Player.STATE_IDLEDOWN

	self.hotspotOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = 0},
		left_bot  = {x = 0, y = 0}
	}

	NPC.init(self)
end

function Reflection:update(dt)
	self:updateSprite()

	if 	self.scene.player.cinematic or
		self.scene.player.cinematicStack > 0 or
		self.scene.player.blocked or
		not self.scene:playerMovable() or
		self.scene.player.dontfuckingmove or
		self.scene.player.doingChangeChar
	then
		if not self.scene.player.noIdle then
			self.sprite:setAnimation(self.state)
		end
		return
	end

	if love.keyboard.isDown("lshift") and not self.scene.player.stickyLShift then
		return
	end

	self.x = self.scene.player.x - self.sprite.w

	local hotspots = self.scene.player:updateCollisionObj()
	local collisionHSOffsets = self.scene.player.collisionHSOffsets
	hotspots.right_top.x = hotspots.right_top.x + collisionHSOffsets.right_top.x
	hotspots.right_top.y = hotspots.right_top.y + collisionHSOffsets.right_top.y
	hotspots.right_bot.x = hotspots.right_bot.x + collisionHSOffsets.right_bot.x
	hotspots.right_bot.y = hotspots.right_bot.y + collisionHSOffsets.right_bot.y
	hotspots.left_top.x = hotspots.left_top.x + collisionHSOffsets.left_top.x
	hotspots.left_top.y = hotspots.left_top.y + collisionHSOffsets.left_top.y
	hotspots.left_bot.x = hotspots.left_bot.x + collisionHSOffsets.left_bot.x
	hotspots.left_bot.y = hotspots.left_bot.y + collisionHSOffsets.left_bot.y

	local prevState = self.state
	local baseMoveSpeed = self.movespeed
	local movespeed = baseMoveSpeed * (dt/0.016)

    if love.keyboard.isDown("right") then
		if  self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, movespeed, 0) and
			self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, movespeed, 0)
		then
			self.x = self.x + movespeed
		end

    elseif love.keyboard.isDown("left") then
		if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, -movespeed, 0) and
			self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, -movespeed, 0)
		then
			self.x = self.x - movespeed
		end
    end

    if love.keyboard.isDown("down") then
		if  self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, 0, movespeed) and
			self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, 0, movespeed)
		then
			self.y = self.y - movespeed
		end

    elseif love.keyboard.isDown("up") then
		if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, 0, -movespeed) and
			self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, 0, -movespeed)
		then
			self.y = self.y + movespeed
		end
    end
	
	self.state = self.scene.player.state
	if self.state == Player.STATE_IDLEDOWN then
		self.state = Player.STATE_IDLEUP
	elseif self.state == Player.STATE_IDLEUP then
		self.state = Player.STATE_IDLEDOWN
	elseif self.state == Player.STATE_WALKUP then
		self.state = Player.STATE_WALKDOWN
	elseif self.state == Player.STATE_WALKUP then
		self.state = Player.STATE_WALKDOWN
	end

	if prevState ~= self.state then
		self.sprite.animations[self.state]:reset()
	end
	
	self.sprite:setAnimation(self.state)
end

function Reflection:updateSprite()
	if not GameState.leader then
		return
	end

	local spriteName = GameState.party[GameState.leader].sprite
	if self.currentSprite == spriteName then
		return
	end

	if self.sprite then
		self.sprite:remove()
	end

	self.currentSprite = spriteName
	self.transform = Transform(0, 0, 2, 2)
	self.sprite = SpriteNode(
		self.scene,
		self.transform,
		self.color,
		spriteName,
		nil,
		nil,
		self.layer.name
	)

	local spriteWidth, spriteHeight = self.sprite.w,self.sprite.h
	self.transform.x = love.graphics.getWidth()/2 - spriteWidth
	self.transform.y = love.graphics.getHeight()/2 - spriteHeight
	self.transform.sx = 2
	self.transform.sy = 2

	self.width,self.height = spriteWidth, spriteHeight
	self.halfWidth,self.halfHeight = math.floor(spriteWidth/2), math.floor(spriteHeight/2)
end

function Reflection:split(orderedParty, horizontal)
	-- Create sprites for all party members
	local paths = {
		{"walkright", "idleleft",  "walkleft",  Transform(self.movespeed, 0)},
		{"walkleft",  "idleright", "walkright", Transform(-self.movespeed, 0)},
		{"walkup",    "idledown",  "walkdown",  Transform(0, -self.movespeed)},
		{"walkdown",  "idleup",    "walkup",    Transform(0, self.movespeed)}
	}
	if horizontal then
		paths = {
			{"walkright", "idleleft",  "walkleft",  Transform(self.movespeed, 0)},
			{"walkleft",  "idleright", "walkright", Transform(-self.movespeed, 0)},
			{"walkright", "idleleft",  "walkleft",  Transform(self.movespeed, 0)},
			{"walkleft",  "idleright", "walkright", Transform(-self.movespeed, 0)}
		}
	end

	local walkOutActions = {}
	local walkInActions = {}
	
	self.partySprites = {}
	for _, member in pairs(orderedParty or GameState.party) do
		local id = member.id
		local xform = Transform.from(self.transform)
		self.partySprites[id] = BasicNPC(
			self.scene,
			self.layer,
			{name = "split"..id, x = self.x, y = self.y, width = self.width, height = self.height,
				properties = {
					ghost = true,
					sprite = "art/sprites/"..member.sprite..".png"
				}
			}
		)
		self.partySprites[id].sprite.color = {255,255,255,255}
		self.partySprites[id].hidden = true
		self.scene:addObject(self.partySprites[id])

		local walkOutAnim, idleAnim, walkInAnim, dir = unpack(table.remove(paths, 1))
		table.insert(
			walkOutActions,
			Serial {
				Do(function()
					self.partySprites[id].hidden = false
				end),
				Animate(self.partySprites[id].sprite, walkOutAnim, true),
				Parallel {
					-- Baby T is way wider and taller than other Freedom Fighters, so we need spread out more
					self.partySprites["babyt"] and Wait(0.4) or Wait(0.2),
					Do(function()
						self.partySprites[id].x = self.partySprites[id].x + dir.x * (love.timer.getDelta()/0.016)
						self.partySprites[id].y = self.partySprites[id].y + dir.y * (love.timer.getDelta()/0.016)
					end)
				},
				Do(function()
					self.partySprites[id].sprite:setAnimation(idleAnim)
				end)
			}
		)
		table.insert(
			walkInActions,
			Serial {
				Animate(self.partySprites[id].sprite, walkInAnim, true),
				Parallel {
					Wait(0.2),
					Do(function()
						self.partySprites[id].x = self.partySprites[id].x - dir.x * (love.timer.getDelta()/0.016)
						self.partySprites[id].y = self.partySprites[id].y - dir.y * (love.timer.getDelta()/0.016)
					end)
				},
				Do(function()
					self.partySprites[id]:remove()
					self.partySprites[id] = nil
				end)
			}
		)
	end

	local walkOut = Serial {
		Do(function()
			-- Hide our primary sprite
			self.sprite.visible = false
		end),
		
		-- Show all other sprites walking out
		Parallel(walkOutActions),
	}
	local walkIn = Serial {	
		-- Show all other sprites walking in
		Parallel(walkInActions),
		
		Do(function()
			self.x = self.x - self.width + 9
			self.y = self.y - 12

			-- Show our primary sprite
			self.sprite.visible = true
		end)
	}
	return walkOut, walkIn, self.partySprites
end

function Reflection:spin(rotations, speed, sprite)
	local lazySprite = sprite or function() return self.sprite end
	return Repeat(
		Serial {
			Animate(lazySprite, "idledown", true),
			Wait(speed),
			Animate(lazySprite, "idleleft", true),
			Wait(speed),
			Animate(lazySprite, "idleup", true),
			Wait(speed),
			Animate(lazySprite, "idleright", true),
			Wait(speed),
			Animate(lazySprite, "idledown", true),
		},
		rotations
	)
end

function Reflection:keytriggered(key)
	if key == "c" then
		self:onChangeChar()
	end
end

function Reflection:onChangeChar()
	if self.noChangeChar or self.doingChangeChar or self.scene.player.cinematic or self.scene.player.cinematicStack > 0 then
		return
	end
	
	self.doingChangeChar = true

	self.origUpdate = self.update
	self.update = function(self, dt) end

	-- Spin around, change sprite/leader, spin, pose
	self:run {
		Wait(0.05),
		self:spin(1, 0.01),

		Do(function()
			self:updateSprite()
		end),
		
		self:spin(1, 0.02),
		
		Animate(function() return self.sprite end, "pose", true),
		Wait(0.5),
		
		Do(function()
			self.update = self.origUpdate
			self.doingChangeChar = false
		end)
	}
end

function Reflection:run(action)
	if not action.type then
		action = Serial(action)
	end
	Executor(self.scene):act(action)
end


return Reflection
