local Fun = require "util/EasingFunctions"

return {
	id = "antoine",
	name = "Antoine",
	altName = "Antoine",

	avatar = "avatar/antoineavatar",
	sprite = "sprites/antoine",
	battlesprite = "sprites/antoinebattle",

	startingstats = {
		startxp = 0,
		maxhp   = 500,
		maxsp   = 10,
		attack  = 5,
		defense = 5,
		speed   = 6,
		focus   = 6,
		luck    = 6,
	},

	maxstats = {
		startxp = 95000,
		maxhp   = 10000,
		maxsp   = 100,
		attack  = 50,
		defense = 50,
		speed   = 60,
		focus   = 60,
		luck    = 60,
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
		weapon = nil,
		armor  = require "data/armor/RoyalCoat",
		legs   = require "data/legs/Boots",
	},

	items = {
	},
	
	levelup = {
		[2] = {
			messages = {"Antoine learned \"Bore\"!"},
			skills = {
				require "data/battle/skills/Bore",
			}
		},
		[5] = {
			messages = {"Antoine learned \"Run\"!"},
			skills = {
				require "data/battle/skills/Bore",
				require "data/battle/skills/Run",
			}
		},
		[6] = {
			messages = {"Antoine learned \"Cook\"!"},
			skills = {
				require "data/battle/skills/Bore",
				require "data/battle/skills/Run",
				require "data/battle/skills/Cook",
			}
		}
	},
	
	specialmove = require "data/specialmoves/antoine",

	battle = {
		require "data/battle/AntoineHit",
		require "data/battle/Skills",
		require "data/battle/Items",
	}
}