local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Move = require "actions/Move"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"

return function(scene)
    GameState:removeFromParty("antoine")
	
	scene.camPos.y = 1300
	
	local sonicfall = BasicNPC(
		scene,
		{name="objects"},
		{name = "sonicfall", x = 750, y = -120, width = 47, height = 55,
			properties = {
				ghost = true,
				ignoreMapCollision = true,
				sprite = "art/sprites/sonic.png"
			}
		}
	)
	scene:addObject(sonicfall)

	local sallyfall = BasicNPC(
		scene,
		{name="objects"},
		{name = "sallyfall", x = 870, y = -150, width = 47, height = 55,
			properties = {
				ghost = true,
				ignoreMapCollision = true,
				sprite = "art/sprites/sally.png"
			}
		}
	)
	scene:addObject(sallyfall)
	
	sonicfall.sprite:setAnimation("shock")
	sallyfall.sprite:setAnimation("shock")
	
	GameState.leader = "sally"
	scene.player:updateSprite()
	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	scene.player.cinematic = true
	
	local nicole = SpriteNode(
		scene,
		Transform(),
		{255,255,255,0},
		"nicholeprojection",
		nil,
		nil,
		"objects"
	)
	
	local walkout, walkin, sprites = scene.player:split()
	
	return Serial {
		Wait(3),
		
		Parallel {
			Ease(scene.camPos, "y", 0, 0.4, "inout"),
			
			Serial {
				Parallel {
					Ease(sonicfall, "y", 2100, 0.5, "linear"),
					Ease(sallyfall, "y", 2100, 0.5, "linear")
				},
				Do(function()
					scene.sonicsplash = BasicNPC(
						scene,
						{name="aboveupper"},
						{name = "sonicsplash", x = sonicfall.x, y = sonicfall.y - 100, width = 59, height = 47,
							properties = {
								ghost = true,
								sprite = "art/sprites/lakesplash.png"
							}
						}
					)
					scene:addObject(scene.sonicsplash)

					scene.sallysplash = BasicNPC(
						scene,
						{name="aboveupper"},
						{name = "sallysplash", x = sallyfall.x, y = sallyfall.y - 100, width = 59, height = 47,
							properties = {
								ghost = true,
								sprite = "art/sprites/lakesplash.png"
							}
						}
					)
					scene:addObject(scene.sallysplash)
				end),
				PlayAudio("sfx", "splash2", 1.0, true),
				Wait(0.7),
				Do(function()
					scene.sonicsplash:remove()
					scene.sallysplash:remove()
				end)
			}
		},
		
		Wait(0.5),
		
		Do(function()
			sonicfall.sprite:setAnimation("swimup")
			sallyfall.sprite:setAnimation("swimup")
		end),
		
		Do(function()
			scene.sonicripple = BasicNPC(
				scene,
				{name="objects"},
				{name = "sonicripple", x = sonicfall.x, y = sonicfall.y, width = 59, height = 47,
					properties = {
						ghost = true,
						sprite = "art/sprites/lakeripple.png"
					}
				}
			)
			scene:addObject(scene.sonicripple)

			scene.sallyripple = BasicNPC(
				scene,
				{name="objects"},
				{name = "sallyripple", x = sallyfall.x, y = sallyfall.y, width = 59, height = 47,
					properties = {
						ghost = true,
						sprite = "art/sprites/lakeripple.png"
					}
				}
			)
			scene:addObject(scene.sallyripple)
		end),
		
		Parallel {
			Ease(sonicfall, "y", 2000, 0.5, "linear"),
			Ease(sallyfall, "y", 2000, 0.5, "linear")
		},
		
		Wait(0.2),
		
		PlayAudio("music", "mysterious", 1.0, true),
		
		Ease(scene.player, "y", 1578, 0.5, "inout"),
		
		Do(function()
			sallyfall.x = scene.player.x - 50
			sallyfall.sprite:setAnimation("walkup")
		end),
		
		Ease(sallyfall, "y", scene.player.y - 532, 0.5, "linear"),
		Animate(sallyfall.sprite, "idleup"),
		
		Do(function()
			scene.player.state = "idleup"
			scene.player.sprite:setAnimation("idleup")
			scene.player.sprite.visible = true
			scene.player.dropShadow.sprite.visible = true
			sonicfall:remove()
			sallyfall:remove()
			scene.player.cinematic = true
			
			sprites.sonic.x = scene.player.x - 60
			sprites.sonic.y = scene.player.y - 60
			sprites.sally.x = scene.player.x - 60
			sprites.sally.y = scene.player.y - 60
		end),
		
		walkout,
		Animate(sprites.sonic.sprite, "idleright"),
		Animate(sprites.sally.sprite, "idleleft"),
		
		MessageBox {message="Sonic: Where are we, Sal?", blocking = true},
		
		Parallel {
			Serial {
				Animate(sprites.sally.sprite, "nichole_project_start"),
				Do(function()
					sprites.sally.sprite:setAnimation("nichole_project_idle")
					nicole.transform = Transform(
						sprites.sally.sprite.transform.x,
						sprites.sally.sprite.transform.y + 70,
						2,
						2
					)
				end),
				Ease(nicole.color, 4, 220, 5)
			},
			MessageBox {message="Sally: I'm not sure... {p20}this isn't on any of my father's maps...", blocking = true}
		},
		
		Ease(nicole.color, 4, 0, 5),
		Animate(sprites.sally.sprite, "idledown"),
		
		Do(function()
			nicole:remove()
		end),
		
		Move(scene.objectLookup.R, scene.objectLookup.Waypoint1, "walk"),
		Animate(scene.objectLookup.R.sprite, "idledown"),
		
		Parallel {
			MessageBox {message= "???: ...!", blocking = true},
			Serial {
				Wait(0.5),
				Ease(scene.objectLookup.R, "y", function() return scene.objectLookup.R.y - 50 end, 8, "linear"),
				Ease(scene.objectLookup.R, "y", function() return scene.objectLookup.R.y + 50 end, 8, "linear"),
			}
		},
		
		Animate(sprites.sonic.sprite, "idleup"),
		Animate(sprites.sally.sprite, "idleup"),
		MessageBox {message= "Sonic: Whoah, {p30}is that--", blocking = true},
		MessageBox {message= "Sally: --a roboticized child?", blocking = true},

		Do(function()
			scene.audio:stopMusic()
		end),

		MessageBox {message= "Sonic: Uh{p20}.{p20}.{p20}. Hey little buddy!", blocking = true, textSpeed = 4},
		Wait(0.2),
		PlayAudio("music", "follow", 0.7, true),

		Do(function()
			scene.player.cinematic = true
			scene.objectLookup.R.movespeed = 5
		end),
		Parallel {
			Ease(scene.camPos, "y", 300, 1, "inout"),
			Move(scene.objectLookup.R, scene.objectLookup.Exit1, "walk")
		},
		Animate(scene.objectLookup.R.sprite, "idleup"),
		Parallel {
			Ease(scene.objectLookup.WallEdge1, "y", scene.objectLookup.WallEdge1.y - 100, 2, "linear"),
			Ease(scene.objectLookup.WallEdge2, "y", scene.objectLookup.WallEdge2.y - 100, 2, "linear"),
		},
		Move(scene.objectLookup.R, scene.objectLookup.Waypoint, "walk"),
		Do(function()
			scene.objectLookup.R:remove()
			scene.player.cinematic = true
		end),
		Parallel {
			Ease(scene.objectLookup.WallEdge1, "y", scene.objectLookup.WallEdge1.y, 2, "linear"),
			Ease(scene.objectLookup.WallEdge2, "y", scene.objectLookup.WallEdge2.y, 2, "linear"),
		},
		Ease(scene.camPos, "y", 0, 1, "inout"),

		Animate(sprites.sonic.sprite, "thinking"),
		MessageBox {message= "Sonic: Was it something I said?", blocking = true, textSpeed = 4},
		Animate(sprites.sally.sprite, "idleleft"),
		MessageBox {message= "Sally: He doesn't seem to be under Robotnik's control.", blocking = true, textSpeed = 4},
		Animate(sprites.sonic.sprite, "idleright"),
		MessageBox {message= "Sally: We should follow him. {p30}Maybe he can help us find a way out of here.", blocking = true, textSpeed = 4},
		walkin,
		Do(function()
			scene.player.cinematic = false
		end)
	}
end
