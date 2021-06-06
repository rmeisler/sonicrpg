local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local BouncyText = require "actions/BouncyText"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"

return {
	name = "Torso",
	altName = "Torso",
	sprite = "sprites/juggerbotbody",

	stats = {
		xp    = 100,
		maxhp = 3000,
		attack = 20,
		defense = 50,
		speed = 1,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		--{item = require "data/items/MetallicPlate", count = 6, chance = 1.0},
	},
	
	scan = "Focus damage on Juggerbot's weapons systems.",
	
	skipAnimation = true,

	onPreInit = function(self)
		self.scene.juggerbotbody = self
		self.sprite.sortOrderY = self.sprite.transform.y + self.sprite.h

		self.scene:addMonster("juggerbothead")
		self.scene:addMonster("juggerbotleftarm")
		self.scene:addMonster("juggerbotrightarm")
		
		self.sprite.h = self.sprite.h + 10
	end,
	
	behavior = function (self, target)
		-- Turn 1 roar
		-- Turn 2 stun gun (while gun arm available)
		-- Turn 3 missile launcher
		
		-- If you destroy head, juggerbot misses on each attack
		-- If you destroy right arm, no benefit		
		-- If you destroy left arm, move on to next behavior

		-- Turn 1 roar
		-- Turn 2 charge plasma cannon (3)
		-- Turn 3 charge plasma cannon (2)
		-- Turn 4 charge plasma cannon (1)
		-- Turn 5 fire plasma cannon (kills whole party unless you use laser shield)
		
		-- Can interrupt the plasma cannon if you destroy a body part,
		-- including left arm or head.
		
		-- Can delay it if you use Bunnie's grab or Sonic's roundabout
		
		-- Can interrupt plasma cannon with Mine
		
		-- Can survive plasma cannon if you are using a laser shield
		
		--[[
		if not self.turnCount then
			self.turnCount = 0
			self.turnPhase = 1
		end
		
		local action
		
		if self.turnPhase == 1 then
			if self.parts.leftarm.hp <= 0 then
				self.turnCount = 0
				self.turnPhase = 2
			end
			
			local turnIdx = self.turnCount % 3

			-- roar
			if turnIdx == 0 then
				
			-- stun
			elseif turnIdx == 1 then
				
			-- missile
			elseif turnIdx == 2 then
				
			end
		end
		
		if self.turnPhase == 2 then
			local turnIdx = self.turnCount % 4

			-- roar
			if turnIdx == 0 then
				
			-- charge
			elseif turnIdx < 3 then
				
			-- plasma cannon
			elseif turnIdx == 3 then
				
			end
		end
		
		self.turnCount = self.turnCount + 1
		
		return action]]
		return Action()
	end
}