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
	self.hidingSpot = object.properties.hidingspot
	self.movespeed = object.properties.movespeed or 3
	self.disappearOn = object.properties.disappearOn
	
	if object.properties.whileColliding then
		self.whileColliding = assert(loadstring(object.properties.whileColliding))()
	end
	
	if object.properties.onInteract then
		self:addInteract(NPC.onInteract)
	end
	
	self.hotspotOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top  = {x = 0, y = 0},
		left_bot  = {x = 0, y = 0}
	}

	-- TODO: Change this to be a metadata file in some cases, that contains info about image and animations
	local sprite = object.properties.sprite
	if sprite then
		self.sprite = SpriteNode(
		    scene,
			Transform(object.x, object.y, object.properties.scalex or 2, object.properties.scaley or 2),
			{255,255,255, object.properties.alphaOverride or (255 * (self.layer.opacity or 1))},
			sprite:match("art/sprites/(.*)%."),
			nil,
			nil,
			self.layer.name
		)
		self.sprite.sortOrderY = object.properties.sortOrderY
		if self.object.properties.defaultAnim then
			self.sprite:setAnimation(self.object.properties.defaultAnim)
		end
	end
end

function NPC:onInteract()
	self.scene:run(assert(loadstring(self.object.properties.onInteract))()(self))
end

function NPC:onScan()
	local scanAction = assert(loadstring(self.object.properties.onScan))
	if scanAction then
		self.scene:run(scanAction()(self))
	else
		return Action()
	end
end

function NPC:updateCollision()
	self.collision = {}
	
	if not self.object.properties.nocollision then
		local sx,sy = self.scene:worldCoordToCollisionCoord(self.x, self.y)
		local dx,dy = self.scene:worldCoordToCollisionCoord(self.x + self.object.width, self.y + self.object.height)
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
	
	if self.sprite then
		if self.alignment == NPC.ALIGN_TOPLEFT then
			-- No-op
		elseif self.alignment == NPC.ALIGN_TOPRIGHT then
			self.x = self.x + self.sprite.w*2
		elseif self.alignment == NPC.ALIGN_BOTLEFT then
			self.y = self.y - self.sprite.h*2 + self.scene:getTileHeight()
		elseif self.alignment == NPC.ALIGN_BOTCENTER then
			self.x = self.x - self.sprite.w/2
			self.y = self.y - self.sprite.h*2 + self.scene:getTileHeight()
		elseif self.alignment == NPC.ALIGN_BOTRIGHT then
			self.x = self.x + self.sprite.w*2
			self.y = self.y - self.sprite.h*2 + self.scene:getTileHeight()
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
end

function NPC:clone()
	return self.type(self.scene, self.layer, self.object)
end

function NPC:isFacing(direction)
	if not self.sprite or not direction then
		return false
	end
	return string.find(self.sprite.selected, direction) ~= nil
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
	if objProps.battle then
		self.collided = true

		local battleArgs = {}
		if objProps.boss then
			battleArgs.music = "boss"
			battleArgs.bossBattle = true
		end
		
		battleArgs.initiative = self:getInitiative()
		
		local npcArgs = self:getBattleArgs()
		if next(npcArgs) then
			for k, v in pairs(npcArgs) do
				battleArgs[k] = v
			end
		end
	
		action = BlockInput {
			action,
			self.scene:enterBattle(battleArgs),
			Do(function()
				self:onBattleComplete()
			end)
		}
	end
	self.scene:run(action)
end

function NPC:getMonsterData()
	return self.object.properties.battle:match(".*/data/monsters/([%w_]+)%.lua")
end

function NPC:getBattleArgs()
	return {
		opponents = {
			self:getMonsterData()
		}
	}
end

function NPC:onBattleComplete()
	-- noop
end

function NPC:getInitiative()
	return nil
end

function NPC:getFlag()
	return string.format(
		"%s.%s.%d.%d",
		self.scene.mapName,
		self.name,
		self.x,
		self.y
	)
end

function NPC:drop()
	self:removeSceneHandler("update")
	self:run {
		Wait(0.2),
		Parallel {
			Ease(self, "y", self.y + self.sprite.h + 200, 1),
			Ease(self.sprite.color, 4, 0, 1.5)
		},
		Do(function()
			self:remove()
		end)
	}
end

function NPC:update(dt)
	local prevState = self.state
	self.state = NPC.STATE_IDLE
	
	if not self.scene.player then
		return
	end
	
	-- Update hotspots
	if self.sprite then
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
				
				if prevState ~= NPC.STATE_TOUCHING and not self.disabled then
					self.scene.player:showKeyHint(
						self.isInteractable,
						self.specialHintPlayer
					)
					self.scene.player.keyHintObj = tostring(self)
					
					if not self.scene.player.touching then
						self.scene.player.touching = {}
					end
					self.scene.player.touching[tostring(self)] = self
				end
				break
			end
		end
	end
	
	if 	self.state ~= NPC.STATE_TOUCHING and
		self.scene.player.keyHintObj == tostring(self)
	then
		self.scene.player.touching[tostring(self)] = nil
		self.scene.player:removeKeyHint()
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

function NPC:onCollision(prevState)
	if  GameState.leader == "sally" and
		self.scene.player.doingSpecialMove and
		self.sprite
	then
		self.scene.player:scan(self)
	end
	
	if self.whileColliding then
		self.whileColliding(self, self.scene.player)
	end
	
	if self.hidingSpot then
		self.scene.player.inHidingSpot[tostring(self)] = self
	end
end

function NPC:keytriggered(key, uni)
    if  self.scene.player.keyHint and
		self.scene.player.keyHintObj == tostring(self) and
		key == "x"
	then
		self:invoke("interact")
	end
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
	for _, pair in pairs(self.collision or {}) do
		if self.scene.map.collisionMap[pair[2]] then
			self.scene.map.collisionMap[pair[2]][pair[1]] = nil
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
	
	SceneNode.remove(self)
end


return NPC
