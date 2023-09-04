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
local Executor = require "actions/Executor"
local While = require "actions/While"
local MessageBox = require "actions/MessageBox"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local TargetType = require "util/TargetType"
local ItemType = require "util/ItemType"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

local getDodgeAction = function(self, target)
	if target.id == "sonic" and not target.laserShield then
		return PressX(
			self,
			target,
			Serial {
				Do(function()
					target.dodged = true
				end),
				PlayAudio("sfx", "pressx", 1.0, true),
				Parallel {
					Serial {
						Animate(target.sprite, "leap_dodge"),
						Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h*2, 6, "linear"),
						Wait(0.1),
						Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
						Animate(target.sprite, "crouch"),
						Wait(0.1),
						Animate(target.sprite, "victory"),
						Wait(0.6),
						Animate(target.sprite, "idle"),
					},
					BouncyText(
						Transform(
							target.sprite.transform.x + 10 + (target.textOffset.x),
							target.sprite.transform.y + (target.textOffset.y)),
						{255,255,255,255},
						FontCache.ConsolasLarge,
						"miss",
						6,
						false,
						true -- outline
					),
				}
			},
			Do(function() end)
		)
	else
		return target.defenseEvent and
			target.defenseEvent(self, target) or
			Action()
	end
end

return {
	name = "Legacy Swatbot",
	altName = "Legacy Swatbot",
	sprite = "sprites/swatbotwhite",
	
	insult = "Swatbutt",

	stats = {
		xp    = 10,
		maxhp = 380,
		attack = 26,
		defense = 20,
		speed = 9,
		focus = 5,
		luck = 5,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},
	
	onInit = function(self)
		-- Setup beam sprite
		self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
		self.beamSprite.transform.sx = 0
		self.beamSprite.transform.sy = 1
		self.beamSprite.transform.ox = 0
		self.beamSprite.color = {512,255,512,255}
		self.beamSprite:setAnimation("purple")
		
		self.gasSprite = SpriteNode(self.scene, Transform(), nil, "gas", nil, nil, "ui")
		self.gasSprite.color[4] = 0
		
		self.targetSprite = SpriteNode(self.scene, Transform(0, 0, 2, 2), nil, "target", nil, nil, "ui")
		self.targetSprite.transform.ox = self.targetSprite.w/2
		self.targetSprite.transform.oy = self.targetSprite.h/2
		self.targetSprite.color[4] = 0
	end,

	behavior = function (self, target)
		-- Either do laser attack or poison gas
		if math.random() < 0.4 or self.scene.usedPoisonGas then
			-- Either do Arm Laser or Laser Sweep
			if math.random() < 0.9 or next(self.targetOverrideStack) ~= nil then
				local laserShot = function(t)
					local dodgeAction = getDodgeAction(self, t)
					return Serial {
						Do(function()
							self.targetSprite.transform.x = t.sprite.transform.x - 40
							self.targetSprite.transform.y = t.sprite.transform.y + 10
						end),
						Parallel {
							Ease(self.targetSprite.color, 4, 255, 5),
							Serial {
								Parallel {
									PlayAudio("sfx", "target", 1.0),
									Serial {
										Ease(self.targetSprite.transform, "x", t.sprite.transform.x + 26, 8, "inout"),
										Ease(self.targetSprite.transform, "x", t.sprite.transform.x - 30, 8, "inout"),
										Ease(self.targetSprite.transform, "x", t.sprite.transform.x + 16, 8, "inout"),
										Ease(self.targetSprite.transform, "x", t.sprite.transform.x - 20, 8, "inout"),
										Ease(self.targetSprite.transform, "x", t.sprite.transform.x + 3, 8, "inout"),
										Ease(self.targetSprite.transform, "x", t.sprite.transform.x - 7, 8, "inout"),
									}
								},
								
								PlayAudio("sfx", "lockon", 1.0, true),
								Parallel {
									Ease(self.targetSprite.transform, "sx", 4, 12, "inout"),
									Ease(self.targetSprite.transform, "sy", 4, 12, "inout")
								},
								Parallel {
									Ease(self.targetSprite.transform, "sx", 1.5, 12, "inout"),
									Ease(self.targetSprite.transform, "sy", 1.5, 12, "inout")
								},
								Parallel {
									Ease(self.targetSprite.transform, "sx", 3, 12, "inout"),
									Ease(self.targetSprite.transform, "sy", 3, 12, "inout")
								},
								Parallel {
									Ease(self.targetSprite.transform, "sx", 2, 12, "inout"),
									Ease(self.targetSprite.transform, "sy", 2, 12, "inout")
								},
								
								Ease(self.targetSprite.color, 4, 0, 5),
							}
						},

						Parallel {
							dodgeAction,
							Serial {
								Wait(0.2),
								PlayAudio("sfx", "swatbotlaser", 1.0, true),
								
								Do(function()
									self.beamSprite.transform.x = self.sprite.transform.x - 25 + self.beamSprite.w
									self.beamSprite.transform.y = self.sprite.transform.y - 50 + self.beamSprite.h*2
									self.beamSprite.transform.ox = 0
									
									local x1, y1 = self.beamSprite.transform.x, self.beamSprite.transform.y
									local x2, y2 = t.sprite.transform.x, t.sprite.transform.y

									local dx = (x2 - x1)
									local dy = (y2 - y1)

									local dot = dx * dx
									local m1 = math.sqrt(dx*dx + dy*dy)
									local m2 = dx
									local angle = math.acos(dot / (m1 * m2))
									
									if self.beamSprite.transform.y > t.sprite.transform.y then
										self.beamSprite.transform.angle = -angle
									else
										self.beamSprite.transform.angle = angle
									end
									
									self.xDist = dx
									self.yDist = dy
									self.len = m1/self.beamSprite.w	
								end),
								
								-- Beam stretch to target and recede
								Ease(self.beamSprite.transform, "sx", function() return self.len end, 8),
								
								Do(function()
									self.beamSprite.transform.ox = self.beamSprite.w
									
									self.beamSprite.transform.x = self.beamSprite.transform.x + self.xDist
									self.beamSprite.transform.y = self.beamSprite.transform.y + self.yDist
								end),
								
								Ease(self.beamSprite.transform, "sx", 0, 8),
								
								Try(
									YieldUntil(
										function()
											return t.dodged
										end
									),
									Do(function()
										t.dodged = false
									end),
									t:takeDamage(self.stats, true, BattleActor.shockKnockback)
								)
							}
						}
					}
				end
				
				local secondTarget
				if self.confused then
					local targetList = {}
					for i, c in pairs(self.scene.opponents) do
						if c.state ~= BattleActor.STATE_DEAD then
							table.insert(targetList, i)
						end
					end
					secondTarget = self.scene.opponents[targetList[math.random(#targetList)]]
				else
					local targetList = {}
					for i, c in pairs(self.scene.party) do
						if c.state ~= BattleActor.STATE_DEAD then
							table.insert(targetList, i)
						end
					end
					secondTarget = self.scene.party[targetList[math.random(#targetList)]]
				end
			
				return Serial {
					Telegraph(self, "Arm Laser", {255,255,255,50}),
					Animate(self.sprite, "shoot"),
					Animate(self.sprite, "shoot_idle"),
					Wait(0.5),
					laserShot(target),
					Animate(self.sprite, "shoot_retract"),
					Animate(self.sprite, "idle")
				}
			else
				-- Damage all party members
				local dodgeAllPartyMembers = {}
				local dmgAllPartyMembers = {}
				local _, firstPartyMember = next(self.scene.party)
				local lastPartyMember
				for _, mem in pairs(self.scene.party) do
					table.insert(dodgeAllPartyMembers, getDodgeAction(self, mem))
					table.insert(dmgAllPartyMembers, Try(
						YieldUntil(
							function()
								return mem.dodged
							end
						),
						Do(function()
							mem.dodged = false
						end),
						mem:takeDamage(self.stats, true, BattleActor.shockKnockback)
					))
					lastPartyMember = mem
				end

				return Serial {
					Telegraph(self, "Laser Sweep", {255,255,255,50}),
					
					Animate(self.sprite, "shoot"),
					Animate(self.sprite, "shoot_idle"),
					
					Wait(0.2),

					Parallel(dodgeAllPartyMembers),
					
					PlayAudio("sfx", "lasersweep", 1.0, true),
					
					Do(function()
						self.beamSprite.transform.x = self.sprite.transform.x - 25 + self.beamSprite.w
						self.beamSprite.transform.y = self.sprite.transform.y - 50 + self.beamSprite.h*2
						self.beamSprite.transform.angle = -math.pi/6
						self.beamSprite.transform.ox = 0
					end),
					
					Ease(self.beamSprite.transform, "sx", 25.0, 12, "linear"),
					Ease(self.beamSprite.transform, "angle", math.pi/6, 1, "linear"),
					
					-- Hide beam sprite
					Do(function()
						self.beamSprite.transform.sx = 0
						self.beamSprite.transform.angle = 0
					end),

					Parallel(dmgAllPartyMembers),
					Animate(self.sprite, "shoot_retract"),
					Animate(self.sprite, "idle"),
				}
			end
		else
			local targetActionList = {}
			local backToIdleList = {}
			self.scene.usedPoisonGas = true
			for i, c in pairs(self.confused and self.scene.opponents or self.scene.party) do
				if c.state ~= BattleActor.STATE_DEAD then
					table.insert(
						targetActionList,
						Serial {
							Wait(0.2 * i),
							Do(function()
								-- Can't poison someone wearing Copper Amulet
								if  c.side == TargetType.Party and
									GameState:isEquipped(c.id, ItemType.Accessory, "Copper Amulet") then
									return
								end

								c.poisoned = table.clone(self.stats)
								c.poisoned.attack = c.poisoned.attack * 0.3
								c.poisoned.speed = 100
								c.poisoned.nomiss = true
								c.poisoned.nonlethal = true
								c.sprite:setAnimation("hurt")

								-- Always fade in and out green
								c.poisonAnim = Executor(c.scene)
								c.poisonAnim:act(While(
									function()
										return c.poisoned
									end,
									Repeat(Serial {
										Ease(c.sprite.color, 2, 400, 1.5),
										Ease(c.sprite.color, 2, 300, 1.5)
									}),
									Ease(c.color, 2, 255, 1)
								))
							end)
						}
					)
					table.insert(backToIdleList, Do(function() c.sprite:setAnimation("idle") end))
				end
			end
			return Serial {
				Telegraph(self, "Poison Gas", {255,255,255,50}),
				Animate(self.sprite, "shoot"),
				Animate(self.sprite, "shoot_idle"),
				Do(function()
					self.gasSprite.transform.x = self.sprite.transform.x - 25 + 25
					self.gasSprite.transform.y = self.sprite.transform.y - 50
				end),
				Parallel {
					Animate(self.gasSprite, "release"),
					Ease(self.gasSprite.color, 4, 250, 2)
				},
				Do(function()
					self.gasSprite:setAnimation("idle")
				end),
				Parallel {
					Ease(self.scene.bgColor, 2, 510, 1, "quad"),
					Do(function() 
						ScreenShader:sendColor("multColor", self.scene.bgColor)
					end)
				},
				Parallel(targetActionList),
				MessageBox {message="Party is poisoned!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
				Parallel(backToIdleList),
				Parallel {
					Ease(self.scene.bgColor, 2, 255, 1, "quad"),
					Do(function() 
						ScreenShader:sendColor("multColor", self.scene.bgColor)
					end)
				},
				Ease(self.gasSprite.color, 4, 0, 2),
				Animate(self.sprite, "shoot_retract"),
				Animate(self.sprite, "idle")
			}
		end
	end
}