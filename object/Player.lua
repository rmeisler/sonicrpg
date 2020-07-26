local DrawableNode = require "object/DrawableNode"
local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local SceneNode = require "object/SceneNode"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"

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

local Player = class(SceneNode)

--[[ States ]]--
Player.STATE_IDLEDOWN  = "idledown"
Player.STATE_IDLEUP    = "idleup"
Player.STATE_IDLELEFT  = "idleleft"
Player.STATE_IDLERIGHT = "idleright"

Player.STATE_WALKDOWN  = "walkdown"
Player.STATE_WALKUP    = "walkup"
Player.STATE_WALKLEFT  = "walkleft"
Player.STATE_WALKRIGHT = "walkright"

Player.STATE_HIDELEFT  = "hideleft"
Player.STATE_HIDERIGHT = "hideright"
Player.STATE_HIDEUP    = "hideup"
Player.STATE_HIDEDOWN  = "hidedown"

Player.ToIdle = {
    [Player.STATE_WALKUP]    = Player.STATE_IDLEUP,
	[Player.STATE_WALKDOWN]  = Player.STATE_IDLEDOWN,
	[Player.STATE_WALKLEFT]  = Player.STATE_IDLELEFT,
	[Player.STATE_WALKRIGHT] = Player.STATE_IDLERIGHT,
	
	[Player.STATE_IDLEUP]    = Player.STATE_IDLEUP,
	[Player.STATE_IDLEDOWN]  = Player.STATE_IDLEDOWN,
	[Player.STATE_IDLELEFT]  = Player.STATE_IDLELEFT,
	[Player.STATE_IDLERIGHT] = Player.STATE_IDLERIGHT
}

function Player:construct(scene, layer, object)
    self.resistx = 0
    self.resisty = 0
	self.x = 0
	self.y = 0
	self.collisionX = 0
	self.collisionY = 0
	self.movespeed = 4
	self.layer = layer
	self.object = object
	self.cinematicStack = 0
	
	-- A hashset of objects that are contributing to our hiding in shadow
	-- Note: If hashset is empty, we are not in shadows. If it has at least
	-- one element, then we are in shadows.
	self.shadows = {}
	
	-- A hashset of bots that are investigating you
	self.investigators = {}
	
	-- A hashset of bots that are chasing you
	self.chasers = {}
	
	-- A hashset of fallable regions we are touching
	self.fallables = {}
	
	-- A hashset of platforms we are touching
	self.platforms = {}
	
	-- A hashset of things we are touching
	self.touching = {}
	
	-- A hashset of stairs we are touching
	self.stairs = {}
	
	-- Place player
	self.x = object.x
	self.y = object.y

    local spriteWidth, spriteHeight = 47,55
	self.transform = Transform(
		love.graphics.getWidth()/2 - spriteWidth,
		love.graphics.getHeight()/2 - spriteHeight,
		2,
		2
	)
	
	self.color = {255,255,255,255}
	
	self.state = object.properties.orientation and "idle"..object.properties.orientation or Player.STATE_IDLEDOWN
	self.width,self.height = spriteWidth, spriteHeight
	self.halfWidth,self.halfHeight = math.floor(spriteWidth/2), math.floor(spriteHeight/2)
	
	self:updateSprite()
	
	if object.properties.hidden then
		self.cinematic = true
		self.sprite:remove()
	else
		self.cinematic = false
	end
	
	self.inHidingSpot = {}
	self.hidingBehindPillar = false
	self.hidingDirection = nil
	
	self.dropShadow = BasicNPC(
		self.scene,
		{name = "objects"},
		{name = "playerDropShadow", x = 0, y = 0, width = 36, height = 6,
			properties = {nocollision = true, sprite = "art/sprites/dropshadow.png", align = NPC.ALIGN_TOPLEFT}
		}
	)
	self.dropShadow.sprite.transform.sx = 1.3
	self.dropShadow.sprite.sortOrderY = -1
	self.scene:addObject(self.dropShadow)
	
	self:updateHotspots()
	
	self:createVisuals()
	
	self:addSceneHandler("update", Player.update)
	self:addSceneHandler("keytriggered", Player.keytriggered)
	
	-- Set scene reference to this player
	scene.player = self
end

function Player:updateHotspots()
	self.hotspots = {
		right_top = {x = self.x + 12, y = self.y + self.halfHeight + 5},
		right_bot = {x = self.x + 12, y = self.y + self.height},
		left_top  = {x = self.x - 15, y = self.y + self.halfHeight + 5},
		left_bot  = {x = self.x - 15, y = self.y + self.height}
	}
	return self.hotspots
end

function Player:showKeyHint(showPressX, specialHint)
	if self.erasingKeyHint or self.doingChangeChar or self.blockingKeyHint then
		return
	end

	if not self.keyHint then
		self.keyHint = {}
	end
	local keyHintActions = {}
	
	if specialHint ~= nil and not self.showPressLsh then
		if self.showPressX then
			local pressX = table.remove(self.keyHint)
			pressX:remove()
			self.showPressX = false
		end
		
		local pressLshXForm = Transform.relative(
			self.transform,
			Transform(self.sprite.w - 12, 0)
		)
		local pressLsh = SpriteNode(
			self.scene,
			pressLshXForm,
			{255,255,255,0},
			specialHint == GameState.leader and "presslsh" or "pressc",
			nil,
			nil,
			"objects"
		)
		pressLsh.sortOrderY = self.transform.y + self.sprite.h*2
		table.insert(self.keyHint, pressLsh)
		table.insert(keyHintActions, Ease(pressLsh.color, 4, 255, 5))
		self.showPressLsh = true
	elseif showPressX and not self.showPressX and not self.showPressLsh then
		local pressXXForm = Transform.relative(
			self.transform,
			Transform(self.sprite.w - 10, 0)
		)
		local pressX = SpriteNode(
			self.scene,
			pressXXForm,
			{255,255,255,0},
			"pressx",
			nil,
			nil,
			"objects"
		)
		pressX.sortOrderY = self.transform.y + self.sprite.h*2
		table.insert(self.keyHint, pressX)
		table.insert(keyHintActions, Ease(pressX.color, 4, 255, 5))
		self.showPressX = true
	end
	
	if next(keyHintActions) ~= nil then
		self:run(Parallel(keyHintActions))
	end
end

function Player:removeKeyHint(refreshKeyHint)
	if 	self.keyHint and
		not self.erasingKeyHint
	then
		self.erasingKeyHint = true
		
		local keyHintActions = {}
		for _, v in pairs(self.keyHint) do
			table.insert(keyHintActions, Serial {
				Ease(v.color, 4, 0, 5),
				Do(function()
					v:remove()
				end)
			})
		end
		self:run {
			Parallel(keyHintActions),
			Do(function()
				self.keyHint = nil
				self.erasingKeyHint = false
				self.showPressLsh = false
				self.showPressX = false
				
				-- Refresh collision with objects
				if refreshKeyHint then
					for _, obj in pairs(self.scene.player.touching) do
						print("idle state for "..obj.name)
						obj.state = NPC.STATE_IDLE
					end
				end
			end)
		}
	end
end

function Player:split()
	-- Create sprites for all party members
	local paths = {
		{"walkright", "idleleft",  "walkleft",  Transform(self.movespeed, 0)},
		{"walkleft",  "idleright", "walkright", Transform(-self.movespeed, 0)},
		{"walkup",    "idledown",  "walkdown",  Transform(0, -self.movespeed)},
		{"walkdown",  "idleup",    "walkup",    Transform(0, self.movespeed)}
	}
	local walkOutActions = {}
	local walkInActions = {}
	
	self.partySprites = {}
	for id, member in pairs(GameState.party) do
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
		--self.partySprites[id].sprite.color = self.color
		self.partySprites[id].sprite.visible = false
		self.scene:addObject(self.partySprites[id])

		local walkOutAnim, idleAnim, walkInAnim, dir = unpack(table.remove(paths, 1))
		table.insert(
			walkOutActions,
			Serial {
				Do(function()
					self.partySprites[id].sprite.visible = true
				end),
				Animate(self.partySprites[id].sprite, walkOutAnim, true),
				Parallel {
					Wait(0.2),
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
			if self.dropShadow.sprite then
				self.dropShadow.sprite.visible = false
			end
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
			if self.dropShadow.sprite then
				self.dropShadow.sprite.visible = true
			end
		end)
	}
	return walkOut, walkIn, self.partySprites
end

function Player:spin(rotations, speed, sprite)
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

function Player:keytriggered(key)
	if key == "c" then
		self:onChangeChar()
	end
end

function Player:onChangeChar()
	if self.doingSpecialMove or self.doingChangeChar or self.cinematic then
		return
	end	
	
	self.doingChangeChar = true

	self.origUpdate = self.basicUpdate
	self.basicUpdate = function(self, dt)
		self:updateShadows()
		self:updateVisuals()
	end
	
	self.scene.audio:playSfx("switchcharshort", 1.0)
	
	-- Spin around, change sprite/leader, spin, pose
	self:run {
		self:spin(1, 0.01),

		Do(function()
			local currentLeader = GameState.leader
			local lastId
			for id, _ in pairs(GameState.party) do
				if lastId == GameState.leader then
					GameState.leader = id
					break
				end
				lastId = id
			end
			-- At end of party list, choose first
			if GameState.leader == currentLeader then
				GameState.leader = next(GameState.party)
			end
			self:updateSprite()
		end),
		
		self:spin(1, 0.02),
		
		Animate(function() return self.sprite end, "pose", true),
		Wait(0.5),
		
		Do(function()
			self.basicUpdate = self.origUpdate
			self.origUpdate = nil
			self.doingChangeChar = false
			
			-- Update keyhint
			self:removeKeyHint(true)
		end)
	}
end

function Player:onSpecialMove()
	self.doingSpecialMove = true
	GameState.party[GameState.leader].specialmove(self)
end

function Player:addVisual(partyMember, location, name, sprite, transformOffset)
	if not self.visuals then
		self.visuals = {}
	end
	if not self.visuals[partyMember] then
		self.visuals[partyMember] = {}
	end
	if not self.visuals[partyMember][location] then
		self.visuals[partyMember][location] = {}
	end
	sprite.transformOffset = transformOffset
	self.visuals[partyMember][location][name] = sprite
end

function Player:removeVisual(partyMember, location, name)
	self.visuals[partyMember][location][name]:remove()
	self.visuals[partyMember][location][name] = nil
end

function Player:isFacing(direction)
	if not self.state or not direction then
		return false
	end
	return string.find(self.state, direction) ~= nil
end

function Player:updateSprite()
	if not GameState.leader then
		return
	end
	if self.sprite then
		self.sprite:remove()
	end
	self.sprite = SpriteNode(
		self.scene,
		self.transform,
		self.color,
		GameState.party[GameState.leader].sprite,
		nil,
		nil,
		self.layer.name
	)
	
	-- Debug
	if self.debugHotspots then
		local drawFn = self.sprite.draw
		self.sprite.draw = function()
			drawFn(self.sprite)
			self:draw()
		end
	end
end

function Player:updateShadows()
	-- If we are hiding, display our sprite more darkly
	if self:inShadow() then
		self.sprite.color[1] = 150
		self.sprite.color[2] = 150
		self.sprite.color[3] = 150
	else
		self.sprite.color[1] = 255
		self.sprite.color[2] = 255
		self.sprite.color[3] = 255
	end
end

function Player:createVisuals()
	for name, member in pairs(GameState.party) do
		for _itemType, item in pairs(member.equip) do
			if item.onEquip then
				item.onEquip(name, self)
			end
		end
	end
end

function Player:updateVisuals()
	for partyMember, locations in pairs(self.visuals or {}) do
		if partyMember == GameState.leader then
			for location, sprites in pairs(locations or {}) do
				for _, sprite in pairs(sprites or {}) do
					sprite.visible = true

					local locationOffset = self:getLocationOffset(location)
					sprite.transform.x = self.sprite.transform.x + locationOffset.x + sprite.transformOffset.x
					sprite.transform.y = self.sprite.transform.y + locationOffset.y + sprite.transformOffset.y
					sprite.transform.sx = 2 * sprite.transformOffset.sx
					sprite.transform.sy = 2 * sprite.transformOffset.sy
					sprite.sortOrderY = self.y + self.sprite.h*2 + 1
					
					-- hacks
					if self:isFacing("left") then
						sprite.transform.x = sprite.transform.x - sprite.w/2
					elseif self:isFacing("up") then
						sprite.transform.x = sprite.transform.x - sprite.h/5
						sprite.transform.y = sprite.transform.y - sprite.h/10
					end

					sprite:setAnimation(self.state)
				end
			end
		else
			for _, sprites in pairs(locations or {}) do
				for _, sprite in pairs(sprites or {}) do
					sprite.visible = false
				end
			end
		end
	end
end

function Player:getLocationOffset(location)
	return self.sprite:getLocationOffset(location)
end

function Player:isHiding(direction)
	if direction then
		return self.hidingDirection == direction
	else
		return self.hidingDirection ~= nil
	end
end

function Player:inShadow()
	return next(self.shadows)
end

function Player:basicUpdate(dt)
	if not self.sprite then
		return
	end

	-- Scale movespeed by time
	local movespeed = self.movespeed * (dt/0.016)
	
	self:updateShadows()
	self:updateVisuals()
	
	-- Update drop shadow position
	self.dropShadow.x = self.x - 22
	self.dropShadow.y = self.dropShadowOverrideY or self.y + self.sprite.h - 15
	
	local prevState = self.state
	
	if not self.noIdle then
		self.state = Player.ToIdle[self.state] or self.state
	end
	
	self.collisionX, self.collisionY = self.scene:worldCoordToCollisionCoord(self.x, self.y)
	local hotspots = self:updateHotspots()
    
	if 	self.cinematic or
		self.cinematicStack > 0 or
		self.blocked or
		not self.scene:playerMovable() or
		self.dontfuckingmove
	then
		if not self.noIdle then
			self.sprite:setAnimation(self.state)
		end
		return
	end
	
	if love.keyboard.isDown("lshift") then
		self:onSpecialMove()
		return
	end
	self.doingSpecialMove = false
	
	local moving = false
    if love.keyboard.isDown("right") then
		if  self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, movespeed, 0) and
			self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, movespeed, 0)
		then
			self.x = self.x + movespeed
			self.state = Player.STATE_WALKRIGHT
			
			-- Going up stairs
			local _, stairs = next(self.stairs)
			if stairs then
				if stairs.direction == "up_right" then
					self.y = self.y - movespeed * 0.7
				elseif stairs.direction == "up_left" then
					self.y = self.y + movespeed * 0.7
				end
			end
			
			moving = true
		elseif not moving then
			local _, spot = next(self.inHidingSpot)
			if spot and not (love.keyboard.isDown("up") or love.keyboard.isDown("down")) then
				self.y = spot.y + spot.sprite.h*2 - self.sprite.h + 1
				--self.sprite.sortOrderY = spot.y + spot.sprite.h*2 + 1
				self.state = Player.STATE_HIDERIGHT
				self.cinematic = true
				self.hidingDirection = "right"
				self.scene:run(
					While(
						function()
							return love.keyboard.isDown("right") and not next(self.investigators)
						end,
						Serial {
							Wait(1),
							Do(function()
								self.state = "peekright"
							end),
							Ease(self.scene.camPos, "x", -self:peakDistance("right"), 1, "inout"),
							Repeat(Action())
						},
						Serial {
							Ease(self.scene.camPos, "x", 0, 5, "inout"),
							Do(function()
								self.cinematic = false
								if not next(self.investigators) then
									self.state = Player.STATE_IDLERIGHT
									--self.sprite.sortOrderY = nil
								end
							end),
							Wait(1),
							Do(function()
								self.hidingDirection = nil
							end)
						}
					)
				)
			else
				self.state = Player.STATE_IDLERIGHT
			end
		end

    elseif love.keyboard.isDown("left") then
		if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, -movespeed, 0) and
			self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, -movespeed, 0)
		then
			self.x = self.x - movespeed
			self.state = Player.STATE_WALKLEFT
			
			-- Going up stairs
			local _, stairs = next(self.stairs)
			if stairs then
				if stairs.direction == "up_right" then
					self.y = self.y + movespeed * 0.7
				elseif stairs.direction == "up_left" then
					self.y = self.y - movespeed * 0.7
				end
			end
			
			moving = true
		elseif not moving then
			local _, spot = next(self.inHidingSpot)
			if spot and not (love.keyboard.isDown("up") or love.keyboard.isDown("down")) then
				self.y = spot.y + spot.sprite.h*2 - self.sprite.h + 1
				--self.sprite.sortOrderY = spot.y + spot.sprite.h*2 + 1
				self.state = Player.STATE_HIDELEFT
				self.cinematic = true
				self.hidingDirection = "left"
				self.scene:run(
					While(
						function()
							return love.keyboard.isDown("left") and not next(self.investigators)
						end,
						Serial {
							Wait(1),
							Do(function()
								self.state = "peekleft"
							end),
							Ease(self.scene.camPos, "x", self:peakDistance("left"), 1, "inout"),
							Repeat(Action())
						},
						Serial {
							Ease(self.scene.camPos, "x", 0, 5, "inout"),
							Do(function()
								self.cinematic = false
								if not next(self.investigators) then
									self.state = Player.STATE_IDLELEFT
									--self.sprite.sortOrderY = nil
								end
							end),
							Wait(1),
							Do(function()
								self.hidingDirection = nil
							end)
						}
					)
				)
			else
				self.state = Player.STATE_IDLELEFT
			end
		end
    end

    if love.keyboard.isDown("down") then
		if  self.scene:canMove(hotspots.left_bot.x, hotspots.left_bot.y, 0, movespeed) and
			self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, 0, movespeed)
		then
			-- Not allowed to move up and down if going up stairs
			if not next(self.stairs) then
				self.y = self.y + movespeed
				self.state = Player.STATE_WALKDOWN
				moving = true
			else
				self.state = Player.STATE_IDLEDOWN
			end
		elseif not moving then
			local _, spot = next(self.inHidingSpot)
			if spot and not (love.keyboard.isDown("left") or love.keyboard.isDown("right")) then
				self.state = Player.STATE_HIDEDOWN
				self.x = spot.x + self.scene:getTileWidth() + (spot.object.properties.hideOffset or 0) - 7
				self.cinematic = true
				self.hidingDirection = "down"
				self.hideHand = BasicNPC(
					self.scene,
					{name = "objects"},
					{name = "playerHideHand", x = self.x - 20, y = self.y + self.height, width = self.width, height = self.height,
						properties = {
							nocollision = true,
							sprite = "art/sprites/"..GameState.party[GameState.leader].sprite..".png"
						}
					}
				)
				self.scene:addObject(self.hideHand)
				self.hideHand.sprite.visible = false
				self.scene:run(
					While(
						function()
							return love.keyboard.isDown("down") and not next(self.investigators)
						end,
						Serial {
							Parallel {
								Ease(self, "x", self.x - 20, 4, "inout"),
								Wait(1)
							},
							Do(function()
								self.hideHand.sprite:setAnimation("hidedownhand")
								self.hideHand.sprite.transform.ox = 0
								self.hideHand.sprite.transform.oy = self.hideHand.sprite.h
								self.hideHand.sprite.transform.sx = 0
								self.hideHand.sprite.transform.sy = 2
								self.hideHand.sprite.visible = true
								self.hideHand.sprite.sortOrderY = self.hideHand.sprite.transform.y + self.hideHand.sprite.h*2 + 10
							end),
							Parallel {
								Ease(self, "x", self.x - 25, 1, "inout"),
								Ease(self.scene.camPos, "y", -self:peakDistance("down"), 1, "inout"),
								Ease(self.hideHand.sprite.transform, "sx", 2, 2, "inout"),
								Ease(self.hideHand, "x", self.hideHand.x - self.width, 2, "inout")
							},
							Repeat(Action())
						},
						Serial {
							Parallel {
								Ease(self, "x", self.x, 5, "inout"),
								Ease(self.scene.camPos, "y", 0, 5, "inout"),

								Ease(self.hideHand.sprite.transform, "sx", 0, 5, "inout"),
								Ease(self.hideHand, "x", self.x - 20, 5, "inout")
							},
							Do(function()
								self.cinematic = false
								self.hideHand:remove()
								self.dropShadowOverrideY = nil
								if not next(self.investigators) then
									self.state = Player.STATE_IDLEUP
								end
							end),
							Wait(1),
							Do(function()
								-- Hold hiding direction power for a little
								self.hidingDirection = nil
							end)
						}
					)
				)
			else
				self.state = Player.STATE_IDLEDOWN
			end
		end

    elseif love.keyboard.isDown("up") then
		if  self.scene:canMove(hotspots.left_top.x, hotspots.left_top.y, 0, -movespeed) and
			self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, 0, -movespeed)
		then
			-- Not allowed to move up and down if going up stairs
			if not next(self.stairs) then
				self.y = self.y - movespeed
				self.state = Player.STATE_WALKUP
				moving = true
			else
				self.state = Player.STATE_IDLEUP
			end
		elseif not moving then
			local _, spot = next(self.inHidingSpot)
			if spot and not (love.keyboard.isDown("left") or love.keyboard.isDown("right")) then
				self.state = Player.STATE_HIDEUP
				self.x = spot.x + self.scene:getTileWidth() + (spot.object.properties.hideOffset or 0) - 7
				self.cinematic = true
				self.hidingDirection = "up"
				self.dropShadowOverrideY = self.y + self.sprite.h - 25
				self.scene:run(
					While(
						function()
							return love.keyboard.isDown("up") and not next(self.investigators)
						end,
						Serial {
							Wait(1),
							Do(function()
								self.state = "peekup"
							end),
							Ease(self.scene.camPos, "y", self:peakDistance("up"), 1, "inout"),
							Repeat(Action())
						},
						Serial {
							Ease(self.scene.camPos, "y", 0, 5, "inout"),
							Do(function()
								self.cinematic = false
								self.dropShadowOverrideY = nil
								if not next(self.investigators) then
									self.state = Player.STATE_IDLEUP
								end
							end),
							Wait(1),
							Do(function()
								-- Hold hiding direction power for a little
								self.hidingDirection = nil
							end)
						}
					)
				)
			else
				self.state = Player.STATE_IDLEUP
			end
		end
    end

	if prevState ~= self.state then
		self.sprite.animations[self.state]:reset()
	end
	
	self.sprite:setAnimation(self.state)
end

function Player:peakDistance(dir)
	local maxDist = 250
	if dir == "left" then
		if self.x <= love.graphics.getWidth()/2 then
			return 0
		elseif self.x >= self.scene:getMapWidth() - love.graphics.getWidth()/2 then
			return math.min(maxDist, self.scene:getMapWidth() - self.x - self.sprite.w*2)
		else
			return math.min(maxDist, self.x - love.graphics.getWidth()/2)
		end
	elseif dir == "right" then
		if self.x >= self.scene:getMapWidth() - love.graphics.getWidth()/2 then
			return 0
		elseif self.x <= love.graphics.getWidth()/2 then
			return math.min(maxDist, love.graphics.getWidth()/2 - self.x - self.sprite.w*2)
		else
			return math.min(maxDist, self.scene:getMapWidth() - love.graphics.getWidth()/2 - self.x)
		end
	elseif dir == "up" then
		if self.y <= love.graphics.getHeight()/2 then
			return 0
		elseif self.y >= self.scene:getMapHeight() - love.graphics.getHeight()/2 then
			return math.min(maxDist, self.scene:getMapHeight() - self.y - self.sprite.h*2)
		else
			return math.min(maxDist, self.y - love.graphics.getHeight()/2)
		end
	elseif dir == "down" then
		if self.y >= self.scene:getMapHeight() - love.graphics.getHeight()/2 then
			return 0
		elseif self.y <= love.graphics.getHeight()/2 then
			return math.min(maxDist, love.graphics.getHeight()/2 - self.y - self.sprite.h*2)
		else
			return math.min(maxDist, self.scene:getMapHeight() - love.graphics.getHeight()/2 - self.y)
		end
	end
end

function Player:update(dt)
	self:basicUpdate(dt)
end

function Player:isMoving()
	return  self.state == Player.STATE_WALKUP or
			self.state == Player.STATE_WALKDOWN or
			self.state == Player.STATE_WALKLEFT or
			self.state == Player.STATE_WALKRIGHT
end

function Player:isTouching(x, y, w, h)
	if not self.hotspots then
		return false
	end
	
	w = w or self.scene:getTileWidth()
	h = h or self.scene:getTileHeight()
	
	local fuzz = 5
	return (x + w) >= (self.hotspots.left_bot.x - fuzz) and
		x < (self.hotspots.right_bot.x + fuzz) and
		(self.hotspots.left_bot.y + fuzz) >= y and
		(self.hotspots.right_top.y - fuzz) <= (y + h)
end

function Player:isTouchingObj(obj)
	if not self.hotspots or not obj.hotspots then
		return false
	end
	
	return self:isTouching(
		obj.hotspots.left_top.x,
		obj.hotspots.left_top.y,
		obj.hotspots.right_bot.x - obj.hotspots.left_top.x,
		obj.hotspots.right_bot.y - obj.hotspots.left_top.y
	)
end

function Player:remove()
	SceneNode.remove(self)
	self.sprite:remove()
	self.dropShadow:remove()
	
	-- Remove all visuals
	for _partyMember, locations in pairs(self.visuals or {}) do
		for _locationName, sprites in pairs(locations or {}) do
			for _visualName, sprite in pairs(sprites or {}) do
				sprite:remove()
			end
		end
	end
end

function Player:run(action)
	if not action.type then
		action = Serial(action)
	end
	Executor(self.scene):act(action)
end

function Player:draw()
	-- draw hotspots
	love.graphics.setColor(255,255,255,255)
	
	local worldOffsetX = -self.x + love.graphics.getWidth()/2
	local worldOffsetY = -self.y + love.graphics.getHeight()/2
	for k,v in pairs(self.hotspots or {}) do
		love.graphics.rectangle("fill", worldOffsetX+v.x, worldOffsetY+v.y, 2, 2)
	end
end


return Player
