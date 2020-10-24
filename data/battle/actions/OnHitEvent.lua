local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local BouncyText = require "actions/BouncyText"
local Do = require "actions/Do"
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"

local PressX = require "data/battle/actions/PressX"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local PartyMember = require "object/PartyMember"

-- Respond to attack with defense event, if possible,
-- otherwise target takes damage as normal
return function(self, target, returnAction, knockbackActionFun, details)
	if not returnAction then
		returnAction = Action()
	end
	
	if not details then
		details = {}
	end

	local actions = {}
	if self.istype(PartyMember) and self.attackEvent then
		table.insert(actions, self:attackEvent(target, returnAction, knockbackActionFun))
	end
	if target.istype(PartyMember) and target.defenseEvent then
		table.insert(actions, target.defenseEvent(self, target, returnAction, knockbackActionFun))
	end
	
	-- 20% chance, all else being equal, you will get a chance at a special "x" event
	if  next(actions) == nil and
		self.istype(PartyMember)
		--and (math.random() < 0.4 + (self.stats.luck/100))
	then
		local bonusStats = {
			attack = 1.5 * self.stats.attack,
			speed = self.stats.speed,
			luck = self.stats.luck
		}
		local starCount = 0
		table.insert(
			actions,
			PressX(
				self,
				target,
				Serial {
					PlayAudio("sfx", "gotit", 1.0, true),
					
					-- Spawn stars around target starting from body and bouncing outwards
					Parallel {
						Repeat(Serial {
							Wait(0.05),
							Do(function()
								local targetXform = target.sprite.transform
								local star = SpriteNode(
									target.scene,
									Transform(targetXform.x, targetXform.y, 0.5, 0.5),
									{0,0,0,0},
									"star",
									nil,
									nil,
									"ui"
								)
								star.transform.ox = star.w/2
								star.transform.oy = star.h/2
								local randomsize = 1.2 - 0.2 * starCount
								local starColors = {
									{0,255,255,0},
									{255,0,0,0},
									{0,255,0,0},
									{255,255,0,0},
									{0,0,255,0},
								}
								Executor(target.scene):act(Parallel {
									Ease(star.color, 4, 255, 9),
									Ease(star.color, 1, starColors[starCount + 1][1], 3),
									Ease(star.color, 2, starColors[starCount + 1][2], 3),
									Ease(star.color, 3, starColors[starCount + 1][3], 3),
									Ease(star.transform, "sx", randomsize, 2, "inout"),
									Ease(star.transform, "sy", randomsize, 2, "inout"),
									Ease(star.transform, "angle", (starCount % 2 == 0 and -math.pi/3 or math.pi/3), 2),
									Ease(star.transform, "x", targetXform.x + (starCount % 2 == 0 and -70 or 70), 2, "inout"),
									Serial {
										Ease(star.transform, "y", targetXform.y - target.sprite.h*0.8, 3, "inout"),
										Parallel {
											Ease(star.transform, "y", targetXform.y + target.sprite.h/2, 2, "quad"),
											Ease(star.color, 4, 0, 2)
										},
										Do(function()
											star:remove()
										end)
									},
								})
								
								starCount = starCount + 1
							end)
						}, 5),

						target:takeDamage(
							bonusStats,
							false,
							function(self, impact, direction)
								return Serial {
									PlayAudio("sfx", self.hurtSfx, nil, true),
									Parallel {
										Animate(function()
											local xform = Transform(
												self.sprite.transform.x,
												self.sprite.transform.y,
												3,
												3
											)
											return SpriteNode(self.scene, xform, nil, "smack", nil, nil, "ui"), true
										end, "idle"),
										Serial {
											Ease(self.sprite.transform, "x", self.sprite.transform.x + (impact/1.5 * direction), 20, "quad"),
											Ease(self.sprite.transform, "x", self.sprite.transform.x - (impact/3 * direction), 20, "quad"),
											Ease(self.sprite.transform, "x", self.sprite.transform.x - (impact/1.5 * direction), 20, "quad"),
											Ease(self.sprite.transform, "x", self.sprite.transform.x + (impact/3 * direction), 20, "quad"),
											Ease(self.sprite.transform, "x", self.sprite.transform.x + (impact/2 * direction), 20, "quad"),
											Ease(self.sprite.transform, "x", self.sprite.transform.x - (impact/4 * direction), 20, "quad"),
											Ease(self.sprite.transform, "x", self.sprite.transform.x + (impact/3 * direction), 20, "quad"),
											Ease(self.sprite.transform, "x", self.sprite.transform.x - (impact/6 * direction), 20, "quad"),
											Ease(self.sprite.transform, "x", self.sprite.transform.x, 20, "linear")
										},
										Serial {
											Ease(self.sprite.color, 1, 800, 2.7, "linear"),
											Ease(self.sprite.color, 1, 255, 2.7, "linear")
										}
									}
								}
							end
						)
					}
				},
				target:takeDamage(self.stats, false, knockbackActionFun)
			)
		)
		table.insert(
			actions,
			returnAction
		)
	end
	
	-- If target is sonic and attack is a laser, allow dodge
	if  next(actions) == nil and
		target.istype(PartyMember) and
		target.id == "sonic" and
		details.attackType == "laser"
	then
		table.insert(
			actions,
			PressX(
				self,
				target,
				Serial {
					Do(function()
						target.dodged = true
					end),
					PlayAudio("sfx", "pressx", 1.0, true),
					Parallel {
						Serial {
							Animate(target.sprite, "crouch"),
							Wait(0.1),
							Animate(target.sprite, "leap_dodge"),
							Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h*2, 6, "linear"),
							Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
							Animate(target.sprite, "crouch"),
							Wait(0.1),
							Animate(target.sprite, "victory"),
							Wait(0.3),
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
				Action()
			)
		)
		table.insert(
			actions,
			returnAction
		)
	end

	if next(actions) == nil then
		table.insert(actions, target:takeDamage(self.stats, false, knockbackActionFun))
		table.insert(actions, returnAction)
	end
	return Parallel(actions)
end
