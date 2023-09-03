local Serial = require "actions/Serial"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local IfElse = require "actions/IfElse"
local BouncyText = require "actions/BouncyText"
local YieldUntil = require "actions/YieldUntil"
local Executor = require "actions/Executor"
local While = require "actions/While"
local Spawn = require "actions/Spawn"
local Try = require "actions/Try"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local TargetType = require "util/TargetType"
local ItemType = require "util/ItemType"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local BattleActor = require "object/BattleActor"

return {
	name = "Buzz Bomber",
	altName = "Buzz Bomber",
	sprite = "sprites/buzzbomber",

	stats = {
		xp    = 20,
		maxhp = 300,
		attack = 35,
		defense = 10,
		speed = 15,
		focus = 5,
		luck = 2,
	},
	
	aerial = true,
	
	hasDropShadow = true,

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/items/RainbowSyrup", count = 1, chance = 0.2},
	},
	
	scan = "Buzz Bomber can't fly if stunned.",
	
	onInit = function(self)
		-- Be in the air plz
		self.sprite.transform.y = self.sprite.transform.y - 100
		
		-- Setup beam sprite
		self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
		self.beamSprite.transform.sx = 0
		self.beamSprite.transform.sy = 1
		self.beamSprite.transform.ox = 0
		self.beamSprite.color = {512,255,512,255}
		self.beamSprite:setAnimation("purple")

		-- Setup target sprite
		self.targetSprite = SpriteNode(self.scene, Transform(0, 0, 2, 2), nil, "target", nil, nil, "ui")
		self.targetSprite.transform.ox = self.targetSprite.w/2
		self.targetSprite.transform.oy = self.targetSprite.h/2
		self.targetSprite.color[4] = 0

		-- Buzz Bomber always gets initiative
		self.scene.initiative = "opponent"
		
		-- Create knockback function we will use if impacted by Sally's "Interrupt" skill
		self.interruptKnockbackFn = function(self, impact, direction)
			-- Standard knockback function with edits
			local sprite = self:getSprite()
			return Serial {
				PlayAudio("sfx", self.hurtSfx, nil, true),
				Ease(sprite.transform, "x", sprite.transform.x + (impact/3 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x - (impact/6 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x - (impact/3 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x + (impact/6 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x, 20, "linear"),
				
				-- Fall to ground
				Ease(sprite.transform, "y", sprite.transform.y + 120, 5, "quad"),
				Ease(sprite.transform, "y", sprite.transform.y + 118, 20, "quad"),
				Ease(sprite.transform, "y", sprite.transform.y + 120, 20, "quad"),
				Do(function()
					self.aerial = false
					sprite:pushOverride("idle", "hurt")
				end)
			}
		end
		-- Slam will also knock you out of the air
		self.slamKnockbackFn = function(self, impact, direction)
			return Serial {
				self.interruptKnockbackFn(self, impact, direction),
				Do(function()
					self.lostTurns = 1
					self.lostTurnType = "shock"
				end)
			}
		end
		
		-- After lost turns over, buzz bomber resumes flying
		self.afterLostTurns = function(self, lostTurnType)
			if lostTurnType == "interrupt" or lostTurnType == "shock" then
				local sprite = self:getSprite()
				return Serial {
					Do(function()
						sprite:popOverride("idle")
						sprite:setAnimation("idle")
						self.aerial = true
					end),
					Ease(sprite.transform, "y", sprite.transform.y - 120, 3, "quad")
				}
			else
				return Action()
			end
		end
	end,

	behavior = function (self, target)
		local dodgeAction = Action()
		if target.id == "sonic" and not target.laserShield then
			dodgeAction = PressX(
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
			dodgeAction = target.defenseEvent and
				target.defenseEvent(self, target) or
				dodgeAction
		end

		-- Dive bomb
		if math.random() < 0.7 then
			self.origX = self.sprite.transform.x
			self.origY = self.sprite.transform.y
			return Serial {
				Telegraph(self, "Dive Bomb", {255,255,255,50}),
				Wait(0.5),
				Do(function()
					self.targetSprite.transform.x = target.sprite.transform.x - 40
					self.targetSprite.transform.y = target.sprite.transform.y + 10
				end),
				Parallel {
					Ease(self.targetSprite.color, 4, 255, 5),
					Serial {
						Parallel {
							PlayAudio("sfx", "target", 1.0),
							Serial {
								Ease(self.targetSprite.transform, "x", target.sprite.transform.x + 26, 8, "inout"),
								Ease(self.targetSprite.transform, "x", target.sprite.transform.x - 30, 8, "inout"),
								Ease(self.targetSprite.transform, "x", target.sprite.transform.x + 16, 8, "inout"),
								Ease(self.targetSprite.transform, "x", target.sprite.transform.x - 20, 8, "inout"),
								Ease(self.targetSprite.transform, "x", target.sprite.transform.x + 3, 8, "inout"),
								Ease(self.targetSprite.transform, "x", target.sprite.transform.x - 7, 8, "inout"),
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
					Ease(self.sprite.transform, "x", target.sprite.transform.x + 500, 1),
					Ease(self.sprite.transform, "y", target.sprite.transform.y, 4, "linear"),
					
					Serial {
						Wait(0.3),
						Do(function() self.sprite:setAnimation("stinger") end)
					},
					
					Serial {
						dodgeAction,
						Try(
							YieldUntil(
								function()
									return target.dodged
								end
							),
							Do(function()
								target.dodged = false
							end),
							target:takeDamage(self.stats, true)
						)
					}
				},
				
				Do(function()
					self.sprite:setAnimation("idle")
					self.sprite.transform.x = self.origX - 600
					self.sprite.transform.y = self.origY
				end),
				
				Ease(self.sprite.transform, "x", self.origX, 2)
			}
		-- Tail Laser
		else
			local laserShot = function(t)
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
								self.beamSprite.transform.x = self.sprite.transform.x + 134 - self.sprite.w + self.beamSprite.w
								self.beamSprite.transform.y = self.sprite.transform.y + 40 + self.beamSprite.h*2
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
							Do(function() self.sprite:setAnimation("stinger") end),
							Ease(self.beamSprite.transform, "sx", function() return self.len end, 8),
							
							Do(function()
								self.beamSprite.transform.ox = self.beamSprite.w
								
								self.beamSprite.transform.x = self.beamSprite.transform.x + self.xDist
								self.beamSprite.transform.y = self.beamSprite.transform.y + self.yDist
							end),
							
							Ease(self.beamSprite.transform, "sx", 0, 8),
							Do(function() self.sprite:setAnimation("idle") end),
							
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
				secondTarget = self.scene.opponents[targetList[math.random(1, #targetList)]]
			else
				local targetList = {}
				for i, c in pairs(self.scene.party) do
					if c.state ~= BattleActor.STATE_DEAD then
						table.insert(targetList, i)
					end
				end
				secondTarget = self.scene.party[targetList[math.random(1, #targetList)]]
			end
		
			return Serial {
				Telegraph(self, "Tail Laser", {255,255,255,50}),
				Wait(0.5),
				laserShot(target)
			}
		end
	end
}
