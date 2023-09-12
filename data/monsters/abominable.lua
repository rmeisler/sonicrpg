local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local BouncyText = require "actions/BouncyText"
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"
local While = require "actions/While"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"
local TargetType = require "util/TargetType"

local BattleActor = require "object/BattleActor"

return {
	name = "Yeti",
	altName = "Yeti",
	sprite = "sprites/phantomstandin",

	mockSprite = "sprites/abominable",
	mockSpriteOffset = Transform(-100, -200),

	--insult = "creepo",

	hpBarOffset = Transform(160, 150),

	stats = {
		xp    = 20,
		maxhp = 1200,
		attack = 100,
		defense = 50,
		speed = 5,
		focus = 20,
		luck = 5,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/armor/YetiArmor", count = 1, chance = 1.0},
	},
	
	scan = "Yeti's like sweets...",
	
	onAttack = function(self, attacker)
		if self.angry or self.gaveMarshmallow then
			return Action()
		else
			self.angry = true
			return Telegraph(self, "Yeti is angry!", {255,255,255,50})
		end
	end,

	behavior = function (self, target)
		if not GameState:isFlagSet("ep4_abominable_fight") then
			GameState:setFlag("ep4_abominable_fight")
			self.turns = 0
			return Serial {
				Wait(1),
				Do(function()
					target.scene.partyByName.rotor.sprite:setAnimation("shock")
				end),
				MessageBox{message="Rotor: Whoah{p60}, that thing is big!"},
				Do(function()
					target.scene.partyByName.rotor.sprite:setAnimation("idle")
					target.scene.partyByName.logan.sprite:setAnimation("pose")
				end),
				MessageBox{message="Logan: Yeah, and it's in our way. {p60}We gotta do something to get past it."},
				Do(function()
					target.scene.partyByName.logan.sprite:setAnimation("idle")
				end)
			}
		end

		local selfSp = self:getSprite()
		if self.angry then
			local damageAllParty = {}
			for _,mem in pairs(self.scene.party) do
				table.insert(damageAllParty, mem:takeDamage(self.stats))
			end
			return Serial {
				Animate(selfSp, "leap_right"),
				Ease(selfSp.transform, "y", function() return selfSp.transform.y - 200 end, 2),
				Ease(selfSp.transform, "y", function() return selfSp.transform.y + 200 end, 4, "quad"),
				Do(function() selfSp:setAnimation("idle") end),
				self.scene:screenShake(20, 30, 1),
				Parallel(damageAllParty)
			}
		elseif self.turns == 3 then
			return Serial {
				Do(function() selfSp:setAnimation("idleleft") end),
				Wait(1),
				Animate(selfSp, "leap_left"),
				Parallel {
					Ease(selfSp.transform, "x", function() return selfSp.transform.x - 400 end, 3, "linear"),
					Ease(selfSp.transform, "y", function() return selfSp.transform.y - 200 end, 3, "linear")
				},
				Parallel {
					Ease(selfSp.transform, "x", function() return selfSp.transform.x - 400 end, 4, "linear"),
					Ease(selfSp.transform, "y", function() return selfSp.transform.y + 200 end, 4, "quad")
				},
				Do(function()
					self.hp = 0
					self.state = self.STATE_DEAD
					selfSp:remove()
					self:invoke("dead")
					self.scene.enemyRan = true
				end),
				MessageBox {message="Yeti left the battle...", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(0.6)},
				
				self.gaveMarshmallow and
					MessageBox {message=(self.gaveMarshmallow).." learned \"Call Yeti\"!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(3), sfx="levelup"} or
					Action()
			}
		else
			self.turns = self.turns + 1
			return Serial {
				Telegraph(self, "Yeti looks at you curiously...", {255,255,255,50})
			}
		end
	end
}