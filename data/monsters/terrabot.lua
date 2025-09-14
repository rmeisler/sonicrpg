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
		maxhp = 5000,
		attack = 80,
		defense = 30,
		speed = 5,
		focus = 1,
		luck = 1,
	},

	boss = true,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "{h Laser Shields} might be a good idea...",

	onInit = function(self)
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
	end,

	behavior = function (self, target)
		if self.hp <= 0 then
			return Action()
		end
		
		local shootLaser = function(self, target)
			local selfSprite = self:getSprite()
			
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
				Wait(0.2),
				PlayAudio("sfx", "swatbotlaser", 1.0, true),
				
				Parallel {
					singleLaser(self.beamSpriteLeft, 360),
					singleLaser(self.beamSpriteRight, 386)
				},

				target:takeDamage(self.stats, true, BattleActor.shockKnockback)
			}
		end
		
		return Serial {
			PlayAudio("music", "boss", 1.0, true, true),
			Animate(self.scene.partyByName.tails.sprite, "shock"),
			Animate(self.scene.partyByName.b.sprite, "shock"),
			Animate(self.scene.partyByName.babyt.sprite, "shock"),
			MessageBox{message="Tails: W-what is that thing!?{p60} It...{p60} it looks like--"},
			Animate(self.scene.partyByName.babyt.sprite, "sadleft"),
			Parallel {
				Serial {
					AudioFade("music", 1, 0, 1),
					PlayAudio("music", "sonicsad", 1.0, true, true)
				},
				MessageBox{message="Baby T: Uncle!{p60} W...{p60}what have they done to you!?"}
			},
			Animate(self.scene.partyByName.b.sprite, "seriousdown"),
			MessageBox{message="B: He's been roboticized..."},
			Animate(self.scene.partyByName.tails.sprite, "sadleft"),
			MessageBox{message="Tails: I'm sorry, Baby T..."},
			MessageBox{message="Terrabot: ..."},
			MessageBox{message="B: Your uncle is still in there, son. {p60}He's just buried under Robotnik's programming."},
			MessageBox{message="Baby T: Uncle! {p60}Please remember who you are!!"},
			MessageBox{message="Terrabot: ..."},
			Animate(self.scene.partyByName.b.sprite, "idleleft"),
			MessageBox{message="B: Let me try."},
			AudioFade("music", 1, 0, 1),
			Animate(self.scene.partyByName.b.sprite, "camoflauge"),
			Animate(self.scene.partyByName.b.sprite, "redleft"),
			MessageBox{message="B: 111101001000101011010101010010010011100011"},
			Wait(1),
			Animate(self:getSprite(), "getangry"),
			Do(function() self:getSprite():setAnimation("angryidle") end),
			Wait(1),
			Animate(self.scene.partyByName.tails.sprite, "shock"),
			Animate(self.scene.partyByName.babyt.sprite, "shock"),
			Animate(self:getSprite(), "roar"),
			-- ROAR
			Parallel {
				PlayAudio("sfx", "juggerbotroar", 0.8),
				self.scene:screenShake(20, 30, 15)
			},
			Do(function() self:getSprite():setAnimation("angryidle") end),
			Wait(1),
			PlayAudio("music", "roboterrapod", 1.0, true, true),
			Wait(1),

			-- Shoot lasers from eyes at B
			shootLaser(self, self.scene.partyByName.b),
			Animate(self.scene.partyByName.b.sprite, "dead"),
			Animate(self.scene.partyByName.tails.sprite, "saddown"),
			Animate(self.scene.partyByName.babyt.sprite, "idleup"),
			MessageBox{message="Tails: B!!"},
			Animate(self.scene.partyByName.babyt.sprite, "roar"),
			MessageBox{message="Baby T: Uncle!! Stop!!"},
			
			-- Shoot lasers from eyes at whole party
			Wait(2),
			shootLaser(self, self.scene.partyByName.tails),
			Animate(self.scene.partyByName.tails.sprite, "dead"),
			Wait(1),
			shootLaser(self, self.scene.partyByName.babyt),
			Animate(self.scene.partyByName.babyt.sprite, "dead"),
			Wait(1),
			MessageBox{message="Baby T: Ugh... why?..."},
			Wait(1),
			-- TO BE CONTINUED
			Spawn(Serial {
				Wait(1),
				TypeText(
					Transform(40, 200),
					{255, 255, 255, 255},
					FontCache.Techno,
					"To Be Continued...",
					4,
					false,
					true
				),
				Wait(5),
				Do(function()
					self.scene.sceneMgr:pushScene {class = "CreditsSplashScene", fadeOutSpeed=0.05,fadeInSpeed=0.3, enterDelay=4}
				end)
			}),
			Wait(15)
		}
	end
}