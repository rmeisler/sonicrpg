local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local BouncyText = require "actions/BouncyText"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"
local TypeText = require "actions/TypeText"
local AudioFade = require "actions/AudioFade"
local IfElse = require "actions/IfElse"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Terrabot",
	altName = "Terrabot",
	sprite = "sprites/phantomstandin",
	
	mockSprite = "sprites/terrabot",
	mockSpriteOffset = Transform(-230, -200),

	stats = {
		xp = 120,
		maxhp = 6000,
		attack = 100,
		defense = 100,
		speed = 100,
		focus = 100,
		luck = 100,
	},

	boss = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "{h Laser Shields} might be a good idea...",

	onInit = function(self)
		self:getSprite():pushOverride("idle", "angryidle")
		self:getSprite().sortOrderY = -100
		self.scene.audio:playMusic("roboterrapod", 0.7, true)

		-- Setup beam sprite
		self.beamSpriteLeft = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
		self.beamSpriteLeft.transform.sx = 0
		self.beamSpriteLeft.transform.sy = 1
		self.beamSpriteLeft.transform.ox = 0
		self.beamSpriteLeft.color = {512,255,512,255}
		self.beamSpriteLeft:setAnimation("red")
		
		self.beamSpriteRight = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
		self.beamSpriteRight.transform.sx = 0
		self.beamSpriteRight.transform.sy = 1
		self.beamSpriteRight.transform.ox = 0
		self.beamSpriteRight.color = {512,255,512,255}
		self.beamSpriteRight:setAnimation("red")
		
		self.targetSprite = SpriteNode(self.scene, Transform(0, 0, 2, 2), nil, "target", nil, nil, "ui")
		self.targetSprite.transform.ox = self.targetSprite.w/2
		self.targetSprite.transform.oy = self.targetSprite.h/2
		self.targetSprite.color[4] = 0
		
		self.turnCount = 0
		self.translate = GameState:isEquipped("babyt", ItemType.Accessory, "Translator Collar")
		self.shootLaser = function(self, target)
			local selfSprite = self:getSprite()
			local dodgeAction = target.defenseEvent and
				target.defenseEvent(self, target) or
				Action()

			local singleLaser = function(beamSprite, xOffset)
				return Serial {
					Do(function()
						beamSprite.transform.x = selfSprite.transform.x + xOffset + beamSprite.w
						beamSprite.transform.y = selfSprite.transform.y + 83 + beamSprite.h*2
						beamSprite.transform.ox = 0

						local x1, y1 = beamSprite.transform.x, beamSprite.transform.y
						local x2, y2 = target.sprite.transform.x, target.sprite.transform.y

						local dx = (x2 - x1)
						local dy = (y2 - y1)

						local dot = dx * dx
						local m1 = math.sqrt(dx*dx + dy*dy)
						local m2 = dx
						local angle = math.acos(dot / (m1 * m2))
						
						if beamSprite.transform.y > target.sprite.transform.y then
							beamSprite.transform.angle = -angle
						else
							beamSprite.transform.angle = angle
						end
						
						self.xDist = dx
						self.yDist = dy
						self.len = m1/beamSprite.w
					end),
					
					-- Beam stretch to target and recede
					Ease(beamSprite.transform, "sx", function() return self.len end, 8),
					
					Do(function()
						beamSprite.transform.ox = beamSprite.w
						
						beamSprite.transform.x = beamSprite.transform.x + self.xDist
						beamSprite.transform.y = beamSprite.transform.y + self.yDist
					end),
					
					Ease(beamSprite.transform, "sx", 0, 8),
				}
			end
			
			return Serial {
				Telegraph(self, "Eye Beam", {255,255,255,50}),

				Do(function()
					self.targetSprite.transform.x = target.sprite.transform.x
					self.targetSprite.transform.y = target.sprite.transform.y + 10
				end),

				Parallel {
					Serial {
						Wait(0.5),
						dodgeAction
					},
					Serial {
						Parallel {
							Ease(self.targetSprite.color, 4, 255, 5),
							Serial {
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

						Wait(0.3),
						PlayAudio("sfx", "swatbotlaser", 1.0, true),
						
						Parallel {
							singleLaser(self.beamSpriteLeft, 360),
							singleLaser(self.beamSpriteRight, 386)
						},
						
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
				}
			}
		end
		self.roar = function (self, target)
			return Serial {
				Animate(self:getSprite(), "roar"),
				-- ROAR
				Parallel {
					PlayAudio("sfx", "juggerbotroar", 0.8),
					self.scene:screenShake(20, 30, 15)
				},
				Do(function() self:getSprite():setAnimation("angryidle") end)
			}
		end
	end,

	behavior = function (self, target)
		self.turnCount = self.turnCount + 1
		
		if self.scene.partyByName.babyt.hp == 0 then
			-- Can't win without Baby T
			self.scene.specialLoseAction = Serial {
				self.scene.partyByName.tails.hp > 0 and
					Animate(self.scene.partyByName.tails.sprite, "saddown") or
					Action(),
				self.scene.partyByName.b.hp > 0 and
					Serial {
						Animate(self.scene.partyByName.b.sprite, "pose"),
						MessageBox{message="B: We won't make it without Baby T..."}
					} or
					MessageBox{message="Tails: Without Baby T, we don't stand a chance..."}
			}
			return Action()
		end

		if self.turnCount == 1 then
			return Serial {
				MessageBox{message="B: We won't be able to fight him, he's too strong!"},
				MessageBox{message="B: Baby T, try to get through to your uncle!"},
				MessageBox{message="B: I can try to reflect his lasers..."},
			}
		elseif self.turnCount == 2 then
			return MessageBox{message="Baby T: Uncle, {p60}we need your help now to stop Robotnik!"}
		elseif self.turnCount == 3 then
			return Serial {
				self.roar(self, target),
				self.shootLaser(self, target)
			}
		elseif self.turnCount == 4 then
			return Serial {
				MessageBox{message="Baby T: I know it's not fair to ask you to do this after you've already done so much for our family..."},
				MessageBox{message="Baby T: ...but we don't have any other options!"}
			}
		elseif self.turnCount == 5 then
			return Serial {
				self.roar(self, target),
				self.shootLaser(self, target)
			}
		elseif self.turnCount == 6 then
			self.scene.partyByName.tails.targetOverride = nil
			self.scene.partyByName.babyt.targetOverride = nil
			return MessageBox{message="Baby T: If you can fight Robotnik's programming{p60} just this once{p60}, then I promise I'll take care of the rest!"}
		elseif self.turnCount == 7 then
			return Serial {
				AudioFade("music", 1, 0, 1),
				Animate(self:getSprite(), "roar"),
				PlayAudio("sfx", "juggerbotroarsilence", 0.8),
				Wait(2),
				Animate(self:getSprite(), "getangry"),
				Do(function()
					self:getSprite():popOverride("idle")
					self:getSprite():setAnimation("idle")
				end),
				PlayAudio("music", "babyt", 2, true, true),
				MessageBox{message="Uncle T: ..."},
				MessageBox{message="Uncle T: Nephew?... {p60}i-s-*zzz*-s *zzzzz*-that you?..."},
				Wait(1),
				self.scene.partyByName.b.hp > 0 and
					Serial {
						Animate(self.scene.partyByName.b.sprite, "pose"),
						MessageBox{message="B: Well done, Baby T!"}
					} or
					(self.scene.partyByName.tails.hp > 0 and
						Serial {
							Animate(self.scene.partyByName.tails.sprite, "pose"),
							Parallel {
								self.scene.partyByName.tails:hop(),
								MessageBox{message="Tails: You did it, Baby T!!"}
							}
						} or
						Action()),
				MessageBox{message="Uncle T: I-I'm s-*zzzz*-so s-*zzzz*-sorry."},
				Animate(self.scene.partyByName.babyt.sprite, "sadleft"),
				MessageBox{message="Baby T: It's ok!{p60} It's not your fault, uncle!"},
				MessageBox{message="Uncle T: I ca-ca-can't-t-t harm R-R-Robotnik *zzzzzz*{p60}-- b-but I ca-can ru-ru-run..."},
				MessageBox{message="Uncle T: Y-y-you must p-p-protect family now{p40},\nn-n-n-nephew..."},
				Ease(self:getSprite().transform, "x", -600, 3),
				Wait(1),
				Animate(self.scene.partyByName.babyt.sprite, "verysadleft"),
				MessageBox{message="Baby T: *sniff* Goodbye uncle... {p60}I won't let you down."},
				Wait(1),
				self.scene:earlyExit(),
				Do(function() end)
			}
		end
	end
}