local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local BouncyText = require "actions/BouncyText"
local IfElse = require "actions/IfElse"
local Repeat = require "actions/Repeat"
local While = require "actions/While"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"

local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local ShakeOff = function(self, key, _, target)
	if key == "x" then
		self.shakeCount = self.shakeCount + 1
		self.scene.audio:stopSfx()
		self.scene.audio:playSfx("bang", 0.5)
		
		if self.shakeCount % 2 == 0 then
			target.sprite.transform.x = target.sprite.transform.x - 10
		else
			target.sprite.transform.x = target.sprite.transform.x + 10
		end
	end
end

local PainTimer = function(self, dt)
	self.painTime = self.painTime + dt
end

return {
	name = "Bugs",
	altName = "Bugs",
	sprite = "sprites/ladybug",

	stats = {
		xp    = 10,
		maxhp = 500,
		attack = 5,
		defense = 10,
		speed = 30,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,
	
	weakness = "focus",

	coin = 0,

	drops = {
		{item = require "data/items/GreenLeaf", count = 1, chance = 0.2},
	},
	
	onInit = function(self)
		self.scene.bgImgColor = {170,170,170,255}
		self.scene.partyByName.sally.sprite.color = {170,170,170,255}
		self.sprite.color = {170,170,170,255}

		self.growth = 0

		self.ladybugSprites = {}
		for i=1,10 do
			local sp = SpriteNode(
				self.scene,
				Transform(-100, self.sprite.transform.y, 2, 2),
				{170,170,170,255},
				"ladybug",
				nil,
				nil,
				"sprites"
			)
			sp.transform.ox = self.sprite.w/2
			sp.transform.oy = self.sprite.h/2
			table.insert(self.ladybugSprites, sp)
		end
	end,
	
	onAttack = function(self, attacker)
		if self.growth == 2 and self.hp < 400 then
			return Serial {
				
			}
		elseif self.growth == 1 and self.hp < 300 then
			return Serial {
				
			}
		else
			return Serial {
			}
		end
	end,

	behavior = function (self, target)
		if self.growth == 0 then
			self.growth = self.growth + 1

			local newBug1 = table.remove(self.ladybugSprites)
			local newBug2 = table.remove(self.ladybugSprites)
			local newBug3 = table.remove(self.ladybugSprites)
			local newBug4 = table.remove(self.ladybugSprites)
			local newBug5 = table.remove(self.ladybugSprites)

			return Serial {
				Telegraph(self, "Gather", {255,255,255,50}),
				Parallel {
					Ease(newBug1.transform, "x", self.sprite.transform.x, 3),
					Serial {
						Wait(0.2),
						Ease(newBug2.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.4),
						Ease(newBug3.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.6),
						Ease(newBug4.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.8),
						Ease(newBug5.transform, "x", self.sprite.transform.x, 3)
					},
					--[[
					Serial {
						Wait(0.5),
						Repeat(Serial {
							Animate(self.sprite, "idle"),
							Wait(0.2),
							Animate(self.sprite, "level2_idle"),
							Wait(0.2)
						}, 5)
					}]]
				},
				Animate(self.sprite, "level2_idle"),
				Do(function()
					self.stats.defense = self.stats.defense + 20
					self.stats.speed = self.stats.speed - 10
					
					self.sprite:pushOverride("idle", "level2_idle")
					self.sprite:pushOverride("move", "level2_move")
					self.sprite:pushOverride("hurt", "level2_hurt")

					newBug1.transform.x = -200
					newBug2.transform.x = -200
					newBug3.transform.x = -200
					newBug4.transform.x = -200
					newBug5.transform.x = -200
					table.insert(self.ladybugSprites, newBug1)
					table.insert(self.ladybugSprites, newBug2)
					table.insert(self.ladybugSprites, newBug3)
					table.insert(self.ladybugSprites, newBug4)
					table.insert(self.ladybugSprites, newBug5)
				end),
				MessageBox {message="Defense increased! {p40}Speed decreased!", rect=MessageBox.HEADLINER_RECT}
			}
		end
		
		local chance = math.random()
		if chance > 0.6 and self.growth == 1 then
			self.growth = self.growth + 1

			local newBug1 = table.remove(self.ladybugSprites)
			local newBug2 = table.remove(self.ladybugSprites)
			local newBug3 = table.remove(self.ladybugSprites)
			local newBug4 = table.remove(self.ladybugSprites)
			local newBug5 = table.remove(self.ladybugSprites)
			local newBug6 = table.remove(self.ladybugSprites)
			local newBug7 = table.remove(self.ladybugSprites)
			local newBug8 = table.remove(self.ladybugSprites)
			local newBug9 = table.remove(self.ladybugSprites)
			local newBug10 = table.remove(self.ladybugSprites)

			return Serial {
				Telegraph(self, "Gather", {255,255,255,50}),
				Parallel {
					Ease(newBug1.transform, "x", self.sprite.transform.x, 3),
					Serial {
						Wait(0.2),
						Ease(newBug2.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.4),
						Ease(newBug3.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.6),
						Ease(newBug4.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(0.8),
						Ease(newBug5.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1),
						Ease(newBug6.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1.2),
						Ease(newBug7.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1.4),
						Ease(newBug8.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1.6),
						Ease(newBug9.transform, "x", self.sprite.transform.x, 3)
					},
					Serial {
						Wait(1.8),
						Ease(newBug10.transform, "x", self.sprite.transform.x, 3)
					},
					--[[
					Serial {
						Wait(1.2),
						Repeat(Serial {
							Animate(self.sprite, "idle"),
							Wait(0.2),
							Animate(self.sprite, "level2_idle"),
							Wait(0.2)
						}, 5)
					}]]
				},
				Animate(self.sprite, "level3_idle"),
				Do(function()
					self.stats.defense = self.stats.defense + 20
					self.stats.speed = self.stats.speed - 10
					
					self.sprite:pushOverride("idle", "level3_idle")
					self.sprite:pushOverride("move", "level3_move")
					self.sprite:pushOverride("hurt", "level3_hurt")
					
					newBug1.transform.x = -200
					newBug2.transform.x = -200
					newBug3.transform.x = -200
					newBug4.transform.x = -200
					newBug5.transform.x = -200
					newBug6.transform.x = -200
					newBug7.transform.x = -200
					newBug8.transform.x = -200
					newBug9.transform.x = -200
					newBug10.transform.x = -200
					table.insert(self.ladybugSprites, newBug1)
					table.insert(self.ladybugSprites, newBug2)
					table.insert(self.ladybugSprites, newBug3)
					table.insert(self.ladybugSprites, newBug4)
					table.insert(self.ladybugSprites, newBug5)
					table.insert(self.ladybugSprites, newBug6)
					table.insert(self.ladybugSprites, newBug7)
					table.insert(self.ladybugSprites, newBug8)
					table.insert(self.ladybugSprites, newBug9)
					table.insert(self.ladybugSprites, newBug10)
				end),
				MessageBox {message="Defense increased! {p40}Speed decreased!", rect=MessageBox.HEADLINER_RECT}
			}
		else
			local origX, origY = self.sprite.transform.x, self.sprite.transform.y
			return Serial {
				Telegraph(self, "Swarm", {255,255,255,50}),
				Animate(target.sprite, "shock"),
				Parallel {
					Ease(self.sprite.transform, "x", target.sprite.transform.x, 3),
					Ease(self.sprite.transform, "y", target.sprite.transform.y + 1, 3)
				},
				Do(function()
					self.sprite.sortOrderY = self.sprite.transform.y + 1
					target.sprite:pushOverride("hurt", "shock")
				end),
				MessageBox {message="Rapidly press x to shake off bugs!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},

				-- Do repeated little amounts of damage until player shakes them off
				Do(function()
					self.shakeCount = 0
					self.painTime = 0
					
					target.origX = target.sprite.transform.x

					self.scene:addHandler("keytriggered", ShakeOff, self, target)
					self.scene:focus("keytriggered", self) -- HACK, focus past skills + battle menu
					self.scene:focus("keytriggered", self)
					self.scene:focus("keytriggered", self)
					
					self.scene:addHandler("update", PainTimer, self)
				end),
				While(
					function() return self.shakeCount < 15 and self.painTime < 5 and target.hp > 0 end,
					Parallel {
						Repeat(Serial {
							Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - 20 end, 10),
							Ease(self.sprite.transform, "y", function() return self.sprite.transform.y + 20 end, 10)
						}),
						Animate(function()
							local xform = Transform.from(self.sprite.transform)
							xform.x = xform.x + self.sprite.w
							return SpriteNode(self.scene, xform, nil, "pressx", nil, nil, "ui"), true
						end, "rapidly"),
						Repeat(
							Serial {
								Wait(0.4),
								Do(function()
									local damage = target:calculateDamage(self.stats)
									target.hp = math.max(target.hp - damage, 0)

									Executor(self.scene):act(
										BouncyText(
											Transform(
												target.sprite.transform.x + target.textOffset.x + 30,
												target.sprite.transform.y + target.textOffset.y
											),
											{255,0,0,255},
											FontCache.ConsolasLarge,
											tostring(damage),
											6,
											false,
											true -- outline
										)
									)
								end)
							}
						)	
					},
					Do(function()
						
					end)
				),
				Do(function()
					self.sprite.sortOrderY = nil
					target.sprite.transform.x = target.origX

					self.scene:removeHandler("keytriggered", ShakeOff, self, target)
					self.scene:unfocus("keytriggered")
					self.scene:unfocus("keytriggered")
					self.scene:unfocus("keytriggered")
					
					self.scene:removeHandler("update", PainTimer, self)
					
					target.sprite:popOverride("hurt")

					if target.hp <= 0 then
						Executor(self.scene):act(target:die())
					end
				end),
				Parallel {
					Ease(self.sprite.transform, "x", origX, 3),
					Ease(self.sprite.transform, "y", origY, 3)
				},
				Do(function()
					if target.hp > 0 then
						target.sprite:setAnimation("idle")
					end
				end)
			}
		end
	end,
	
	scan = "Bugs are weak against hacking skills."
}