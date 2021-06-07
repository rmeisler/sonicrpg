local Do = require "actions/Do"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"

return {
	name = "Left Arm",
	altName = "Left Arm",
	sprite = "sprites/juggerbotbody",
	
	mockSprite = "sprites/juggerbotleftarm",
	mockSpriteOffset = Transform(0, 0),

	stats = {
		xp      = 0,
		maxhp   = 1000,
		attack  = 30,
		defense = 10,
		speed   = 1,
		focus   = 1,
		luck    = 1,
	},
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		
	},
	
	scan = "Focus damage on Juggerbot's weapons systems.",
	
	skipAnimation = true,

	onPreInit = function(self)
		self.scene.juggerbotleftarm = self
	end,
	
	onInit = function(self)
		-- Relocate arm to proper area of juggerbot body
		local body = self.scene.juggerbotbody
		self.mockSprite.transform.ox = 0
		self.mockSprite.transform.oy = 0
		self.mockSprite.transform.x = body.sprite.transform.x - body.sprite.w + 30
		self.mockSprite.transform.y = body.sprite.transform.y - body.sprite.h + 50
		self.mockSprite.sortOrderY = body.sprite.sortOrderY - 200
		
		-- Locate where we want the cursor to be
		self.sprite.transform.x = body.sprite.transform.x + 50
		self.sprite.transform.y = body.sprite.transform.y + 20
		self.sprite.h = self.sprite.h - 20
	end,
	
	behavior = function (self, target)
		return Do(function() end)
	end
}