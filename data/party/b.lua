local Fun = require "util/EasingFunctions"

return {
	id = "b",
	name = "B",
	altName = "B",

	avatar = "avatar/bavatar",
	sprite = "sprites/b",
	battlesprite = "sprites/b",

	startingstats = {
		startxp = 0,
		maxhp   = 450,
		maxsp   = 10,
		attack  = 8,
		defense = 7,
		speed   = 7,
		focus   = 5,
		luck    = 4,
	},

	maxstats = {
		startxp = 95000,
		maxhp   = 10000,
		maxsp   = 100,
		attack  = 80,
		defense = 70,
		speed   = 70,
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
		weapon    = require "data/weapons/ReflectorMecha",
	},

	items = {
	},
	
	levelup = {
		[5] = {
			messages = {},
			skills = {
				require "data/battle/skills/Protect",
				require "data/battle/skills/Encourage",
				require "data/battle/skills/EMP"
			}
		},
	},
	
	specialmove = require "data/specialmoves/b",

	battle = {
		require "data/battle/BHit",
		require "data/battle/Skills",
		require "data/battle/Items",
	}
}