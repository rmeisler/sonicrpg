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
local Executor = require "actions/Executor"
local YieldUntil = require "actions/YieldUntil"
local BouncyText = require "actions/BouncyText"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

local Swatbot = require "data/monsters/swatbot"

return {
	name = "Armed Swatbot",
	altName = "Armed Swatbot",
	sprite = "sprites/swatbotwithblaster",

	stats = {
		xp    = 20,
		maxhp = 600,
		attack = 25,
		defense = 25,
		speed = 10,
		focus = 10,
		luck = 5,
	},

	run_chance = 0.3,

	coin = 0,

	drops = {},
	
	scan = "A Laser Shield can be useful against these bots.",
	
	onInit = function(self)
		-- Start out as "armed"
		self.armed = true
		
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

		-- Setup stun sprites
		self.stunSprites = {}
		for i=1, 15 do
			local stunSp = SpriteNode(self.scene, Transform(), nil, "stuneffect", nil, nil, "ui")
			stunSp.transform.ox = stunSp.w/2
			stunSp.transform.oy = stunSp.h/2
			stunSp.color[4] = 0
			table.insert(self.stunSprites, stunSp)
		end
		
		-- When we get hit and lose the majority of our hp, lose the rifle
		local hitHandler
		hitHandler = function(damage)
			if self.scene.state ~= self.scene.STATE_MONSTERTURN_PENDING and
				self.armed and damage > 0 and self.hp <= 300
			then
				self.armed = false
				self.sprite:pushOverride("hurt", "hurt_nopistol")
				self.sprite:pushOverride("hurtdown", "hurtdown_nopistol")
				self.sprite:pushOverride("idle", "idle_nopistol")
				self.sprite:pushOverride("backward", "backward_nopistol")
				self.sprite:pushOverride("dead", "dead_nopistol")
				self.beamSprite:setAnimation("blue")
				
				-- Drop attack power
				self.stats = table.clone(self.stats)
				self.stats.attack = 12
				
				-- Setup gun sprite
				local gunSprite = SpriteNode(
					self.scene,
					Transform(self.sprite.transform.x, self.sprite.transform.y, 2, 2),
					nil,
					"blaster2",
					nil,
					nil,
					"ui"
				)
				gunSprite.transform.ox = gunSprite.w/2
				gunSprite.transform.oy = gunSprite.h/2
				gunSprite.color = {255,255,255,255}
				
				-- Create pistol sprite, then animate it bouncing
				-- away from you and fading out
				Executor(self.scene):act(Serial {
					Parallel {
						Ease(gunSprite.transform, "angle", math.pi*3, 2),
						Ease(gunSprite.transform, "x", function() return gunSprite.transform.x + 100 end, 2),
						Serial {
							Ease(gunSprite.transform, "y", function() return gunSprite.transform.y - 50 end, 4),
							Ease(gunSprite.transform, "y", function() return gunSprite.transform.y + 80 end, 4)
						},
						Serial {
							Wait(0.5),
							Ease(gunSprite.color, 4, 0, 2),
							Do(function()
								gunSprite:remove()
							end)
						}
					}
				})
				self:removeHandler("hit", hitHandler)
			end
		end
		self:addHandler("hit", hitHandler)
	end,
	
	behavior = function (self, target)
		-- If armed, this swatbot has a different set of attacks
		-- Stun & Laser Rifle
		if self.armed then
			-- Stun turn
			local stunAction
			local targetSp = target:getSprite()
			stunAction = Serial {
				Telegraph(self, "Stun", {255,255,255,50}),
				Do(function() self.sprite:setAnimation("pistol_idle") end),
				PlayAudio("sfx", "stun", 1.0, true),
				Do(function()
					for index,stunSp in pairs(self.stunSprites) do
						Executor(self.scene):act(Serial {
							Wait(0.1 * index),
							Do(function()
								stunSp.transform.x = self.sprite.transform.x + 36 + stunSp.w*2
								stunSp.transform.y = self.sprite.transform.y - 74 + stunSp.h*2
								stunSp.transform.sx = 0.5
								stunSp.transform.sy = 0.5
								stunSp.color[4] = 255
							end),
							Parallel {
								Ease(stunSp.transform, "sx", 2, 4),
								Ease(stunSp.transform, "sy", 3, 1.5),
								Ease(stunSp.transform, "x", targetSp.transform.x - targetSp.w/2, 1.6),
								Ease(stunSp.transform, "y", targetSp.transform.y, 1.6),
								
								Serial {
									Wait(0.3),
									Do(function()
										if targetSp.selected ~= "hurt" then
											targetSp:setAnimation("hurt")
											
											local revAction = target.reverseAnimation or Action()
											Executor(self.scene):act(Serial {
												Parallel {
													revAction,
													Repeat(Parallel {
														Serial {
															Ease(targetSp.color, 1, 512, 8),
															Ease(targetSp.color, 1, 300, 8)
														},
														Serial {
															Ease(targetSp.transform, "x", function() return targetSp.transform.x + 1 end, 20),
															Ease(targetSp.transform, "x", function() return targetSp.transform.x - 1 end, 20)
														}
													}, 10)
												},
												Ease(targetSp.color, 1, 255, 8)
											})
										end
									end)
								}
							},
							Parallel {
								Ease(stunSp.transform, "sy", 7, 8),
								Ease(stunSp.color, 4, 0, 4)
							}
						})
					end
				end),

				not target.laserShield
					and Telegraph(target, target.name.." is stunned!", {255,255,255,50})
					or BouncyText(
						Transform(
							targetSp.transform.x + 10 + (target.textOffset.x),
							targetSp.transform.y + (target.textOffset.y)),
						{255,255,255,255},
						FontCache.ConsolasLarge,
						"miss",
						6,
						false,
						true -- outline
					),
				Wait(1),
				Do(function()
					self.sprite:setAnimation("idle")
					if not target.laserShield then
						target.state = BattleActor.STATE_IMMOBILIZED
						target.turnsImmobilized = 2
						targetSp:setAnimation("dead")
					end
				end)
			}
			
			-- Laser rifle turn
			local rifleAction
			local dodgeAction = Action()
			
			-- Find diff target
			local stunTarget = target.id == "sonic"
			local newTarget = target
			for k, v in pairs(self.scene.party) do
				if v ~= target and v.state ~= BattleActor.STATE_DEAD then
					newTarget = v
					break
				end
			end
			if newTarget.id == "sonic" and
			   newTarget.state ~= BattleActor.STATE_IMMOBILIZED and
			   not stunTarget and
			   not newTarget.laserShield
			then
				dodgeAction = PressX(
					self,
					newTarget,
					Serial {
						Do(function()
							newTarget.dodged = true
						end),
						PlayAudio("sfx", "pressx", 1.0, true),
						Parallel {
							Serial {
								Animate(newTarget.sprite, "leap_dodge"),
								Ease(newTarget.sprite.transform, "y", newTarget.sprite.transform.y - newTarget.sprite.h*2, 6, "linear"),
								Wait(0.1),
								Ease(newTarget.sprite.transform, "y", newTarget.sprite.transform.y, 6, "quad"),
								Animate(newTarget.sprite, "crouch"),
								Wait(0.1),
								Animate(newTarget.sprite, "victory"),
								Wait(0.6),
								Animate(newTarget.sprite, "idle"),
							},
							BouncyText(
								Transform(
									newTarget.sprite.transform.x + 10 + (newTarget.textOffset.x),
									newTarget.sprite.transform.y + (newTarget.textOffset.y)),
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
			end
			
			rifleAction = Serial {
				Telegraph(self, "Laser Rifle", {255,255,255,50}),
				Do(function()
					self.targetSprite.transform.x = newTarget.sprite.transform.x - 40
					self.targetSprite.transform.y = newTarget.sprite.transform.y + 10
				end),
				Parallel {
					Do(function() self.sprite:setAnimation("pistol_idle") end),
					Ease(self.targetSprite.color, 4, 255, 5),
					Serial {
						Parallel {
							PlayAudio("sfx", "target", 1.0),
							Serial {
								Ease(self.targetSprite.transform, "x", newTarget.sprite.transform.x + 26, 8, "inout"),
								Ease(self.targetSprite.transform, "x", newTarget.sprite.transform.x - 30, 8, "inout"),
								Ease(self.targetSprite.transform, "x", newTarget.sprite.transform.x + 16, 8, "inout"),
								Ease(self.targetSprite.transform, "x", newTarget.sprite.transform.x - 20, 8, "inout"),
								Ease(self.targetSprite.transform, "x", newTarget.sprite.transform.x + 3, 8, "inout"),
								Ease(self.targetSprite.transform, "x", newTarget.sprite.transform.x - 7, 8, "inout"),
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
				
				Do(function()
					self:getSprite():setAnimation("pistol")
				end),

				Parallel {
					Serial {
						Wait(0.2),
						dodgeAction
					},
					
					Serial {
						PlayAudio("sfx", "swatbotlaser", 1.0, true),
						
						Do(function()
							self.beamSprite.transform.x = self.sprite.transform.x + 25 + self.beamSprite.w
							self.beamSprite.transform.y = self.sprite.transform.y - 40 + self.beamSprite.h*2
							self.beamSprite.transform.ox = 0
							
							local x1, y1 = self.beamSprite.transform.x, self.beamSprite.transform.y
							local x2, y2 = newTarget.sprite.transform.x, newTarget.sprite.transform.y

							local dx = (x2 - x1)
							local dy = (y2 - y1)

							local dot = dx * dx
							local m1 = math.sqrt(dx*dx + dy*dy)
							local m2 = dx
							local angle = math.acos(dot / (m1 * m2))
							
							if self.beamSprite.transform.y > newTarget.sprite.transform.y then
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
									return newTarget.dodged
								end
							),
							Do(function()
								newTarget.dodged = false
							end),
							newTarget:takeDamage(self.stats, true, BattleActor.shockKnockback)
						),
						
						Do(function()
							self:getSprite():setAnimation("idle")
						end)
					}
				}
			}
			
			return Serial {
				stunAction,
				rifleAction
			}
		else
			-- Becomes just a regular swatbot
			return Swatbot.behavior(self, target)
		end
	end
}