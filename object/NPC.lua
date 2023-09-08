local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local BlockInput = require "actions/BlockInput"
local While = require "actions/While"
local Move = require "actions/Move"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"
local Executor = require "actions/Executor"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local SceneNode = require "object/SceneNode"

local NPC = class(SceneNode)

NPC.STATE_TOUCHING = "touching"
NPC.STATE_IDLE     = "idle"

NPC.COLLISION_FUZZ = 2

NPC.ALIGN_DEFAULT = "default" -- Sort of centered
NPC.ALIGN_TOPLEFT = "top_left"
NPC.ALIGN_TOPRIGHT = "top_right"
NPC.ALIGN_BOTLEFT = "bottom_left"
NPC.ALIGN_BOTRIGHT = "bottom_right"
NPC.ALIGN_BOTCENTER = "bottom_center"

function NPC:construct(scene, layer, object)
	self.state = NPC.STATE_IDLE
	
	self.appearAfter = object.properties.appearAfter
	self.showOn = object.properties.showOn
	self.ghost = object.properties.ghost or false
	self.alignment = object.properties.align or NPC.ALIGN_DEFAULT
	
	self.x = object.x
	self.y = object.y
	self.name = object.name
	self.object = object
	self.layer = layer

	self.specialHintPlayer = object.properties.specialHint
	self.showHint = object.properties.showHint
	self.hidingSpot = object.properties.hidingspot
	self.noHideDown = object.properties.nohidedown
	self.movespeed = object.properties.movespeed or 3
	self.disappearOn = object.properties.disappearOn
	self.disappearOnFlag = object.properties.disappearOnFlag
	self.angle = (object.properties.angle or 0) * (math.pi/180)
	self.isBot = object.properties.isBot
	self.destructable = object.properties.destructable
	
	if object.properties.onInit then
		self.onInit = assert(loadstring(object.properties.onInit))()
	end

	if object.properties.onRotorTrap then
		self.onRotorTrap = assert(loadstring(object.properties.onRotorTrap))()
	end

	if object.properties.onPostInit then
		self.onPostInit = assert(loadstring(object.properties.onPostInit))()
	end
	
	if object.properties.whileColliding then
		self.whileColliding = assert(loadstring(object.properties.whileColliding))()
	end
	
	if object.properties.notColliding then
		self.notColliding = assert(loadstring(object.properties.notColliding))()
	end
	
	if object.properties.onUpdate then
		self.onUpdate = assert(loadstring(object.properties.onUpdate))()
	end
	
	if object.properties.onRemove then
		self.onRemove = assert(loadstring(object.properties.onRemove))()
	end
	
	if object.properties.usableBy then
		self.specialHintPlayer = object.properties.usableBy
		--[[
		local usableBy = pack((object.properties.usableBy):split(','))
		self.usableBy = {}
		for _, v in pairs(usableBy) do
			self.usableBy[v] = v
		end
		]]
	end

	if object.properties.onInteract then
		self:addInteract(NPC.onInteract)
	end
	
	self.hidden = object.properties.hidden
	
	self.hotspotOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = 0},
		left_bot  = {x = 0, y = 0}
	}

	-- TODO: Change this to be a metadata file in some cases, that contains info about image and animations
	local sprite = object.properties.sprite
	if sprite then
		local alpha = object.properties.alphaOverride or (255 * (self.layer.opacity or 1))
		self.sprite = SpriteNode(
		    scene,
			Transform(object.x, object.y, object.properties.scalex or 2, object.properties.scaley or 2),
			{255,255,255, alpha},
			sprite:match("art/sprites/(.*)%."),
			nil,
			nil,
			self.layer.name
		)
		if self.hidden then
			self.sprite.visible = false
		end
		self.sprite.sortOrderY = object.properties.sortOrderY
		if self.object.properties.defaultAnim then
			self.sprite:setAnimation(self.object.properties.defaultAnim)
		end
		if self.angle > 0 or self.angle < 0 then
			self.sprite.transform.ox = self.sprite.w/2
			self.sprite.transform.oy = self.sprite.h/2
			self.x = self.x + self.sprite.w
			self.y = self.y + self.sprite.h
			self.sprite.transform.angle = self.angle
		end
		
		if  self.scene.nighttime and
		    not self.scene.map.properties.ignorenight and
			object.properties.nonight
		then
			self.sprite.drawWithNight = false
			if object.properties.bright then
				self.sprite.color = {512, 512, 512, alpha}
			elseif not object.properties.nightbright then
				self.sprite.color = {150, 150, 150, alpha}
			end
		end
	end
end

function NPC:onInteract()
	self.scene.player.hidekeyhints[tostring(self)] = self
	self.scene:run(assert(loadstring(self.object.properties.onInteract))()(self))
end

function NPC:onScan()
	if self.object.properties.onScan then
		local scanAction = assert(loadstring(self.object.properties.onScan))
		if scanAction then
			self.scene:run(scanAction()(self))
		end
	end
	return Action()
end

function NPC:distanceFromPlayerSq(ignoreCache)
	if not self.scene.player then
		return 0
	end

	if ignoreCache or not self.distanceFromPlayer then
		local w = self.sprite and self.sprite.w or self.object.width/2
		local h = self.sprite and self.sprite.h or self.object.height/2
		local dx = (self.scene.player.x - (self.x + w))
		local dy = (self.scene.player.y - (self.y + h))
		self.distanceFromPlayer = (dx*dx + dy*dy)
	end
	return self.distanceFromPlayer
end

function NPC:updateCollision()
	self.collision = {}
    if self.scene.map.properties.layered and
	   self.scene.currentLayer ~= self.layer.name and
	   self.layer.name ~= "all"
	then
		return
	end

	if not self.object.properties.nocollision then
		local sx,sy = self.scene:worldCoordToCollisionCoord(self.object.x, self.object.y)
		local dx,dy = self.scene:worldCoordToCollisionCoord(self.object.x + self.object.width, self.object.y + self.object.height)
		for y=sy, dy-1 do
			for x=sx, dx-1 do
				if not self.ghost then
					self.scene.map.collisionMap[y][x] = 1
				end
				table.insert(self.collision, {x,y})
			end
		end
	end
end

function NPC:onPuzzleSolve()
	if self.object.properties.onPuzzleSolve then
		local puzzleSolveFun = assert(loadstring(self.object.properties.onPuzzleSolve))()
		if puzzleSolveFun then
			return puzzleSolveFun(self)
		end
	end
	return Action()
end

function NPC:removeCollision()
	for _, pair in pairs(self.collision or {}) do
		if self.scene.map.collisionMap[pair[2]] then
			self.scene.map.collisionMap[pair[2]][pair[1]] = nil
		end
	end
	self.collision = {}
end

function NPC:init(useBaseUpdate)
	if self.sprite then
		self.sprite.color[4] = self.object.properties.alphaOverride or (255 * (self.layer.opacity or 1))
	end
	
	self:updateCollision()
	
	if self.object.properties.msg then
		self:addHandler(
			"interact",
			NPC.messageBox,
			self,
			self.object
		)
	end
	
	if self.sprite and not self.object.properties.useObjectCollision then
		if self.alignment == NPC.ALIGN_TOPLEFT then
			-- No-op
		elseif self.alignment == NPC.ALIGN_TOPRIGHT then
			self.x = self.x + self.sprite.w*2
		elseif self.alignment == NPC.ALIGN_BOTLEFT then
			self.y = self.y - self.sprite.h*2 + self.object.height
		elseif self.alignment == NPC.ALIGN_BOTCENTER then
			self.x = self.x - self.sprite.w/2
			self.y = self.y - self.sprite.h*2 + self.object.height
		elseif self.alignment == NPC.ALIGN_BOTRIGHT then
			self.x = self.x + self.sprite.w*2
			self.y = self.y - self.sprite.h*2 + self.object.height
		end
		self.x = self.x + (self.object.properties.alignOffsetX or 0)
		self.y = self.y + (self.object.properties.alignOffsetY or 0)
		
		self.hotspots = {
			right_top = {},
			right_bot = {},
			left_top  = {},
			left_bot  = {}
		}
		self.hotspots.right_top.x = self.x + self.sprite.w*2 + self.hotspotOffsets.right_top.x
		self.hotspots.right_top.y = self.y + self.hotspotOffsets.right_top.y
		self.hotspots.right_bot.x = self.x + self.sprite.w*2 + self.hotspotOffsets.right_bot.x
		self.hotspots.right_bot.y = self.y + self.sprite.h*2 + self.hotspotOffsets.right_bot.y
		self.hotspots.left_top.x = self.x + self.hotspotOffsets.left_top.x
		self.hotspots.left_top.y = self.y + self.hotspotOffsets.left_top.y
		self.hotspots.left_bot.x = self.x + self.hotspotOffsets.left_bot.x
		self.hotspots.left_bot.y = self.y + self.sprite.h*2 + self.hotspotOffsets.left_bot.y
	else
		self.hotspots = {
			right_top = {x = self.x + self.object.width, y = self.y},
			right_bot = {x = self.x + self.object.width, y = self.y + self.object.height},
			left_top  = {x = self.x, y = self.y},
			left_bot  = {x = self.x, y = self.y + self.object.height}
		}
	end
	
	if self.object.properties.battleOnCollide then
		self:addHandler(
			"collision",
			NPC.messageBox,
			self,
			self.object
		)
	end
	
	if self.onInit then
		self.onInit(self)
		
		if self:isRemoved() then
			return
		end
	end
	
	if (self.isBot or self.disappearOnFlag) and GameState:isFlagSet(self:getFlag()) then
		self:remove()
		return
	end
	
	self.followStack = {}
	if self.object.properties.follow then
		self.followStack = pack((self.object.properties.follow):split(','))
	end
	self.followRepeat = self.object.properties.followRepeat
	
    self:addSceneHandler("keytriggered")
	self:addSceneHandler("update", useBaseUpdate and NPC.update)
end

function NPC:postInit()
	local actions = self.object.properties.actions
	if actions then
		local fun = assert(loadstring(actions))
		self:run(fun()(self))
	end
	
	if self.showOn then
		self:remove()
		GameState:onSetFlag(
			self.scene.objectLookup[self.showOn],
			function()
				local new = self:clone()
				self.scene:addObject(new)
			end
		)
	end
	
	if self.appearAfter then
		self:remove()
		local obj = self.scene.objectLookup[self.appearAfter]
		local removeFn = obj.remove
		obj.remove = function()
			local new = self:clone()
			self.scene:addObject(new)
			removeFn(obj)
		end
	end
	
	if self.onPostInit then
		self.onPostInit(self)
	end
end

function NPC:clone()
	return self.type(self.scene, self.layer, self.object)
end

function NPC:isFacing(direction)
	if self.manualFacing then
		return self.manualFacing == direction
	end
	if not self.sprite or not direction then
		return false
	end
	return string.find(self.sprite.selected, direction) ~= nil
end

function NPC:facePlayer()
	local player = self.scene.player
	local dx = self.x + self.sprite.w/2 - player.x
    local dy = self.y + self.sprite.h/2 - player.y

    if math.abs(dx) < math.abs(dy) then
        if dy < 0 then
            self.sprite:setAnimation("idledown")
        else
            self.sprite:setAnimation("idleup")
        end
    else
        if dx < 0 then
            self.sprite:setAnimation("idleright")
        else
            self.sprite:setAnimation("idleleft")
        end
    end
end

function NPC:messageBox()
	if self.collided then
		return
	end
	
	local objProps = self.object.properties
	local action = Serial{}
	
	local msg = objProps.msg or ""
	local messages = {msg:split(';')}
	for _,message in pairs(messages) do
		action:add(self.scene, MessageBox {message=message, blocking=true})
	end
	if objProps.battle and not self.falling then
		self.collided = true

		local battleArgs = {}
		if objProps.boss then
			battleArgs.music = "boss"
			battleArgs.bossBattle = true
		end
		
		battleArgs.initiative = self:getInitiative()
		battleArgs.flags = {self:getFlag()}
		
		local npcArgs = self:getBattleArgs()
		if next(npcArgs) then
			for k, v in pairs(npcArgs) do
				battleArgs[k] = v
			end
		end
	
		action = BlockInput {
			action,
			Do(function()
				self:onBattleComplete(battleArgs)
			end),
			self.scene:enterBattle(battleArgs),
			Do(function()
				for _,piece in pairs(self.scene.player.extenderPieces or {}) do
					piece:remove()
				end
				if self.scene.player.extenderarm then
					self.scene.player.extenderarm:remove()
				end
				self.scene.player.extenderPieces = {}
			end)
		}
	end
	self.scene:run(action)
end

function NPC:getMonsterData()
	return self.object.properties.battle:match(".*/data/monsters/([%w_]+)%.lua")
end

function NPC:getBattleArgs()
	self.flagForDeletion = true
	return {
		opponents = {
			self:getMonsterData()
		},
		flags = {
			self:getFlag()
		}
	}
end

function NPC:onBattleComplete(args)
	for _, flag in pairs(args.flags) do
		print("Setting flag "..flag)
		GameState:setFlag(flag)
	end
end

function NPC:permanentRemove()
	GameState:setFlag(self:getFlag())
	self:remove()
	self.scene.player.keyhints[tostring(self)] = nil
	self.scene.player.hidekeyhints[tostring(self)] = nil
	self.scene.player.touching[tostring(self)] = nil
end

function NPC:getInitiative()
	return self.object.properties.battleInitiative
end

function NPC:getFlag()
    if self.object.properties.flagOverride then
	    return self.object.properties.flagOverride
	else
		return string.format(
			"%s.%s.%d.%d",
			self.scene.mapName,
			self.name,
			self.x,
			self.y
		)
	end
end

function NPC:drop()
	self:removeCollision()
	self:run {
		Wait(0.2),
		Parallel {
			Ease(self, "y", self.y + 400, 1),
			Ease(self.sprite.color, 4, 0, 1),
			
			Serial {
				Wait(0.05),
				Do(function()
					self.sprite:swapLayer("under")
					self.dropShadow.sprite:swapLayer("under")
				end)
			}
		},
		Do(function()
			self:remove()
		end)
	}
end

function NPC:walk(to, speed, walkAnim, stopAnim)
	return Serial {
		Do(function()
			self.sprite:setAnimation(walkAnim)
		end),
		Parallel {
			Ease(self, "x", to.x, speed, "linear"),
			Ease(self, "y", to.y, speed, "linear")
		},
		Do(function()
			self.sprite:setAnimation(stopAnim)
			self.object.x = self.x
			self.object.y = self.y
			self:updateCollision()
		end)
	}
end

function NPC:hop()
	return Serial {
		Ease(self, "y", function() return self.y - 50 end, 8),
		Ease(self, "y", function() return self.y + 50 end, 8)
	}
end

function NPC:update(dt)
	local prevState = self.state
	self.state = NPC.STATE_IDLE
	
	if self.sprite then
		self.sprite.visible = not self.hidden
	end

	if not self.scene.player or self.hidden then
		return
	end
	
	if self.onUpdate then
		self.onUpdate(self, dt)
	end
	
	-- Update hotspots
	if self.sprite and not self.useObjectCollision then
		self.hotspots.right_top.x = self.x + self.sprite.w*2 + self.hotspotOffsets.right_top.x
		self.hotspots.right_top.y = self.y + self.hotspotOffsets.right_top.y
		self.hotspots.right_bot.x = self.x + self.sprite.w*2 + self.hotspotOffsets.right_bot.x
		self.hotspots.right_bot.y = self.y + self.sprite.h*2 + self.hotspotOffsets.right_bot.y
		self.hotspots.left_top.x = self.x + self.hotspotOffsets.left_top.x
		self.hotspots.left_top.y = self.y + self.hotspotOffsets.left_top.y
		self.hotspots.left_bot.x = self.x + self.hotspotOffsets.left_bot.x
		self.hotspots.left_bot.y = self.y + self.sprite.h*2 + self.hotspotOffsets.left_bot.y
	else
		self.hotspots.right_top.x = self.x + self.object.width + self.hotspotOffsets.right_top.x
		self.hotspots.right_top.y = self.y + self.hotspotOffsets.right_top.y
		self.hotspots.right_bot.x = self.x + self.object.width + self.hotspotOffsets.right_bot.x
		self.hotspots.right_bot.y = self.y + self.object.height + self.hotspotOffsets.right_bot.y
		self.hotspots.left_top.x = self.x + self.hotspotOffsets.left_top.x
		self.hotspots.left_top.y = self.y + self.hotspotOffsets.left_top.y
		self.hotspots.left_bot.x = self.x + self.hotspotOffsets.left_bot.x
		self.hotspots.left_bot.y = self.y + self.object.height + self.hotspotOffsets.left_bot.y
	end
	
	if self.hidingSpot then
		self.scene.player.inHidingSpot[tostring(self)] = nil
		self.scene.player.keyhints[tostring(self)] = self
	end
	
	if 	self.disappearOn and
		self.scene.objectLookup[self.disappearOn] and
		GameState:isFlagSet(self.scene.objectLookup[self.disappearOn])
	then
		self:removeSceneHandler("update")
		local easeAction = self.sprite and Ease(self.sprite.color, 4, 0, 5) or Action()
		self:run {
			easeAction,
			Do(function()
				self:remove()
			end)
		}
		return
	end

	-- Don't interact with player if player doesn't care about your layer
	if (self.scene.player.onlyInteractWithLayer ~= nil and
		self.scene.player.onlyInteractWithLayer ~= self.layer.name) and
		self.layer.name ~= "all"
	then
		return
	end

	for _,coord in ipairs(self.collision) do
		-- Separating axis-theorem
		local x = self.scene.player.collisionX
		local y = self.scene.player.collisionY
		
		-- Loosely touching
		if math.abs(x - coord[1]) + math.abs(y - coord[2]) <= NPC.COLLISION_FUZZ then
			-- More specific check
			local cx, cy = self.scene:collisionCoordToWorldCoord(coord[1], coord[2])
			if self.scene.player:isTouching(cx, cy, self.object.width, self.object.height) then
				self.state = NPC.STATE_TOUCHING
				self:invoke("collision", prevState)
				self:onCollision(prevState)
				
				if  prevState ~= NPC.STATE_TOUCHING and
					not self.disabled and
					self.scene.player:isFacingObj(self)
				then
					if self.isInteractable or self.specialHintPlayer then
						self.scene.player.keyhints[tostring(self)] = self
					end

					if not self.scene.player.touching then
						self.scene.player.touching = {}
					end
					self.scene.player.touching[tostring(self)] = self
				end
				break
			end
		end
	end
	
	if self.state ~= NPC.STATE_TOUCHING then
		if self.notColliding then
			self.notColliding(self, self.scene.player)
		end

		self.scene.player.keyhints[tostring(self)] = nil
		self.scene.player.hidekeyhints[tostring(self)] = nil
		self.scene.player.touching[tostring(self)] = nil
	end
end

function NPC:isTouching(x, y, w, h)
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

function NPC:isTouchingObj(obj)
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

function NPC:addInteract(fun)
	self:addHandler("interact", fun, self)
	self.isInteractable = true
end

function NPC:removeInteract(fun)
	self:removeHandler("interact", fun, self)
	self.isInteractable = false
end

function NPC:onCollision(prevState)
	if  GameState.leader == "sally" and
		self.scene.player.doingSpecialMove and
		self.sprite
	then
		self.scene.player:scan(self)
	end
	
	if self.whileColliding then
		self.whileColliding(self, self.scene.player, prevState)
	end
	
	if self.hidingSpot then
		self.scene.player.inHidingSpot[tostring(self)] = self
	end
end

function NPC:keytriggered(key, uni)
	if not self.scene.player then
		return
	end
    if  tostring(self.scene.player.curKeyHint) == tostring(self) and
		self.isInteractable and
		(not self.specialHintPlayer or string.find(self.specialHintPlayer, GameState.leader)) and
		key == "x"
	then
		self.scene.player.hidekeyhints[tostring(self)] = self
		self:invoke("interact")
	end
end

function NPC:refreshKeyHint()
	self.scene.player.hidekeyhints[tostring(self)] = nil
end

function NPC:draw()
	-- draw collision
	love.graphics.setColor(255,255,255,255)
	
	--local worldOffsetX = -self.scene.player.x + love.graphics.getWidth()/2
	--local worldOffsetY = -self.scene.player.y + love.graphics.getHeight()/2
	for _,coord in ipairs(self.collision) do
		love.graphics.rectangle("fill", coord[1] % love.graphics.getWidth(), coord[2] % love.graphics.getHeight(), 32, 32)
	end
end

function NPC:run(action)
	if not action.type then
		action = Serial(action)
	end
	self.curAction = action
	Executor(self.scene):act(action)
end

function NPC:remove()
	-- Remove from collision map
	if not self.ghost and not self.object.properties.ghost then
		for _, pair in pairs(self.collision or {}) do
			if self.scene.map.collisionMap[pair[2]] then
				self.scene.map.collisionMap[pair[2]][pair[1]] = nil
			end
		end
	end
	
	if self.scene.player then
		self.scene.player.touching[tostring(self)] = nil
		self.scene.player:removeKeyHint()
	end
	
	-- Causes bugs in display?...
	--self.scene:removeObject(self)
	
	if self.sprite then
		self.sprite:remove()
		self.sprite = nil
	end
	
	if self.onRemove then
		self.onRemove(self)
	end
	
	SceneNode.remove(self)
end


return NPC
