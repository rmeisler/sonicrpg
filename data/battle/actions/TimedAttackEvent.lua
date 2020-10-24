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
return function(self, target, returnAction)
	local bonusStats = {
		attack = 1.5 * self.stats.attack,
		speed = self.stats.speed,
		luck = self.stats.luck
	}
	local starCount = 0
	return PressX(
		self,
		target,
		Serial {
			PlayAudio("sfx", "gotit", 1.0, true),
			
			-- Spawn stars around target starting from body and bouncing outwards
			Parallel {
				returnAction,
			
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
						local randomsize = 1 + math.random()
						local starColors = {
							{0,255,255,0},
							{255,0,0,0},
							{0,255,0,0},
							{255,255,0,0},
							{0,0,255,0},
						}
						Executor(target.scene):act(Parallel {
							Ease(star.color, 4, 255, 9),
							Ease(star.color, 1, starColors[starCount + 1][1], 4),
							Ease(star.color, 2, starColors[starCount + 1][2], 4),
							Ease(star.color, 3, starColors[starCount + 1][3], 4),
							Ease(star.transform, "sx", randomsize, 3, "inout"),
							Ease(star.transform, "sy", randomsize, 3, "inout"),
							Ease(star.transform, "angle", (starCount % 2 == 0 and -math.pi/3 or math.pi/3), 3),
							Ease(star.transform, "x", targetXform.x + (starCount % 2 == 0 and -target.sprite.w*1.3 or target.sprite.w*1.3), 3, "inout"),
							Serial {
								Ease(star.transform, "y", targetXform.y - target.sprite.h*0.8, 4, "inout"),
								Parallel {
									Ease(star.transform, "y", targetXform.y + target.sprite.h/2, 3, "quad"),
									Ease(star.color, 4, 0, 3)
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
									Parallel {
										Ease(self.sprite.color, 2, 150, 2.7, "linear"),
										Ease(self.sprite.color, 3, 150, 2.7, "linear")
									},
									Parallel {
										Ease(self.sprite.color, 2, 255, 2.7, "linear"),
										Ease(self.sprite.color, 3, 255, 2.7, "linear")
									}
								}
							}
						}
					end
				)
			}
		},
		Parallel {
			target:takeDamage(self.stats),
			returnAction
		}
	)
end
