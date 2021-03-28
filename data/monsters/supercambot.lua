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
	name = "Super Cambot",
	altName = "Super Cambot",
	sprite = "sprites/supercambot",

	stats = {
		xp    = 100,
		maxhp = 3000,
		attack = 30,
		defense = 20,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		{item = require "data/items/ElectronEmitter", count = 1, chance = 0.8},
		{item = require "data/items/PhotonEmitter", count = 1, chance = 0.8},
		{item = require "data/items/SuperCharger", count = 1, chance = 0.8},
	},
	
	scan = "Super Cambot is easily confused.",

	behavior = function (self, target)
		-- Init behavior stack
		if not self.behaviorList then
			self.behaviorList = {
				'shock',
				'shock',
				'electrical field',
				'heal',
				'shock',
				'shock',
				'electrical field',
				'countdown',
				'countdown',
				'countdown',
				'photon ring'
			}
			self.currentBehavior = 1
			self.countdown = 3
		end
		
		local action = Action()
		local behavior = self.behaviorList[self.currentBehavior]
		if behavior == "shock" then
			action = Serial {
				Telegraph(self, "Shock", {255,255,255,50})
			}
		if behavior == "electrical field" then
			action = Serial {
				Telegraph(self, "Electrical Field", {255,255,255,50})
			}
		elseif behavior == "heal" then
			action = Serial {
				Telegraph(self, "Repair", {255,255,255,50})
			}
		elseif behavior == "countdown" then
			action = Serial {
				Telegraph(self, "Countdown", {255,255,255,50}),
				Telegraph(self, tostring(self.countdown), {255,255,255,50}),
			}
			self.countdown = self.countdown - 1
			if self.countdown == 0 then
				self.countdown = 3
			end
		elseif behavior == "photon ring" then
			action = Serial {
				Telegraph(self, "Photon Ring", {255,255,255,50})
			}
		end
		
		-- Update current behavior
		self.currentBehavior = self.currentBehavior + 1
		if self.currentBehavior > #self.behaviorList then
			self.currentBehavior = 1
		end

		return action
	end
}