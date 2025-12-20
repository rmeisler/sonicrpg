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
local While = require "actions/While"

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
	sprite = "sprites/phantomstandin",
	
	mockSprite = "sprites/robotnikbattle",
	mockSpriteOffset = Transform(-50, -50),

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

		self.dropShadow2 = SpriteNode(self.scene, Transform(), nil, "dropshadow", nil, nil, "behind")
		self.dropShadow2.transform.ox = self.dropShadow.w/2
		self.dropShadow2.transform.oy = self.dropShadow.h/2
		self.dropShadow2.transform.sx = 3
		self.dropShadow2.transform.sy = 2
		self.dropShadow2.color[4] = 0

		self.translate = GameState:isEquipped("babyt", ItemType.Accessory, "Translator Collar")
		self.aerial = true
		
		local selfSprite = self:getSprite()
		selfSprite.transform.x = selfSprite.transform.x - 50
		selfSprite.transform.y = selfSprite.transform.y - 100
		selfSprite.continuousAnimation = true
		
		self.calledShotKnockbackFn = function(self, impact, direction)
			local selfSprite = self:getSprite()
			return Serial {
				Do(function()
					self.aerial = false
				end),
				PlayAudio("sfx", "robotnikhurt", 1, true),
				Animate(selfSprite, "veryhurt"),
				Parallel {
					Ease(selfSprite.transform, "x", function() return selfSprite.transform.x - 20 end, 3),
					Ease(selfSprite.transform, "y", function() return selfSprite.transform.y - 20 end, 3),
					Ease(self.dropShadow2.transform, "x", function() return self.dropShadow2.transform.x - 20 end, 3),
				},
				Ease(selfSprite.transform, "y", function() return selfSprite.transform.y + 100 end, 6),
				Animate(selfSprite, "knockdown"),
				Ease(selfSprite.transform, "y", function() return selfSprite.transform.y - 5 end, 8),
				Ease(selfSprite.transform, "y", function() return selfSprite.transform.y + 5 end, 8),
				Do(function()
					selfSprite:pushOverride("idle", "knockdown")
					selfSprite:pushOverride("hurt", "knockdown")

					self.sprite.w = self.sprite.w - 80
					self.sprite.h = self.sprite.h - 80
				end)
			}
		end

		self.scene.audio:stopMusic()
	end,

	behavior = function (self, target)
		if self.hp <= 0 then
			return Action()
		end
		
		if not self.introDone then
			self.introDone = true

			local selfSprite = self:getSprite()
			return Serial {
				PlayAudio("sfx", "yourstoryendshere", 1),
				Do(function()
					selfSprite:setAnimation("flyup")

					self.dropShadow2.color[4] = 255
					self.dropShadow2.transform.x = selfSprite.transform.x + selfSprite.w - self.dropShadow2.w/2
					self.dropShadow2.transform.y = selfSprite.transform.y + selfSprite.h*2
				end),
				PlayAudio("music", "robotnikbattle", 0.3, true, true),
				Parallel {
					Ease(selfSprite.transform, "y", function() return selfSprite.transform.y - 100 end, 1),
					Ease(self.dropShadow2.transform, "sx", 2.5, 1)
				},
				Do(function()
					selfSprite:setAnimation("idle")

					self.sprite.w = self.sprite.w + 80
					self.sprite.h = self.sprite.h + 80
				end),
				Spawn(While(
					function() return self.aerial end,
					Repeat(
						Serial {
							Parallel {
								Ease(selfSprite.transform, "y", function() return self:getSprite().transform.y + 50 end, 0.5),
								Ease(self.dropShadow2.transform, "sx", 3, 0.5),
							},
							Parallel {
								Ease(selfSprite.transform, "y", function() return self:getSprite().transform.y - 50 end, 0.5),
								Ease(self.dropShadow2.transform, "sx", 2.5, 0.5)
							},
						}
					)
				)),
			}
		else
			return Action()
		end
	end
}