local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local Do = require "actions/Do"
local Spawn = require "actions/Spawn"
local YieldUntil = require "actions/YieldUntil"
local While = require "actions/While"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local IfElse = require "actions/IfElse"
local Action = require "actions/Action"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Telegraph = require "data/monsters/actions/Telegraph"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

local MakeWeapon = function(self)
	local spriteName
	if GameState:isEquipped("rotor", ItemType.Weapon, "Hammer") then
		spriteName = "hammer"
	elseif GameState:isEquipped("rotor", ItemType.Weapon, "Wrench") then
		spriteName = "wrench"
	else
		return Telegraph(self, "No weapon equipped...", {255,255,255,50})
	end
	local wrench = SpriteNode(
		self.scene,
		Transform.from(self.sprite.transform),
		{255,255,255,255},
		spriteName,
		nil,
		nil,
		"ui"
	)
	wrench.transform.ox = wrench.w/2
	wrench.transform.oy = wrench.h/2
	wrench.transform.angle = math.pi / 6
	wrench.transform.x = wrench.transform.x + 49 - wrench.w/2
	wrench.transform.y = wrench.transform.y + 42 - wrench.h/2
	return wrench
end

local Update = function(self, dt)
	if self.timeDelay > 0 then
		self.timeDelay = self.timeDelay - dt
	end
end

local KeyTrigger = function(self, key)
	if self.timeDelay > 0 then
		return
	end
	if key == self.curKey then
		self.timeDelay = 0.2

		-- Alternate between x and z
		if self.curKey == "x" then
			self.pressx.color[4] = 0
			self.pressz.color[4] = 255
			self.curKey = "z"
		else
			self.pressz.color[4] = 0
			self.pressx.color[4] = 255
			self.curKey = "x"
		end
		
		if next(self.hurtEnemies) == nil then
			self.weapon:remove()
		end
		
		-- Round robin select target from opponents list
		local target = self.scene.opponents[(self.lastSelection % #self.scene.opponents) + 1]
		table.insert(self.hurtEnemies, target)
		self.lastSelection = self.lastSelection + 1

		self.weapon = MakeWeapon(self)
		local weapon = self.weapon
		self.scene.audio:stopSfx()
		local targetSp = target.sprite
		Executor(self.scene):act(Serial {
			PlayAudio("sfx", "levelup", 1.0, true),
			Spawn(Animate(self.sprite, "throw")),
			Parallel {
				Ease(weapon.transform, "x", self.sprite.transform.x + 32 - weapon.w, 7, "linear"),
				Ease(weapon.transform, "y", self.sprite.transform.y - weapon.h, 7, "linear"),
				Ease(weapon.transform, "angle", math.pi / 2, 7, "linear")
			},
			Parallel {
				Ease(weapon.transform, "x", self.sprite.transform.x - weapon.w * 2, 7, "linear"),
				Ease(weapon.transform, "y", self.sprite.transform.y + 12 - weapon.h, 7, "linear"),
				Ease(weapon.transform, "angle", math.pi / 6, 7, "linear"),
			},
			
			Parallel {
				Ease(weapon.transform, "x", targetSp.transform.x + 150, 2, "linear"),
				Ease(weapon.transform, "y", targetSp.transform.y - 200, 2, "linear"),
				Ease(weapon.transform, "angle", math.pi * 3.25, 5, "linear")
			},
			
			Parallel {
				Ease(weapon.transform, "x", targetSp.transform.x, 2, "linear"),
				Ease(weapon.transform, "y", targetSp.transform.y, 2, "linear"),
				Ease(weapon.transform, "angle", math.pi * 6.25, 5, "linear")
			},

			Parallel {
				Serial {
					PlayAudio("sfx", "smack", nil, true),
					Ease(targetSp.transform, "x", targetSp.transform.x + (-50/3), 20, "quad"),
					Ease(targetSp.transform, "x", targetSp.transform.x - (-50/6), 20, "quad"),
					Ease(targetSp.transform, "x", targetSp.transform.x - (-50/3), 20, "quad"),
					Ease(targetSp.transform, "x", targetSp.transform.x + (-50/6), 20, "quad"),
					Ease(targetSp.transform, "x", targetSp.transform.x, 20, "linear"),
				},
				Ease(weapon.transform, "x", targetSp.transform.x + 60, 4, "linear"),
				Ease(weapon.transform, "y", targetSp.transform.y - 60, 4, "linear"),
				Ease(weapon.transform, "sx", 3, 4, "linear"),
				Ease(weapon.transform, "sy", 3, 4, "linear"),
				Ease(weapon.transform, "angle", -math.pi * 1.25 + math.pi, 4, "linear"),
				Ease(weapon.color, 4, 0, 4, "linear"),
				Animate(self.sprite, "idle")
			},
			Do(function()
				weapon:remove()
			end)
		})
	end
end


return function(self, target)
	self.pressx = SpriteNode(self.scene, Transform.fromoffset(self.sprite.transform, Transform(-40,-self.sprite.h)), nil, "pressx", nil, nil, "ui")
	self.pressx:setAnimation("idle")
	self.pressx.color[4] = 0

	self.pressz = SpriteNode(self.scene, Transform.fromoffset(self.sprite.transform, Transform(0,-self.sprite.h)), nil, "pressz", nil, nil, "ui")
	self.pressz:setAnimation("idle")
	self.pressz.color[4] = 0

	self.timeDelay = 0.2
	self.lastSelection = 1
	self.hurtEnemies = {}

	self.weapon = MakeWeapon(self)
	local weapon = self.weapon

	self.curKey = "x"
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "prethrow"),
		Telegraph(self, "Continuously press x -> z -> x -> z...", {255,255,255,50}),
		Do(function()
			self.scene:addHandler("keytriggered", KeyTrigger, self)
			self.scene:addHandler("update", Update, self)
			self.scene:focus("keytriggered", self) -- HACK, focus past skills + battle menu
			self.scene:focus("keytriggered", self)
			self.scene:focus("keytriggered", self)
		end),
		Ease(self.pressx.color, 4, 255, 2),
		Parallel {
			YieldUntil(self, "earlyExitThrow"),
			Serial {
				Wait(4),
				Do(function() self.earlyExitThrow = true end)
			}
		},
		Do(function()
			self.scene:removeHandler("keytriggered", KeyTrigger, self)
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.pressx:remove()
			self.pressz:remove()
			weapon:remove()

			local dmgCounter = {}
			for _, t in pairs(self.hurtEnemies) do
				local tkey = tostring(t)
				if dmgCounter[tkey] == nil then
					dmgCounter[tkey] = {
						target = t,
						damage = 0
					}
				end
				local calcDmg = t:calculateDamage({attack=self.stats.attack, luck=0, speed=100})
				dmgCounter[tkey].damage = dmgCounter[tkey].damage + calcDmg
			end
			local dmgActions = {}
			for _, r in pairs(dmgCounter) do
				table.insert(dmgActions, r.target:takeDamage({damage=math.floor(r.damage/2), attack=0, speed=100, luck=0}))
			end
			Executor(self.scene):act(Serial {
				Parallel(dmgActions),
				Do(function()
					self.doneWithMultiThrow = true
				end)
			})
		end),
		YieldUntil(self, "doneWithMultiThrow"),
		IfElse(
			function()
				return self.earlyExitThrow
			end,
			Action(),
			Serial {
				Parallel {
					PlayAudio("sfx", "pressx", 1.0),
					Animate(self.sprite, "victory"),
					Wait(1),
				},
				Animate(self.sprite, "idle")
			}
		)
	}
end
