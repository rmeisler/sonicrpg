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

		local parts = {"juggerbothead", "juggerbotleftarm", "juggerbotrightarm"}
		for k,v in pairs(parts) do
			local oppo = self.scene:addMonster(v)
			oppo:onPreInit()
		end
		
		self.sprite.h = self.sprite.h + 10
	end,
	
	behavior = function (self, target)
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
		
		if not self.turnCount then
			self.turnCount = 0
			self.turnPhase = 1
		end
		
		local action = Action()
		local isblind = self.scene.juggerbothead.hp <= 0
		
		-- First phase of boss:
		-- roar, stun (all), missile (all)
		if self.turnPhase == 1 then
			local blindAction = Action()
			local turnIdx = self.turnCount % 3

			-- If lost leftarm, move on to next boss phase
			if self.scene.juggerbotleftarm.hp <= 0 then
				turnIdx = -1
				self.turnCount = 0
				self.turnPhase = 2
			else
				-- If lost head, this affects boss' sight/aim
				if isblind then
					blindAction = Telegraph(self, self.name.." can't see!", {255,255,255,50})
					
					-- Skip roar
					if turnIdx == 0 then
						turnIdx = 1
					end
				end
				
				-- If lost rightarm, can no longer do stun
				local lostrightarm = self.scene.juggerbotrightarm.hp <= 0
				if lostrightarm then
					-- Skip stun
					if turnIdx == 1 then
						turnIdx = 2
					end
				end
			end

			-- roar
			if turnIdx == 0 then
				action = Serial {
					Animate(self.scene.juggerbothead:getSprite(), "roar"),
					Animate(self.scene.juggerbothead:getSprite(), "idleright")
				}
			-- stun
			elseif turnIdx == 1 then
				action = Serial {
					blindAction,
					Telegraph(self, "Phasic Stun", {255,255,255,50}),
					Do(function()
						local spr = self.scene.juggerbotrightarm:getSprite()
						spr.transform.ox = 32
						spr.transform.oy = 6
						spr.transform.x = spr.transform.x + 64
						spr.transform.y = spr.transform.y + 12
					end),
					Ease(self.scene.juggerbotrightarm:getSprite().transform, "angle", -math.pi/2, 1.3),
					Wait(2),
					Ease(self.scene.juggerbotrightarm:getSprite().transform, "angle", 0, 1.3),
					Do(function()
						local spr = self.scene.juggerbotrightarm:getSprite()
						spr.transform.ox = 0
						spr.transform.oy = 0
						spr.transform.x = spr.transform.x - 64
						spr.transform.y = spr.transform.y - 12
					end),
				}
			-- missile
			elseif turnIdx == 2 then
				action = Serial {
					blindAction,
					Telegraph(self, "Missile Launcher", {255,255,255,50}),
					Animate(self.scene.juggerbotleftarm:getSprite(), "cannonright"),
					Animate(self.scene.juggerbotleftarm:getSprite(), "missilecannonright"),
					Animate(self.scene.juggerbotleftarm:getSprite(), "idlecannonright"),
					Wait(1),
					Animate(self.scene.juggerbotleftarm:getSprite(), "undocannonright")
				}
			end
		end
		
		-- Second phase of boss:
		-- roar, charge up plasma cannon for three turns, fire (can kill whole party)
		if self.turnPhase == 2 then
			local turnIdx = self.turnCount % 5
			
			-- If lost head
			if isblind then
				-- Skip roar
				if turnIdx == 0 then
					turnIdx = 1
				end
			end

			-- roar
			if turnIdx == 0 then
				action = Serial {
					Animate(self.scene.juggerbothead:getSprite(), "roar"),
					Animate(self.scene.juggerbothead:getSprite(), "idleright")
				}
			-- charge
			elseif turnIdx == 1 then
				action = Serial {
					Animate(self:getSprite(), "cannonright"),
					Animate(self:getSprite(), "idlecannonright"),
					Telegraph(self, "3...", {255,255,255,50}),
				}
			elseif turnIdx == 2 then
				action = Serial {
					Telegraph(self, "2...", {255,255,255,50}),
				}
			elseif turnIdx == 3 then
				action = Serial {
					Telegraph(self, "1...", {255,255,255,50}),
				}
			-- plasma cannon
			elseif turnIdx == 4 then
				action = Serial {
					Telegraph(self, "Plasma Beam", {255,255,255,50}),
					Wait(1),
					Animate(self:getSprite(), "undocannonright")
				}
			end
		end
		
		self.turnCount = self.turnCount + 1
		
		return action
		--return Action()
	end
}