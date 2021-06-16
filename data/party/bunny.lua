local Fun = require "util/EasingFunctions"

return {
	id = "bunny",
	name = "Bunnie",
	altName = "Bunnie",

	avatar = "avatar/bunnyavatar",
	sprite = "sprites/bunny",
	battlesprite = "sprites/bunnybattle",

	startingstats = {
		startxp = 0,
		maxhp   = 350,
		maxsp   = 5,
		attack  = 8,
		defense = 8,
		speed   = 5,
		focus   = 1,
		luck    = 2,
	},

	maxstats = {
		startxp = 99999,
		maxhp   = 10000,
		maxsp   = 100,
		attack  = 100,
		defense = 90,
		speed   = 70,
		focus   = 40,
		luck    = 50,
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
		weapon    = require "data/weapons/Mecha",
		armor     = nil,
		accessory = nil,
	},

	items = {},

	levelup = {
		[1] = {
			messages = {},
			skills = {
				require "data/battle/skills/Grab"
			}
		},
		[4] = {
			messages = {"Bunnie learned \"Rocket Punch\"!"},
			skills = {
				require "data/battle/skills/Grab",
				require "data/battle/skills/RocketPunch"
			}
		},
		[5] = {
			messages = {"Bunnie learned \"Boulder\"!"},
			skills = {
				require "data/battle/skills/Grab",
				require "data/battle/skills/RocketPunch",
				require "data/battle/skills/Boulder"
			}
		}
	},
	
	specialmove = require "data/specialmoves/bunny",
	
	battle = {
		require "data/battle/BunnyHit",
		require "data/battle/Skills",
		require "data/battle/Items"
	}
}