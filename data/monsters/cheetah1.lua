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
local IfElse = require "actions/IfElse"
local BouncyText = require "actions/BouncyText"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"
local TypeText = require "actions/TypeText"
local While = require "actions/While"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"
local Parallax = require "object/Parallax"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Cheetah",
	altName = "Cheetah",
	sprite = "sprites/cheeta",

	stats = {
		xp = 200,
		maxhp = 10000,
		attack = 40,
		defense = 40,
		speed = 50,
		focus = 10,
		luck = 5,
	},

	boss = true,
	is_bot = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "I'm picking up unusually high energy readings, Sally...",

	onConfused = function(self)
		return Serial {
			Do(function() self.confused = false end),
			MessageBox {message=self.name.." is unfazed.", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)}
		}
	end,
	
	onInit = function(self)
		self.scene.partyByName.sonic.stats.miss = true
		self.scene.partyByName.sally.stats.miss = true
		self.scene.partyByName.sonic.stats.damage = 0
		self.scene.partyByName.sally.stats.damage = 0
		self.turn = 0
	end,

	behavior = function (self, target)
		if self.turn == 0 then
			self.turn = self.turn + 1
			return Serial {
				Wait(2),
				Animate(self.scene.partyByName.sally.sprite, "thinking4"),
				MessageBox{message="Sally: Why is it just standing there like that?..."},
				Wait(1),
				Animate(self.scene.partyByName.sonic.sprite, "takenback"),
				MessageBox{message="Sonic: Somethin's not right about this..."},
				Wait(0.5),
				Animate(self.scene.partyByName.sally.sprite, "idle"),
				Animate(self.scene.partyByName.sonic.sprite, "idle")
			}
		elseif self.turn == 1 then
			self.turn = self.turn + 1
			return Serial {
				PlayAudio("sfx", "cheetabreathe", 1, true),
				Telegraph(self, "Cheetah stares at Sonic...{p80}", {500,500,500,50}, 2)
			}
		elseif self.turn == 2 then
			self.turn = self.turn + 1
			return Serial {
				Do(function() self.sprite:setGlow({255,255,0,255},2) end),
				PlayAudio("sfx", "usering", 1.0, true),
				Parallel {
					Ease(self.sprite, "glowSize", 6, 2),
					Ease(self.sprite.color, 1, 500, 2),
					Ease(self.sprite.color, 2, 500, 2),
				},
				MessageBox {
					message="Cheetah is emitting a mysterious light...",
					rect=MessageBox.HEADLINER_RECT,
					closeAction=Wait(2)
				},
				Parallel {
					Ease(self.sprite.glowColor, 4, 0, 5, "quad"),
					Ease(self.sprite, "glowSize", 2, 5, "quad"),
					Ease(self.sprite.color, 1, 255, 5, "quad"),
					Ease(self.sprite.color, 2, 255, 5, "quad")
				},
				Do(function() self.sprite:removeGlow() end)
			}
		elseif self.turn == 3 then
			return Serial {
				Telegraph(self, "Yellow Streak", {500,500,500,50}, 2),
				PlayAudio("sfx", "cheetarun", 1, true),
				Do(function() self.sprite:setAnimation("runright") end),
				Wait(1),
				Ease(self.sprite.transform, "x", function() return self.sprite.transform.x + 700 end, 8)
			}
		end
	end
}