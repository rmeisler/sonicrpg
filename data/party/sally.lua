local Fun = require "util/EasingFunctions"

return {
	id = "sally",
	name = "Sally",
	altName = "Sally",

	avatar = "avatar/sallyavatar",
	sprite = "sprites/sally",
	battlesprite = "sprites/sallybattle",

	startingstats = {
		startxp = 0,
		maxhp   = 500,
		maxsp   = 15,
		attack  = 7,
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
		armor = require "data/armor/ElbowPads",
		legs = require "data/legs/Boots",
		accessory = require "data/accessories/LeatherSash",
	},

	items = {
		{count = 3, item = require "data/items/GreenLeaf"},
		{count = 3, item = require "data/items/BlueLeaf"},
		{count = 3, item = require "data/items/CrystalWater"}
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
		[5] = {
			messages = {"Sally learned \"Interrupt\"!"},
			skills = {
				GameState:getEarnedSkill("nicole_upgrade_scan", "Scan"),
				GameState:getEarnedSkill("nicole_upgrade_infect", "Infect"),
				require "data/battle/skills/Rally",
				GameState:getEarnedSkill("nicole_upgrade_interrupt", "Interrupt")
			}
		},
		[7] = {
			messages = {"Sally learned \"Inspire\"!"},
			skills = {
				GameState:getEarnedSkill("nicole_upgrade_scan", "Scan"),
				GameState:getEarnedSkill("nicole_upgrade_infect", "Infect"),
				require "data/battle/skills/Rally",
				GameState:getEarnedSkill("nicole_upgrade_interrupt", "Interrupt"),
				require "data/battle/skills/Inspire"
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