local Fun = require "util/EasingFunctions"

return {
	id = "tails",
	name = "Tails",
	altName = "Tails",

	avatar = "avatar/tailsavatar",
	sprite = "sprites/tails",
	battlesprite = "sprites/tails",

	startingstats = {
		startxp = 0,
		maxhp   = 350,
		maxsp   = 10,
		attack  = 7,
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
		weapon = require "data/weapons/HockeyStick",
		accessory = require "data/accessories/LuckyCoin",
	},

	items = {
	},

	levelup = {
		[3] = {
			messages = {},
			skills = {
				--require "data/battle/skills/SlapShot",
				--require "data/battle/skills/Fly",
			}
		}
	},
	
	specialmove = require "data/specialmoves/tails",

	battle = {
		require "data/battle/TailsHit",
		require "data/battle/Skills",
		require "data/battle/Items"
	}
}