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
		maxhp   = 350,
		maxsp   = 5,
		attack  = 5,
		defense = 5,
		speed   = 5,
		focus   = 5,
		luck    = 5,
	},

	maxstats = {
		startxp = 95000,
		maxhp   = 10000,
		maxsp   = 100,
		attack  = 50,
		defense = 50,
		speed   = 50,
		focus   = 50,
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
		weapon = require "data/weapons/Computer",
		armor  = require "data/armor/RoyalCoat",
		legs   = require "data/legs/Boots"
	},

	items = {
		{count = 3, item = require "data/items/GreenLeaf"},
		{count = 3, item = require "data/items/BlueLeaf"},
		{count = 3, item = require "data/items/CrystalWater"},
		{count = 1, item = require "data/items/RainbowSyrup"},
	},

	levelup = {
		[5] = {
			messages = {"Logan learned \"Super Shield\"!"},
			skills = {
				require "data/battle/skills/LoganScan",
				require "data/battle/skills/Hologram",
				GameState:getGatedSkill("ep4_abominable_logan", "CallYeti")
			}
		},
	},

	specialmove = require "data/specialmoves/logan",

	battle = {
		require "data/battle/LoganHit",
		require "data/battle/Skills",
		require "data/battle/Items",
	}
}