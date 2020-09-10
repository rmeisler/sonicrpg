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

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

return {
	name = "Swatbot",
	altName = "Swatbot",
	sprite = "sprites/swatbot",

	stats = {
		xp    = 5,
		maxhp = 100,
		attack = 12,
		defense = 15,
		speed = 5,
		focus = 0,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},
	
	scan = "Swatbots are succeptible to water damage.",

	behavior = function (self, target)
		if not self.beamSprite then
			-- Setup beam sprite
			self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
			self.beamSprite.transform.sx = 0
			self.beamSprite.transform.sy = 1
			self.beamSprite.transform.ox = 0
			
			self.targetSprite = SpriteNode(self.scene, Transform(0, 0, 2, 2), nil, "target", nil, nil, "ui")
			self.targetSprite.transform.ox = self.targetSprite.w/2
			self.targetSprite.transform.oy = self.targetSprite.h/2
			self.targetSprite.color[4] = 0
		end
		
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
		end
	
		return Serial {
			Telegraph(self, "Arm Laser", {255,255,255,50}),
			Animate(self.sprite, "shoot"),
			Animate(self.sprite, "shoot_idle"),
			
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
						xform.x = xform.x - 25
						xform.y = xform.y - 50
						return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
					end, "idle"),

					PlayAudio("sfx", "swatbotlaser", 1.0, true),
					
					Do(function()
						self.beamSprite.transform.x = self.sprite.transform.x - 25 + self.beamSprite.w
						self.beamSprite.transform.y = self.sprite.transform.y - 50 + self.beamSprite.h*2
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
					),

					Animate(self.sprite, "shoot_retract"),
					Animate(self.sprite, "idle")
				}
			}
		}
	end
}