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
local BasicNPC = require "object/BasicNPC"

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

	scan = "Cheetah is emitting an unusual aura...",

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
		self.turn = 3
	end,

	behavior = function (self, target)
		if self.turn == 0 then
			self.turn = self.turn + 1
			return Serial {
				Wait(1),
				MessageBox{message="Sally: Sonic{p80}, isn't this that bot you raced awhile\nback?..."},
				Wait(1),
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
			local sonicXForm = self.scene.partyByName.sonic.sprite.transform
			local cheetahOrigX = self.sprite.transform.x
			local ring = SpriteNode(
				self.scene,
				Transform(
					self.scene.partyByName.sonic.sprite.transform.x - 35,
					self.scene.partyByName.sonic.sprite.transform.y - 20
				),
				{255,255,255,0},
				"powerring",
				nil,
				nil,
				"infront"
			)
			ring.transform.sx = 2
			ring.transform.sy = 2

			self.scene.hint = "runaway"
			self.scene.noBattleMusic = true

			return Serial {
				Telegraph(self, "Yellow Streak", {500,500,500,50}, 2),
				PlayAudio("sfx", "cheetarun", 1, true),
				Do(function() self.sprite:setAnimation("runright") end),
				Wait(1),
				Do(function()
					local dust = SpriteNode(
						self.scene,
						Transform(self.sprite.transform.x, self.sprite.transform.y),
						nil,
						"dust",
						nil,
						nil,
						"sprites"
					)
					dust.color[1] = 130
					dust.color[2] = 130
					dust.color[3] = 200
					dust.color[4] = 255
					dust.sortOrderY = 9999

					dust.transform.x = dust.transform.x - self.sprite.w*2
					dust.transform.y = dust.transform.y - dust.h*4
					dust.transform.sx = 6
					dust.transform.sy = 6
					dust:setAnimation("right")

					dust.transform.y = dust.transform.y - 10

					dust.animations[dust.selected].callback = function()
						local ref = dust
						ref:remove()
					end
				end),
				Ease(self.sprite.transform, "x", function() return self.sprite.transform.x + 700 end, 8),

				-- Knock Sonic into the air and fall to the ground dead (1 hp)
				PlayAudio("sfx", "smack2", 1, true),
				Animate(self.scene.partyByName.sonic.sprite, "hurt"),
				Do(function()
					self.scene.partyByName.sonic.sprite:pushOverride("idle", "dead")
				end),
				Parallel {
					Serial {
						Ease(sonicXForm, "y", function() return sonicXForm.y - 150 end, 5),
						Wait(0.2),
						Ease(sonicXForm, "y", function() return sonicXForm.y + 150 end, 5),
						PlayAudio("sfx", "bang", 1, true),
						Animate(self.scene.partyByName.sonic.sprite, "dead"),
						Ease(sonicXForm, "y", function() return sonicXForm.y - 2 end, 8),
						Ease(sonicXForm, "y", function() return sonicXForm.y + 2 end, 8)
					},
					self.scene.partyByName.sonic:takeDamage(
						{
							attack=1,
							speed=1,
							luck=0,
							damage=self.scene.partyByName.sonic.hp-1,
						},
						false,
						BattleActor.noKnockback
					)
				},

				Animate(self.scene.partyByName.sally.sprite, "shock"),
				MessageBox{message="Sally: Sonic!!"},
				Do(function()
					self.sprite.transform.x = -100
				end),
				PlayAudio("sfx", "cheetarun", 1, true),
				Ease(self.sprite.transform, "x", cheetahOrigX, 8),
				Do(function() self.sprite:setAnimation("idle") end),
				Wait(1),
				Animate(self.scene.partyByName.sonic.sprite, "stun"),
				Ease(sonicXForm, "x", sonicXForm.x, 1),
				Do(function()
					self.scene.partyByName.sonic.sprite:popOverride("idle")
				end),
				MessageBox{message="Sonic: Ugh..."},
				MessageBox{message="Sonic: T-This guy's fast... {p60}faster than last time..."},
				Wait(0.5),
				Animate(self.scene.partyByName.sally.sprite, "idle_grit"),
				MessageBox{message="Sally: What do we do?"},
				Wait(0.5),
				Animate(self.scene.partyByName.sonic.sprite, "idle"),
				MessageBox{message="Sonic: Pull out all the stops!"},
				AudioFade("music", 1, 0, 1),
				Animate(self.scene.partyByName.sonic.sprite, "fish_backpack"),
				Animate(self.scene.partyByName.sonic.sprite, "foundring_backpack"),
				Animate(self.scene.partyByName.sonic.sprite, "liftring"),
				Wait(0.5),
				PlayAudio("sfx", "cheetarun", 1, true),
				Do(function() self.sprite:setAnimation("runright") end),
				Ease(self.sprite.transform, "x", function() return self.sprite.transform.x + 700 end, 8),
				Animate(self.scene.partyByName.sonic.sprite, "noring_shocked_idle"),
				Do(function()
					ring.color[4] = 255
				end),
				PlayAudio("sfx", "slice", 0.2, true),
				Parallel {
					Ease(ring.transform, "x", function() return ring.transform.x + 300 end, 0.7),
					Ease(ring.transform, "y", function() return ring.transform.y - 150 end, 1.5, "linear")
				},
				Animate(self.scene.partyByName.sally.sprite, "shock"),
				Wait(2),
				Do(function()
					self.sprite.transform.x = -100
				end),
				PlayAudio("sfx", "cheetarun", 1, true),
				Ease(self.sprite.transform, "x", cheetahOrigX, 8),
				Do(function() self.sprite:setAnimation("idle") end),

				Wait(2),
				MessageBox{message="Sonic: ..."},
				PlayAudio("music", "sonicscared", 1, true, true),
				Wait(1),
				Animate(self.scene.partyByName.sally.sprite, "idle_grit"),
				MessageBox{message="Sally: Sonic...?"},
				PlayAudio("sfx", "cheetabreathe", 1, true),
				Wait(1),
				Animate(self.scene.partyByName.sonic.sprite, "scared"),
				MessageBox{message="Sonic: ..."},
				Wait(1),
				Animate(self.scene.partyByName.sally.sprite, "idle_grit_lookdown"),
				MessageBox{message="Sally: Sonic!"},
				PlayAudio("sfx", "cheetabreathe", 1, true),
				Wait(1),
				MessageBox{message="Sonic: ..."},
				Animate(self.scene.partyByName.sally.sprite, "idle_shout"),
				MessageBox{message="Sally: Sonic!! {p80}Run!!"},

				Animate(self.scene.partyByName.sonic.sprite, "scared_chargerun1"),
				PlayAudio("sfx", "sonicrun", 1, true),
				Do(function() self.scene.partyByName.sonic.sprite:setAnimation("scared_chargerun2") end),
				Parallel {
					Ease(self.scene.partyByName.sally.sprite.transform, "x", function() return self.scene.partyByName.sally.sprite.transform.x + 30 end, 3),
					Ease(self.scene.partyByName.sally.sprite.transform, "y", function() return self.scene.partyByName.sally.sprite.transform.y + 50 end, 3)
				},
				Do(function()
					self.scene.partyByName.sally.sprite:remove()
				end),
				Wait(0.5),
				Do(function()
					self.scene.partyByName.sonic.sprite:setAnimation("juiceright")
					
					local dust = SpriteNode(
						self.scene,
						Transform(sonicXForm.x, sonicXForm.y),
						nil,
						"dust",
						nil,
						nil,
						"sprites"
					)
					dust.color[1] = 130
					dust.color[2] = 130
					dust.color[3] = 200
					dust.color[4] = 255
					dust.sortOrderY = 9999

					dust.transform.x = dust.transform.x - self.scene.partyByName.sonic.sprite.w*2
					dust.transform.y = dust.transform.y - dust.h*4
					dust.transform.sx = 6
					dust.transform.sy = 6
					dust:setAnimation("right")

					dust.transform.y = dust.transform.y - 10

					dust.animations[dust.selected].callback = function()
						local ref = dust
						ref:remove()
					end
				end),
				Ease(sonicXForm, "x", function() return sonicXForm.x + 200 end, 10),
				Wait(2),
				self.scene:earlyExit(),
				Do(function() end)
			}
		end
	end
}