local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"

local Stars = require "data/battle/actions/Stars"
local BouncyText = require "actions/BouncyText"
local HealText = require "data/items/actions/HealText"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local setNextTurn
setNextTurn = function(self)
	print("on next turn")
	local direction = (self.sprite.transform.x > love.graphics.getWidth()/2) and 1 or -1
	local bouncyTextOffset = (direction > 0) and -10 or -30
	local prevMusic = self.scene.audio:getCurrentMusic()

	self.onNextTurn = Parallel {
		Serial {
			AudioFade("music", 1.0, 0.0, 1),
			PlayAudio("music", "resiliency", 1.0),
			PlayAudio("music", prevMusic, 1.0, true)
		},
		Serial {
			Parallel {
				Ease(self.sprite.glowColor, 4, 255, 3),
				Ease(self.sprite, "glowSize", 6, 3),
				Ease(self.sprite.color, 1, 500, 3),
				Ease(self.sprite.color, 2, 500, 3),
				Ease(self.sprite.color, 3, 500, 3),
				
				Serial {
					Wait(0.5),
					Do(function() self.sprite:setAnimation("rise") end),
					Wait(2.5),
					HealText("hp", 400, {0,255,0,255})(
						self,
						Transform(
							self.sprite.transform.x + bouncyTextOffset + self.textOffset.x,
							self.sprite.transform.y + self.textOffset.y
						)
					),
					Do(function() self.sprite:setAnimation("idle") end),
					MessageBox {
						rect=MessageBox.HEADLINER_RECT,
						message="Antoine got up!",
						textSpeed=8,
						closeAction=Wait(1)
					}
				}
			},
			Parallel {
				Ease(self.sprite.glowColor, 4, 0, 3),
				Ease(self.sprite, "glowSize", 6, 3),
				Ease(self.sprite.color, 1, 255, 3),
				Ease(self.sprite.color, 2, 255, 3),
				Ease(self.sprite.color, 3, 255, 3)
			}
		}
	}
	self:removeHandler("dead", setNextTurn)
end

return function(self)
	local direction = (self.sprite.transform.x > love.graphics.getWidth()/2) and 1 or -1
	local bouncyTextOffset = (direction > 0) and -10 or -30

	local selfXform = self.sprite.transform
	local sparkleCount = 0
	return Serial {
		Animate(self.sprite, "victory"),
		
		-- Spawn sparkles around self starting from foot and moving upward in sine-wave
		Repeat(Serial {
			Do(function()
				local sparkle = SpriteNode(
					self.scene,
					Transform(selfXform.x - sparkleCount*10, selfXform.y + self.sprite.h/2),
					{500,500,500,0},
					"sparkle",
					5,
					5,
					"ui"
				)
				Executor(self.scene):act(Parallel {
					Repeat(Animate(sparkle, "idle"), nil, false),
					Ease(sparkle.transform, "y", selfXform.y - self.sprite.h/2, 1.5),
					Ease(sparkle.color, 4, 255, 9),
					Repeat(Serial {
						Parallel {
							Ease(sparkle.transform, "x", sparkle.transform.x - self.sprite.w/2, 6),
							Ease(sparkle.transform, "sx", 2, 12),
							Ease(sparkle.transform, "sy", 2, 12),
						},
						Parallel {
							Ease(sparkle.transform, "x", sparkle.transform.x + self.sprite.w, 6),
							Ease(sparkle.transform, "sx", 1, 12),
							Ease(sparkle.transform, "sy", 1, 12),
						}
					}, 2, true),
					Serial {
						Wait(1),
						Ease(sparkle.color, 4, 0, 3)
					},
				})
				sparkleCount = sparkleCount + 1
			end),
			Wait(0.1)
		}, 4),
		
		-- Fade in and out white glow
		Serial {
			Do(function() self.sprite:setGlow({512,512,512,255},2) end),
			PlayAudio("sfx", "levelup", 1.0, true),
			Parallel {
				Ease(self.sprite.glowColor, 4, 50, 3),
				Ease(self.sprite, "glowSize", 6, 3),
				Ease(self.sprite.color, 1, 500, 3),
				Ease(self.sprite.color, 2, 500, 3),
				Ease(self.sprite.color, 3, 500, 3),
			},
			BouncyText(
				Transform(
					self.sprite.transform.x + bouncyTextOffset + self.textOffset.x,
					self.sprite.transform.y + self.textOffset.y
				),
				{255, 255, 255, 255},
				FontCache.Consolas,
				"extra life",
				12,
				false,
				true
			),
			Parallel {
				Ease(self.sprite.glowColor, 4, 0, 6, "quad"),
				Ease(self.sprite, "glowSize", 2, 6, "quad"),
				Ease(self.sprite.color, 1, self.color[1], 6, "quad"),
				Ease(self.sprite.color, 2, self.color[2], 6, "quad"),
				Ease(self.sprite.color, 3, self.color[3], 6, "quad"),
			},
			Do(function() self.sprite:removeGlow() end)
		},

		Do(function()
			self.extraLives = self.extraLives + 1
			self:addHandler("dead", setNextTurn, self)
			self.sprite:removeGlow()
			self.state = BattleActor.STATE_IDLE
			self.sprite:setAnimation("idle")
			self:endTurn()
		end)
	}
end