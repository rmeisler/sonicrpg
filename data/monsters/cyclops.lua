local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local BouncyText = require "actions/BouncyText"
local Repeat = require "actions/Repeat"
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"
local Executor = require "actions/Executor"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Cyclops",
	altName = "Cyclops",
	sprite = "sprites/phantomstandin",
	
	mockSprite = "sprites/cyclops",
	mockSpriteOffset = Transform(-60, 50),

	stats = {
		xp    = 50,
		maxhp = 1500,
		attack = 26,
		defense = 100,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss_part = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		{item = require "data/items/CrystalWater", count = 1, chance = 0.8},
	},
	
	scan = "Cyclops can lose balance when made dizzy.",
	
	getHpStats = function(self)
		return self.eye.hp, self.eye.maxhp
	end,
	
	onInit = function(self)
		self.sprite.transform.x = 230
		self.sprite.transform.y = 310
		self.sprite.sortOrderY = -100
		self.pummelXForm = Transform(350, 330) -- Hack to make Sonic's Pummel skill work
		
		self.mockSprite.transform.x = -60
		self.mockSprite.transform.y = 50
		self.mockSprite.sortOrderY = -100
		
		local oppo = self.scene:addMonster("cyclopseye")
		oppo.body = self
		oppo:onPreInit()
		self.eye = oppo
		
		local hitHandler
		hitHandler = function(damage)
			self.eye.hp = self.eye.hp - damage
			if self.eye.hp <= 0 then
				self.hp = 0
				self.state = BattleActor.STATE_DEAD
			end
		end
		self:addHandler("hit", hitHandler)
		
		-- Screen shake every x seconds
		self.scene:run(Spawn(
			Repeat(
				Serial {
					PlayAudio("sfx", "quake", 1.0, true),
					self.scene:screenShake(10, 30, 20),
					Wait(5)
				}
			)
		))
		
		self.proneTurns = 0
	end,
	
	onConfused = function(self)
		self.proneTurns = 2
		self:getSprite():pushOverride("hurt", "prone_hurt")

		self.eye.aerial = false
		self.eye.sprite.transform.x = 340
		self.eye.sprite.transform.y = 300

		return Serial {
			Do(function()
				self.confused = false
				self:getSprite():setAnimation("dazed")
			end),
			Wait(0.5),
			MessageBox {
				message="Cyclops is feeling dizzy!",
				rect=MessageBox.HEADLINER_RECT,
				closeAction=Wait(1)
			},
			Animate(self:getSprite(), "fall"),
			Do(function()
				self:getSprite():setAnimation("prone")
				self:getSprite():pushOverride("idle", "prone")
				self:getSprite():pushOverride("backward", "prone")
			end),
			PlayAudio("sfx", "cyclopsstep", 1.0, true),
			self.scene:screenShake(20, 30, 1)
		}
	end,
	
	onTease = function(self)
		self.doLaser = 3
	end,
	
	behavior = function (self, target)
		if  self.hp <= 0 or
		    self.eye.hp <= 0 or
		    self.state == BattleActor.STATE_DEAD or
		    self.eye.state == BattleActor.STATE_DEAD
		then
			return Action()
		end
	
		if self.proneTurns > 1 then
			self.proneTurns = self.proneTurns - 1
			return Action()
		elseif self.proneTurns == 1 then
			self.proneTurns = self.proneTurns - 1
			self:getSprite():popOverride("hurt")

			self.eye.aerial = true
			self.eye.sprite.transform.y = 130
			
			local sp = self:getSprite()
			return Serial {
				Parallel {
					Animate(sp, "unprone"),
					Serial {
						Ease(sp.transform, "y", function() return sp.transform.y - 150 end, 2),
						Ease(sp.transform, "y", function() return sp.transform.y + 150 end, 3)
					},
				},
				Do(function()
					self:getSprite():setAnimation("idle")
					self:getSprite():popOverride("idle")
					self:getSprite():popOverride("backward")
				end),
				PlayAudio("sfx", "cyclopsstep", 1.0, true),
				self.scene:screenShake(20, 30, 1)
			}
		end
		
		if math.random() < 0.2 then
			self.doLaser = 1
		end
		
		--[[if self.doLaser and self.doLaser > 0 then
			self.doLaser = self.doLaser - 1
			return Serial {
				Telegraph(self, "Eye Laser", {255,255,255,50}),
				
			}
		end]]
	
		local sprite = self:getSprite()
		if math.random() < 0.3 then
			local sapActions = {}
			for _, mem in pairs(self.scene.party) do
				if mem.state ~= BattleActor.STATE_DEAD then
					table.insert(sapActions, Serial {
						Animate(mem.sprite, "hurt"),
						Wait(2),
						Animate(mem.sprite, mem.sprite.selected)
					})
				end
			end

			return Serial {
				Do(function() sprite:setAnimation("roar") end),
				PlayAudio("sfx", "cyclopsroar", 1.0, true),
				Parallel {
					Serial {
						self.scene:screenShake(20, 30, 15),
						Do(function() sprite:setAnimation("idle") end)
					},
					Parallel(sapActions)
				}
			}
		else
			local takeDamageAction = Do(function()
				for _, mem in pairs(self.scene.party) do
					if mem.state ~= BattleActor.STATE_DEAD then
						Executor(self.scene):act(Serial {
							Do(function()
								self.doneWithDamage = false
							end),
							mem:takeDamage{attack = 10, speed = 30, luck = 0},
							Do(function()
								self.doneWithDamage = true
							end)
						})
					end
				end
			end)
			return Serial {
				Telegraph(self, "Stomp", {255,255,255,50}),
				
				Repeat(Serial {
					PlayAudio("sfx", "cyclopsstep", 1.0, true),
					Do(function() sprite:setAnimation("stomp1") end),
					takeDamageAction,
					self.scene:screenShake(20, 30, 1),
					Wait(0.6),
					PlayAudio("sfx", "cyclopsstep", 1.0, true),
					Do(function() sprite:setAnimation("stomp2") end),
					self.scene:screenShake(20, 30, 1),
					Wait(0.6)
				}, 2),
				
				Do(function()
					sprite:setAnimation("idle")
				end),
				
				Wait(1),
				Do(function()
					for _, mem in pairs(self.scene.party) do
						if mem.state ~= BattleActor.STATE_DEAD then
							mem.state = BattleActor.STATE_IMMOBILIZED
							mem.sprite:setAnimation("stun")
						end
					end
				end),
				MessageBox {
					message="Party is paralyzed!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(1)
				}
			}
		end
	end
}