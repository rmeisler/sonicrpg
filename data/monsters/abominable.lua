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
	mockSpriteOffset = Transform(-100, -240),

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
		{item = require "data/items/Mushroom", count = 2, chance = 1.0},
	},

	
	scan = "Yeti's like sweets...",

	behavior = function (self, target)
		if not GameState:isFlagSet("ep4_abominable_fight") then
			GameState:setFlag("ep4_abominable_fight")
			return Serial {
				Wait(1),
				Do(function()
					target.scene.partyByName.rotor.sprite:setAnimation("shock")
				end),
				MessageBox{message="Rotor: Whoah{p60}, that thing is big!"},
				Do(function()
					target.scene.partyByName.logan.sprite:setAnimation("pose")
				end),
				MessageBox{message="Logan: Yeah, and it's in our way. {p60}We gotta do something to get past it."},
				Do(function()
					target.scene.partyByName.rotor.sprite:setAnimation("idle")
					target.scene.partyByName.logan.sprite:setAnimation("idle")
				end)
			}
		end

		return Serial {
			Telegraph(self, "Yeti looks curious...", {255,255,255,50})
		}
	end
}