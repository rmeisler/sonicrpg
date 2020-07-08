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
		{name="aboveobjects"},
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
		{name="aboveobjects"},
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
			scene.player.cinematic = false
		end)
	}
end
