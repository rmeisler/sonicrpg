local Menu = require "actions/Menu"
local BouncyText = require "actions/BouncyText"
local Rect = unpack(require "util/Shapes")
local Transform = require "util/Transform"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Shake = require "actions/Shake"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"
local Spawn = require "actions/Spawn"
local Do = require "actions/Do"
local Lazy = require "util/Lazy"
local MessageBox = require "actions/MessageBox"
local SpriteNode = require "object/SpriteNode"

local TargetType = require "util/TargetType"

local Telegraph = require "data/monsters/actions/Telegraph"

local BattleActor = require "object/BattleActor"

local OpposingPartyMember = class(BattleActor)

function OpposingPartyMember:construct(scene, data)
	self.scene = scene
	self.transform = transform
	self.playerSlot = data.playerSlot
	self.sprite = data.sprite
	self.lostTurns = 0
	self.malfunctioningTurns = 0
	self.state = BattleActor.STATE_IDLE

	self.name = data.altName or ""
	self.stats = data.stats
	self.flying = data.flying
	self.run_chance = data.run_chance or 1.0
	self.drops = data.drops
	self.hp = data.stats.maxhp
	self.maxhp = data.stats.maxhp
	self.maxsp = 999 -- just to prevent issues
	self.scan = data.scan
	self.insult = data.insult
	self.hpBarOffset = data.hpBarOffset or Transform(0,0)
	self.hurtSfx = data.hurtSfx or "smack"
	self.behavior = data.behavior or function() end
	self.onDead = data.onDead or function() return Action() end
	self.onEnter = data.onEnter or function() return Action() end
	self.onPreInit = data.onPreInit or function() end
	self.onInit = data.onInit or function() end
	self.onUpdate = data.onUpdate or function(self, dt) end
	self.onScan = data.onScan or nil
	self.onConfused = data.onConfused or nil
	self.onTease = data.onTease or nil
	self.getHpStats = data.getHpStats or function(self) return self.hp, self.maxhp end
	self.getIdleAnim = data.getIdleAnim or function(_self) return "idle" end
	self.getBackwardAnim = data.getBackwardAnim or function(_self) return "backward" end
	self.onAttack = data.onAttack
	self.onBeforeAttack = data.onBeforeAttack
	self.textOffset = data.textOffset or Transform(0, self:getSprite().h/2 - 15)
	self.color = data.color or {255,255,255,255}
	self.boss = data.boss
	self.bossPart = data.boss_part
	self.aerial = data.aerial
	self.targetOverrideStack = {}
	
	self.sprite.color = self.color
	
	self.side = TargetType.Opponent
end

function OpposingPartyMember:setShadow(visible)
	local sprite = self:getSprite()
	self.dropShadow = SpriteNode(
		self.scene,
		Transform(sprite.transform.x - sprite.w/2 + 18, sprite.transform.y + sprite.h - 14, 2, 2),
		nil,
		"dropshadow"
	)
	self.dropShadow.sortOrderY = -1
	self.dropShadow.visible = visible
end

function OpposingPartyMember:beginTurn()
	-- Choose a target
	self.selectedTarget = math.random(#self.scene.party)
	
	-- If current target is dead, choose another
	local iterations = 1
	while self.scene.party[self.selectedTarget].state == BattleActor.STATE_DEAD do
		self.selectedTarget = (self.selectedTarget % #self.scene.party) + 1
		iterations = iterations + 1
		if iterations > #self.scene.party then
			print "this be broken"
			return
		end
	end
	
	local sprite = self:getSprite()
	local target
	
	local additionalActions = {}
	
	-- Choose action based on current state
	if self.state == BattleActor.STATE_IMMOBILIZED then
		-- Shake left and right
		local shake = Repeat(Serial {
			Do(function()
				self.scene.audio:playSfx("bang")
			end),

			Ease(
				sprite.transform,
				"x",
				sprite.transform.x + 7,
				10
			),
			Ease(
				sprite.transform,
				"x",
				sprite.transform.x - 7,
				10
			),
			Ease(
				sprite.transform,
				"x",
				sprite.transform.x + 3,
				10
			),
			Ease(
				sprite.transform,
				"x",
				sprite.transform.x - 3,
				10
			),
			Ease(
				sprite.transform,
				"x",
				sprite.transform.x,
				10
			),
			
			Wait(0.5)
		}, 2)
		
		if not self.chanceToEscape then
			self.chanceToEscape = 0.2
		else
			self.chanceToEscape = self.chanceToEscape * 2
		end
		
		if math.random() > self.chanceToEscape then
			self.action = Serial {
				shake,
				Telegraph(self, self.name.." is immobilized!", {self.color[1],self.color[2],self.color[3],50}),
			}
		else
			-- If the immobilizer is bunny...
			if self.immobilizedBy == "bunny" then
				self.immobilizedBy = nil
				-- Retract bunny ext arm and linkages and go back to idle anim
				self.action = Serial {
					shake,
					
					Do(function()
						if self.prevAnim == "backward" or not self.prevAnim then
							self.prevAnim = "idle"
						end
						sprite:setAnimation(self.prevAnim)
						self.state = BattleActor.STATE_IDLE
						self.chanceToEscape = nil
						
						self:invoke("escape")
					end),
					
					self.scene.partyByName.bunny.reverseAnimation,
					
					Telegraph(self, self.name.." broke free!", {self.color[1],self.color[2],self.color[3],50}),
				}
			else
				self.action = Serial {
					shake,
					
					Do(function()
						if self.prevAnim == "backward" or not self.prevAnim then
							self.prevAnim = "idle"
						end
						sprite:setAnimation(self.prevAnim)
						self.state = BattleActor.STATE_IDLE
						self.chanceToEscape = nil
						
						self:invoke("escape")
					end),
					
					Telegraph(self, self.name.." broke free!", {self.color[1],self.color[2],self.color[3],50}),
				}
			end
		end
	elseif self.confused then
		self.selectedTarget = math.random(#self.scene.opponents)
		self.action = Serial {
			Telegraph(self, self.name.." is confused!", {self.color[1],self.color[2],self.color[3],50}),
			self.behavior(self, self.scene.opponents[self.selectedTarget]) or Action()
		}
		self.confused = false
	elseif self.lostTurns > 1 then
		local lostTurnMsg = self.name.." is still "..((self.lostTurnType.."ed") or "bored").."!"
		self.action = Telegraph(self, lostTurnMsg, {self.color[1],self.color[2],self.color[3],50})
		self.lostTurns = self.lostTurns - 1
	elseif self.lostTurns > 0 then
		local lostTurnMsg = self.name.."'s "..(self.lostTurnType or "boredom").." has subsided."
		self.action = Serial {
			Do(function() self:getSprite():setAnimation("idle") end),
			self.afterLostTurns and self.afterLostTurns(self, self.lostTurnType) or Action(),
			Telegraph(self, lostTurnMsg, {self.color[1],self.color[2],self.color[3],50})
		}
		self.lostTurns = self.lostTurns - 1
		self.lostTurnType = nil
	else
		local targetOverride = table.remove(self.targetOverrideStack, 1)
		if targetOverride then
			self.selectedTarget = targetOverride
		end

		-- Choose action based on behavior
		target = self.scene.party[self.selectedTarget]
		if target.laserShield and target.sprite ~= target.laserShield then
			target.lastSprite = target.sprite
			target.sprite = target.laserShield
		end
		
		self.action = self.behavior(self, target) or Action()
		
		if target.laserShield then
			self.action = Serial {
				self.action,
				Do(function()
					target.sprite = target.lastSprite
					target.lastSprite = nil
				end)
			}
		end
		
		if targetOverride then
			self.action = Serial {
				Telegraph(self, self.name.." feels compelled to attack "..target.name.."!", {255,255,255,50}),
				self.action
			}
		end
	end
	
	if self.malfunctioningTurns > 1 then
		table.insert(
			additionalActions,
			Serial {
				Telegraph(self, self.name.." is still malfunctioning!", {self.color[1],self.color[2],self.color[3],50}),
				Parallel {
					Animate(function()
						local xform = Transform(
							sprite.transform.x - 50,
							sprite.transform.y - 50,
							2,
							2
						)
						return SpriteNode(self.scene, xform, nil, "lightning", nil, nil, "ui"), true
					end, "idle"),
					
					Serial {
						Wait(0.2),
						PlayAudio("sfx", "shocked", 0.5, true),
					}
				},
				self:takeDamage(self.infectedStats or {attack = 10, speed = 100, luck = 0})
			}
		)
		self.malfunctioningTurns = self.malfunctioningTurns - 1
	elseif self.malfunctioningTurns > 0 then
		table.insert(
			additionalActions,
			Telegraph(self, self.name.." is no longer malfunctioning.", {self.color[1],self.color[2],self.color[3],50})
		)
		self.infectedStats = nil
		self.malfunctioningTurns = self.malfunctioningTurns - 1
	end
	
	-- If poisoned, take some damage
	if self.poisoned then
		table.insert(
			additionalActions,
			Serial {
				MessageBox {message=self.name.." is poisoned!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(0.6)},
				self:takeDamage(self.poisoned, true, BattleActor.poisonKnockback)
			}
		)
	end
	
	self.scene:run {
		Serial(additionalActions),
		self.action,
		Do(function()
			-- Noop... why is this necessary in some cases?
		end)
	}
end

function OpposingPartyMember:isTurnOver()
	return not self.action or self.action:isDone()
end

function OpposingPartyMember:getSprite()
	return self.mockSprite or self.sprite
end

function OpposingPartyMember:die()
	-- Don't do counter attack
	self.onAttack = nil
	
	local extraAnim = Action()
	if self.state == BattleActor.STATE_IMMOBILIZED then
		extraAnim = self.scene.partyByName["bunny"].reverseAnimation
	end
	
	local sprite = self:getSprite()
	
	if self.scene.bossBattle and self.boss then
	
		local explosions = {}
		for i=0,20 do
			table.insert(
				explosions,
				Serial {
					Wait(math.max(0, 5 - i/4)),
					PlayAudio("sfx", "explosion", 1.0, true),
					Animate(function()
						local xform = Transform.from(self.sprite.transform) 
						return SpriteNode(self.scene, Transform(xform.x - 20 - math.random(40,80) + math.random(0,50), xform.y - math.random(40,80) + math.random(0,50), 2, 2), nil, "explosion", nil, nil, "ui"), true
					end, "explode")
				}
			)
		end
		
		local killOtherMonsters = {}
		for _, v in pairs(self.scene.opponents) do
			if v ~= self then
				table.insert(killOtherMonsters, v:die())
			end
		end
	
		return Serial {
			Parallel {
				extraAnim,
				Ease(self:getSprite().color, 1, 800, 5),
				
				Serial {
					Wait(1),
					Parallel(explosions)
				},
				
				Repeat(Serial {
					PlayAudio("sfx", "bossdie", 1.0, true),

					Ease(
						sprite.transform,
						"x",
						sprite.transform.x + 7,
						10
					),
					Ease(
						sprite.transform,
						"x",
						sprite.transform.x - 7,
						10
					),
					Ease(
						sprite.transform,
						"x",
						sprite.transform.x + 3,
						10
					),
					Ease(
						sprite.transform,
						"x",
						sprite.transform.x - 3,
						10
					),
					Ease(
						sprite.transform,
						"x",
						sprite.transform.x,
						10
					),
				}, 10)
			},
			PlayAudio("sfx", "oppdeath", 1.0, true),
			Spawn(Parallel(killOtherMonsters)),
			Do(function()
				self.dropShadow:remove()
			end),
			Ease(sprite.color, 4, 0, 2),
			
			Do(function()
				self.hp = 0
				self.state = BattleActor.STATE_DEAD
				sprite:remove()

				self:invoke("dead")
			end),
			
			self.onDead(self),
			
			Do(function()
				self.action = nil
			end)
		}
	else
		return Serial {
			PlayAudio("sfx", "oppdeath", 1.0, true),
		
			Do(function()
				self.dropShadow:remove()
			end),
			
			-- Fade out with red and play sound
			Parallel {
				extraAnim,
				Ease(sprite.color, 1, 800, 5),
				Ease(sprite.color, 4, 0, 2)
			},
			
			Do(function()
				self.hp = 0
				self.state = BattleActor.STATE_DEAD
				sprite:remove()
				
				self:invoke("dead")
			end),
			
			self.onDead(self),
			
			Do(function()
				self.action = nil
			end)
		}
	end
end


return OpposingPartyMember
