local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local BouncyText = require "actions/BouncyText"
local Repeat = require "actions/Repeat"
local While = require "actions/While"
local Executor = require "actions/Executor"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"
local SpriteNode = require "object/SpriteNode"

return {
	name = "Head",
	altName = "Head",
	sprite = "sprites/juggerbotbody",
	
	mockSprite = "sprites/juggerbothead",
	mockSpriteOffset = Transform(0, 0),

	stats = {
		xp      = 0,
		maxhp   = 800,
		attack  = 1,
		defense = 10,
		speed   = 1,
		focus   = 1,
		luck    = 1,
	},
	
	boss_part = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		
	},
	
	scan = "Focus damage on Juggerbot's weapons systems.",
	
	skipAnimation = true,

	onPreInit = function(self)
		self.scene.juggerbothead = self
	end,
	
	onInit = function(self)
		-- Relocate head to proper area of juggerbot body
		local body = self.scene.juggerbotbody

		self.mockSprite.transform.ox = 0
		self.mockSprite.transform.oy = 0
		self.mockSprite.transform.x = body.sprite.transform.x - body.sprite.w + 89
		self.mockSprite.transform.y = body.sprite.transform.y - body.sprite.h + 35
		self.mockSprite.sortOrderY = body.sprite.sortOrderY + 1
		
		-- Locate where we want the cursor to be
		self.sprite.transform.x = body.sprite.transform.x + 45
		self.sprite.transform.y = body.sprite.transform.y + 5
		self.sprite.h = self.sprite.h - 5
	end,
	
	behavior = function (self, target)
		if not self.headturns then
			self.headturns = -1
		end
		self.headturns = self.headturns + 1
		if (self.headturns % 3) > 0 then
			return Action()
		end
		
		local headSp = self:getSprite()
		return Serial {
			PlayAudio("sfx", "juggerbotroar", 0.3, true),
			Animate(headSp, "roar"),
			Parallel {
				self.scene:screenShake(20, 30, 14),
				Repeat(Serial {
					Ease(headSp.transform, "x", headSp.transform.x - 1, 10),
					Ease(headSp.transform, "x", headSp.transform.x + 1, 10),
				}, 10)
			},
			Animate(headSp, "undoroar"),
			Animate(headSp, "idleright")
		}
	end,
	
	getBackwardAnim = function(self)
		return "idleright"
	end
}