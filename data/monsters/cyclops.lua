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
	sprite = "sprites/cyclops",

	stats = {
		xp    = 30,
		maxhp = 1000,
		attack = 24,
		defense = 20,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		{item = require "data/items/CrystalWater", count = 1, chance = 0.8},
	},
	
	scan = "Don't attack rover when standing.",

	onPreInit = function(self)
		self.sprite.transform = Transform(-60, 50, 2, 2)
		--self.sprite.transform.x = 0
		--self.sprite.transform.y = self.sprite.transform.y - self.sprite.h/1.5
	end,
	
	onInit = function(self)
		-- Party members need to look up at cyclops
		for _,mem in pairs(self.scene.party) do
			mem.sprite:pushOverride("idle", "idle_lookup")
		end
	end,
	
	behavior = function (self, target)
		if math.random() < 0.5 then
			local sapActions = {}
			local spLoss = 5
			for _, mem in pairs(self.scene.party) do
				if mem.state ~= BattleActor.STATE_DEAD then
					mem.sp = math.max(0, mem.sp - spLoss)
					table.insert(sapActions, Serial {
						Animate(mem.sprite, "hurt"),
						Wait(2),
						Animate(mem.sprite, "idle")
					})
				end
			end

			return Serial {
				Telegraph(self, "Roar", {255,255,255,50}),
				Wait(0.5),
				Do(function() self.sprite:setAnimation("roar") end),
				PlayAudio("sfx", "cyclopsroar", 1.0, true),
				Parallel {
					Serial {
						self.scene:screenShake(20, 30, 15),
						Do(function() self.sprite:setAnimation("idle") end)
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
			local paralyzedActions = {}
			for _, mem in pairs(self.scene.party) do
				if mem.state ~= BattleActor.STATE_DEAD then
					mem.state = BattleActor.STATE_IMMOBILIZED
					table.insert(paralyzedActions, Serial {
						Animate(mem.sprite, "hurt"),
						Wait(5),
						Animate(mem.sprite, "stun")
					})
				end
			end
			
			return Serial {
				Telegraph(self, "Stomp", {255,255,255,50}),
				
				Parallel {
					Repeat(Serial {
						PlayAudio("sfx", "cyclopsstep", 1.0, true),
						Do(function() self.sprite:setAnimation("stomp1") end),
						self.scene:screenShake(20, 30, 1),
						Wait(0.6),
						PlayAudio("sfx", "cyclopsstep", 1.0, true),
						Do(function() self.sprite:setAnimation("stomp2") end),
						self.scene:screenShake(20, 30, 1),
						Wait(0.6)
					}, 2),
					
					Serial {
						Wait(0.6),
						Parallel(paralyzedActions)
					}
				},
				
				Do(function() self.sprite:setAnimation("idle") end),
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