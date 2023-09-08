local Player      = require "object/Player"
local BattleMenu  = require "object/BattleMenu"
local SpriteNode  = require "object/SpriteNode"
local TextNode    = require "object/TextNode"
local BattleActor = require "object/BattleActor"
local PartyMember = require "object/PartyMember"
local OpposingPartyMember = require "object/OpposingPartyMember"
local Parallax    = require "object/Parallax"
local Arrow       = require "object/Arrow"

local Rect       = unpack(require "util/Shapes")
local Animation  = require "util/AnAL"
local Transform  = require "util/Transform"
local Gradient   = require "util/Gradient"
local Layout     = require "util/Layout"
local Audio      = require "util/Audio"
local ItemType   = require "util/ItemType"

local Action    = require "actions/Action"
local Executor  = require "actions/Executor"
local Serial    = require "actions/Serial"
local Ease      = require "actions/Ease"
local Parallel  = require "actions/Parallel"
local Do        = require "actions/Do"
local Wait      = require "actions/Wait"
local TypeText  = require "actions/TypeText"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local MessageBox  = require "actions/MessageBox"
local Menu        = require "actions/Menu"
local BlockPlayer = require "actions/BlockPlayer"
local Animate     = require "actions/Animate"
local Repeat      = require "actions/Repeat"

local Scene = require "scene/Scene"

local BattleScene = class(Scene)

BattleScene.STATE_PLAYERTURN           = "playerstart"
BattleScene.STATE_PLAYERTURN_PENDING   = "playerpending"
BattleScene.STATE_PLAYERTURN_COMPLETE  = "playerdone"
BattleScene.STATE_MONSTERTURN          = "monsterstart"
BattleScene.STATE_MONSTERPENDING       = "monsterpending"
BattleScene.STATE_MONSTERTURN_COMPLETE = "monsterdone"

BattleScene.STATE_PLAYERWIN            = "playerwin"
BattleScene.STATE_MONSTERWIN           = "monsterwin"

BattleScene.STATE_CUSTOM               = "custom"

function BattleScene:onEnter(args)
	self:pushLayer("tiles")
	self:pushLayer("behind")
	self:pushLayer("sprites")
	self:pushLayer("infront")
	self:pushLayer("ui")

	self.images = args.images
	self.animations = args.animations
	self.audio = args.audio
	self.bgimg = args.background
	self.nextMusic = args.nextMusic or "battle"
	self.prevMusic = args.prevMusic
	self.blur = args.blur
	self.bossBattle = args.bossBattle
	self.initiative = args.initiative
	self.color = args.color
	self.practice = args.practice
	self.camPos = Transform()
	self.noBattleMusic = args.noBattleMusic
	self.arrowColor = args.arrowColor
	
	local onEnterCallback = args.onEnter or function(scene) return Action() end

	self.mboxGradient = self.images["mboxgradient"]

	self.bgColor = {0,0,0,255}
	
	self.playerSlots = {
		Transform(580,150,2,2),
		Transform(640,210,2,2),
		Transform(580,270,2,2),
		Transform(640,340,2,2),
	}
	self.opponentSlots = {
		Transform(220,150,2,2),
		Transform(220,270,2,2),
		Transform(60,270,2,2),
		Transform(60,150,2,2),
		Transform(140,210,2,2),
	}
	
	self.cachedMonsters = {}
	self.opponents = {}
	self.opponentTurns = {}
	for k,v in pairs(args.opponents) do
		local oppo = self:addMonster(v)
		oppo:onPreInit()
	end
	table.sort(self.opponents, function(a, b) return a.sprite.transform.y < b.sprite.transform.y end)
	
	self.partyByName = {}
	self.party = {}
	self.partyTurns = {}
	self.selectedTarget = 1

	for _,v in pairs(GameState.party) do
		self:addParty(v.id)
	end
	
	self.xpGain = 0
	self.rewards = {}
	
	self.menu = BattleMenu(
		self,
		self.mboxGradient,
		Transform(5, love.graphics.getHeight() - 154),
		self.party,
		self.opponents
	)

	self.initialized = false
	self.state = BattleScene.STATE_PLAYERTURN
	
	local initiativeAction = Action()
	
	-- Initiative modified by Tuning Fork
	if self.initiative == "opponent" and
	   GameState:isEquipped(GameState.leader, ItemType.Accessory, "Tuning Fork")
	then
		self.initiative = nil
	end

	-- Player has initiative by encountering enemy from behind
	if self.initiative == "player" then
		for _, opponent in pairs(self.opponents) do
			opponent.sprite:setAnimation("backward")
		end
		
		-- Double the turns
		for _, mem in pairs(self.party) do
			if mem.state ~= BattleActor.STATE_DEAD and not mem.isHologram then
				table.insert(self.partyTurns, mem)
			end
		end
		for _, mem in pairs(self.party) do
			if mem.state ~= BattleActor.STATE_DEAD and not mem.isHologram then
				table.insert(self.partyTurns, mem)
			end
		end

		if #self.opponents == 1 then
			initiativeAction = Serial {
				MessageBox {
					message=self.opponents[1].name.." was caught off guard!",
					rect=MessageBox.HEADLINER_RECT
				},
				Do(function()
					for _, opponent in pairs(self.opponents) do
						opponent.sprite:setAnimation("backward")
					end
				end)
			}
		else
			initiativeAction = Serial {
				MessageBox {
					message="Bots were caught off guard!",
					rect=MessageBox.HEADLINER_RECT
				},
				Do(function()
					for _, opponent in pairs(self.opponents) do
						opponent.sprite:setAnimation("backward")
					end
				end)
			}
		end
	-- Opponent has initiative by running toward player
	elseif self.initiative == "opponent" then
		for _, player in pairs(self.party) do
			if player.state ~= BattleActor.STATE_DEAD then
				player.sprite:setAnimation("backward")
			end
		end
		for _, oppo in pairs(self.opponents) do
			table.insert(self.opponentTurns, oppo)
		end
		self.state = BattleScene.STATE_MONSTERTURN

		initiativeAction = Serial {
			MessageBox {
				message="You were caught off guard!",
				rect=MessageBox.HEADLINER_RECT
			},
			Do(function()
				for _, player in pairs(self.party) do
					if player.state ~= BattleActor.STATE_DEAD then
						player.sprite:setAnimation("idle")
					end
				end
			end)
		}
	-- Cinematic, opponent gets first turn but its just for cinematic purposes
	elseif self.initiative == "cinematic" then
		for _, oppo in pairs(self.opponents) do
			table.insert(self.opponentTurns, oppo)
		end
		self.state = BattleScene.STATE_MONSTERTURN
	else
		for _, mem in pairs(self.party) do
			if mem.state ~= BattleActor.STATE_DEAD and not mem.isHologram then
				table.insert(self.partyTurns, mem)
			end
		end
	end
	
	self.musicVolume = 1.0
	return Serial {
		PlayAudio("music", self.nextMusic, self.musicVolume, true, true),
		Parallel {
			-- Unblur + fade in
			Ease(self.blur, "radius_h", 0, 2),
			Ease(self.bgColor, 1, 255, 1, "linear"),
			Ease(self.bgColor, 2, 255, 1, "linear"),
			Ease(self.bgColor, 3, 255, 1, "linear"),
			Do(function() ScreenShader:sendColor("multColor", self.bgColor) end),
			
			onEnterCallback(self)
		},
		initiativeAction
	}
end

function BattleScene:endCondition()
	return self.partyHp == 0 or self.monsterHp == 0
end

function BattleScene:onPostEnter()
	self.initialized = true
end

function BattleScene:update(dt)
	Scene.update(self, dt)

	if not self.initialized then
		return
	end
	
	-- Update shadows for monsters
	for _, oppo in pairs(self.opponents) do
		if oppo.dropShadow then
			local sprite = oppo:getSprite()
			oppo.dropShadow.transform.x = sprite.transform.x - sprite.w/2 + 18
		end

		oppo:onUpdate(dt)
	end

	if self.state == BattleScene.STATE_PLAYERTURN then
		-- Resolve against dead players
		self.currentPlayer = table.remove(self.partyTurns, 1)
		while self.currentPlayer and self.currentPlayer.state == BattleActor.STATE_DEAD and next(self.partyTurns) do
			self.currentPlayer = table.remove(self.partyTurns, 1)
		end
		
		if  not self.currentPlayer or
			(self.currentPlayer.state == BattleActor.STATE_DEAD and not next(self.partyTurns))
		then
			local allDead = true
			for _, mem in pairs(self.party) do
				if mem.state ~= BattleActor.STATE_DEAD and not mem.isHologram then
					allDead = false
					break
				end
			end
			if allDead then
				self.state = BattleScene.STATE_MONSTERWIN
			else
				self.state = BattleScene.STATE_MONSTERTURN
			end
			return
		end
		
		-- Fix messed up sfx
		self.audio:stopSfx("choose")
		self.audio:stopSfx("levelup")

		-- Player begin turn
		self.currentPlayer:beginTurn()

		local sprite = self.currentPlayer.sprite
		local playerId = self.currentPlayer.id
		self.topSprite = sprite

		if playerId == "rotor" then
			self.arrow = Arrow(self, Transform.relative(sprite.transform, Transform(0, -sprite.h * 1.3)), self.arrowColor)
		else
			self.arrow = Arrow(self, Transform.relative(sprite.transform, Transform(0, -sprite.h)), self.arrowColor)
		end
		self.state = BattleScene.STATE_PLAYERTURN_PENDING
	elseif self.state == BattleScene.STATE_PLAYERTURN_PENDING then
		local member = self.currentPlayer
		if member:isTurnOver() then
			-- Fix messed up sfx
			self.audio:stopSfx("choose")
			self.audio:stopSfx("levelup")
			self.arrow:remove()
			self.state = BattleScene.STATE_PLAYERTURN_COMPLETE
		end
	elseif self.state == BattleScene.STATE_PLAYERTURN_COMPLETE then
		if self:cleanMonsters() then
			if not next(self.partyTurns) then
				-- Add turns for opponents
				for _, mem in pairs(self.opponents) do
					table.insert(self.opponentTurns, mem)
				end
			
				self.state = BattleScene.STATE_MONSTERTURN
			else
				self.state = BattleScene.STATE_PLAYERTURN
			end
		end
		
	elseif self.state == BattleScene.STATE_MONSTERTURN then
		-- Resolve against dead opponents
		self.currentOpponent = table.remove(self.opponentTurns, 1)
		while (not self.currentOpponent or
			   self.currentOpponent.state == BattleActor.STATE_DEAD) and
			   next(self.opponentTurns)
		do
			self.currentOpponent = table.remove(self.opponentTurns, 1)
		end
		
		if (not self.currentOpponent or
			self.currentOpponent.state == BattleActor.STATE_DEAD) and
			not next(self.opponentTurns)
		then
			self.state = BattleScene.STATE_MONSTERTURN_COMPLETE
			return
		end
		
		self.currentOpponent:beginTurn()
		self.topSprite = self.currentOpponent.sprite
		self.state = BattleScene.STATE_MONSTERTURN_PENDING

	elseif self.state == STATE_MONSTERTURN_PENDING then
		if self.currentOpponent:isTurnOver() then
			self.state = BattleScene.STATE_MONSTERTURN_COMPLETE
		end

	elseif self.state == BattleScene.STATE_MONSTERTURN_COMPLETE then
		if self:cleanMonsters() then
			if not next(self.opponentTurns) then
				-- Add turns for non-dead party members
				for _, mem in pairs(self.party) do
					if mem.state ~= BattleActor.STATE_DEAD and not mem.isHologram then
						table.insert(self.partyTurns, mem)
					elseif mem.extraLives > 0 then
						mem.extraLives = mem.extraLives - 1
						mem.state = BattleActor.STATE_IDLE
						table.insert(self.partyTurns, mem)
					end
				end

				self.state = BattleScene.STATE_PLAYERTURN
			else
				self.state = BattleScene.STATE_MONSTERTURN
			end
		end
		
	elseif self.state == BattleScene.STATE_PLAYERWIN then
		if self.practice then
			self.bgColor = {255,255,255,255}
			
			local victoryPoses = {}
			for _, mem in pairs(self.party) do
				if mem.state == BattleActor.STATE_IDLE then
					table.insert(victoryPoses, Animate(mem.sprite, "victory"))
				end
			end
			self:run {
				-- Fade out current music
				self.noBattleMusic and Action() or Serial {
					AudioFade("music", self.audio:getMusicVolume(), 0, 2),
					PlayAudio("music", "victory", 1.0, true, true)
				},
				
				Parallel(victoryPoses),
				
				MessageBox {
					message="Computer: Well done.",
					rect=MessageBox.HEADLINER_RECT
				},
				
				Do(function()
					self.sceneMgr:popScene{}
				end),
				
				Do(function()
				end)
			}
			self.state = "playerwinpending"
			return
		end
	
		-- Add up spoils of war from each opponent
		local spoilsActions = {}
		if not self.enemyRan then
			for _,reward in pairs(self.rewards) do
				GameState:grantItem(reward.item, reward.count)
				table.insert(
					spoilsActions,
					MessageBox {
						message="Found "..tostring(reward.count).." "..tostring(reward.item.name)..
						(reward.count > 1 and "s" or "").."!",
						rect=MessageBox.HEADLINER_RECT
					}
				)
			end
		end
		table.insert(
			spoilsActions,
			MessageBox {
				message="Gained "..tostring(self.xpGain).." experience!",
				rect=MessageBox.HEADLINER_RECT
			}
		)
		
		-- Update hp + sp + xp on all players
		local victoryAnimActions = {}
		for _,mem in ipairs(self.party) do
			if not mem.isHologram then
				local partyMember = GameState.party[mem.id]
				partyMember.hp = mem.hp
				partyMember.sp = mem.sp
				
				-- Only living players get xp and to do their cool pose at end of battle
				if mem.state ~= BattleActor.STATE_DEAD then
					partyMember.xp = partyMember.xp + self.xpGain
					
					if partyMember.xp >= GameState:calcNextXp(mem.id, partyMember.level) then
						table.insert(
							spoilsActions,
							MessageBox {
								message=mem.name .. " gained a level!",
								rect=MessageBox.HEADLINER_RECT,
								sfx="levelup"
							}
						)
						local messages = GameState:levelup(mem.id)
						
						-- If we learned anything this level, show message for that
						for _, message in pairs(messages) do
							table.insert(
								spoilsActions,
								MessageBox {
									message=message,
									rect=MessageBox.HEADLINER_RECT,
									sfx="levelup"
								}
							)
						end
					end
					table.insert(victoryAnimActions, Animate(mem.sprite, "victory"))
				end
			end
		end
				
		self.bgColor = {255,255,255,255}
		self:run {
			-- Fade out current music
			self.noBattleMusic and Action() or Serial {
				AudioFade("music", self.audio:getMusicVolume(), 0, 2),
				PlayAudio("music", "victory", 1.0, true, true)
			},
			
			-- Play victory
			Parallel {
				Parallel(victoryAnimActions),
				Serial(spoilsActions)
			},
			
			Do(function()
				self.sceneMgr:popScene{}
			end),
			
			Do(function()
			end)
		}
		self.state = "playerwinpending"
	elseif self.state == BattleScene.STATE_MONSTERWIN then
		-- Game over
		self.musicVolume = self.audio:getMusicVolume()
		self.bgColor = {255,255,255,255}
		
		if self.practice then
			self:run {
				AudioFade("music", self.audio:getMusicVolume(), 0, 2),
				PlayAudio("music", "nomore", 1.0, true),
				MessageBox {
					message="Computer: How embarassing for you...",
					rect=MessageBox.HEADLINER_RECT,
					textSpeed = 3
				},
				Do(function()
					self.sceneMgr:popScene{}
				end),
				Do(function()
				end)
			}
		elseif self.noLose then
			self:run {
				AudioFade("music", self.audio:getMusicVolume(), 0, 2),
				PlayAudio("music", "nomore", 1.0, true),
				Do(function() self.opponents[1].sprite:setAnimation("hatlaugh") end),
				MessageBox {
					message="Fleet: How embarassing for you...",
					rect=MessageBox.HEADLINER_RECT,
					textSpeed = 3
				},
				Do(function()
					self.sceneMgr:popScene{hint="lost_fight"}
				end),
				Do(function()
				end)
			}
		else
			-- HACK: For factoryfloor
			self.audio:stopSfx("factoryfloor")
			
			self.sceneMgr:backToTitle()
		end

		self.state = "monsterwinpending"
	end
end

function BattleScene:earlyExit()
	return Serial {
		-- Fade out current music
		self.noBattleMusic and Action() or
			AudioFade("music", self.audio:getMusicVolume(), 0, 2),
		Do(function()
			-- Make sure party hp is reflected back into GameState if you run away...
			for _,mem in ipairs(self.party) do
				local partyMember = GameState.party[mem.id]
				partyMember.hp = mem.hp
				partyMember.sp = mem.sp
			end
			
			self.sceneMgr:popScene{}
		end)
	}
end

function BattleScene:onExit(args)
	if args.toTitle then
		return Serial {
			AudioFade("music", self.audio:getMusicVolume(), 0, 2),
			PlayAudio("music", "nomore", 1.0, true),
			MessageBox {
				message="The Freedom Fighters are no more...",
				rect=MessageBox.HEADLINER_RECT
			},
		
			-- Motion blur + fade to black + fade music
			Parallel {
				Ease(self.blur, "radius_h", 150, 2),
				Ease(self.bgColor, 1, 0, 1, "linear"),
				Ease(self.bgColor, 2, 0, 1, "linear"),
				Ease(self.bgColor, 3, 0, 1, "linear"),
				
				Serial {
					AudioFade("music", self.audio:getMusicVolume(), 0, 2),
					Do(function()
						self.audio:stopMusic("nomore")
					end)
				},
				Do(function()
					ScreenShader:sendColor("multColor", self.bgColor)
				end)
			}
		}
	else
		return Serial {
			-- Motion blur + fade to black + fade music
			Parallel {
				Ease(self.blur, "radius_h", 150, 2),
				Ease(self.bgColor, 1, 0, 1, "linear"),
				Ease(self.bgColor, 2, 0, 1, "linear"),
				Ease(self.bgColor, 3, 0, 1, "linear"),
				Do(function()
					ScreenShader:sendColor("multColor", self.bgColor)
				end),
				
				self.noBattleMusic and Action() or
					AudioFade("music", self.audio:getMusicVolume(), 0, 1)
			},
			
			self.noBattleMusic and Action() or
				PlayAudio("music", self.prevMusic, 1, true, true)
		}
	end
end

function BattleScene:addParty(id)
	-- Ran out of space on game board
	if next(self.playerSlots) == nil then
		return
	end
	
	local slot = table.count(self.party) + 1
	local partyMem = GameState.party[id]
	local mem = table.clone(partyMem)
	mem.sprite = SpriteNode(
		self,
		self.playerSlots[slot],
		{255,255,255,255},
		partyMem.battlesprite
	)
	mem.sprite.transform.ox = mem.sprite.w/2
	mem.sprite.transform.oy = mem.sprite.h/2
	mem.sprite.transform.x = mem.sprite.transform.x + mem.sprite.w
	mem.sprite.transform.y = mem.sprite.transform.y + mem.sprite.h
	mem.playerSlot = slot

	local partyMember = PartyMember(self, mem)
	partyMember:setShadow()
	table.insert(self.party, partyMember)
	self.partyByName[id] = partyMember

	return partyMember
end

function BattleScene:addMonster(monster)
	-- Ran out of space on game board
	if next(self.opponentSlots) == nil then
		return
	end

	if not self.cachedMonsters[monster] then
		self.cachedMonsters[monster] = love.filesystem.load("data/monsters/"..monster..".lua")()
	end
	local monster = self.cachedMonsters[monster]
	local mem = table.clone(monster)

	local slot = table.remove(self.opponentSlots)
	mem.sprite = SpriteNode(self, Transform.from(slot), {255,255,255,255}, monster.sprite)
	mem.sprite.transform.ox = mem.sprite.w/2
	mem.sprite.transform.oy = mem.sprite.h/2
	mem.sprite.transform.x = mem.sprite.transform.x + mem.sprite.w
	mem.sprite.transform.y = mem.sprite.transform.y + mem.sprite.h
	
	local origPosX = mem.sprite.transform.x
	mem.sprite.transform.x = -mem.sprite.w*2
	
	local oppo = OpposingPartyMember(self, mem)
	oppo.slot = slot
	
	-- Monster add animation
	if not mem.skipAnimation then
		Executor(self):act(Serial {
			Ease(mem.sprite.transform, "sx", (origPosX + mem.sprite.w*4)/mem.sprite.w, 7, "log"),
			Parallel {
				Ease(mem.sprite.transform, "sx", 2, 7, "quad"),
				Ease(mem.sprite.transform, "x", origPosX, 7, "quad"),
			},
			Do(function()
				oppo:setShadow(mem.hasDropShadow)
				
				if mem.mockSprite then
					oppo.sprite.visible = false
					oppo.mockSprite = SpriteNode(
						self,
						Transform(mem.sprite.transform.x,mem.sprite.transform.y,2,2),
						{255,255,255,255},
						mem.mockSprite
					)
					oppo.mockSprite.transform.x = oppo.mockSprite.transform.x + mem.mockSpriteOffset.x
					oppo.mockSprite.transform.y = oppo.mockSprite.transform.y + mem.mockSpriteOffset.y					
				end
				
				oppo:onInit()
			end)
		})
	else
		mem.sprite.transform.x = origPosX
		oppo:setShadow(mem.hasDropShadow)
		
		if mem.mockSprite then
			oppo.sprite.visible = false
			oppo.mockSprite = SpriteNode(
				self,
				Transform.from(mem.sprite.transform),
				{255,255,255,255},
				mem.mockSprite
			)
			oppo.mockSprite.transform.x = oppo.mockSprite.transform.x + mem.mockSpriteOffset.x
			oppo.mockSprite.transform.y = oppo.mockSprite.transform.y + mem.mockSpriteOffset.y
		end
		
		oppo:onInit()
	end
	
	table.insert(self.opponents, oppo)
	
	-- Sort by y position, which makes it so our cursor implicitly moves across bots in order of their screen position
	table.sort(
		self.opponents,
		function(a,b)
			return a.sprite.transform.y < b.sprite.transform.y
		end
	)
	
	return oppo
end

function BattleScene:cleanMonsters()
	-- Check if all monsters dead (This can happen due to counter attack or reflection)
	local toremove = {}
	for index,oppo in pairs(self.opponents) do
		if oppo.state == BattleActor.STATE_DEAD or oppo.hp == 0 then
			oppo.state = BattleActor.STATE_DEAD
			self.xpGain = self.xpGain + oppo.stats.xp				
			for _,drop in pairs(oppo.drops) do
				if math.random() < drop.chance then
					table.insert(self.rewards, drop)
				end
			end
			table.insert(toremove, 1, index)
			table.insert(self.opponentSlots, oppo.slot)
			
			self.selectedTarget = 1
		end
	end
	for _,index in pairs(toremove) do
		table.remove(self.opponents, index)
	end
	if next(self.opponents) == nil then
		self.state = BattleScene.STATE_PLAYERWIN
		return false -- Return whether battle should continue
	else
		table.sort(self.opponents, function(a, b) return a.sprite.transform.y < b.sprite.transform.y end)
		return true
	end
end

function BattleScene:keytriggered(key)
    -- Exit game
    if key == "escape" and self.practice then
        if self.showingEscapeMenu then
			return
		end
		self.showingEscapeMenu = true
		
		self:run(BlockPlayer{ Menu {
			layout = Layout {
				{Layout.Text("Leave battle?"), selectable = false},
				{Layout.Text("Yes"), choose = function(menu)
					menu:close()
					self:run {
						menu,
						Do(function() self.sceneMgr:popScene{} end),
						Do(function() end)
					}
				end},
				{Layout.Text("No"),
					choose = function(menu)
						menu:close()
						self:run {
							menu,
							Do(function() self.showingEscapeMenu = false end)
						}
					end},
				colWidth = 200
			},
			transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
			selectedRow = 2,
			cancellable = true
		}})
    end
end

function BattleScene:draw()
	local sceneLayer = self.sceneLookup.sprites
	if self.isScreenShaking then
		for _, node in pairs(sceneLayer.nodes) do
			if not node.transform then
				node.transform = Transform(0,0,1,1)
			end
			node.origXformY = node.transform.y
			node.transform.y = node.transform.y + self.camPos.y
		end
	end

	if self.blur then
		self.blur(function()
			love.graphics.setDefaultFilter("nearest", "nearest")
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw(self.bgimg, 0, self.camPos.y)
		
			self:sortedDraw("behind")
			self:sortedDraw("sprites")
			self:sortedDraw("infront")
			Scene.draw(self, "ui")
		end)
	else
		love.graphics.setDefaultFilter("nearest", "nearest")
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(self.bgimg, 0, self.camPos.y)
		
		self:sortedDraw("behind")
		self:sortedDraw("sprites")
		self:sortedDraw("infront")
		Scene.draw(self, "ui")
	end
	
	if self.isScreenShaking then
		for _, node in pairs(sceneLayer.nodes) do
			node.transform.y = node.origXformY
		end
	end
	
	--[[
	-- Debug code for showing enemy collision (for things like Sonic "Slam" skill)
	for _,oppo in pairs(self.opponents) do
		love.graphics.circle("line", oppo.sprite.transform.x, oppo.sprite.transform.y, 32)
	end
	]]
end

-- Vertical screen shake
function BattleScene:screenShake(str, sp, rp)
	local strength = str or 50
	local speed = sp or 15
	local repeatTimes = rp or 1
	
	return Serial {
		Do(function()
			self.isScreenShaking = true
		end),
		
		Repeat(Serial {
			Ease(self.camPos, "y", function() return self.camPos.y - strength end, speed, "quad"),
			Ease(self.camPos, "y", function() return self.camPos.y + strength end, speed, "quad")
		}, repeatTimes),
		
		Ease(self.camPos, "y", function() return self.camPos.y - strength/2 end, speed, "quad"),
		Ease(self.camPos, "y", function() return self.camPos.y + strength/2 end, speed, "quad"),
		
		Do(function()
			self.isScreenShaking = false
			self.camPos.y = 0
		end)
	}
end


return BattleScene