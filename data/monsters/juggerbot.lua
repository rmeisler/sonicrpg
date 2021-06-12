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

local Roar = function(self)
	local headSp = self.scene.juggerbothead:getSprite()
	return Serial {
		PlayAudio("sfx", "juggerbotroar", 0.3, true),
		Animate(headSp, "roar"),
		Parallel {
			self.scene:screenShake(20, 30, 7),
			Repeat(Serial {
				Ease(headSp.transform, "x", headSp.transform.x - 1, 10),
				Ease(headSp.transform, "x", headSp.transform.x + 1, 10),
			}, 10)
		},
		Animate(headSp, "undoroar"),
		Animate(headSp, "idleright")
	}
end

return {
	name = "Juggerbot",
	altName = "Juggerbot",
	sprite = "sprites/juggerbotbody",

	stats = {
		xp    = 100,
		maxhp = 1000,
		attack = 20,
		defense = 50,
		speed = 1,
		focus = 1,
		luck = 1,
	},

	boss = true,
	
	run_chance = 0.2,

	coin = 0,

	drops = {
		--{item = require "data/items/MetallicPlate", count = 6, chance = 1.0},
	},
	
	scan = "Focus damage on Juggerbot's weapons systems.",
	
	skipAnimation = true,

	onPreInit = function(self)
		self.scene.juggerbotbody = self
		self.sprite.sortOrderY = self.sprite.transform.y + self.sprite.h

		-- Spawn body parts
		local parts = {"juggerbothead", "juggerbotleftarm", "juggerbotrightarm"}
		for k,v in pairs(parts) do
			local oppo = self.scene:addMonster(v)
			oppo:onPreInit()
		end
		
		self.sprite.h = self.sprite.h + 10
	end,
	
	behavior = function (self, target)
		-- Initialize battle data
		if not self.turnCount then
			self.turnCount = 0
			self.turnPhase = 1
			
			-- Setup stun sprites
			self.stunSprites = {}
			for i=1, 15 do
				local sp = SpriteNode(self.scene, Transform(), nil, "stuneffect", nil, nil, "ui")
				sp.transform.ox = sp.w/2
				sp.transform.oy = sp.h/2
				sp.color[4] = 0
				table.insert(self.stunSprites, sp)
			end
			
			-- Setup blast
			self.blastSprite = SpriteNode(self.scene, Transform(), nil, "blast1", nil, nil, "ui")
			self.blastSprite.transform.sx = 2
			self.blastSprite.transform.sy = 2
			self.blastSprite.transform.ox = 0
			self.blastSprite.color[4] = 0
		end
		
		local action = Action()
		local isblind = self.scene.juggerbothead.hp <= 0
		local misschance = isblind and 0.8 or 0
		
		-- First phase of boss:
		-- roar, stun (all), missile (one)
		if self.turnPhase == 1 then
			local blindAction = Action()
			local turnIdx = self.turnCount % 3

			-- If lost leftarm, move on to next boss phase
			if self.scene.juggerbotleftarm.hp <= 0 then
				turnIdx = -1
				self.turnCount = 0
				self.turnPhase = 2
			else
				-- If lost head, this affects boss' sight/aim
				if isblind then
					blindAction = Telegraph(self, "Juggerbot can't see!", {255,255,255,50})
					
					-- Skip roar
					if turnIdx == 0 then
						turnIdx = 1
						self.turnCount = self.turnCount + 1
					end
				end
				
				-- If lost rightarm, can no longer do stun
				local lostrightarm = self.scene.juggerbotrightarm.hp <= 0
				if lostrightarm then
					-- Skip stun
					if turnIdx == 1 then
						turnIdx = 2
						self.turnCount = self.turnCount + 1
					end
				end
			end

			-- roar
			if turnIdx == 0 then
				action = Roar(self)
			-- stun
			elseif turnIdx == 1 then
				action = Serial {
					blindAction,
					Telegraph(self, "Phasic Stun", {255,255,255,50}),
					Do(function()
						local spr = self.scene.juggerbotrightarm:getSprite()
						spr.transform.ox = 32
						spr.transform.oy = 6
						spr.transform.x = spr.transform.x + 64
						spr.transform.y = spr.transform.y + 12
					end),
					Ease(self.scene.juggerbotrightarm:getSprite().transform, "angle", -math.pi/2, 1.3),
					
					PlayAudio("sfx", "stun", 1.0, true),
					Do(function()
						local rightArmSp = self.scene.juggerbotrightarm:getSprite()
						for index,sp in pairs(self.stunSprites) do
							Executor(self.scene):act(Serial {
								Wait(0.1 * index),
								Do(function()
									sp.transform.x = rightArmSp.transform.x + rightArmSp.h*1.5
									sp.transform.y = rightArmSp.transform.y + 16
									sp.transform.sx = 2
									sp.transform.sy = 2
									sp.color[4] = 255
								end),
								Parallel {
									Ease(sp.transform, "sy", 3, 1.5),
									Ease(sp.transform, "x", target.sprite.transform.x - target.sprite.w/2, 1.3),
									Ease(sp.transform, "y", target.sprite.transform.y, 1.3),
									
									Serial {
										Wait(0.3),
										Do(function()
											if target.sprite.selected ~= "hurt" then
												target.sprite:setAnimation("hurt")										
												Executor(self.scene):act(Serial {
													Repeat(Serial {
														Ease(target.sprite.color, 1, 512, 8),
														Ease(target.sprite.color, 1, 300, 8)
													}, 10),
													Ease(target.sprite.color, 1, 255, 8)
												})
											end
										end)
									}
								},
								Parallel {
									Ease(sp.transform, "sy", 7, 8),
									Ease(sp.color, 4, 0, 4)
								}
							})
						end
					end),

					Wait(1.6),
					Ease(self.scene.juggerbotrightarm:getSprite().transform, "angle", 0, 1.3),
					Do(function()
						local spr = self.scene.juggerbotrightarm:getSprite()
						spr.transform.ox = 0
						spr.transform.oy = 0
						spr.transform.x = spr.transform.x - 64
						spr.transform.y = spr.transform.y - 12
					end),
					
					Telegraph(target, target.name.." is stunned!", {255,255,255,50}),
					Do(function()
						target.sprite:setAnimation("idle")
					end)
				}
			-- fire shot
			elseif turnIdx == 2 then
				local dodgeAction = Do(function()
					target.dodged = false
				end)
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
						Serial {
							Do(function()
								target.dodged = false
							end)
						}
					)
				end
			
				action = Serial {
					blindAction,
					Telegraph(self, "Fire Shot", {255,255,255,50}),
					Animate(self.scene.juggerbotleftarm:getSprite(), "cannonright"),
					
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
			end
		end
		
		-- Second phase of boss:
		-- roar, charge up plasma cannon for three turns, fire (can kill whole party)
		if self.turnPhase == 2 then
			local turnIdx = self.turnCount % 5
			
			-- Reduce defense in phase 2
			if self.stats.defense > 20 then
				turnIdx = -1
				self.stats.defense = 20
				action = Serial {
					Telegraph(self, "Juggerbot's defenses are down!", {255,255,255,50}),
					isblind and Action() or Roar(self)
				}
			end
			
			-- If lost head
			if isblind then
				-- Skip roar
				if turnIdx == 0 then
					turnIdx = 1
					self.turnCount = self.turnCount + 1
				end
			end

			-- roar
			if turnIdx == 0 then
				action = Roar(self)
			-- charge
			elseif turnIdx == 1 then
				action = Serial {
					Animate(self:getSprite(), "cannonright"),
					Animate(self:getSprite(), "idlecannonright"),
					PlayAudio("sfx", "lockon", 1.0, true),
					Telegraph(self, "3...", {255,255,255,50}),
				}
			elseif turnIdx == 2 then
				action = Serial {
					PlayAudio("sfx", "lockon", 1.0, true),
					Telegraph(self, "2...", {255,255,255,50}),
				}
			elseif turnIdx == 3 then
				action = Serial {
					PlayAudio("sfx", "lockon", 1.0, true),
					Telegraph(self, "1...", {255,255,255,50}),
				}
			-- plasma cannon
			elseif turnIdx == 4 then
				-- Can interrupt the plasma cannon if you destroy a body part,
				-- including left arm or head.
				
				-- Can delay it if you use Bunnie's grab or Sonic's roundabout
				
				-- Can interrupt plasma cannon with Mine
				
				-- Can survive plasma cannon if you are using a laser shield
				action = Serial {
					Telegraph(self, "Plasma Beam", {255,255,255,50}),
					Wait(1),
					Animate(self:getSprite(), "undocannonright")
				}
			end
		end
		
		self.turnCount = self.turnCount + 1
		
		return action
	end
}