local Fun = require "util/EasingFunctions"

return {
	id = "babyt",
	name = "Baby T",
	altName = "Baby T",

	avatar = "avatar/babytavatar",
	sprite = "sprites/babyt",
	battlesprite = "sprites/babyt",

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
		--weapon = require "data/weapons/HockeyStick",
	},

	items = {
	},

	levelup = {
		[3] = {
			messages = {},
			skills = {
				GameState:getEarnedSkill("nicole_upgrade_scan", "Scan"),
				--require "data/battle/skills/Slap",
				--require "data/battle/skills/Fly",
			}
		}
	},
	
	specialmove = require "data/specialmoves/babyt",

	battle = {
		require "data/battle/SonicHit",
		require "data/battle/Skills",
		require "data/battle/Items"
	}
}