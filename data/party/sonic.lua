local Fun = require "util/EasingFunctions"

return {
	id = "sonic",
	name = "Sonic",
	altName = "Sonic",

	avatar = "avatar/sonicavatar",
	sprite = "sprites/sonic",
	battlesprite = "sprites/sonicbattle",

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
		weapon    = require "data/weapons/Gloves",
		armor     = nil,
		accessory = require "data/accessories/Backpack",
	},

	items = {
		{count = 1, item = require "data/items/Carrot"},
		{count = 1, item = require "data/items/Mushroom"},
		{count = 2, item = require "data/items/LaserShield"},
	},
	
	levelup = {
		[1] = {
			messages = {},
			skills = {
				require "data/battle/skills/Spindash",
				--require "data/battle/skills/PowerRing"
			}
		},
		[2] = {
			messages = {"Sonic learned \"Roundabout\"!"},
			skills = {
				require "data/battle/skills/Spindash",
				require "data/battle/skills/Roundabout",
			}
		},
		[4] = {
			messages = {"Sonic learned \"Tease\"!"},
			skills = {
				require "data/battle/skills/Spindash",
				require "data/battle/skills/Roundabout",
				require "data/battle/skills/Tease"
			}
		},
	},
	
	specialmove = require "data/specialmoves/sonic",

	battle = {
		require "data/battle/SonicHit",
		require "data/battle/Skills",
		require "data/battle/Items",
	}
}