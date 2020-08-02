local Fun = require "util/EasingFunctions"

return {
	id = "sally",
	name = "Sally",
	altName = "Sally",

	avatar = "avatar/sally",
	sprite = "sprites/sally",
	battlesprite = "sprites/sallybattle",

	startingstats = {
		startxp = 0,
		maxhp   = 500,
		maxsp   = 15,
		attack  = 5,
		defense = 9,
		speed   = 8,
		focus   = 8,
		luck    = 2,
	},

	maxstats = {
		startxp = 99000,
		maxhp   = 10000,
		maxsp   = 100,
		attack  = 50,
		defense = 90,
		speed   = 80,
		focus   = 100,
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
		weapon    = nil,
		armor     = nil,
		accessory = require "data/accessories/Boots",
	},

	items = {
		{count = 1, item = require "data/items/GreenLeaf"},
		{count = 1, item = require "data/items/CrystalWater"},
	},

	levelup = {
		[1] = {
			messages = {},
			skills = {
				require "data/battle/skills/Scan",
			}
		},
		[2] = {
			messages = {"Sally learned \"Infect\"!"},
			skills = {
				require "data/battle/skills/Scan",
				require "data/battle/skills/Infect",
			}
		},
		[3] = {
			messages = {"Sally learned \"Rally\"!"},
			skills = {
				require "data/battle/skills/Scan",
				require "data/battle/skills/Infect",
				require "data/battle/skills/Rally",
			}
		},
	},
	
	specialmove = require "data/specialmoves/sally",

	battle = {
		require "data/battle/SallyHit",
		require "data/battle/Skills",
		require "data/battle/Items"
	}
}