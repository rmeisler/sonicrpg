local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Animate = require "actions/Animate"
local Try = require "actions/Try"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local BouncyText = require "actions/BouncyText"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local PressZ = require "data/battle/actions/PressZ"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

return {
	name = "Fleet",
	altName = "Fleet",
	sprite = "sprites/fleet",

	stats = {
		xp    = 0,
		maxhp = 1, --1000,
		attack = 50,
		defense = 30,
		speed = 10,
		focus = 0,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},

	onInit = function(self)
		-- Change logan and rotor skills to only be throwing snowball or items
		for _,mem in pairs(self.scene.party) do
			mem.options = {}
			mem:addBattleOption(require "data/battle/RotorHit")
			mem:addBattleOption(require "data/battle/Items")
		end

		-- Leave on death
		self.die = function(_)
			GameState:setFlag("ep4_beat_fleet")
			GameState:grantItem(require "data/items/TopHat", 1)
			return Serial {
				Animate(self.sprite, "hatfrustrated"),
				MessageBox {message="Fleet: Ok, ok{p60}, I give up!"},
				MessageBox {message="Fleet gave you her {h Top Hat}!", rect=MessageBox.HEADLINER_RECT, sfx="levelup"},
				Animate(self.sprite, "frustrated"),
				Wait(0.5),
				self.scene:earlyExit()
			}
		end
	end,

	behavior = function (self, target)
		local snowball = SpriteNode(
			self.scene,
			Transform.from(self.sprite.transform),
			{255,255,255,0},
			"snowball",
			nil,
			nil,
			"ui"
		)
		snowball.transform.ox = snowball.w/2
		snowball.transform.oy = snowball.h/2
		snowball.transform.angle = math.pi / 6
		return Serial {
			Telegraph(self, "Fastball", {255,255,255,50}),
			Animate(self.sprite, "prethrow"),
			Wait(0.5),
			Animate(self.sprite, "throw", true),
			Do(function()
				snowball.color[4] = 255
			end),
			Parallel {
				Serial {
					Parallel {
						Ease(snowball.transform, "x", target.sprite.transform.x, 2.5, "linear"),
						Ease(snowball.transform, "y", target.sprite.transform.y, 2.5, "linear")
					},
					Do(function()
						snowball:remove()
						self.sprite:setAnimation("idle")
					end)
				},
				Ease(snowball.transform, "angle", -math.pi * 3.25, 2.5, "linear"),
				PressZ(
					self,
					target,
					Serial {
						PlayAudio("sfx", "pressx", 1.0, true),
						target:takeDamage({miss = true, attack = 1, speed = 1, luck = 1})
					},
					target:takeDamage(self.stats)
				)
			},
			
		}
	end
}