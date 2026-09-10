return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local Move = require "actions/Move"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Do = require "actions/Do"
	local AudioFade = require "actions/AudioFade"
	local Spawn = require "actions/Spawn"
	local BlockPlayer = require "actions/BlockPlayer"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local TextNode = require "object/TextNode"
	local EscapePlayer = require "object/EscapePlayer"

	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	scene.pressXText = TextNode(
		scene,
		Transform(10, 550),
		{255,255,255,0},
		"Boost",
		FontCache.TechnoMed,
		"ui",
		false
	)
	scene.pressX1 = SpriteNode(
		scene,
		Transform(190, 570, 2, 2),
		{255,255,255,0},
		"pressx",
		12,
		12,
		"ui"
	)
	scene.pressX1:setAnimation("nopress")
	scene.pressX2 = SpriteNode(
		scene,
		Transform(220, 570, 2, 2),
		{255,255,255,0},
		"pressx",
		12,
		12,
		"ui"
	)
	scene.pressX2:setAnimation("nopress")
	scene.pressX3 = SpriteNode(
		scene,
		Transform(250, 570, 2, 2),
		{255,255,255,0},
		"pressx",
		12,
		12,
		"ui"
	)
	scene.pressX3:setAnimation("nopress")
	scene.pressX4 = SpriteNode(
		scene,
		Transform(280, 570, 2, 2),
		{255,255,255,0},
		"pressx",
		12,
		12,
		"ui"
	)
	scene.pressX4:setAnimation("nopress")

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		PlayAudio("music", "racewithfleet", 1, true),
		Wait(1),
		Parallel {
			Ease(scene.camPos, "x", 2150, 0.07),
			Serial {
				Wait(1),
				MessageBox{message="Tails: Welcome{p40}, one and all...", textSpeed=3, closeAction=Wait(2)},
				MessageBox{message="Tails: ...to the ultimate race{p60}, which will finally answer the question...", textSpeed=3, closeAction=Wait(2.5)},
				MessageBox{message="Tails: ...who is the fastest thing alive?!", textSpeed=3, closeAction=Wait(2.5)}
			}
		},
		Parallel {
			Serial {
				Animate(scene.objectLookup.Tails.sprite, "idleright"),
				Wait(1.2),
				PlayAudio("sfx", "sonicrun", 1.0, true, false, true),
				Animate(scene.objectLookup.Fleet.sprite, "prepare_race2"),
				Parallel {
					Animate(scene.objectLookup.Sonic.sprite, "chargerun1"),
					Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y - 20 end, 4)
				},
				Do(function() scene.objectLookup.Sonic.sprite:setAnimation("chargerun2") end),
				Wait(1.2),
				Animate(scene.objectLookup.Tails.sprite, "joyright"),
				scene.objectLookup.Tails:hop()
			},
			MessageBox{message="Tails: On your mark...{p60} get set...{p60} GO!!", closeAction=Wait(0.5)}
		},
		Do(function()
			scene.player:addSceneHandler("update", EscapePlayer.update)
			scene.player.x = scene.objectLookup.Sonic.x + scene.player.width
			scene.player.y = scene.objectLookup.Sonic.y + scene.player.height + 20
			scene.player.sprite.visible = true
			scene.player.dropShadow.hidden = false
			scene.player.dustColor = {255,255,255,255}
			scene.player.extraSpeed = 10
			scene.player.extraBx = 0
			scene.objectLookup.Sonic.hidden = true
			scene.camPos.x = 0
			
			scene.objectLookup.Fleet.sprite:setAnimation("flyright")
			scene.objectLookup.Fleet.sprite.transform.angle = math.pi*1/6
			scene.objectLookup.Fleet.frameCount = 0
			scene.objectLookup.Fleet.extraBx = 0
			scene.objectLookup.Fleet:addSceneHandler("update", function(self, dt)
				if self.frameCount <= 0 then
					self.bx = math.random(0,1)
					self.frameCount = 3
				end
				self.frameCount = self.frameCount - dt
				self.x = self.x + (self.bx + self.extraBx + (scene.player.fx > 1 and scene.player.fx + 1 or 0) + scene.player.bx + scene.player.extraSpeed) * (dt/0.016)
			end)
			
			scene.player:addHandler("boost", function(numBoosts)
				scene.audio:playSfx("choose")
				if numBoosts == 3 then
					scene.player:run {
						Ease(scene.pressX4.color, 4, 0, 2),
						Do(function() scene.pressX4:remove() end)
					}
				elseif numBoosts == 2 then
					scene.player:run {
						Ease(scene.pressX3.color, 4, 0, 2),
						Do(function() scene.pressX3:remove() end)
					}
				elseif numBoosts == 1 then
					scene.player:run {
						Ease(scene.pressX2.color, 4, 0, 2),
						Do(function() scene.pressX2:remove() end)
					}
				elseif numBoosts == 0 then
					scene.player:run {
						Ease(scene.pressX1.color, 4, 0, 2),
						Do(function() scene.pressX1:remove() end)
					}
				end
			end)
		end),
		
		Parallel {
			Ease(scene.pressXText.color, 4, 255, 2),
			Ease(scene.pressX1.color, 4, 255, 2),
			Ease(scene.pressX2.color, 4, 255, 2),
			Ease(scene.pressX3.color, 4, 255, 2),
			Ease(scene.pressX4.color, 4, 255, 2)
		},

		Wait(24),
		
		Do(function()
			scene.player.cinematic = true
			scene.player.sprite:setAnimation("juicesurpriseright")
		end),
		
		Wait(2),
		
		Do(function()
			scene.player.sprite:setAnimation("skidright")
			scene.objectLookup.Sally.x = scene.player.x + 2700
			scene.objectLookup.Sally.y = scene.player.y - 80
		end),

		Parallel {
			Do(function()
				if scene.player.blocked then
					return
				end
				if (scene.player.fx + scene.player.bx + scene.player.extraSpeed) < 0.5 then
					scene.player.extraSpeed = -(scene.player.fx + scene.player.bx)
					scene.player.blocked = true
				else
					scene.player.extraSpeed = scene.player.extraSpeed - 0.25
					scene.objectLookup.Fleet.extraBx = scene.objectLookup.Fleet.extraBx + 0.25
				end
			end),

			Wait(3)
		},
		
		Do(function()
			scene.player.sprite:setAnimation("earnestright")
		end),
		Wait(1),

		Do(function()
			scene:changeScene{map="knothole_ep6", fadeInSpeed=0.2, fadeOutSpeed=0.2, enterDelay=1, fadeOutMusic=false}
		end)
	}
end
