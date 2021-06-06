local Action = require "actions/Action"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"

return {
	name = "Right Arm",
	altName = "Right Arm",
	sprite = "sprites/juggerbotbody",
	
	mockSprite = "sprites/juggerbotrightarm",
	mockSpriteOffset = Transform(0, 0),

	stats = {
		xp      = 0,
		maxhp   = 1000,
		attack  = 1,
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
		self.scene.juggerbotrightarm = self
	end,
	
	onInit = function(self)
		-- Relocate arm to proper area of juggerbot body
		local body = self.scene.juggerbotbody
		self.mockSprite.transform.ox = 0
		self.mockSprite.transform.oy = 0
		self.mockSprite.transform.x = body.sprite.transform.x - body.sprite.w - 10
		self.mockSprite.transform.y = body.sprite.transform.y - body.sprite.h + 50
		self.mockSprite.sortOrderY = body.sprite.sortOrderY + 1
		
		-- Locate where we want the cursor to be
		self.sprite.transform.x = body.sprite.transform.x - 40
		self.sprite.transform.y = body.sprite.transform.y + 20
		self.sprite.h = self.sprite.h - 20
	end,
	
	behavior = function (self, target)
		return Action()
	end
}