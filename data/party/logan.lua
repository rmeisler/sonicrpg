local Fun = require "util/EasingFunctions"

return {
	id = "logan",
	name = "Logan",
	altName = "Logan",

	avatar = "avatar/loganavatar",
	sprite = "sprites/logan",
	battlesprite = "sprites/logan",

	startingstats = {
		startxp = 0,
		maxhp   = 450,
		maxsp   = 10,
		attack  = 8,
		defense = 7,
		speed   = 10,
		focus   = 5,
		luck    = 4,
	},

	maxstats = {
		startxp = 95000,
		maxhp   = 10000,
		maxsp   = 100,
		attack  = 80,
		defense = 70,
		speed   = 100,
		focus   = 80,
		luck    = 40,
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
	},

	items = {
	},
	
	levelup = {
		[1] = {
			messages = {},
			skills = {
				require "data/battle/skills/Spindash",
				--require "data/battle/skills/PowerRing"
			}
		},
		--[[[3] = {
			messages = {"Sonic learned \"Bounce\"!"},
			skills = {
				require "data/battle/skills/Spindash",
				require "data/battle/skills/Bounce",
			}
		},]]
	},
	
	specialmove = require "data/specialmoves/logan",

	battle = {
		require "data/battle/SonicHit",
		require "data/battle/Skills",
		require "data/battle/Items",
	}
}