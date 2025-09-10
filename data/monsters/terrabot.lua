local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local BouncyText = require "actions/BouncyText"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"

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
	name = "Terrabot",
	altName = "Terrabot",
	sprite = "sprites/phantomstandin",
	
	mockSprite = "sprites/terrabot",
	mockSpriteOffset = Transform(-230, -200),

	stats = {
		xp = 120,
		maxhp = 5000,
		attack = 80,
		defense = 30,
		speed = 5,
		focus = 1,
		luck = 1,
	},

	boss = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "{h Laser Shields} might be a good idea...",

	onInit = function (self)
		
	end,

	behavior = function (self, target)
		if self.hp <= 0 then
			return Action()
		end
		
		return Serial {
			Animate(self.scene.partyByName.tails.sprite, "shock"),
			Animate(self.scene.partyByName.b.sprite, "shock"),
			Animate(self.scene.partyByName.babyt.sprite, "shock"),
			MessageBox{message="Tails: W-what is that thing!?{p60} It...{p60} it looks like--"},
			Animate(self.scene.partyByName.babyt.sprite, "sadleft"),
			PlayAudio("music", "sonicsad", 1.0, true, true),
			MessageBox{message="Baby T: Uncle!{p60} W...{p60}what have they done to you!?"},
			Animate(self.scene.partyByName.b.sprite, "seriousdown"),
			MessageBox{message="B: He's been roboticized..."},
			Animate(self.scene.partyByName.tails.sprite, "sadleft"),
			MessageBox{message="Tails: I'm sorry, Baby T..."},
			MessageBox{message="Terrabot: ..."},
			MessageBox{message="B: Your uncle is still in there, son. {p60}He's just buried under Robotnik's programming."},
			MessageBox{message="Baby T: Uncle! {p60}Please remember who you are!!"},
			MessageBox{message="Terrabot: ..."},
			Animate(self.scene.partyByName.b.sprite, "idleleft"),
			MessageBox{message="B: Let me try."},
			MessageBox{message="B: 111101001000101011010101010010010011100011"},
			Wait(1),
			-- ROAR
		}
	end
}