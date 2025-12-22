local Fun = require "util/EasingFunctions"
local Transform = require "util/Transform"

return {
	id = "babyt",
	name = "Baby T",
	altName = "Baby T",

	avatar = "avatar/babytavatar",
	sprite = "sprites/babyt",
	battlesprite = "sprites/babyt",
	textOffset = Transform(-50, 0),

	startingstats = {
		startxp = 0,
		maxhp   = 250,
		maxsp   = 5,
		attack  = 15,
		defense = 20,
		speed   = 6,
		focus   = 3,
		luck    = 3,
	},

	maxstats = {
		startxp = 95000,
		maxhp   = 10000,
		maxsp   = 100,
		attack  = 100,
		defense = 100,
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
		accessory = require "data/accessories/TranslatorCollar",
	},

	items = {
	},

	levelup = {
		[1] = {
			messages = {"Baby T learned \"{h Charge}\"!"},
			skills = {
				require "data/battle/skills/Charge"
			}
		},
		[4] = {
			messages = {"Baby T learned \"{h Roar}\"!"},
			skills = {
				require "data/battle/skills/Charge",
				require "data/battle/skills/Roar",
			}
		},
		[5] = {
			messages = {"Baby T learned \"{h Support}\"!"},
			skills = {
				require "data/battle/skills/Charge",
				require "data/battle/skills/Roar",
				require "data/battle/skills/Support",
			}
		},
		[6] = {
			messages = {"Baby T learned \"{h Super Support}\"!"},
			skills = {
				require "data/battle/skills/Charge",
				require "data/battle/skills/Roar",
				require "data/battle/skills/Support",
				require "data/battle/skills/SuperSupport",
			}
		}
	},
	
	specialmove = require "data/specialmoves/babyt",

	battle = {
		require "data/battle/BabyTHit",
		require "data/battle/Skills",
		require "data/battle/Items"
	}
}