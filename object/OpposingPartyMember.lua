local Menu = require "actions/Menu"
local BouncyText = require "actions/BouncyText"
local Rect = unpack(require "util/Shapes")
local Transform = require "util/Transform"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Shake = require "actions/Shake"
local Ease = require "actions/Ease"
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"
local Do = require "actions/Do"
local Lazy = require "util/Lazy"
local MessageBox = require "actions/MessageBox"
local SpriteNode = require "object/SpriteNode"

local BattleActor = require "object/BattleActor"

local OpposingPartyMember = class(BattleActor)

function OpposingPartyMember:construct(scene, data)
	self.scene = scene
	self.transform = transform
	self.playerSlot = data.playerSlot
	self.sprite = data.sprite
	self.turns = 0
	self.state = BattleActor.STATE_IDLE

	self.name = data.altName or ""
	self.stats = data.stats
	self.flying = data.flying
	self.run_chance = data.run_chance or 1.0
	self.drops = data.drops
	self.hp = data.stats.maxhp
	self.maxhp = data.stats.maxhp
	self.scan = data.scan
	self.hurtSfx = "smack"
	self.behavior = data.behavior or function() end
	self.onDead = data.onDead or function() return Action() end
	self.onAttack = data.onAttack
	self.textOffset = data.textOffset or Transform(0, self.sprite.h/2 - 15)
end

function OpposingPartyMember:setShadow(visible)
	self.dropShadow = SpriteNode(
		self.scene,
		Transform(self.sprite.transform.x - self.sprite.w + 18, self.sprite.transform.y + self.sprite.h - 14, 2, 2),
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
	
	-- Choose action based on current state
	if self.immobilized then
		-- Shake left and right
		local shake = Repeat(Serial {
			Do(function()
				self.scene.audio:playSfx("bang")
			end),

			Ease(
				self.sprite.transform,
				"x",
				self.sprite.transform.x + 7,
				10
			),
			Ease(
				self.sprite.transform,
				"x",
				self.sprite.transform.x - 7,
				10
			),
			Ease(
				self.sprite.transform,
				"x",
				self.sprite.transform.x + 3,
				10
			),
			Ease(
				self.sprite.transform,
				"x",
				self.sprite.transform.x - 3,
				10
			),
			Ease(
				self.sprite.transform,
				"x",
				self.sprite.transform.x,
				10
			),
			
			Wait(0.5)
		}, 2)
		
		if not self.chanceToEscape then
			self.chanceToEscape = 0.4
		else
			self.chanceToEscape = self.chanceToEscape * 2
		end
		
		if math.random() > self.chanceToEscape then
			self.action = Serial {
				shake,
				MessageBox {
					message=self.name.." is immobilized!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(0.6)
				}
			}
		else
			-- Retract bunny ext arm and linkages and go back to idle anim
			self.action = Serial {
				shake,
				
				Do(function()
					if self.prevAnim == "backward" then
						self.prevAnim = "idle"
					end
					self.sprite:setAnimation(self.prevAnim)
					self.immobilized = false
					self.chanceToEscape = nil
				end),
				
				self.scene.partyByName["bunny"].reverseAnimation,
				
				MessageBox {
					message=self.name.." broke free!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(0.6)
				}
			}
		end
	elseif self.confused then
		-- If confused, choose random target from opponent side, or don't attack at all
		if #self.scene.opponents > 1 then
			self.selectedTarget = math.random(#self.scene.opponents)
			self.action = Serial {
				MessageBox {
					message=self.name.." is confused!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(0.6)
				},
				self.behavior(self, self.scene.opponents[self.selectedTarget]) or Action()
			}
		else
			self.action = MessageBox {
				message=self.name.." is confused!",
				rect=MessageBox.HEADLINER_RECT,
				closeAction=Wait(0.6)
			}
		end
		self.confused = false
	else
		-- Choose action based on behavior
		self.action = self.behavior(self, self.scene.party[self.selectedTarget]) or Action()
	end
	self.scene:run(self.action)
end

function OpposingPartyMember:isTurnOver()
	return not self.action or self.action:isDone()
end

function OpposingPartyMember:die()
	-- Don't do counter attack
	self.onAttack = nil
	
	local extraAnim = Action()
	if self.immobilized then
		extraAnim = self.scene.partyByName["bunny"].reverseAnimation
	end
	
	if self.scene.bossBattle then
		return Serial {
			Parallel {
				extraAnim,
				Ease(self.sprite.color, 1, 800, 5),
				
				Repeat(Serial {
					Do(function()
						self.scene.audio:playSfx("bossdie")
					end),

					Ease(
						self.sprite.transform,
						"x",
						self.sprite.transform.x + 7,
						10
					),
					Ease(
						self.sprite.transform,
						"x",
						self.sprite.transform.x - 7,
						10
					),
					Ease(
						self.sprite.transform,
						"x",
						self.sprite.transform.x + 3,
						10
					),
					Ease(
						self.sprite.transform,
						"x",
						self.sprite.transform.x - 3,
						10
					),
					Ease(
						self.sprite.transform,
						"x",
						self.sprite.transform.x,
						10
					),
				}, 10)
			},
			Do(function()
				self.scene.audio:playSfx("oppdeath")
				self.dropShadow:remove()
			end),
			Ease(self.sprite.color, 4, 0, 2),
			
			Do(function()
				self.hp = 0
				self.state = BattleActor.STATE_DEAD
				self.sprite:remove()
			end),
			
			self.onDead(self)
		}
	else
		return Serial {
			Do(function()
				self.scene.audio:playSfx("oppdeath")
				self.dropShadow:remove()
			end),
			
			-- Fade out with red and play sound
			Parallel {
				extraAnim,
				Ease(self.sprite.color, 1, 800, 5),
				Ease(self.sprite.color, 4, 0, 2)
			},
			
			Do(function()
				self.hp = 0
				self.state = BattleActor.STATE_DEAD
				self.sprite:remove()
			end),
			
			self.onDead(self)
		}
	end
end


return OpposingPartyMember
