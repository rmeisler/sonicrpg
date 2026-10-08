local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"
local Animate = require "actions/Animate"
local Try = require "actions/Try"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local BouncyText = require "actions/BouncyText"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local Throw = require "data/items/actions/Throw"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

return {
	name = "Mess",
	altName = "Mess",
	sprite = "sprites/messbot",

	stats = {
		xp    = 5,
		maxhp = 150,
		attack = 25,
		defense = 25,
		speed = 10,
		focus = 0,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},
	
	scan = "Look out for their grapple!",

	onInit = function(self)
		self.scene.bgImgColor = {170,170,170,255}
		self.scene.partyByName.sally.sprite.color = {170,170,170,255}
	end,
	
	behavior = function (self, target)
		if self.noPower then
			return Action()
		end
	
		return Action()
	end
}