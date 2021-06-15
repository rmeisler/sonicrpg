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
local Repeat = require "actions/Repeat"
local While = require "actions/While"
local Executor = require "actions/Executor"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local Transform = require "util/Transform"

local BattleActor = require "object/BattleActor"
local SpriteNode = require "object/SpriteNode"

return {
	name = "Left Arm",
	altName = "Left Arm",
	sprite = "sprites/juggerbotbody",
	
	mockSprite = "sprites/juggerbotleftarm",
	mockSpriteOffset = Transform(0, 0),

	stats = {
		xp      = 0,
		maxhp   = 800,
		attack  = 30,
		defense = 10,
		speed   = 1,
		focus   = 1,
		luck    = 1,
	},
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		
	},
	
	scan = "Focus damage on Juggerbot's weapons systems.",
	
	skipAnimation = true,

	onPreInit = function(self)
		self.scene.juggerbotleftarm = self
		self:getSprite():setAnimation("idle")
	end,
	
	onInit = function(self)
		-- Relocate arm to proper area of juggerbot body
		local body = self.scene.juggerbotbody
		self.mockSprite.transform.ox = 0
		self.mockSprite.transform.oy = 0
		self.mockSprite.transform.x = body.sprite.transform.x - body.sprite.w + 30
		self.mockSprite.transform.y = body.sprite.transform.y - body.sprite.h + 50
		self.mockSprite.sortOrderY = body.sprite.sortOrderY - 200
		
		-- Locate where we want the cursor to be
		self.sprite.transform.x = body.sprite.transform.x + 50
		self.sprite.transform.y = body.sprite.transform.y + 20
		self.sprite.h = self.sprite.h - 20
	end,
	
	onDead = function(self)
		self.scene.juggerbotbody.turnCount = 0
		self.scene.juggerbotbody.turnPhase = 2

		-- Reduce defense on body
		self.scene.juggerbotbody.stats.defense = 20

		return Telegraph(self, "Juggerbot's defenses are down!", {255,255,255,50})
	end,
	
	behavior = function (self, target)
		-- Setup blast
		if not self.blastSprite then
			self.blastSprite = SpriteNode(self.scene, Transform(), nil, "blast1", nil, nil, "ui")
			self.blastSprite.transform.sx = 2
			self.blastSprite.transform.sy = 2
			self.blastSprite.transform.ox = 0
			self.blastSprite.color[4] = 0
		end
	
		local dodgeAction = Do(function()
			target.dodged = false
		end)
		if target.id == "sonic" and not target.laserShield and target.state ~= BattleActor.STATE_IMMOBILIZED then
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
				Serial {
					Do(function()
						target.dodged = false
					end)
				}
			)
		end
		
		local isblind = self.scene.juggerbothead.hp <= 0
		local misschance = isblind and 0.8 or 0
		
		local blindAction = Action()
		if isblind then
			blindAction = Telegraph(self, "Juggerbot can't see!", {255,255,255,50})
		end
	
		return Serial {
			blindAction,
			Telegraph(self.scene.juggerbotleftarm, "Fire Shot", {255,255,255,50}),
			Animate(self.scene.juggerbotleftarm:getSprite(), "cannonright"),
			
			Wait(0.2),
			PlayAudio("sfx", "laser", 1.0, true),
			Parallel {
				dodgeAction,
				Animate(function()
					local leftarmSp = self.scene.juggerbotleftarm:getSprite()
					local xform = Transform(
						leftarmSp.transform.x + leftarmSp.w * 1.5,
						leftarmSp.transform.y + leftarmSp.h/2 - 5,
						2,
						2
					)
					return SpriteNode(self.scene, xform, nil, "fireshot", nil, nil, "ui"), true
				end, "fire"),
				Serial {
					Wait(0.2),
					Do(function()
						local leftarmSp = self.scene.juggerbotleftarm:getSprite()
						self.blastSprite.transform.x = leftarmSp.transform.x + leftarmSp.w + self.blastSprite.w
						self.blastSprite.transform.y = leftarmSp.transform.y + leftarmSp.h/2 + self.blastSprite.h*3 + 5
						self.blastSprite.transform.ox = 0
						self.blastSprite.transform.sx = 2
						self.blastSprite.color[4] = 255
						
						local x1, y1 = self.blastSprite.transform.x, self.blastSprite.transform.y
						local x2, y2 = target.sprite.transform.x, target.sprite.transform.y

						local dx = (x2 - x1)
						local dy = (y2 - y1)

						local dot = dx * dx
						local m1 = math.sqrt(dx*dx + dy*dy)
						local m2 = dx
						local angle = math.acos(dot / (m1 * m2))
						
						if self.blastSprite.transform.y > target.sprite.transform.y then
							self.blastSprite.transform.angle = -angle
						else
							self.blastSprite.transform.angle = angle
						end
						
						self.xDist = dx
						self.yDist = dy
						self.len = m1/self.blastSprite.w	
					end),
					
					Do(function()
						self.blastSprite.transform.ox = self.blastSprite.w
						self.blastSprite.transform.x = self.blastSprite.transform.x + self.blastSprite.w
					end),
					
					While(
						function()
							return target.dodged == nil or target.dodged == false
						end,
						Serial {
							Parallel {
								Ease(self.blastSprite.transform, "x", target.sprite.transform.x, 5),
								Ease(self.blastSprite.transform, "y", target.sprite.transform.y, 5)
							},
							Parallel {
								Ease(self.blastSprite.transform, "sx", 0, 10),
								target:takeDamage(
									math.random() > misschance
										and self.stats
										or {attack = 0, speed = 0, miss = true},
									true,
									BattleActor.shockKnockback
								)
							}
						},
						Serial {
							Parallel {
								Ease(self.blastSprite.transform, "x", target.sprite.transform.x, 6),
								Ease(self.blastSprite.transform, "y", target.sprite.transform.y, 6)
							},
							Ease(self.blastSprite.transform, "sx", 0, 10)
						}
					),
					
					Animate(self.scene.juggerbotleftarm:getSprite(), "undocannonright")
				}
			},
			Do(function()
				target.dodged = nil
			end)
		}
	end,
	
	getBackwardAnim = function(self)
		return "idleright"
	end
}