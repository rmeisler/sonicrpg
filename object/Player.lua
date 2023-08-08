local DrawableNode = require "object/DrawableNode"
local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local SceneNode = require "object/SceneNode"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"

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

Player.DEFAULT_DUST_COLOR      = {255, 255, 255, 255}
Player.ROBOTROPOLIS_DUST_COLOR = {130, 130, 200, 255}
Player.FOREST_DUST_COLOR       = {255, 255, 200, 255}
Player.SNOW_FOOTPRINT_TIME     = 0.2

Player.MAX_SORT_ORDER_Y = 999999999

function Player:construct(scene, layer, object)
    self.resistx = 0
    self.resisty = 0
	self.x = 0
	self.y = 0
	self.collisionX = 0
	self.collisionY = 0
	self.baseMoveSpeed = 4
	self.movespeed = self.baseMoveSpeed
	self.layer = layer
	self.object = object
	self.cinematicStack = 0
	self.spriteOverride = {}
	self.dustColor = Player.DEFAULT_DUST_COLOR
	
	self.isSwatbot = {}
	self.lastSwatbotStepSfx = love.timer.getTime()

	-- A hashset of objects that are contributing to our hiding in shadow
	-- Note: If hashset is empty, we are not in shadows/light. If it has at least
	-- one element, then we are in shadows/light.
	self.shadows = {}
	self.lights = {}
	
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
	
	-- A hashset of ladders we are touching
	self.ladders = {}

	-- A hashset of things blocking your ladder access
	self.noLadder = {}

	-- A hashset of keyhints we are touching
	self.keyhints = {}

	-- A hashset of keyhints to suppress
	self.hidekeyhints = {}
	
	-- Current keyhint sprite and obj
	self.curKeyHintSprite = nil
	self.curKeyHint = nil
	
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
	
	self.hotspotOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = 0},
		left_bot  = {x = 0, y = 0}
	}
	
	self.collisionHSOffsets = {
		right_top = {x = 18, y = 0},
		right_bot = {x = 18, y = 0},
		left_top = {x = -15, y = 0},
		left_bot = {x = -15, y = 0},
	}
	
	self:createVisuals()
	
	self:addSceneHandler("update", Player.update)
	self:addSceneHandler("keytriggered", Player.keytriggered)
	
	self.updateFun = self.basicUpdate
	
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

function Player:updateKeyHint()
	if self.erasingKeyHint then
		return
	end

	-- Figure out if we are colliding with multiple key hints,
	-- resolve to the best one based on distance and context
	local closestKeyHint = nil
	local specialKeyHint = nil
	for _, obj in pairs(self.keyhints) do
		if not self.hidekeyhints[tostring(obj)] then
			if not closestKeyHint or self:distanceFromSq(obj) > self:distanceFromSq(closestKeyHint) then
				closestKeyHint = obj
			end
			if not specialKeyHint and obj.specialHintPlayer then
				specialKeyHint = obj
			end
		end
	end

	if specialKeyHint and not specialKeyHint.isInteractable and specialKeyHint.showHint then
		self.curKeyHint = specialKeyHint
		self:showKeyHint(false, specialKeyHint.specialHintPlayer)
	elseif closestKeyHint then
		self.curKeyHint = closestKeyHint
		if closestKeyHint.hidingSpot then
			local dir
			if  math.abs(self.x -
						 (closestKeyHint.x + closestKeyHint.sprite.w)) >
				math.abs((self.y + self.sprite.h) -
						 (closestKeyHint.y + closestKeyHint.sprite.h*2))
			then
				if  self.x >
					(closestKeyHint.x + closestKeyHint.sprite.w)
				then
					dir = "left"
				else
					dir = "right"
				end
			else
				if (self.y + self.sprite.h) >
				   (closestKeyHint.y + closestKeyHint.sprite.h*2)
				then
					dir = "up"
				else
					dir = "down"
				end
			end
			self:showKeyHint(false, nil, "press"..dir)
		elseif closestKeyHint.isInteractable then
			self:showKeyHint(true, closestKeyHint.specialHintPlayer)
		end
	else
		self:removeKeyHint()
	end
end

function Player:showKeyHint(showPressX, specialHint, showPressDir)
	if self.erasingKeyHint then
		return
	end

	if not self.keyHint then
		self.keyHint = {}
	end
	local keyHintActions = {}
	
	-- Ignore special hint if that player is pretending to be a swatbot
	if specialHint and self.isSwatbot[specialHint] then
		specialHint = nil
	end

	-- Highest precedence goes to dir press
	if showPressDir and showPressDir ~= self.showPressDir then
		if self.showPressDir then
			self.curKeyHintSprite:remove()
		end
		local pressDirXForm = Transform.relative(
			self.transform,
			Transform(self.sprite.w - 10, 0)
		)
		-- HACK: Rotor is too differently shaped for this transform, change it
		if GameState.leader == "rotor" then
			pressDirXForm = Transform.relative(
				self.transform,
				Transform(self.sprite.w - 15, -10)
			)
		end
		local pressDir = SpriteNode(
			self.scene,
			pressDirXForm,
			{255,255,255,0},
			showPressDir,
			nil,
			nil,
			self.scene:hasUpperLayer() and "upper" or "objects"
		)
		pressDir.sortOrderY = Player.MAX_SORT_ORDER_Y
		self.curKeyHintSprite = pressDir
		table.insert(keyHintActions, Ease(pressDir.color, 4, 255, 5))
		self.showPressDir = showPressDir
	elseif specialHint ~= nil and showPressX and not self.showPressX then
		local pressXXForm = Transform.relative(
			self.transform,
			Transform(self.sprite.w - 10, 0)
		)
		-- HACK: Rotor is too differently shaped for this transform, change it
		if GameState.leader == "rotor" then
			pressXXForm = Transform.relative(
				self.transform,
				Transform(self.sprite.w - 15, -10)
			)
		end
		local pressX = SpriteNode(
			self.scene,
			pressXXForm,
			{255,255,255,0},
			string.find(specialHint, GameState.leader) and "pressx" or "pressc",
			nil,
			nil,
			self.scene:hasUpperLayer() and "upper" or "objects"
		)
		pressX.drawWithNight = false
		pressX.sortOrderY = Player.MAX_SORT_ORDER_Y
		self.curKeyHintSprite = pressX
		table.insert(keyHintActions, Ease(pressX.color, 4, 255, 5))
		self.showPressX = true
	elseif specialHint ~= nil and not self.showPressLsh and not self.showPressX then
		local pressLshXForm = Transform.relative(
			self.transform,
			Transform(self.sprite.w - 12, 0)
		)
		-- HACK: Rotor is too differently shaped for this transform, change it
		if GameState.leader == "rotor" then
			pressLshXForm = Transform.relative(
				self.transform,
				Transform(self.sprite.w - 17, -10)
			)
		end
		local pressLsh = SpriteNode(
			self.scene,
			pressLshXForm,
			{255,255,255,0},
			specialHint == GameState.leader and "presslsh" or "pressc",
			nil,
			nil,
			self.scene:hasUpperLayer() and "upper" or "objects"
		)
		pressLsh.drawWithNight = false
		pressLsh.sortOrderY = Player.MAX_SORT_ORDER_Y
		self.curKeyHintSprite = pressLsh
		table.insert(keyHintActions, Ease(pressLsh.color, 4, 255, 5))
		self.showPressLsh = true
	elseif showPressX and not self.showPressX and not self.showPressLsh then
		local pressXXForm = Transform.relative(
			self.transform,
			Transform(self.sprite.w - 10, 0)
		)
		-- HACK: Rotor is too differently shaped for this transform, change it
		if GameState.leader == "rotor" then
			pressXXForm = Transform.relative(
				self.transform,
				Transform(self.sprite.w - 15, -10)
			)
		end
		local pressX = SpriteNode(
			self.scene,
			pressXXForm,
			{255,255,255,0},
			"pressx",
			nil,
			nil,
			self.scene:hasUpperLayer() and "upper" or "objects"
		)
		pressX.drawWithNight = false
		pressX.sortOrderY = Player.MAX_SORT_ORDER_Y
		self.curKeyHintSprite = pressX
		table.insert(keyHintActions, Ease(pressX.color, 4, 255, 5))
		self.showPressX = true
	end
	
	if next(keyHintActions) ~= nil then
		self:run(Parallel(keyHintActions))
	end
end

function Player:removeKeyHint()
	if 	self.curKeyHintSprite and
		not self.erasingKeyHint
	then
		self.erasingKeyHint = true
		self.curKeyHint = nil

		self:run {
			Ease(self.curKeyHintSprite.color, 4, 0, 5),
			Do(function()
				self.curKeyHintSprite:remove()
				self.curKeyHintSprite = nil
				
				self.showPressLsh = false
				self.showPressX = false
				self.showPressDir = false
				self.erasingKeyHint = false
			end)
		}
	end
end

function Player:split(orderedParty)
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
		self.partySprites[id].sprite.color = self:inShadow() and {150,150,150,255} or {255,255,255,255}
		self.partySprites[id].hidden = true
		self.scene:addObject(self.partySprites[id])
		self.scene.partySprites = self.partySprites

		local walkOutAnim, idleAnim, walkInAnim, dir = unpack(table.remove(paths, 1))
		table.insert(
			walkOutActions,
			Serial {
				Do(function()
					self.partySprites[id].hidden = false
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
				self.dropShadow.hidden = true
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
				self.dropShadow.hidden = false
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
	if self.noChangeChar or self.doingSpecialMove or self.doingChangeChar or self.cinematic or self.cinematicStack > 0 then
		return
	end	
	
	self.doingChangeChar = true

	self.basicUpdate = function(self, dt)
		self:updateShadows()
		self:updateVisuals()
	end
	
	-- Suppress keyhints
	for k,obj in pairs(self.keyhints) do
		self.hidekeyhints[k] = obj
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
			self:removeKeyHint()
		end),
		
		self:spin(1, 0.02),
		
		Animate(function() return self.sprite end, "pose", true),
		Wait(0.5),
		
		Do(function()
			self.basicUpdate = self.updateFun
			self.doingChangeChar = false
			
			-- Update keyhint
			self.hidekeyhints = {}
			self:removeKeyHint()
		end)
	}
end

function Player:onSpecialMove()
	if not self.noSpecialMove then
		self.doingSpecialMove = true
		self.keyhints = {}
		self.hidekeyhints = {}
		self:removeKeyHint()
		GameState.party[GameState.leader].specialmove(self)
	end
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

function Player:isFacingObj(object)
	return true
	--[[if  math.abs(self.x - object.object.x) >
		math.abs(self.y - object.object.y)
	then
		if self.x < object.object.x then
			return self:isFacing("left")
		else
			return self:isFacing("right")
		end
	else
		if self.y < object.object.y then
			return self:isFacing("down")
		else
			return self:isFacing("up")
		end
	end]]
end

function Player:updateSprite()
	if not GameState.leader then
		return
	end
	if self.sprite then
		self.sprite:remove()
	end
	local spriteName = GameState.party[GameState.leader].sprite
	if self.spriteOverride[GameState.leader] then
		spriteName = self.spriteOverride[GameState.leader]
	end
	self.sprite = SpriteNode(
		self.scene,
		self.transform,
		self.color,
		spriteName,
		nil,
		nil,
		self.layer.name
	)
	if self.scene.nighttime then
		self.sprite.drawWithNight = false
	end

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
	if self.ignoreLightingEffects then
		return
	end

	-- If we are hiding, display our sprite more darkly
	if self:inShadow() then
		self.sprite.color[1] = 150
		self.sprite.color[2] = 150
		self.sprite.color[3] = 150
	elseif self:inLight() then
		self.sprite.color[1] = 412
		self.sprite.color[2] = 412
		self.sprite.color[3] = 412
	else
		self.sprite.color[1] = 255
		self.sprite.color[2] = 255
		self.sprite.color[3] = 255
	end
end

function Player:updateSpriteForMember(member, sprite)
	self.spriteOverride[member] = "sprites/"..sprite
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
	return (self.scene.nighttime and not self.scene.map.properties.ignorenight) or
			next(self.shadows)
end

function Player:inLight()
	return next(self.lights)
end

function Player:basicUpdate(dt)
	if not self.sprite then
		return
	end
	
	local isSwatbot = self.isSwatbot[GameState.leader]

	-- Scale movespeed by time
	local baseMoveSpeed = self.movespeed
	if isSwatbot then
		baseMoveSpeed = 3
	end
	
	local movespeed = baseMoveSpeed * (dt/0.016)
	
	self:updateShadows()
	self:updateVisuals()
	self:updateKeyHint()
	
	-- Update drop shadow position
	self.dropShadow.x = self.x - 22
	self.dropShadow.y = self.dropShadowOverrideY or self.y + self.sprite.h - 15

	-- HACK: Rotor is big
	if GameState.leader == "rotor" then
		self.dropShadow.x = self.x - 5
	end

	local prevState = self.state
	
	if not self.noIdle then
		self.state = Player.ToIdle[self.state] or self.state
	end
	
	local hotspots = self:updateCollisionObj()
	
	hotspots.right_top.x = hotspots.right_top.x + self.collisionHSOffsets.right_top.x
	hotspots.right_top.y = hotspots.right_top.y + self.collisionHSOffsets.right_top.y
	hotspots.right_bot.x = hotspots.right_bot.x + self.collisionHSOffsets.right_bot.x
	hotspots.right_bot.y = hotspots.right_bot.y + self.collisionHSOffsets.right_bot.y
	hotspots.left_top.x = hotspots.left_top.x + self.collisionHSOffsets.left_top.x
	hotspots.left_top.y = hotspots.left_top.y + self.collisionHSOffsets.left_top.y
	hotspots.left_bot.x = hotspots.left_bot.x + self.collisionHSOffsets.left_bot.x
	hotspots.left_bot.y = hotspots.left_bot.y + self.collisionHSOffsets.left_bot.y
    
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
	
	if not isSwatbot and love.keyboard.isDown("lshift") then
		self:onSpecialMove()
		return
	end
	self.doingSpecialMove = false
	
	if self.scene.map.properties.snow then
		if not self.snowtime then
			self.snowtime = 0
			self.snowoffsety = 1
		end
		self.snowtime = self.snowtime + dt
	end
	
	local moving = false
	local movingX = false
	local movingY = false
    if love.keyboard.isDown("right") then
		if  self.scene:canMove(hotspots.right_top.x, hotspots.right_top.y, movespeed, 0) and
			self.scene:canMove(hotspots.right_bot.x, hotspots.right_bot.y, movespeed, 0)
		then
			self.x = self.x + movespeed
			self.state = Player.STATE_WALKRIGHT
			if self.scene.map.properties.snow then
				self:makeSnowFootprint(hotspots.left_bot.x, hotspots.left_bot.y - 10 + self.snowoffsety * 5)
			end

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
			movingX = true
		elseif not moving then
			local _, spot = next(self.inHidingSpot)
			if  not isSwatbot and
			    spot and
				self:spacialRelation(hotspots, spot) == "left" and
				self:isFacing("right") and
			    not (love.keyboard.isDown("up") or love.keyboard.isDown("down"))
			then
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
			if self.scene.map.properties.snow then
				self:makeSnowFootprint(hotspots.right_bot.x - 10, hotspots.right_bot.y - 10 + self.snowoffsety * 5)
			end

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
			movingX = true
		elseif not moving then
			local _, spot = next(self.inHidingSpot)
			if  not isSwatbot and
				spot and
				self:spacialRelation(hotspots, spot) == "right" and
				self:isFacing("left") and
				not (love.keyboard.isDown("up") or love.keyboard.isDown("down"))
			then
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
			self.y = self.y + movespeed
			self.state = Player.STATE_WALKDOWN
			if self.scene.map.properties.snow then
				self:makeSnowFootprint(hotspots.left_top.x + 15 + self.snowoffsety * 5, hotspots.left_top.y)
			end
			moving = true
			movingY = true
		elseif not moving then
			local _, spot = next(self.inHidingSpot)
			if not isSwatbot and
			   spot and
			   not spot.noHideDown and
			   self:isFacing("down") and
			   not (love.keyboard.isDown("left") or love.keyboard.isDown("right"))
			then
				self.state = Player.STATE_HIDEDOWN
				self.x = spot.x + self.scene:getTileWidth() + (spot.object.properties.hideOffset or 0) - 7
				self.y = spot.y + spot.sprite.h*2 - self.height - spot.object.height + 16
				self.cinematic = true
				self.hidingDirection = "down"
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
							Parallel {
								Ease(self, "x", self.x - 25, 1, "inout"),
								Ease(self.scene.camPos, "y", -self:peakDistance("down"), 1, "inout")
							},
							Repeat(Action())
						},
						Serial {
							BlockPlayer {
								Parallel {
									Ease(self, "x", self.x, 5, "inout"),
									Ease(self.scene.camPos, "y", 0, 5, "inout")
								},
								Do(function()
									self.cinematic = false
									self.y = self.y - 20
									self.dropShadowOverrideY = nil
									if not next(self.investigators) then
										self.state = Player.STATE_IDLEUP
									end
								end)
							},
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
			self.y = self.y - movespeed
			self.state = Player.STATE_WALKUP
			if self.scene.map.properties.snow then
				self:makeSnowFootprint(hotspots.left_bot.x + 15 + self.snowoffsety * 5, hotspots.left_bot.y)
			end
			moving = true
			movingY = true
		elseif not moving then
			local _, spot = next(self.inHidingSpot)
			if  not isSwatbot and
			    spot and
				self:spacialRelation(hotspots, spot) == "below" and
				self:isFacing("up") and
				not (love.keyboard.isDown("left") or love.keyboard.isDown("right"))
			then
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
	
	-- Swatbot step sounds
	if moving and isSwatbot and love.timer.getTime() - self.lastSwatbotStepSfx > 0.8 then
		self.scene.audio:playSfx("swatbotstep", 1.0)
		self.lastSwatbotStepSfx = love.timer.getTime()
	end
	
	-- Fan sounds?
	local closestFan = nil
	local closestFanDist = nil
	for _, fan in pairs(self.scene.fans or {}) do
		if not closestFan or
		   (not fan.nosound and
		    fan:distanceFromPlayerSq() < closestFanDist)
		then
		    closestFan = fan
			closestFanDist = closestFan:distanceFromPlayerSq()
		end
	end
	
	if closestFan then
		local minAudibleDist = 800
		local maxAudibleDist = 200
		local num = closestFan:distanceFromPlayerSq() - maxAudibleDist*maxAudibleDist
		local denom = (minAudibleDist - maxAudibleDist)*(minAudibleDist - maxAudibleDist)
		local volume = 1.0 - math.min(1.0, math.max(0.0, num) / denom)

		self.scene.audio:setVolumeFor("sfx", "fan", volume)
	end
	
	self.moving = moving
	self.movingX = movingX
	self.movingY = movingY

	if prevState ~= self.state then
		self.sprite.animations[self.state]:reset()
	end
	
	self.sprite:setAnimation(self.state)
end

function Player:updateCollisionObj()
	self.collisionX, self.collisionY = self.scene:worldCoordToCollisionCoord(self.x, self.y)
	return self:updateHotspots()
end

function Player:distanceFromSq(obj)
	local dx = self.x - obj.x
	local dy = self.y - obj.y
	return dx*dx + dy*dy
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

function Player:makeSnowFootprint(x, y)
	if self.snowtime > Player.SNOW_FOOTPRINT_TIME then
		local footprint = BasicNPC(
			self.scene,
			{name = "footprint"},
			{name = "snow", x = x, y = y, width = 12, height = 6,
				properties = {nocollision = true, sprite = "art/sprites/snowfootprint.png", align = NPC.ALIGN_BOTLEFT}
			}
		)
		self.sprite.color = {255,255,255,255}
		footprint.sprite:addSceneHandler("update", function(self, dt)
			if not self.foottime then
				self.foottime = 0
			end
			self.foottime = self.foottime + dt
			if self.foottime > 1 then
				self.color[4] = self.color[4] - 1
				if self.color[4] == 0 then
					self:remove()
				end
			end
		end)
		self.scene:addObject(footprint)
		self.snowtime = 0
		self.snowoffsety = self.snowoffsety * -1
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
	
	local tw = self.scene:getTileWidth()
	local th = self.scene:getTileHeight()
	w = w or tw
	h = h or th
	
	local fuzz = 5
	return (x + w) >= (self.hotspots.left_bot.x - fuzz) and
		x < (self.hotspots.right_bot.x + fuzz) and
		(self.hotspots.left_bot.y + fuzz) >= y and
		(self.hotspots.right_top.y - fuzz) <= (y + math.max(th*2, h/2))
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

function Player:spacialRelation(hotspots, obj)
	local leftdiff = math.abs(obj.x - hotspots.right_top.x)
	local rightdiff = math.abs(hotspots.left_top.x - (obj.x + obj.sprite.w*2))
	local belowdiff = math.abs((obj.y + obj.sprite.h*2) - hotspots.left_top.y)
	local abovediff = math.abs(hotspots.right_bot.y - obj.y)
	
	local result = math.min(leftdiff, rightdiff, belowdiff, abovediff)
	if result == leftdiff then
		return "left"
	elseif result == rightdiff then
		return "right"
	elseif result == belowdiff then
		return "below"
	elseif result == abovediff then
		return "above"
	end
end

function Player:hop()
	return Serial {
		Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - 50 end, 8),
		Ease(self.sprite.transform, "y", function() return self.sprite.transform.y + 50 end, 8)
	}
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
