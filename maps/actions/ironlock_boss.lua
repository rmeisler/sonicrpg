return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local TextNode = require "object/TextNode"
	local BasicNPC = require "object/BasicNPC"
	
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	
	scene.player.sprite.color[1] = 150
	scene.player.sprite.color[2] = 150
	scene.player.sprite.color[3] = 150

	if GameState:isFlagSet("ep3_boss") then
		scene.audio:stopMusic()
		scene.objectLookup.Boss:remove()
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		scene.objectLookup.Sonic.sprite:setAnimation("idleright")
		scene.objectLookup.Sally.sprite:setAnimation("idleup")
		scene.objectLookup.Antoine.sprite:setAnimation("idleleft")
		return BlockPlayer {
			Do(function()
				scene.audio:stopMusic()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.objectLookup.King.sprite.color[1] = 0
				scene.objectLookup.King.sprite.color[2] = 0
				scene.objectLookup.King.sprite.color[3] = 0
				scene.objectLookup.King.sprite.color[4] = 0
				
				scene.objectLookup.Sonic.y = 352 - 98
				scene.objectLookup.Sally.y = 416 - 98
				scene.objectLookup.Antoine.y = 352 - 98
			end),
			Spawn(Serial {
				PlayAudio("sfx", "quake", 1.0, true),
				scene:screenShake(10, 30, 20)
			}),
			Parallel {
				MessageBox{message="Sally: That was a close one!"},
				Ease(scene.objectLookup.King.sprite.color, 4, 255, 0.3)
			},
			Animate(scene.objectLookup.Sonic.sprite, "idleright"),
			Animate(scene.objectLookup.Sally.sprite, "idleright"),
			Animate(scene.objectLookup.Antoine.sprite, "idleright"),
			MessageBox{message="Sally: !"},
			MessageBox{message="???: Computer, {p60}open file {p60}**zzzzz** {p60} passcode 'Bean' **zzzzz**"},
			MessageBox{message="Sally: ...{p20}D-{p60}Daddy?"},
			Parallel {
				Ease(scene.objectLookup.King.sprite.color, 1, 255, 0.3),
				Ease(scene.objectLookup.King.sprite.color, 2, 255, 0.3),
				Ease(scene.objectLookup.King.sprite.color, 3, 255, 0.3)
			},
			PlayAudio("music", "sallysad", 1.0, true),
			Spawn(Serial {
				PlayAudio("sfx", "quake", 1.0, true),
				scene:screenShake(10, 30, 20)
			}),
			MessageBox{message="King: Sally... {p60}I pray this message finds its way to you as so many before it have not...", closeAction=Wait(2)},
			Animate(scene.objectLookup.Sally.sprite, "idleright"),
			MessageBox{message="Sally: Daddy, it's me! {p60}I'm here!", closeAction=Wait(2)},
			Animate(scene.objectLookup.Sonic.sprite, "idleright"), --worried right
			MessageBox{message="Sonic: I don't think he can hear you Sal-- {p60}we gotta juice before--", closeAction=Wait(1.5)},
			Spawn(Serial {
				PlayAudio("sfx", "quake", 1.0, true),
				scene:screenShake(10, 30, 20)
			}),
			MessageBox{message="Antoine: Ah Sonic{p20}, let her listen Sonic. {p60}We will make it out in time.", closeAction=Wait(1.5)},
			Animate(scene.objectLookup.Sonic.sprite, "shock"),
			MessageBox{message="Sonic: Wow, what's gotten into you?", closeAction=Wait(1.5)},
			Animate(scene.objectLookup.Sonic.sprite, "idleright"), -- calm smile
			MessageBox{message="King: I've been living in-- {p20} **zzzzz** {p60}and while it has not been easy, I can assure you I am safe-- {p20}**zzzz**", closeAction=Wait(3)},
			MessageBox{message="King: From reading your letters I can tell that-- {p20}**zzzz** no longer a child, but a brilliant young woman.", closeAction=Wait(3)},
			MessageBox{message="King: Stay strong and keep fighting my dear daughter--{p20} **zzzz** {p60}I have faith that we will some day be reunited...", closeAction=Wait(3)},
			
			Animate(scene.objectLookup.Sally.sprite, "sadleft"),
			MessageBox{message="Sally: ...*sniff*... {p60}I love you daddy...", closeAction=Wait(2)},
			
			Wait(1),
			MessageBox{message="Sonic: Come on, Sal--", closeAction=Wait(1)},
			Spawn(Serial {
				PlayAudio("sfx", "quake", 1.0, true),
				scene:screenShake(10, 30, 20)
			}),
			MessageBox{message="King: S-{p20}Sally?", closeAction=Wait(1.5)},
			
			Animate(scene.objectLookup.Sally.sprite, "shock"),
			Animate(scene.objectLookup.King.sprite, "king_lookback"),
			Parallel {
				Serial {
					Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y - 50 end, 8, "linear"),
					Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y + 50 end, 8, "linear")
				},
				MessageBox{message="King: Is that you, Sally?", closeAction=Wait(1.5)}
			},
			Animate(scene.objectLookup.Sally.sprite, "idleright"),
			MessageBox{message="Sally: Y-Yes! {p60}It's me, daddy!", closeAction=Wait(1.5)},
			
			Ease(scene.objectLookup.King.sprite.color, 4, 0, 0.3),
			Animate(scene.objectLookup.Sally.sprite, "idleright"), -- angershockright
			Spawn(Parallel {
				Repeat(PlayAudio("sfx", "quake", 1.0)),
				scene:screenShake(10, 30, 300)
			}),
			MessageBox{message="Sally: No!", closeAction=Wait(2)},
			Parallel {
				Ease(scene.objectLookup.Sonic, "x", scene.objectLookup.Sally.x, 2, "linear"),
				Ease(scene.objectLookup.Sally, "y", 352 - 98, 2, "linear"),
				Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Sally.x, 2, "linear")
			},
			Do(function()
				scene.objectLookup.Sonic:remove()
				scene.objectLookup.Sally:remove()
				scene.objectLookup.Antoine:remove()
				
				GameState.leader = "sonic"
				scene.player:updateSprite()
				scene.player.chargeSpeed = 3
				scene.player.sprite.visible = true
				scene.player.dropShadow.hidden = false
				scene.player.cinematic = true
				scene.player.state = "idleright"
				scene.player.ignoreSpecialMoveCollision = true
				scene.player:onSpecialMove()
			end),
			Wait(2),
			Do(function()
				scene.sceneMgr:pushScene {class = "CreditsSplashScene", fadeOutSpeed=0.1,fadeInSpeed=0.3, enterDelay=2}
			end)
		}
	end
	
	GameState:addBackToParty("sally")
	GameState:addBackToParty("sonic")
	GameState.leader = "sonic"

	GameState:setFlag("ep3_boss")
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(2),
		Parallel {
			Ease(scene.objectLookup.Sonic, "y", 352 - 98, 3, "linear"),
			Ease(scene.objectLookup.Sally, "y", 416 - 98, 3, "linear"),
			Ease(scene.objectLookup.Antoine, "y", 352 - 98, 3, "linear")
		},
		PlayAudio("sfx", "bang", 1.0, true),
		Animate(scene.objectLookup.Sonic.sprite, "dead"),
		Animate(scene.objectLookup.Sally.sprite, "dead"),
		Animate(scene.objectLookup.Antoine.sprite, "dead"),
		Wait(2.5),
		Animate(scene.objectLookup.Sonic.sprite, "idleright"),
		Animate(scene.objectLookup.Sally.sprite, "idleup"),
		Animate(scene.objectLookup.Antoine.sprite, "idleleft"),
		Wait(0.5),
		
		MessageBox{message="Sonic: Ugh... {p60}are we done with the falling now?"},
		PlayAudio("sfx", "cyclopsroar", 1.0, true),
		scene:screenShake(20, 30, 15),
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		Animate(scene.objectLookup.Antoine.sprite, "shock"),
		
		Wait(1),
		Animate(scene.objectLookup.Sonic.sprite, "idleleft"),
		Animate(scene.objectLookup.Sally.sprite, "idleleft"),
		Animate(scene.objectLookup.Antoine.sprite, "idleleft"),
		PlayAudio("music", "troublefanfare", 1.0, true),
		Ease(scene.objectLookup.Boss.sprite.color, 4, 255, 0.3),
		
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		Animate(scene.objectLookup.Antoine.sprite, "shock"),
		
		Do(function() scene.objectLookup.Boss.sprite:setAnimation("roar") end),
		PlayAudio("sfx", "cyclopsroar", 1.0, true),
		Parallel {
			scene:screenShake(20, 30, 15),
			Serial {
				Wait(1),
				MessageBox{message="Sonic: Not this guy again!", closeAction=Wait(0.5)}
			}
		},
		
		scene:enterBattle {
			opponents = {"cyclops"},
			music = "boss",
			bossBattle = true
		}
	}
end
