local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local BouncyText = require "actions/BouncyText"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Rover",
	altName = "Rover",
	sprite = "sprites/rover",

	stats = {
		xp    = 30,
		maxhp = 1500,
		attack = 40,
		defense = 20,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		{item = require "data/items/CrystalWater", count = 1, chance = 0.8},
	},
	
	scan = "Don't attack rover when standing.",
	
	onAttack = function (self, attacker)
		if self.hp <= 0 then
			return Action()
		end
	
		if self.state == "upright" or self.state == "transition_to_crouched" then
			-- Damage all party members
			local dmgAllPartyMembers = {}
			local _, firstPartyMember = next(self.scene.party)
			local lastPartyMember
			for _, mem in pairs(self.scene.party) do
				table.insert(dmgAllPartyMembers, OnHitEvent(self, mem))
				lastPartyMember = mem
			end

			return Serial {
				Telegraph(self, "Laser Sweep", {255,255,255,50}),
				
				Animate(function()
					local xform = Transform.from(self.sprite.transform)
					xform.x = xform.x + self.sprite.w/2 - 50
					xform.y = xform.y + self.sprite.h/2 - 40
					return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
				end, "idle"),
				
				PlayAudio("sfx", "lasersweep", 1.0, true),
				
				Do(function()
					self.beamSprite.transform.x = self.sprite.transform.x + self.sprite.w/2 - 20
					self.beamSprite.transform.y = self.sprite.transform.y + self.sprite.h/2 - 15
					self.beamSprite.transform.angle = -math.pi/6
					self.beamSprite.transform.ox = 0
				end),
				
				Ease(self.beamSprite.transform, "sx", 20.0, 12, "linear"),
				Ease(self.beamSprite.transform, "angle", math.pi/6, 1, "linear"),
				
				-- Hide beam sprite
				Do(function()
					self.beamSprite.transform.sx = 0
					self.beamSprite.transform.angle = 0
				end),
				
				Parallel(dmgAllPartyMembers)
			}
		else
			return Action()
		end
	end,

	behavior = function (self, target)
		-- Starting state, setup
		if self.state == "idle" then
			self.turnsBeforeTransition = 2

			-- Setup beam sprite
			self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
			self.beamSprite.transform.sx = 0
			self.beamSprite.transform.sy = 1
			self.beamSprite.transform.ox = 0
			
			self.targetSprite = SpriteNode(self.scene, Transform(0, 0, 2, 2), nil, "target", nil, nil, "ui")
			self.targetSprite.transform.ox = self.targetSprite.w/2
			self.targetSprite.transform.oy = self.targetSprite.h/2
			self.targetSprite.color[4] = 0
			
			self.state = "crouched"
		end
	
		-- Two modes, crouched and up
		-- If you attack when crouched, you hurt it
		-- If you attack when up, it does sweep
		if self.state == "transition_to_crouched" then
			return Serial {
				Animate(self.sprite, "transition"),
				Animate(self.sprite, "crouched"),
				Do(function()
					self.state = "crouched"
					self.turnsBeforeTransition = 2
				end)
			}
		elseif self.state == "crouched" then
			local dodgeAction = Action()
			if target.id == "sonic" then
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
								Wait(0.8),
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
					Do(function() end),
					0.3
				)
			end
		
			return Serial {
				Telegraph(self, "Laser Cannon", {255,255,255,50}),
				
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
					Serial {
						Wait(0.2),
						dodgeAction
					},
					
					Serial {						
						Animate(function()
							local xform = Transform.from(self.sprite.transform)
							xform.x = xform.x + self.sprite.w/2 - 50
							xform.y = xform.y + self.sprite.h/2
							return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
						end, "idle"),
						
						PlayAudio("sfx", "laser", 1.0, true),
						
						Do(function()
							self.beamSprite.transform.x = self.sprite.transform.x + self.sprite.w/2 - 50 + self.beamSprite.w
							self.beamSprite.transform.y = self.sprite.transform.y + self.sprite.h/2 + self.beamSprite.h*2
							self.beamSprite.transform.ox = 0
							
							local x1, y1 = self.beamSprite.transform.x, self.beamSprite.transform.y
							local x2, y2 = target.sprite.transform.x, target.sprite.transform.y

							local dx = (x2 - x1)
							local dy = (y2 - y1)

							local dot = dx * dx
							local m1 = math.sqrt(dx*dx + dy*dy)
							local m2 = dx
							local angle = math.acos(dot / (m1 * m2))
							
							if self.beamSprite.transform.y > target.sprite.transform.y then
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
									return target.dodged
								end
							),
							Do(function()
								target.dodged = false
							end),
							target:takeDamage(self.stats, true, BattleActor.shockKnockback)
						)
					}
				},

				-- Hide beam sprite and update state
				Do(function()
					self.turnsBeforeTransition = self.turnsBeforeTransition - 1
					if self.turnsBeforeTransition == 0 then
						self.state = "transition_to_upright"
					end
				end)
			}
		elseif self.state == "transition_to_upright" then
			return Serial {
				Animate(self.sprite, "transition"),
				Animate(self.sprite, "upright"),
				Do(function()
					self.state = "upright"
				end)
			}
		elseif self.state == "upright" then
			return Serial {
				Telegraph(self, "Rover bot looks poised to attack", {255,255,255,50}),
				Do(function()
					self.state = "transition_to_crouched"
				end)
			}
		end
	end
}