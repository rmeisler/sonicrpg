local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local WaitForFrame = require "actions/WaitForFrame"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local IfElse = require "actions/IfElse"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"
local BlockPlayer = require "actions/BlockPlayer"
local PressX = require "data/battle/actions/PressX"

local BasicNPC = require "object/BasicNPC"
local EscapeObstacle = require "object/EscapeObstacle"
local EscapeHoverbot = require "object/EscapeHoverbot"
local EscapeIndicator = require "object/EscapeIndicator"

local SpriteNode = require "object/SpriteNode"
local BasicNPC = require "object/BasicNPC"
local EscapePlayer = require "object/EscapePlayer"

local TARGET_OFFSET_X = 400

local missileTarget = function(target, player, missile, explosion)
	return Serial {
		Do(function()
			target.sprite.transform.ox = target.sprite.w/2
			target.sprite.transform.oy = target.sprite.h/2

			player.sprite:setAnimation("racescared")
		end),
		Parallel {
			Do(function()
				target.x = player.x - player.sprite.w + target.sprite.w
				target.y = player.y + target.sprite.h - 40
			end),
			Ease(target.sprite.color, 4, 255, 5),
			Serial {
				PlayAudio("sfx", "lockon", 1.0, true),
				Parallel {
					Ease(target.sprite.transform, "sx", 4, 12, "inout"),
					Ease(target.sprite.transform, "sy", 4, 12, "inout")
				},
				Parallel {
					Ease(target.sprite.transform, "sx", 1.5, 12, "inout"),
					Ease(target.sprite.transform, "sy", 1.5, 12, "inout")
				},
				Parallel {
					Ease(target.sprite.transform, "sx", 3, 12, "inout"),
					Ease(target.sprite.transform, "sy", 3, 12, "inout")
				},
				Parallel {
					Ease(target.sprite.transform, "sx", 2, 12, "inout"),
					Ease(target.sprite.transform, "sy", 2, 12, "inout")
				},
				
				Ease(target.sprite.color, 4, 0, 5),
			},
			
			Serial {
				Wait(0.2),
				PressX(
					player,
					player,
					Serial {
						Do(function()
							-- Boost player forward here...
							player.bx = 5
							player.sprite:setAnimation("racesmile")
						end)
					},
					Serial {
						Animate(player.sprite, "racehurt"),
						Do(function()
							player.bx = -1
						end),
						Parallel {
							Ease(player.sprite.transform, "angle", 2*math.pi, 1, "quad"),
							Serial {
								Ease(player, "y", function() return player.y - 80 end, 2, "quad"),
								Ease(player, "y", function() return player.y + 80 end, 2, "quad"),
							},
							Repeat(
								Serial {
									Ease(player.sprite.color, 4, 0, 20, "quad"),
									Ease(player.sprite.color, 4, 255, 20, "quad")
								},
								10
							)
						},
						Do(function()
							player.sprite.transform.angle = 0
							player.sprite:setAnimation("race")
						end)
					},
					0.4
				)
			},
			
			Serial {
				Wait(0.7),
				Do(function()
					explosion.sprite.transform.sx = 4
					explosion.sprite.transform.sy = 4
					explosion.x = player.x + 100
					explosion.y = player.y - 130
					explosion.hidden = true
					missile.move = false
					missile.smokeOnly = true
				end),
				Parallel {
					Ease(missile, "x", function() return explosion.x end, 5, "quad"),
					Ease(missile, "y", function() return explosion.y end, 5, "quad"),
					Wait(0.1)
				},
				Do(function()
					missile.hidden = true
					explosion.hidden = false
				end),
				PlayAudio("sfx", "explosion", 1, true),
				Animate(explosion.sprite, "updown"),
			}
		}
	}
end

return function(scene)
	scene.bgColor = {255,255,255,255}
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	scene.objectLookup.Robotnik.stopMoving = true

	GameState.leader = "tails"
	
	local dustObjects = {}
	local currentDust = 0
	for i=1,20 do
		local dustAnim = "right"
		--local dustX, dustY = self.x, self.y + self.halfHeight
		--dustX = dustX - self.width * 2 - 5

		local dustObject = BasicNPC(
			scene,
			{name = "objects"},
			{name = "dust", x = 0, y = 0, width = 40, height = 36,
				properties = {nocollision = true, sprite = "art/sprites/dust.png", align = "bottom_left"}
			}
		)
		dustObject.sprite.color[1] = 130
		dustObject.sprite.color[2] = 130
		dustObject.sprite.color[3] = 200
		dustObject.sprite.color[4] = 255
		
		--dustObject.x = dustObject.x - dustObject.sprite.w
		--dustObject.y = dustObject.y - dustObject.sprite.h*2
		dustObject.sprite.transform.sx = 4
		dustObject.sprite.transform.sy = 4
		dustObject.sprite:setAnimation(dustAnim)
		dustObject.sprite:addSceneHandler("update", function(self, dt)
			local anim = self.animations[self.selected]
			if not anim then
				return
			end
			if anim.position == #anim.frames then
				self.color[4] = 0
				currentDust = (currentDust + 1) % table.count(dustObjects)
			end
		end)
		scene:addObject(dustObject)
		table.insert(dustObjects, dustObject)
	end

	local ROBOTNIK_SPEED = 20

	local sonic = scene.objectLookup.Sonic
	local fleet = scene.objectLookup.Fleet
	local tails = scene.objectLookup.Tails
	tails.sprite.transform.ox = 30
	tails.sprite.transform.oy = 44
	tails.pressXXForm = Transform.relative(tails.sprite.transform, Transform(50, 20))
	
	local explosion = scene.objectLookup.Explosion
	local robotnik = scene.objectLookup.Robotnik
	local chargeShot = BasicNPC(
		scene,
		{name = "objects"},
		{
			name = "chargeshot",
			x = robotnik.x + 240,
			y = robotnik.y + 70,
			width = 19,
			height = 19,
			properties = {nocollision = true, sprite = "art/sprites/plasmabeam.png"}
		}
	)
	chargeShot.sprite.transform.ox = chargeShot.sprite.w/2
	chargeShot.sprite.transform.oy = chargeShot.sprite.h/2
	chargeShot.sprite.transform.sx = 0.3
	chargeShot.sprite.transform.sy = 0.3
	chargeShot.sprite:setAnimation("charge")
	chargeShot.hidden = true
	scene:addObject(chargeShot)
	
	local target = scene.objectLookup.Target

	local waterfallLayer1 = scene:findLayer("waterfall1")
	local waterfallLayer2 = scene:findLayer("waterfall2")
	local floor2Layer = scene:findLayer("floor2")
	local waterfallAnim = Spawn(
		Repeat(Serial {
			Do(function()
				waterfallLayer1.opacity = 0.7
				waterfallLayer2.opacity = 0
				floor2Layer.opacity = 0
			end),
			Wait(0.2),
			Do(function()
				waterfallLayer1.opacity = 0
				waterfallLayer2.opacity = 0.7
				floor2Layer.opacity = 1
			end),
			Wait(0.2),
		}, 1000000)
	)

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		waterfallAnim,
		Do(function()
			scene.objectLookup.Robotnik:addSceneHandler("update", function(self, dt)
				local vx = ROBOTNIK_SPEED * (dt/0.016)
				if self.hurt then
					self.x = self.x + vx * 0.2
				else
					self.x = self.x + vx
				end
				chargeShot.x = chargeShot.x + vx
				
				if love.keyboard.isDown("up") then
					if tails.y > 420 then
						tails.y = tails.y - 6*(dt/0.016)
					else
						tails.y = 420
					end
				elseif love.keyboard.isDown("down") then
					if tails.y < 750 then
						tails.y = tails.y + 6*(dt/0.016)
					else
						tails.y = 750
					end
				end
				
				if not scene.frameCounter then
					scene.frameCounter = 0
				else
					scene.frameCounter = scene.frameCounter + 1
				end
				if scene.frameCounter % 10 == 0 then
					print("tails x = "..tostring(tails.x))
				end

				--[[
				if self.x > 44000 then
					tails.x = tails.x + vx + 1 * (dt/0.016)
				else
				]]

				if not tails.bx or tails.bx < 0.1 and tails.bx > -0.1 then
					tails.bx = 0.0
				elseif tails.bx > 0.0 then
					tails.bx = tails.bx - 0.05 * (dt/0.016)
				else
					tails.bx = tails.bx + 0.05 * (dt/0.016)
				end

				if self.x > 11000 and self.x < 14500 then
					tails.x = tails.x + vx + 1 * (dt/0.016)
				elseif self.x > 50000 and self.x < 60500 then
					tails.x = tails.x + vx + (2.2 + tails.bx) * (dt/0.016)
				elseif self.x > 2000 then
					tails.x = tails.x + vx + tails.bx * (dt/0.016)
				end
				
				if sonic.x > 80000 then
					if sonic.x < robotnik.x - 200 then
						sonic.x = sonic.x + vx + 2 * (dt/0.016)
					else
						sonic.x = sonic.x + vx
					end
				end
				
				if fleet.x > 80000 and fleet.x < 94500 then
					fleet.x = fleet.x + vx + 60 * (dt/0.016)
				elseif fleet.x > 94500 then
					fleet.sprite:setAnimation("flyrightsmile")
					fleet.x = fleet.x + vx * 0.9
				end

				if self.x > 7000 and self.x < 9000 then
					self.sprite:setAnimation("lookback")
					--self.scene.audio:playSfx("robotnikgrit")
					scene.camPos.x = scene.camPos.x - vx
				elseif self.x > 9000 and self.x < 11000 then
					-- pan back
					scene.camPos.x = scene.camPos.x - vx/2
				elseif self.x > 11000 and self.x < 18000 then
					-- look at tails
					scene.camPos.x = scene.camPos.x - vx
				elseif self.x > 42500 and self.x < 44500 then
					-- pan forward again
					scene.camPos.x = scene.camPos.x - vx*1.5
				elseif self.x > 48000 and self.x < 50000 then
					-- pan back
					scene.camPos.x = scene.camPos.x - vx/2
				elseif self.x > 50000 and self.x < 60500 then
					-- look at tails
					scene.camPos.x = scene.camPos.x - vx - (2 + tails.bx) * (dt/0.016)
				else
					scene.camPos.x = scene.camPos.x - vx

					if self.x > 46000 and self.sprite.selected ~= "lookforward" then
						self.sprite:setAnimation("lookforward")
					end
					
					if self.x > 46500 and self.scene.objectLookup.Missile1.x < 1000 then
						self.scene.audio:playSfx("explosion", 0.5, true)
						self.scene.objectLookup.Missile1.x = self.x + 98*2
						self.scene.objectLookup.Missile1.y = self.y + 43*2
						self.scene.objectLookup.Missile1.speedBonus = ROBOTNIK_SPEED
						self.scene.objectLookup.Missile1.move = true
					end
					
					if self.x > 47000 and self.scene.objectLookup.Missile2.x < 1000 then
						self.scene.audio:playSfx("explosion", 0.5, true)
						self.scene.objectLookup.Missile2.x = self.x + 98*2
						self.scene.objectLookup.Missile2.y = self.y + 43*2
						self.scene.objectLookup.Missile2.speedBonus = ROBOTNIK_SPEED
						self.scene.objectLookup.Missile2.move = true
					end
					
					if self.x > 47500 and self.scene.objectLookup.Missile3.x < 1000 then
						self.scene.audio:playSfx("explosion", 0.5, true)
						self.scene.objectLookup.Missile3.x = self.x + 98*2
						self.scene.objectLookup.Missile3.y = self.y + 43*2
						self.scene.objectLookup.Missile3.speedBonus = ROBOTNIK_SPEED
						self.scene.objectLookup.Missile3.move = true
					end
				end
			end)
		end),
		Wait(2),
		PlayAudio("music", "tailsrace", 1, true),
		Wait(38),
		missileTarget(target, tails, scene.objectLookup.Missile1, explosion),
		Wait(1),
		missileTarget(target, tails, scene.objectLookup.Missile2, explosion),
		Wait(1),
		missileTarget(target, tails, scene.objectLookup.Missile3, explosion),
		
		Do(function()
			robotnik.sprite:setAnimation("scared")
		end),
		
		Wait(1),
		
		Do(function()
			robotnik.sprite:setAnimation("angry")
		end),
		MessageBox{message="Robotnik: I will not be beaten by a CHILD!!", textSpeed=3, closeAction=Wait(2)},

		Do(function()
			robotnik.sprite:setAnimation("aim")
			chargeShot.hidden = false
		end),
		Parallel {
			Ease(chargeShot.sprite.transform, "sx", 1, 0.5),
			Ease(chargeShot.sprite.transform, "sy", 1, 0.5),
		},
		MessageBox{message="Robotnik: DIE!!", textSpeed=3, closeAction=Wait(2)},
		
		
		Do(function()
			sonic.x = robotnik.x - 400
		end),
		MessageBox{message="Sonic: Yo Buttnik! {p60}Watch where you're pointing that thing!", closeAction=Wait(2)},
		Do(function()
			robotnik.sprite:setAnimation("aimlookback")
		end),
		PlayAudio("sfx", "robotnikgrit", 1, true),
		
		Wait(2),
		Do(function()
			fleet.x = robotnik.x - 400
		end),
		
		PlayAudio("music", "sonicfanfare2", 1, true),
		PlayAudio("sfx", "sonicrunturn", 1, true),
		Wait(0.2),
		Do(function()
			robotnik.sprite:setAnimation("hurt")
			robotnik.hurt = true
			chargeShot.hidden = true
		end),
		PlayAudio("sfx", "robotnikhurt", 1, true),
		Ease(robotnik, "y", function() return robotnik.y - 150 end, 3),
		Ease(robotnik, "y", function() return robotnik.y + 250 end, 8),
		Animate(robotnik.sprite, "hurt"),
		
		MessageBox{message="Fleet: Got him!", closeAction=Wait(1.5)},
		MessageBox{message="Sonic: Way past cool, Fleet!", closeAction=Wait(2)},

		PlayAudio("sfx", "battlestart", 1, true),
		Do(function()
			love.graphics.setBackgroundColor(255, 255, 255, 255)
			scene:changeScene {map="lightofmobius", fadeOutSpeed=0.2, enterDelay=2, fadeInSpeed=0.1, fadeWhite=true}
		end)
	}
end
