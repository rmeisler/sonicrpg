local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial" 
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Move = require "actions/Move"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local MoveStep = require "actions/MoveStep"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"
local Player = require "object/Player"

local bfs = require "util/bfs"

local Bot = class(NPC)

Bot.NOTICE_NONE = 0
Bot.NOTICE_SEE  = 1
Bot.NOTICE_HEAR = 2

Bot.BEHAVIOR_PATROLLING    = 0
Bot.BEHAVIOR_INVESTIGATING = 1
Bot.BEHAVIOR_CHASING       = 2

function Bot:construct(scene, layer, object)	
	self.action = Serial{}
	
	self.ghost = true
	self.alignment = NPC.ALIGN_BOTLEFT
	self.ignorePlayer = object.properties.ignorePlayer
	self.noInvestigate = object.properties.noInvestigate
	self.noMusic = object.properties.noMusic
	self.visibleDist = object.properties.visibleDistance
	self.audibleDist = object.properties.audibleDistance
	self.noSetFlag = object.properties.noSetFlag
	self.removeAfterFollow = object.properties.removeAfterFollow
	self.noPushAway = object.properties.noPushAway
	self.disabled = object.properties.disabled

	self.manualFacingTime = 0
	self.movespeed = 2
	self.walkspeed = 3
	self.investigatespeed = 1
	self.runspeed = 5
	self.hotspotOffsets = {
		right_top = {x = -20, y = self.sprite.h + 30},
		right_bot = {x = -20, y = 0},
		left_top  = {x = 20, y = self.sprite.h + 30},
		left_bot  = {x = 20, y = 0}
	}

	--self:updateFacing()
	self.manualFacing = "down"
	self.originalFacing = self.manualFacing

	if not object.properties.noDropShadow then
		self:createDropShadow()
	end

	self.udflashlight = SpriteNode(
		self.scene,
		Transform(),
		nil,
		"flashlightupdown",
		nil,
		nil,
		"objects"
	)
	self.lrflashlight = SpriteNode(
		self.scene,
		Transform(),
		nil,
		"flashlightleftright",
		nil,
		nil,
		"objects"
	)
	self.udflashlight.visible = false
	self.lrflashlight.visible = false
	self.udflashlight.color[4] = 150
	self.lrflashlight.color[4] = 150
	
	self.flashlight = {
		up = self.udflashlight,
		down = self.udflashlight,
		right = self.lrflashlight,
		left = self.lrflashlight
	}
	
	if object.properties.noflashlight then
		self.flashlight.up:remove()
		self.flashlight.down:remove()
		self.flashlight.left:remove()
		self.flashlight.right:remove()
	end
	
	self.stepSfx = nil
	
	if GameState:isFlagSet(self:getFlag()) then
		self:removeSceneHandler("update", NPC.update)
		self:remove()
		return
	end
	
	self.originalX = self.x
	self.originalY = self.y

	self.originalLocation = BasicNPC(
		self.scene,
		{name = "objects"},
		{name = "botloc", x = self.x, y = self.y, width = 32, height = 32,
			properties = {ghost = true, align = NPC.ALIGN_BOTLEFT}
		}
	)
	self.scene:addObject(self.originalLocation)
	
	self:addSceneHandler("update", Bot.update)
	self:addSceneHandler("exit", Bot.exit)
	self:addCollisionHandler()

	self.isBot = true
end

function Bot:addCollisionHandler()
	self:addHandler(
		"collision",
		NPC.messageBox,
		self,
		self.object
	)
end

function Bot:removeCollisionHandler()
	self:removeHandler(
		"collision",
		NPC.messageBox,
		self,
		self.object
	)
end

function Bot:exit()
	if self.prevSceneMusic and not self.scene.enteringBattle then
		self.scene.audio:playMusic(self.prevSceneMusic)
	end

	if self.shocked then
		return
	end

	-- Go back to regular patrolling
	if not self:isRemoved() then
		self:removeAllUpdates()
		self:addSceneHandler("update")
		self:postInit()
		self.scene.player.chasers[tostring(self.name)] = nil
	end
end

function Bot:postInit()
	if self:isRemoved() then
		return
	end

	self:run(self:followActions())

	if self.object.properties.ignoreCollision then
		self.ignoreCollision = {}
		for _, ignore in pairs(pack((self.object.properties.ignoreCollision):split(','))) do
			for _, loc in pairs(self.scene.objectLookup[ignore].collision) do
				local x, y = loc[1], loc[2]
				if not self.ignoreCollision[y] then
					self.ignoreCollision[y] = {}
				end
				self.ignoreCollision[y][x] = 1
			end
		end
	end

	self.behavior = Bot.BEHAVIOR_PATROLLING
	
	if self.object.properties.viewRange then
		self.viewRanges = {}
		for _, view in pairs(pack((self.object.properties.viewRange):split(','))) do
			table.insert(self.viewRanges, self.scene.objectLookup[view])
		end
	end
	
	if not self.object.properties.novisualcolliders and not self.visualColliders then
		self.visualColliders = {}
		self.visualColliders.left = BasicNPC(
			self.scene,
			{name = "objects"},
			{name = "visualproxy", x = self.x - 32 * 8, y = self.y + self.sprite.h, width = 32 * 8, height = 32 * 5,
				properties = {ghost = true, align = NPC.ALIGN_BOTLEFT, sprite = "art/sprites/leftrightview.png", useObjectCollision = true}
			}
		)
		self.visualColliders.right = BasicNPC(
			self.scene,
			{name = "objects"},
			{name = "visualproxy", x = self.x + self.sprite.w*2, y = self.y + self.sprite.h, width = 32 * 8, height = 32 * 5,
				properties = {ghost = true, align = NPC.ALIGN_BOTLEFT, sprite = "art/sprites/leftrightview.png", useObjectCollision = true}
			}
		)
		self.visualColliders.up = BasicNPC(
			self.scene,
			{name = "objects"},
			{name = "visualproxy", x = self.x, y = self.y - 32 * 8, width = 32 * 5, height = 32 * 8,
				properties = {ghost = true, align = NPC.ALIGN_BOTLEFT, sprite = "art/sprites/updownview.png", useObjectCollision = true}
			}
		)
		self.visualColliders.down = BasicNPC(
			self.scene,
			{name = "objects"},
			{name = "visualproxy", x = self.x, y = self.y + self.sprite.h*2, width = 32 * 5, height = 32 * 8,
				properties = {ghost = true, align = NPC.ALIGN_BOTLEFT, sprite = "art/sprites/updownview.png", useObjectCollision = true}
			}
		)
		self.scene:addObject(self.visualColliders.left)
		self.scene:addObject(self.visualColliders.right)
		self.scene:addObject(self.visualColliders.up)
		self.scene:addObject(self.visualColliders.down)

		self.visualColliders.left.sprite.visible = false
		self.visualColliders.right.sprite.visible = false
		self.visualColliders.up.sprite.visible = false
		self.visualColliders.down.sprite.visible = false
		
		self.visualColliders.left.hidden = true
		self.visualColliders.right.hidden = true
		self.visualColliders.up.hidden = true
		self.visualColliders.down.hidden = true
	end
end

function Bot:followActions()
	if self.followStack and next(self.followStack) then
		local closestTarget = self.lastTarget
		if not closestTarget then
			-- First sort our follow stack and move toward the closest waypoint
			local closest = table.clone(self.followStack)
			table.sort(
				closest,
				function(a,b)
					local targetA = self.scene.objectLookup[a]
					local targetB = self.scene.objectLookup[b]
					return  math.abs(targetA.x - self.x) < math.abs(targetB.x - self.x) and
							math.abs(targetA.y - self.y) < math.abs(targetB.y - self.y)
				end
			)
			closestTarget = closest[1]
		end
		
		-- Rotate follow stack based on closest node
		while self.followStack[1] ~= closestTarget do
			local target = table.remove(self.followStack, 1)
			table.insert(self.followStack, target)
		end
		
		local actions = {}
		for index, target in pairs(self.followStack) do
			if self.removeAfterFollow and index == #self.followStack then
				table.insert(
					actions,
					Serial {
						self:follow(self.scene.objectLookup[target], "walk", self.walkspeed),
						Do(function() self:remove() end)
					}
				)
			else
				table.insert(
					actions,
					Serial {
						self:follow(self.scene.objectLookup[target], "walk", self.walkspeed),
						Do(function()
							self.lastTarget = target
							self.sprite:setAnimation("idle"..self.manualFacing)
						end),
						Wait(2)
					}
				)
			end
		end
		if self.followRepeat then
			return Repeat(Serial(actions))
		else
			return Serial(actions)
		end
	else
		return Serial {
			self:follow(self.originalLocation, "walk", self.walkspeed),
			Do(function()
				if self.originalFacing then
					self.sprite:setAnimation("idle"..self.originalFacing)
				end
			end),
			Wait(2)
		}
	end
end

function Bot:getInitiative()
	if self.scene.player:isFacing(self.manualFacing) then
		if ((self.manualFacing == "left"  and self.x > (self.scene.player.x + self.scene.player.sprite.w)) or
		    (self.manualFacing == "right" and (self.x + self.sprite.w*2) < (self.scene.player.x - self.scene.player.sprite.w)) or
		    (self.manualFacing == "up"    and self.y > (self.scene.player.y + self.scene.player.sprite.h)) or
		    (self.manualFacing == "down"  and (self.y + self.sprite.h*2) < (self.scene.player.y - self.scene.player.sprite.h)))
		then
			return "opponent"
		elseif ((self.manualFacing == "left"  and (self.x + self.sprite.w*2) < (self.scene.player.x - self.scene.player.sprite.w)) or
				(self.manualFacing == "right" and self.x > (self.scene.player.x + self.scene.player.sprite.w)) or
				(self.manualFacing == "up"    and (self.y + self.sprite.h*2) > (self.scene.player.y - self.scene.player.sprite.h)) or
				(self.manualFacing == "down"  and self.y < (self.scene.player.y + self.scene.player.sprite.h)))
		then
			return "player"
		end
	end

	return nil
end

function Bot:distanceFromPlayerSq()
	if not self.scene.player then
		return 0
	end

	if not self.distanceFromPlayer then
		local dx = (self.scene.player.x - (self.x + self.sprite.w))
		local dy = (self.scene.player.y - (self.y + self.sprite.h))
		self.distanceFromPlayer = (dx*dx + dy*dy)
	end
	return self.distanceFromPlayer
end

function Bot:getFlag()
	return string.format(
		"%s.%s",
		self.scene.mapName,
		self.name
	)
end

function Bot:update(dt)
	if self:isRemoved() then
		self:removeSceneHandler("update")
	end

	if not self:baseUpdate(dt) then
		return
	end

	-- Don't interact with player if player doesn't care about your layer
	if (self.scene.player.onlyInteractWithLayer ~= nil and
		self.scene.player.onlyInteractWithLayer ~= self.layer.name) and
		self.layer.name ~= "all"
	then
		return
	end

	if not self.friendlyCond or not self.friendlyCond(self) then
		if self.viewRanges then
			local touching = false
			for _, v in pairs(self.viewRanges) do
				if v.state == NPC.STATE_TOUCHING and
				   self:isTouching(v.x, v.y, v.object.width, v.object.height)
				then
					print("is touching view range "..v.object.name)
					touching = true
					break
				end
			end
			if not touching then
				return
			end
		end

		local lineOfSight = self:noticePlayer(false)
		if self.noInvestigate then
			self:removeSceneHandler("update")
			self:addSceneHandler("update", Bot.updateAction)
			self.sprite:setAnimation("idle"..self.manualFacing)
			self:run {
				self:hop(),
				Do(function()
					self:removeSceneHandler("update", Bot.updateAction)
					self:addSceneHandler("update", Bot.chaseUpdate)
					self.behavior = Bot.BEHAVIOR_CHASING
					self.scene.player.chasers[tostring(self.name)] = self
					if self.scene.audio:getCurrentMusic() ~= "trouble" then
						self.prevSceneMusic = self.scene.audio:getCurrentMusic()
					end
					if not self.scene.enteringBattle and not self.noMusic then
						self.scene.audio:playMusic("trouble", 1.0, true)
					end
					self.scene.player:invoke("caught", self)
				end),
				Wait(1),
				self:follow(self.scene.player, "run", self.runspeed, nil, true, function() return self.grabbed end)
			}
		elseif lineOfSight == Bot.NOTICE_HEAR or lineOfSight == Bot.NOTICE_SEE then
			self:removeSceneHandler("update")
			self:addSceneHandler("update", Bot.updateAction)
			self.sprite:setAnimation("idle"..self.manualFacing)
			self.visibleDist = self.visibleDist or 200
			
			-- Slap down a proxy object to move toward
			self.investigateProxy = BasicNPC(
				self.scene,
				{name = "objects"},
				{name = "investigateproxy", x = self.scene.player.x, y = self.scene.player.y, width = 64, height = 64,
					properties = {ghost = true, align = NPC.ALIGN_BOTLEFT}
				}
			)
			self.scene:addObject(self.investigateProxy)
			
			self:run {
				self:hop(1),
				Do(function()					
					self:removeSceneHandler("update", Bot.updateAction)
					self:addSceneHandler("update", Bot.investigateUpdate)
					self.behavior = Bot.BEHAVIOR_INVESTIGATING
					self.scene.player.investigators[tostring(self.name)] = self
					
					self.investigateProxy.x = self.scene.player.x
					self.investigateProxy.y = self.scene.player.y + self.scene.player.sprite.h
				end),
				self:follow(
					self.investigateProxy,
					"lightwalk",
					self.investigatespeed,
					5,
					false,
					function()
						local dx = (self.investigateProxy.x - (self.x + self.sprite.w))
						local dy = (self.investigateProxy.y - (self.y + self.sprite.h))
						return (dx*dx + dy*dy) < 20000
					end
				),
				Do(function()
					self.sprite:setAnimation("light"..self.manualFacing)
				end),
				self:getWaitAfterInvestigate(),
				Do(function()
					self.sprite:setAnimation("idle"..self.manualFacing)
					
					-- Go back to regular patrolling
					self:removeSceneHandler("update", Bot.investigateUpdate)
					self:addSceneHandler("update")
					self:postInit()
					self.scene.player.investigators[tostring(self.name)] = nil
					self.investigateProxy:remove()
				end),
				self:followActions()
			}
		end
	end
end

function Bot:getWaitAfterInvestigate()
	return Wait(1.6)
end

function Bot:investigateUpdate(dt)
	if not self:baseUpdate(dt) then
		return
	end
	
	if self.viewRange and self.viewRange.state ~= NPC.STATE_TOUCHING then
		return
	end

	-- Bot sees you if he's facing you
	if self:noticePlayer(true) == Bot.NOTICE_SEE then
		self:onCaughtPlayer()
		return
	end

	local facing = self.manualFacing
	self.flashlight[facing].transform = self:getFlashlightOffset()
	self.flashlight[facing].visible = true
	self.flashlight[facing]:setAnimation(facing)
end

function Bot:onCaughtPlayer()
	self:removeSceneHandler("update", Bot.investigateUpdate)
	self:addSceneHandler("update", Bot.updateAction)
	self.action:stop()
	self.sprite:setAnimation("idle"..self.manualFacing)
	self:run {
		self:hop(),
		Do(function()
			self:removeSceneHandler("update", Bot.updateAction)
			self:addSceneHandler("update", Bot.chaseUpdate)
			self.behavior = Bot.BEHAVIOR_CHASING
			self.scene.player.investigators[tostring(self.name)] = nil
			self.scene.player.chasers[tostring(self.name)] = self
			self.investigateProxy:remove()
			if self.scene.audio:getCurrentMusic() ~= "trouble" then
				self.prevSceneMusic = self.scene.audio:getCurrentMusic()
			end
			if not self.scene.enteringBattle and not self.noMusic then
				self.scene.audio:playMusic("trouble", 1.0, true)
			end
			self.scene.player:invoke("caught", self)
		end),
		Wait(1),
		self:follow(self.scene.player, "run", self.runspeed, nil, true, function() return self.grabbed end)
	}
end

function Bot:chaseUpdate(dt)
	self:baseUpdate(dt)

	if self.printplayerpos == nil or self.printplayerpos == 0 then
		print ("player = "..tostring(self.scene.player.x)..", "..tostring(self.scene.player.y))
		self.printplayerpos = 10
	end
	self.printplayerpos = self.printplayerpos - 1

	if not self.noPushAway then
		-- If other bots are too close, push them away
		for _, object in pairs(self.scene.map.objects) do
			if object.isBot and
				not object:isRemoved() and
				object.name ~= self.name and
				not object.shocked
			then
				local dx = self.x - object.x
				local dy = self.y - object.y
				local sqdist = dx*dx + dy*dy
				if sqdist < 10*10 then
					if self.x > object.x then
						self.x = self.x + self.movespeed * (dt/0.016)
					else
						self.x = self.x - self.movespeed * (dt/0.016)
					end
					if self.y > object.y then
						self.y = self.y + self.movespeed * (dt/0.016)
					else
						self.y = self.y - self.movespeed * (dt/0.016)
					end
				end
			end
		end
	end

	self.lastx = self.x
	self.lasty = self.y
end

function Bot:getFlashlightOffset()
	local facing = self.manualFacing
	if facing == "up" then
		return Transform(self.sprite.transform.x - 3, self.sprite.transform.y - 35, 2, 2)
	elseif facing == "down" then
		return Transform(self.sprite.transform.x + 23, self.sprite.transform.y + 106, 2, 2)
	elseif facing == "right" then
		return Transform(self.sprite.transform.x + 104, self.sprite.transform.y + 88, 2, 2)
	elseif facing == "left" then
		return Transform(self.sprite.transform.x - 208 + 26, self.sprite.transform.y + 90, 2, 2)
	end
end

function Bot:hideFlashlight()
	for _, sprite in pairs(self.flashlight) do
		sprite.visible = false
	end
end

function Bot:chasePlayer()
	local cx, cy = self.scene:worldCoordToCollisionCoord(self.x, self.y)
	local px, py = self.scene:worldCoordToCollisionCoord(self.scene.player.x, self.scene.player.y)
	local collisionMap = self.scene.collisionLayer[self.layer.name]
	local path = bfs(collisionMap, cx, cy, px, py)

	local earlyExitFun = function() return self.grabbed end
	local actions = {}
	for _, p in ipairs(path) do
		local pathx, pathy = self.scene:collisionCoordToWorldCoord(p[1], p[2])
		print("collision coord = "..tostring(p[1])..", "..tostring(p[2]).."; world coord = "..tostring(pathx)..", "..tostring(pathy))
		table.insert(actions, 1, Move(self, Move.targetFromPos(pathx, pathy), "run", nil, earlyExitFun))
	end
	table.insert(actions, 1,
		Do(function()
			-- set run speed
			self.movespeed = self.runspeed
			self.object.properties.ignoreMapCollision = true
			print "ignore map collision"
		end))
	table.insert(actions,
		Do(function(parent)
			print "made it here"
			self.object.properties.ignoreMapCollision = false
			if not earlyExitFun() then
				parent:add(self.scene, self:chasePlayer())
			end
		end))
	return Serial(actions)
end

function Bot:follow(target, animType, speed, timeout, forever, earlyExitFun)
	local moveAction
	if forever then
		moveAction = While(
			function()
				return not earlyExitFun()
			end,
			Repeat(Serial {
				Move(self, target, animType, nil, earlyExitFun, true),
				Do(function()
					if self:isRemoved() then
						self.action:stop()
					end
				end)
			}),
			Do(function() end)
		)
	else
		moveAction = Move(self, target, animType, timeout, earlyExitFun, true)
	end

	if self.stepSfx then
		local minStepDelay = 0.07
		local maxStepDelay = 0.23
		local maxSpeed = 4
		local minSpeed = 1
		local minAudibleDist = 1000
		local maxAudibleDist = 200

		speed = math.max(minSpeed, math.min(maxSpeed, speed))

		local stepDelay = maxStepDelay - (maxStepDelay - minStepDelay) * ((speed - minSpeed) / (maxSpeed - minSpeed))
		return Serial {
			-- Set walk speed
			Do(function()
				self.movespeed = speed or self.movespeed
			end),
			Parallel {
				-- Adjust volume of steps based on distance from player
				Do(function()
					local num = self:distanceFromPlayerSq() - maxAudibleDist*maxAudibleDist
					local denom = (minAudibleDist - maxAudibleDist)*(minAudibleDist - maxAudibleDist)
					local volume = 1.0 - math.min(1.0, math.max(0.0, num) / denom)
					self.scene.audio:setVolumeFor("sfx", self.stepSfx, volume)
				end),
				
				-- Step sfx
				Repeat(Serial {
					PlayAudio("sfx", self.stepSfx, nil, false, false, true),
					Wait(stepDelay)
				}, nil, false),
				
				-- Movement
				moveAction
			}
		}
	else
		return Serial {
			-- Set walk speed
			Do(function()
				self.movespeed = speed or self.movespeed
			end),

			-- Movement
			moveAction	
		}
	end
end

function Bot:noticePlayer(ignoreShadow)
	local visibleDistance = self.visibleDist or self.noticeDist or 300
	local audibleDistance = self.audibleDist or self.noticeDist or 250
	
	if self.forceSee then
		return Bot.NOTICE_SEE
	end
	
	if self.ignorePlayer then
		return Bot.NOTICE_NONE
	end
 
	-- If player is hiding then distance is halved
	if self.scene.player:inShadow() and not ignoreShadow then
		visibleDistance = visibleDistance / 6
	end

	if self:distanceFromPlayerSq() < visibleDistance*visibleDistance then
		local isRightOfPlayer = (self.scene.player.x + self.scene.player.sprite.w) < self.x
		local isLeftOfPlayer = self.scene.player.x > (self.x + self.sprite.w)
		local isAbovePlayer = (self.scene.player.y + self.scene.player.sprite.h) > (self.y + self.sprite.h*2)
		local isBelowPlayer = (self.scene.player.y + self.scene.player.sprite.h) < (self.y + self.sprite.h*2)
		
		if  self.manualFacing == "right" and isLeftOfPlayer and not self.scene.player:isHiding("left") and
			not ((isAbovePlayer and self.scene.player:isHiding("up")) or
				 (isBelowPlayer and self.scene.player:isHiding("down")))
		then
			return Bot.NOTICE_SEE
		elseif  self.manualFacing == "left" and isRightOfPlayer and not self.scene.player:isHiding("right") and
				not ((isAbovePlayer and self.scene.player:isHiding("up")) or
					 (isBelowPlayer and self.scene.player:isHiding("down")))
		then
			return Bot.NOTICE_SEE
		elseif  self.manualFacing == "up" and isBelowPlayer and not self.scene.player:isHiding("down") and
				not ((isLeftOfPlayer and self.scene.player:isHiding("left")) or
					 (isRightOfPlayer and self.scene.player:isHiding("right")))
		then
			return Bot.NOTICE_SEE
		elseif  self.manualFacing == "down" and isAbovePlayer and not self.scene.player:isHiding("up") and
				not ((isLeftOfPlayer and self.scene.player:isHiding("left")) or
					 (isRightOfPlayer and self.scene.player:isHiding("right")))
		then
			return Bot.NOTICE_SEE
		end
	end
	
	if self:distanceFromPlayerSq() < audibleDistance*audibleDistance and (self.hearWithoutMovement or self.scene.player:isMoving()) then
		return Bot.NOTICE_HEAR
	end

	return Bot.NOTICE_NONE
end

function Bot:hop(waitTime)
	local waitAction = Action()
	if waitTime then
		waitAction = Wait(waitTime)
	end
	self.hopping = true
	return Parallel {
		Serial {
			Ease(self, "y", self.y - 50, 8, "linear"),
			Ease(self, "y", self.y, 8, "linear"),
			waitAction
		},
		Do(function()
			self:updateDropShadowPos(true)
			self.hopping = false
		end)
	}
end

function Bot:createDropShadow()
	self.dropShadow = BasicNPC(
		self.scene,
		{name = "objects"},
		{name = "dropshadow", x = 0, y = 0, width = 36, height = 6,
			properties = {nocollision = true, sprite = "art/sprites/dropshadow.png", align = NPC.ALIGN_TOPLEFT}
		}
	)
	self.scene:addObject(self.dropShadow)
end
--[[
function Bot:updateFacing()
	if self:isFacing("up") and self.manualFacing ~= "up" then
		self.manualFacing = "up"
		self.manualFacingTime = 0
	elseif self:isFacing("down") and self.manualFacing ~= "down" then
		self.manualFacing = "down"
		self.manualFacingTime = 0
	elseif self:isFacing("left") and self.manualFacing ~= "left" then
		self.manualFacing = "left"
		self.manualFacingTime = 0
	elseif self:isFacing("right") and self.manualFacing ~= "right" then
		self.manualFacing = "right"
		self.manualFacingTime = 0
	else
		self.manualFacing = "down"
	end
end]]

function Bot:updateDropShadowPos(xonly)
	if not self.dropShadow then
		return
	end
	self.dropShadow.x = self.x + 18
	
	if not xonly then
		self.dropShadow.y = self.y + self.sprite.h*2 - 14
	end
end

function Bot:baseUpdate(dt)
	-- HACK
	if not self.sprite then
		return
	end

	self.state = NPC.STATE_IDLE
	
	-- Recalculate player distance for frame
	self.distanceFromPlayer = nil
	
	-- Don't update if player doesn't exist, we have no sprite, or Bot is too far away
	-- from the player
	local maxUpdateDistance = self.maxUpdateDistance or 1500
	if self:distanceFromPlayerSq() > maxUpdateDistance*maxUpdateDistance then
		if self.behavior == Bot.BEHAVIOR_CHASING then
			-- Go back to regular patrolling
			self:removeSceneHandler("update", Bot.chaseUpdate)
			self:addSceneHandler("update")
			self:postInit()
			self.scene.player.chasers[tostring(self.name)] = nil

			self.scene:run {
				AudioFade("music", 1.0, 0.0, 2, "linear"),
				PlayAudio("music", self.prevSceneMusic, 0.0, true, true),
				AudioFade("music", 0.0, 1.0, 2, "linear")
			}
		end
		return false
	end
	
	-- Update drop shadow position
	self:updateDropShadowPos()
	
	if not self.scene:playerMovable() or self.disabled then
		return false
	end
	
	self:updateAction(dt)

	if not self.hopping then
		self.object.x = self.x
		self.object.y = self.y + self.sprite.h*2
		self:updateCollision()
	end

	-- HACK
	if not self.sprite or not self.scene.player then
		return
	end
	
	self.manualFacingTime = self.manualFacingTime + dt
	
	if self.visualColliders then
		self.visualColliders.up.x = self.x + math.max(self.sprite.w*2 - self.visualColliders.up.sprite.w*3, 0)
		self.visualColliders.up.y = self.y - 32 * 8 + self.sprite.h*2 - 32
		self.visualColliders.down.x = self.x + math.max(self.sprite.w*2 - self.visualColliders.down.sprite.w*3, 0)
		self.visualColliders.down.y = self.y + self.sprite.h*2
		self.visualColliders.left.x = self.x - 32 * 8
		self.visualColliders.left.y = self.y + self.sprite.h
		self.visualColliders.right.x = self.x + self.sprite.w*2
		self.visualColliders.right.y = self.y + self.sprite.h
	end
	
	--self:updateFacing()
	
	-- Update drop shadow position
	self:updateDropShadowPos()
	
	-- Hack
	self:hideFlashlight()
	
	-- Extender arm logic
	local extenderarm = self.scene.player.extenderarm
	if extenderarm and not self.grabbed and not self.object.properties.noCollideBunnyExt and
		self:distanceFromPlayerSq() > 10000
	then
		-- Check if we are colliding with Bunny's extender arm
		if  extenderarm.transform.x + extenderarm.w*2 > self.sprite.transform.x + self.sprite.w - 10 and
			extenderarm.transform.x <= self.sprite.transform.x + self.sprite.w*2 - 20 and
			extenderarm.transform.y + extenderarm.h*2 > self.sprite.transform.y + self.sprite.h - 10 and
			extenderarm.transform.y <= self.sprite.transform.y + self.sprite.h*2 - 30
		then
			-- Pause the update
			local extenderUpdate = self.scene.player.basicUpdate
			self.scene.player.basicUpdate = function(self, dt) end

			self.patrol = false
			self.sprite:setAnimation("hurt"..self.manualFacing)
			self:removeAllUpdates()
			self:addSceneHandler("update", Bot.updateAction)
			self.scene.player.chasers[tostring(self.name)] = nil

			self.grabbed = true
			self.scene.player.extenderArmColliding = self
			self.scene.player.extenderPull = self

			self.scene:run {
				PlayAudio("sfx", "smack", 1.0),
				Do(function()
					self:removeAllUpdates()
					self:addSceneHandler("update")
					self.readyToFall = true

					-- Resume update
					self.scene.player.basicUpdate = extenderUpdate
				end)
			}
		end
	end

	return true
end

function Bot:updateAction(dt)
	if (not self.grabbed or self.falling) and
		not self.action:isDone()
	then
		self.action:update(dt)

		if self.action:isDone() then
			self.action:cleanup(self)
			self.action = Serial{}
		end
	end

	-- HACK
	if not self.sprite or not self.scene.player then
		return
	end
	
	if self.grabbed or self.falling then
		-- Update drop shadow position
		self:updateDropShadowPos()
	end
	
	-- If colliding with fall object, fall
	if self.readyToFall and not self.falling then
		for _, obj in pairs(self.scene.map.fallables or {}) do
			if  self.x + self.sprite.w*2 > obj.x and
				self.x <= obj.x + obj.width*2 and
				self.y + self.sprite.h*2 > obj.y and
				self.y + self.sprite.h*2 - self.scene:getTileHeight() <= obj.y + obj.height*2
			then
				self.falling = true
				self:removeAllUpdates()
				self:addSceneHandler("update", Bot.updateAction)
				self:drop()
				return
			end
		end
	end
	
	-- Collide for battle, not applicable for sonic when running
	if  not (self.scene.player.doingSpecialMove and
			(GameState.leader == "sonic" or GameState.leader == "bunny")) and
		not self.scene.player.falling and not self.scene.ignorePlayer
	then
		if (self.scene.player.onlyInteractWithLayer ~= nil and
			self.scene.player.onlyInteractWithLayer ~= self.layer.name) and
			self.layer.name ~= "all"
		then
			return
		end

		local cx = self.hotspots.left_top.x
		local cy = self.hotspots.left_top.y
		local cw = self.hotspots.right_top.x - cx
		local ch = self.hotspots.right_bot.y - cy

		if  self.scene.player:isTouching(cx, cy, cw, ch) then
			self.scene.audio:stopSfx(self.stepSfx)
			self.state = NPC.STATE_TOUCHING
			self:invoke("collision")
			self:onCollision()
		end
	end
end

function Bot:getBattleArgs()
	local args = NPC.getBattleArgs(self)
	if self.behavior == Bot.BEHAVIOR_CHASING then
		args.prevMusic = self.prevSceneMusic
	end
	
	self.flagForDeletion = true
	self.collided = true
	
	args.opponents = {
		self:getMonsterData()
	}
	for _, npc in pairs(self.scene.player.chasers) do
		if npc.name ~= self.name and not npc:isRemoved() and not npc.falling then
			npc.flagForDeletion = true
			npc.collided = true
			table.insert(args.opponents, npc:getMonsterData())
			table.insert(args.flags, npc:getFlag())
		end
	end
	
	return args
end

function Bot:run(actions)
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

function Bot:remove()
	if self:isRemoved() then
		return
	end

	if self.dropShadow then
		self.dropShadow:remove()
	end
	for _, light in pairs(self.flashlight) do
		light:remove()
	end
	if self.originalLocation then
		self.originalLocation:remove()
	end
	
	if self.scene.player then
		self.scene.player.chasers[tostring(self.name)] = nil
		self.scene.player.investigators[tostring(self.name)] = nil
		
		if  not next(self.scene.player.chasers) and
			self.prevSceneMusic and
			not self.scene.enteringBattle
		then
			self.scene.audio:playMusic(self.prevSceneMusic)
		end
	end

	self:removeAllUpdates()

	NPC.remove(self)
end

function Bot:removeAllUpdates(exceptActions)
	self:removeSceneHandler("update", Bot.investigateUpdate)
	self:removeSceneHandler("update", Bot.chaseUpdate)
	self:removeSceneHandler("update", Bot.update)
	if not exceptActions then
		self:removeSceneHandler("update", Bot.updateAction)
	end
end

function Bot:disableBot()
	self:removeAllUpdates(true)
end

function Bot:enableBot()
	self:removeSceneHandler("update", Bot.updateAction)
	self:addSceneHandler("update")
end

function Bot:restart()
    self.behavior = Bot.BEHAVIOR_PATROLLING
	self:addSceneHandler("update")
	self:postInit()
end


return Bot
