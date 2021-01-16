return function(scene)
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
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local While = require "actions/While"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local Move = require "actions/Move"
	
	if GameState:isFlagSet("beatboss1") then
		scene.audio:stopMusic()
		
		scene.player.sprite.visible = true
		scene.player.dropShadow.sprite.visible = true
		
		GameState.leader = "sonic"
		scene.player:updateSprite()
		scene.player.sprite:setAnimation("idledown")
		
		local walkout, walkin, sprites = scene.player:split()
		
		scene.objectLookup.Antoine:remove()
		scene.objectLookup.Sonic:remove()
		scene.objectLookup.Sally:remove()
		
		scene.objectLookup.Rover:remove()
		scene.objectLookup.SwatbotSidekick1:remove()
		scene.objectLookup.SwatbotSidekick2:remove()
		scene.player.cinematicStack = 1
		
		return Serial {
			walkout,
			Animate(sprites.sally.sprite, "pose"),
			Animate(sprites.sonic.sprite, "pose"),
			Animate(sprites.antoine.sprite, "pose"),
			MessageBox{message="Sally: We did it! {p50}Now let's get out of here!", blocking = true},
			walkin,
			
			PlayAudio("music", "escapefanfare", 1.0, true),
			
			Do(function()
				scene.player.x = scene.player.x + 50
				scene.player.y = scene.player.y + 50
				scene.player.state = "idleright"
			end),
			
			Do(function()
				scene.player.cinematic = true
				scene.player.chargeSpeed = 3
				scene.player.state = "idleright"
				scene.player.ignoreSpecialMoveCollision = true
				scene.player:onSpecialMove()
			end),
			MessageBox {message="Sonic: Juice and jam time!", closeAction=Wait(2)},
			
			Wait(1),
			Do(function()
				scene.sceneMgr:switchScene {
					class = "BasicScene",
					mapName = "maps/robotnikwarroom.lua",
					map = scene.maps["maps/robotnikwarroom.lua"],
					maps = scene.maps,
					region = scene.region,
					fadeOutSpeed = 0.2,
					fadeInSpeed = 0.7,
					images = scene.images,
					animations = scene.animations,
					audio = scene.audio,
					doingSpecialMove = false,
					cache = true
				}
			end)
		}
	end
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Robotropolis",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Prison Block 7",
		100
	)
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	scene.objectLookup.Sonic.sprite.visible = false
	scene.objectLookup.Sally.sprite.visible = false
	
	scene.objectLookup.SwatbotSidekick1.sprite.visible = false
	scene.objectLookup.SwatbotSidekick2.sprite.visible = false
	scene.objectLookup.Rover.sprite.visible = false
	
	scene.bgColor = {255,255,255,255}
	ScreenShader:sendColor("multColor", scene.bgColor)
	
	scene.player.cinematicStack = scene.player.cinematicStack + 1
	
	local antoine = scene.objectLookup.Antoine
	
	GameState:addToParty("antoine", 2)
	
	return Serial {
		AudioFade("music", 1.0, 0.0, 1),
		Wait(2),
		PlayAudio("music", "prisonintro", 1.0, true),
	
		Spawn(Serial {
			subtext,
			text,
			Parallel {
				Ease(text.color, 4, 255, 1),
				Ease(subtext.color, 4, 255, 1),
			},
			Wait(2),
			Parallel {
				Ease(text.color, 4, 0, 1),
				Ease(subtext.color, 4, 0, 1)
			}
		}),
		
		Ease(scene.camPos, "y", 850, 0.16, "inout"),
		
		Wait(0.5),

		Ease(scene.camPos, "y", 1300, 0.17, "inout"),
		
		MessageBox{message="Antoine: {p30}.{p30}.{p30}.", blocking = true},
		
		MessageBox{message="Antoine: So this is how my life is to end...", blocking = true},
		
		Wait(1),
		
		Do(function()
			scene.camPos.y = 0
			scene.player.y = scene.player.y - 1300
		end),
		
		Parallel {
			Do(function()
				Executor(scene):act(
					scene:screenShake(30, 20)
				)
			end),
			PlayAudio("sfx", "smack", 1.0)
		},
		
		Wait(0.5),
		
		Parallel {
			Do(function()
				Executor(scene):act(
					scene:screenShake(30, 20)
				)
			end),
			PlayAudio("sfx", "smack", 1.0)
		},
		
		PlayAudio("sfx", "smack2", 1.0, true),
		
		Wait(1),
		
		Parallel {
			Do(function()
				Executor(scene):act(
					scene:screenShake(30, 20)
				)
			end),
			PlayAudio("sfx", "smack", 1.0),
			
			Serial {
				Ease(antoine, "y", antoine.y - 50, 7, "linear"),
				Animate(antoine.sprite, "scaredhop3"),
				Ease(antoine, "y", antoine.y, 7, "linear"),
				Animate(antoine.sprite, "idledown")
			}
		},
		
		MessageBox{message="Antoine: W-{p30}W-{p30}W-{p30}hat is happening?", blocking = true},
		
		Wait(0.5),
		
		Do(function()
			scene.objectLookup.Swatbot1:remove()
			scene.objectLookup.Swatbot2:remove()
			scene.objectLookup.Sonic.sprite.visible = true
			scene.objectLookup.Sally.sprite.visible = true
		end),
		
		Parallel {
			Serial {
				Move(antoine, scene.objectLookup.Waypoint1),
				Animate(antoine.sprite, "idledown")
			},
			Ease(scene.player, "y", 1036, 0.25, "inout")
		},
		
		PlayAudio("music", "doittoit2", 1.0, true, true),
		MessageBox{message="Sonic: How's it hangin' Ant? {p50}Ya miss us?", blocking = true},
		MessageBox{message="Sally: Thank goodness we weren't too late!", blocking = true},
		
		MessageBox{message="Antoine: Oh my! {p50}It is so very good to see the both of you!", blocking = true},
		
		Move(scene.objectLookup.Sonic, scene.objectLookup.Waypoint2),
		
		Animate(scene.objectLookup.Sonic.sprite, "idleup"),
		
		Do(function()
			scene.objectLookup.Switch1:flip()
		end),
		
		Wait(1),
		
		AudioFade("music", 1.0, 0.0, 1),
		
		Do(function()
			scene.player:run(
				Repeat(
					While(
						function() return not scene.rovercinematicover end,
						Parallel {
							Serial {
								Ease(scene.bgColor, 1, 510, 5, "quad"),
								Ease(scene.bgColor, 1, 255, 5, "quad"),
							},
							Do(function() 
								ScreenShader:sendColor("multColor", scene.bgColor)
							end)
						},
						Do(function() end)
					),
					1000
				)
			)
		end),
        Spawn(Repeat(While(function() return not scene.rovercinematicover end, PlayAudio("sfx", "alert", 0.3), Do(function() end)), 100)),
		
		Wait(1),
		
		Animate(antoine.sprite, "scaredhop5"),
		Animate(scene.objectLookup.Sonic.sprite, "idledown"),
		
		PlayAudio("music", "robotrouble", 1.0, true),
		
		Wait(1),
		Animate(scene.objectLookup.Sally.sprite, "thinking"),
		MessageBox{message="Sally: Not again!", blocking = true, closeAction=Wait(1)},
		
		Do(function()
			scene.objectLookup.SwatbotSidekick1.sprite.visible = true
			scene.objectLookup.SwatbotSidekick2.sprite.visible = true
			scene.objectLookup.Rover.sprite.visible = true
			scene.objectLookup.Rover.movespeed = 5
			scene.objectLookup.SwatbotSidekick1.movespeed = 4
			scene.objectLookup.SwatbotSidekick2.movespeed = 4
		end),
		
		Ease(scene.player, "y", 1500, 2, "inout"),

		Animate(scene.objectLookup.Sally.sprite, "idledown"),
		
		Parallel {
			Serial {
				Move(scene.objectLookup.Rover, scene.objectLookup.Waypoint3, "walk"),
				Do(function()
					scene.player.cinematicStack = 0
					GameState:setFlag("beatboss1")
				end),
				
				scene:enterBattle {
					opponents = {
						"rover",
						"swatbot",
						"swatbot"
					},
					music = "boss",
					bossBattle = true
				}
			},
			Move(scene.objectLookup.SwatbotSidekick1, scene.objectLookup.Waypoint3, "run"),
			Move(scene.objectLookup.SwatbotSidekick2, scene.objectLookup.Waypoint3, "run"),
			Ease(scene.player, "y", 1056, 1, "inout")
		}
	}
end
