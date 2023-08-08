local Fun = require "util/EasingFunctions"

return {
	id = "rotor",
	name = "Rotor",
	altName = "Rotor",

	avatar = "avatar/rotoravatar",
	sprite = "sprites/rotor",
	battlesprite = "sprites/rotorbattle",

	startingstats = {
		startxp = 0,
		maxhp   = 300,
		maxsp   = 10,
		attack  = 9,
		defense = 9,
		speed   = 2,
		focus   = 5,
		luck    = 1,
	},

	maxstats = {
		startxp = 95000,
		maxhp   = 10000,
		maxsp   = 100,
		attack  = 90,
		defense = 90,
		speed   = 20,
		focus   = 50,
		luck    = 10,
	},

	growth = {
		-- Note: t = normalized level (level/MAX_LEVEL_CAP)
		-- Formula = startingstat + fn(t) * (maxstat - startingstat)
		startxp = Fun.quad,
		maxhp   = Fun.linear,
		maxsp   = Fun.linear,
		attack  = Fun.linear,
		defense = Fun.linear,
		speed   = Fun.linear,
		focus   = Fun.linear,
		luck    = Fun.linear
	},

	equip = {
		weapon    = require "data/weapons/Hammer",
		armor     = nil,
		accessory = require "data/accessories/LeatherSash",
	},

	items = {
	},
	
	levelup = {
		[3] = {
			messages = {"Rotor learned \"Sabotage\"!"},
			skills = {
				require "data/battle/skills/Throw",
				require "data/battle/skills/Sabotage",
				GameState:getGatedSkill("ep4_abominable_rotor", "CallYeti")
			}
		},
	},

	specialmove = require "data/specialmoves/rotor",

	battle = {
		require "data/battle/RotorHit",
		require "data/battle/Skills",
		require "data/battle/Items",
	}
}