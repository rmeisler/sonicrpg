local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local BouncyText = require "actions/BouncyText"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"
local TypeText = require "actions/TypeText"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Robotnik",
	altName = "Robotnik",
	sprite = "sprites/robotnikbattle",

	stats = {
		xp = 200,
		maxhp = 5000,
		attack = 30,
		defense = 30,
		speed = 10,
		focus = 10,
		luck = 5,
	},

	boss = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "{h Laser Shields} might be a good idea...",

	onInit = function(self)
		-- Setup beam sprite
		self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
		self.beamSprite.transform.sx = 0
		self.beamSprite.transform.sy = 1
		self.beamSprite.transform.ox = 0
		self.beamSprite.color = {255,512,255,255}
		self.beamSprite:setAnimation("green")

		self.dropShadow = SpriteNode(self.scene, Transform.from(self.sprite.transform), nil, "dropshadow", nil, nil, "behind")
		self.dropShadow.transform.sx = 3
		self.dropShadow.transform.x = self.dropShadow.transform.x - self.sprite.w*2
		
		self.translate = GameState:isEquipped("babyt", ItemType.Accessory, "Translator Collar")
		
		self.sprite.transform.y = self.sprite.transform.y - 100
		
		self.scene.audio:stopMusic()
	end,

	behavior = function (self, target)
		if self.hp <= 0 then
			return Action()
		end
		
		if not self.introDone then
			self.introDone = true

			return Serial {
				PlayAudio("sfx", "yourstoryendshere", 1),
				Do(function() self.sprite:setAnimation("flyup") end),
				PlayAudio("music", "robotnikbattle", 0.5, true, true),
				Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - 100 end, 1),
				Do(function() self.sprite:setAnimation("idle") end),
				Spawn(Repeat(
					Serial {
						Ease(self.sprite.transform, "y", function() return self.sprite.transform.y + 50 end, 0.5),
						Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - 50 end, 0.5)
					}
				)),
			}
		else
			return Action()
		end
	end
}