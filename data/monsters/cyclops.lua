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
		xp    = 30,
		maxhp = 1, --000,
		attack = 24,
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
	
	scan = "It's body is too powerful to damage.",
	
	onInit = function(self)
		self.sprite.transform.x = 230
		self.sprite.transform.y = 310
		self.sprite.sortOrderY = -100
		
		self.mockSprite.transform.x = -60
		self.mockSprite.transform.y = 50
		self.mockSprite.sortOrderY = -100
		
		local oppo = self.scene:addMonster("cyclopseye")
		oppo:onPreInit()
	end,
	
	behavior = function (self, target)
		local sprite = self:getSprite()
		if math.random() < 0.2 then
			local sapActions = {}
			local spLoss = 5
			for _, mem in pairs(self.scene.party) do
				if mem.state ~= BattleActor.STATE_DEAD then
					mem.sp = math.max(0, mem.sp - spLoss)
					table.insert(sapActions, Serial {
						Animate(mem.sprite, "hurt"),
						Wait(2),
						Animate(mem.sprite, mem.sprite.selected)
					})
				end
			end

			return Serial {
				Telegraph(self, "Roar", {255,255,255,50}),
				Wait(0.5),
				Do(function() sprite:setAnimation("roar") end),
				PlayAudio("sfx", "cyclopsroar", 1.0, true),
				Parallel {
					Serial {
						self.scene:screenShake(20, 30, 15),
						Do(function() sprite:setAnimation("idle") end)
					},
					Parallel(sapActions)
				},
				MessageBox {
					message="Party members lost "..tostring(spLoss).." sp!",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(1)
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
							mem:takeDamage{attack = 16, speed = 30, luck = 0},
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
	end,
	
	getIdleAnim = function(self)
		if self.state == "upright" or self.state == "transition_to_upright" then
			return "upright"
		else
			return "idle"
		end
	end,
	
	getBackwardAnim = function(self)
		if self.state == "upright" or self.state == "transition_to_upright" then
			return "uprightbackward"
		else
			return "backward"
		end
	end
}