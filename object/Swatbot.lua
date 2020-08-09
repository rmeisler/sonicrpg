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

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"
local Player = require "object/Player"

local Swatbot = class(NPC)

Swatbot.NOTICE_NONE = 0
Swatbot.NOTICE_SEE  = 1
Swatbot.NOTICE_HEAR = 2

Swatbot.BEHAVIOR_PATROLLING    = 0
Swatbot.BEHAVIOR_INVESTIGATING = 1
Swatbot.BEHAVIOR_CHASING       = 2

function Swatbot:construct(scene, layer, object)	
	self.action = Serial{}
	
	--self.ghost = true
	self.alignment = NPC.ALIGN_BOTLEFT
	self.ignorePlayer = object.properties.ignorePlayer
	self.noInvestigate = object.properties.noInvestigate
	self.noMusic = object.properties.noMusic
	self.visibleDist = object.properties.visibleDistance
	self.audibleDist = object.properties.audibleDistance
	
	self.movespeed = 2
	self.hotspotOffsets = {
		right_top = {x = -20, y = self.sprite.h + 30},
		right_bot = {x = -20, y = 0},
		left_top  = {x = 20, y = self.sprite.h + 30},
		left_bot  = {x = 20, y = 0}
	}
	
	NPC.init(self, true)
	self.collision = {}

	self.facing = "right"
	
	self:createDropShadow()
	
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
	
	self.stepSfx = "swatbotstep"
	
	if GameState:isFlagSet(self:getFlag()) then
		self:removeSceneHandler("update", NPC.update)
		self:remove()
		return
	end
	
	self:addSceneHandler("update", Swatbot.update)
	self:addSceneHandler("exit", Swatbot.exit)
	
	self.isBot = true
end

function Swatbot:exit()
	if self.prevSceneMusic and not self.scene.enteringBattle then
		self.scene.audio:playMusic(self.prevSceneMusic)
	end
end

function Swatbot:postInit()
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

	self.behavior = Swatbot.BEHAVIOR_PATROLLING
end

function Swatbot:followActions()
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
		for _, target in pairs(self.followStack) do
			table.insert(
				actions,
				Serial {
					self:follow(self.scene.objectLookup[target], "walk", 3),
					Do(function()
						self.lastTarget = target
						self.sprite:setAnimation("idle"..self.facing)
					end),
					Wait(2)
				}
			)
		end
		if self.followRepeat then
			return Repeat(Serial(actions))
		else
			return Serial(actions)
		end
	end
	return Action()
end

function Swatbot:getInitiative()
	if self.scene.player:isFacing(self.facing) then
		if ((self.facing == "left"  and self.x < self.scene.player.x) or
		    (self.facing == "right" and self.x > self.scene.player.x) or
		    (self.facing == "up"    and self.y + self.sprite.h*2 > self.scene.player.y + self.scene.player.sprite.h*2) or
		    (self.facing == "down"  and self.y + self.sprite.h*2 < self.scene.player.y + self.scene.player.sprite.h*2))
		then
			return "opponent"
		elseif ((self.facing == "left"  and self.x > self.scene.player.x) or
				(self.facing == "right" and self.x < self.scene.player.x) or
				(self.facing == "up"    and self.y + self.sprite.h*2 < self.scene.player.y + self.scene.player.sprite.h*2) or
				(self.facing == "down"  and self.y + self.sprite.h*2 > self.scene.player.y + self.scene.player.sprite.h*2))
		then
			return "player"
		end
	end

	return nil
end

function Swatbot:distanceFromPlayerSq()
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

function Swatbot:getFlag()
	return string.format(
		"%s.%s",
		self.scene.mapName,
		self.name
	)
end

function Swatbot:update(dt)
	if not self:baseUpdate(dt) then
		return
	end
	
	if not self.friendlyCond or not self.friendlyCond(self) then
		local lineOfSight = self:noticePlayer()
		if lineOfSight == Swatbot.NOTICE_SEE or (lineOfSight == Swatbot.NOTICE_HEAR and self.noInvestigate) then
			self:removeSceneHandler("update")
			self:addSceneHandler("update", Swatbot.updateAction)
			self.sprite:setAnimation("idle"..self.facing)
			self:run {
				self:hop(),
				Do(function()
					self:removeSceneHandler("update", Swatbot.updateAction)
					self:addSceneHandler("update", Swatbot.chaseUpdate)
					self.behavior = Swatbot.BEHAVIOR_CHASING
					self.scene.player.chasers[tostring(self.name)] = self
					if self.scene.audio:getCurrentMusic() ~= "trouble" then
						self.prevSceneMusic = self.scene.audio:getCurrentMusic()
					end
					if not self.scene.enteringBattle and not self.noMusic then
						self.scene.audio:playMusic("trouble", 1.0, true)
					end
				end),
				Wait(1),
				self:follow(self.scene.player, "run", 5, nil, true)
			}
		elseif lineOfSight == Swatbot.NOTICE_HEAR then
			self:removeSceneHandler("update")
			self:addSceneHandler("update", Swatbot.updateAction)
			self.sprite:setAnimation("idle"..self.facing)
			
			-- Slap down a proxy object to move toward
			self.investigateProxy = BasicNPC(
				self.scene,
				{name = "objects"},
				{name = "investigateproxy", x = self.scene.player.x, y = self.scene.player.y, width = 32, height = 32,
					properties = {ghost = true, align = NPC.ALIGN_BOTLEFT}
				}
			)
			self.scene:addObject(self.investigateProxy)
			self:run {
				self:hop(1),
				Do(function()
					self:removeSceneHandler("update", Swatbot.updateAction)
					self:addSceneHandler("update", Swatbot.investigateUpdate)
					self.behavior = Swatbot.BEHAVIOR_INVESTIGATING
					self.scene.player.investigators[tostring(self.name)] = self
				end),
				self:follow(
					self.investigateProxy,
					"lightwalk",
					1,
					3,
					false,
					function()
						local dx = (self.investigateProxy.x - (self.x + self.sprite.w))
						local dy = (self.investigateProxy.y - (self.y + self.sprite.h))
						return (dx*dx + dy*dy) < 20000
					end
				),
				Do(function()
					self.sprite:setAnimation("light"..self.facing)
				end),
				Wait(1.6),
				Do(function()
					self.sprite:setAnimation("idle"..self.facing)
					
					-- Go back to regular patrolling
					self:removeSceneHandler("update", Swatbot.investigateUpdate)
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

function Swatbot:investigateUpdate(dt)
	if not self:baseUpdate(dt) then
		return
	end

	-- Swatbot sees you if he's facing you
	if self:noticePlayer(true) == Swatbot.NOTICE_SEE then
		self:removeSceneHandler("update", Swatbot.investigateUpdate)
		self:addSceneHandler("update", Swatbot.updateAction)
		self.action:stop()
		self.sprite:setAnimation("idle"..self.facing)
		self:run {
			self:hop(),
			Do(function()
				self:removeSceneHandler("update", Swatbot.updateAction)
				self:addSceneHandler("update", Swatbot.chaseUpdate)
				self.behavior = Swatbot.BEHAVIOR_CHASING
				self.scene.player.investigators[tostring(self.name)] = nil
				self.scene.player.chasers[tostring(self.name)] = self
				self.investigateProxy:remove()
				if self.scene.audio:getCurrentMusic() ~= "trouble" then
					self.prevSceneMusic = self.scene.audio:getCurrentMusic()
				end
				if not self.scene.enteringBattle and not self.noMusic then
					self.scene.audio:playMusic("trouble", 1.0, true)
				end
			end),
			Wait(1),
			self:follow(self.scene.player, "run", 5, nil, true)
		}
		return
	end
	
	self.flashlight[self.facing].transform = self:getFlashlightOffset()
	self.flashlight[self.facing].visible = true
	self.flashlight[self.facing]:setAnimation(self.facing)
end

function Swatbot:chaseUpdate(dt)
	self:baseUpdate(dt)
end

function Swatbot:getFlashlightOffset()
	if self.facing == "up" then
		return Transform(self.sprite.transform.x - 3, self.sprite.transform.y - 35, 2, 2)
	elseif self.facing == "down" then
		return Transform(self.sprite.transform.x + 23, self.sprite.transform.y + 106, 2, 2)
	elseif self.facing == "right" then
		return Transform(self.sprite.transform.x + 104, self.sprite.transform.y + 88, 2, 2)
	elseif self.facing == "left" then
		return Transform(self.sprite.transform.x - 208 + 26, self.sprite.transform.y + 90, 2, 2)
	end
end

function Swatbot:hideFlashlight()
	for _, sprite in pairs(self.flashlight) do
		sprite.visible = false
	end
end

function Swatbot:follow(target, animType, speed, timeout, forever, earlyExitFun)
	local moveAction
	if forever then
		moveAction = Repeat(Serial {
			Move(self, target, animType),
			Do(function()
				if self:isRemoved() then
					self.action:stop()
				end
			end)
		})
	else
		moveAction = Move(self, target, animType, timeout, earlyExitFun)
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

function Swatbot:noticePlayer(ignoreShadow)
	local visibleDistance = self.visibleDist or self.noticeDist or 200
	local audibleDistance = self.audibleDist or self.noticeDist or 250
	
	if self.ignorePlayer then
		return Swatbot.NOTICE_NONE
	end
	
	-- If player is hiding then distance is halved
	if self.scene.player:inShadow() and not ignoreShadow then
		visibleDistance = visibleDistance / 6
	end

	local lineOfSight = 0
	if self:distanceFromPlayerSq() < visibleDistance*visibleDistance then
		local isRightOfPlayer = (self.scene.player.x + self.scene.player.sprite.w) < (self.x + self.sprite.w - lineOfSight)
		local isLeftOfPlayer = (self.scene.player.x + self.scene.player.sprite.w) > (self.x + self.sprite.w + lineOfSight)
		local isAbovePlayer = (self.scene.player.y + self.scene.player.sprite.h) > (self.y + self.sprite.h - lineOfSight)
		local isBelowPlayer = (self.scene.player.y + self.scene.player.sprite.h) < (self.y + self.sprite.h - lineOfSight)

		if  self.facing == "right" and isLeftOfPlayer and not self.scene.player:isHiding("left") and
			not ((isAbovePlayer and self.scene.player:isHiding("up")) or
				 (isBelowPlayer and self.scene.player:isHiding("down")))
		then
			return Swatbot.NOTICE_SEE
		elseif  self.facing == "left" and isRightOfPlayer and not self.scene.player:isHiding("right") and
				not ((isAbovePlayer and self.scene.player:isHiding("up")) or
					 (isBelowPlayer and self.scene.player:isHiding("down")))
		then
			return Swatbot.NOTICE_SEE
		elseif  self.facing == "up" and isBelowPlayer and not self.scene.player:isHiding("down") and
				not ((isLeftOfPlayer and self.scene.player:isHiding("left")) or
					 (isRightOfPlayer and self.scene.player:isHiding("right")))
		then
			return Swatbot.NOTICE_SEE
		elseif  self.facing == "down" and isAbovePlayer and not self.scene.player:isHiding("up") and
				not ((isLeftOfPlayer and self.scene.player:isHiding("left")) or
					 (isRightOfPlayer and self.scene.player:isHiding("right")))
		then
			return Swatbot.NOTICE_SEE
		end
	end
	
	if self:distanceFromPlayerSq() < audibleDistance*audibleDistance and (self.hearWithoutMovement or self.scene.player:isMoving()) then
		return Swatbot.NOTICE_HEAR
	end

	return Swatbot.NOTICE_NONE
end

function Swatbot:hop(waitTime)
	local waitAction = Action()
	if waitTime then
		waitAction = Wait(waitTime)
	end
	return Parallel {
		Serial {
			Ease(self, "y", self.y - 50, 8, "linear"),
			Ease(self, "y", self.y, 8, "linear"),
			waitAction
		},
		Do(function()
			self:updateDropShadowPos(true)
		end)
	}
end

function Swatbot:createDropShadow()
	self.dropShadow = BasicNPC(
		self.scene,
		{name = "objects"},
		{name = "dropshadow", x = 0, y = 0, width = 36, height = 6,
			properties = {nocollision = true, sprite = "art/sprites/dropshadow.png", align = NPC.ALIGN_TOPLEFT}
		}
	)
	self.scene:addObject(self.dropShadow)
end

function Swatbot:updateDropShadowPos(xonly)
	self.dropShadow.x = self.x + 18
	
	if not xonly then
		self.dropShadow.y = self.y + self.sprite.h*2 - 14
	end
end

function Swatbot:baseUpdate(dt)
	-- HACK
	if not self.sprite then
		return
	end

	self.state = NPC.STATE_IDLE
	
	-- Recalculate player distance for frame
	self.distanceFromPlayer = nil
	
	-- Don't update if player doesn't exist, we have no sprite, or swatbot is too far away
	-- from the player
	local maxUpdateDistance = self.maxUpdateDistance or 1500
	if self:distanceFromPlayerSq() > maxUpdateDistance*maxUpdateDistance then
		if self.behavior == Swatbot.BEHAVIOR_CHASING then
			-- Go back to regular patrolling
			self:removeSceneHandler("update", Swatbot.chaseUpdate)
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
	
	-- HACK
	if not self.sprite or not self.scene.player then
		return
	end
	
	if self:isFacing("up") then
		self.facing = "up"
	elseif self:isFacing("down") then
		self.facing = "down"
	elseif self:isFacing("left") then
		self.facing = "left"
	elseif self:isFacing("right") then
		self.facing = "right"
	end
	
	-- Update drop shadow position
	self:updateDropShadowPos()
	
	-- Hack
	self:hideFlashlight()
	
	-- If colliding with fall object, fall
	if self.grabbed then
		for _, obj in pairs(self.scene.map.fallables or {}) do
			if  self.x + self.sprite.w*2 > obj.x and
				self.x <= obj.x + obj.width*2 and
				self.y + self.sprite.h*2 > obj.y and
				self.y + self.sprite.h*2 - self.scene:getTileHeight() <= obj.y + obj.height*2
			then
				self:removeAllUpdates()
				self:addSceneHandler("update", Swatbot.updateAction)
				self:drop()
				return false
			end
		end
	end
	
	-- Extender arm logic
	local extenderarm = self.scene.player.extenderarm
	if extenderarm and not self.grabbed and not self.object.properties.noCollideBunnyExt then
		-- Check if we are colliding with Bunny's extender arm
		if  extenderarm.transform.x + extenderarm.w*2 > self.sprite.transform.x + self.sprite.w - 10 and
			extenderarm.transform.x <= self.sprite.transform.x + self.sprite.w*2 - 20 and
			extenderarm.transform.y + extenderarm.h*2 > self.sprite.transform.y + self.sprite.h - 10 and
			extenderarm.transform.y <= self.sprite.transform.y + self.sprite.h + 25
		then
			-- Pause the update
			local extenderUpdate = self.scene.player.basicUpdate
			self.scene.player.basicUpdate = function(self, dt) end

			self.patrol = false
			self.sprite:setAnimation("hurt"..self.facing)
			self:removeAllUpdates()
			self:addSceneHandler("update", Swatbot.updateAction)

			self.scene:run {
				PlayAudio("sfx", "smack", 1.0),
				Do(function()
					self.scene.player.extenderArmColliding = true
					self.scene.player.extenderPull = self
					self.grabbed = true
					
					self:removeSceneHandler("update", Swatbot.updateAction)
					self:addSceneHandler("update")
					
					-- Resume update
					self.scene.player.basicUpdate = extenderUpdate
				end)
			}
		end
	end
	return true
end

function Swatbot:updateAction(dt)
	if not self.action:isDone() then
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
	
	-- Collide for battle, not applicable for sonic when running
	if  not (GameState.leader == "sonic" and self.scene.player.doingSpecialMove) and
		not self.scene.player.falling
	then
		local cx = self.x + 20
		local cy = self.y + self.sprite.h*2 - self.scene:getTileHeight()
		local cx2 = cx + self.scene:getTileWidth()
		if  self.scene.player:isTouching(cx, cy, self.object.width, self.object.height) or
			self.scene.player:isTouching(cx2, cy, self.object.width, self.object.height)
		then
			self.state = NPC.STATE_TOUCHING
			self:invoke("collision")
			self:onCollision()
		end
	end
end

function Swatbot:getBattleArgs()
	local args = NPC.getBattleArgs(self)
	if self.behavior == Swatbot.BEHAVIOR_CHASING then
		args.prevMusic = self.prevSceneMusic
	end
	
	self.flagForDeletion = true
	self.collided = true
	
	args.opponents = {
		self:getMonsterData()
	}
	for _, npc in pairs(self.scene.player.chasers) do
		if npc.name ~= self.name then
			npc.flagForDeletion = true
			npc.collided = true
			table.insert(args.opponents, npc:getMonsterData())
		end
	end
	
	return args
end

function Swatbot:run(actions)
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

function Swatbot:remove()
	self.dropShadow:remove()
	for _, light in pairs(self.flashlight) do
		light:remove()
	end
	
	if self.scene.player then
		self.scene.player.chasers[tostring(self.name)] = nil
		self.scene.player.investigators[tostring(self.name)] = nil
		
		if not next(self.scene.player.chasers) and self.prevSceneMusic then
			self.scene.audio:playMusic(self.prevSceneMusic)
		end
	end

	GameState:setFlag(self:getFlag())
	
	self:removeAllUpdates()

	NPC.remove(self)
end

function Swatbot:removeAllUpdates()
	self:removeSceneHandler("update", Swatbot.investigateUpdate)
	self:removeSceneHandler("update", Swatbot.chaseUpdate)
	self:removeSceneHandler("update", Swatbot.updateAction)
	self:removeSceneHandler("update", Swatbot.update)
end

return Swatbot
