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

local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local BattleActor = require "object/BattleActor"

return {
	name = "Ratbot",
	altName = "Ratbot",
	sprite = "sprites/ratbot",

	stats = {
		xp    = 10,
		maxhp = 400,
		attack = 15,
		defense = 15,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/items/GreenLeaf", count = 1, chance = 0.2},
	},

	behavior = function (self, target)
		if not self.turnCounter then
			self.turnCounter = 0
		end

		local telegraphAction = Action()
		local prefix = ""
		if self.turnCounter % 3 == 1 then
			self.electricTail = true
			prefix = "electric"
			telegraphAction = Telegraph(self, "Electric Whip", {255,255,255,50})
		else
			self.electricTail = false
			telegraphAction = Telegraph(self, "Whip", {255,255,255,50})
		end
		
		-- Leap toward target, fling tail
		return Serial {
			telegraphAction,
			Animate(self.sprite, "crouch"),
			Wait(0.2),
			Animate(self.sprite, "leap"),
			Parallel {
				Serial {
					Ease(self.sprite.transform, "y", target.sprite.transform.y - 100, 5, "linear"),
					Animate(self.sprite, "lunge"),
					Ease(self.sprite.transform, "y", target.sprite.transform.y, 6, "linear")
				},
				Ease(self.sprite.transform, "x", target.sprite.transform.x - 100, 4, "linear")
			},
			Animate(self.sprite, prefix.."pose"),
			Wait(0.2),
			Animate(self.sprite, prefix.."tail"),
			Try(
				YieldUntil(
					function()
						return target.dodged
					end
				),
				Do(function()
					target.dodged = false
				end),
				target:takeDamage(self.stats, true, self.electricTail and BattleActor.shockKnockback or nil)
			),
		}
	end,
	
	scan = "Do not attack Ratbot when electrified."
}