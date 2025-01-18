local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Move = require "actions/Move"
local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local AudioFade = require "actions/AudioFade"
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
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"

return function(scene)
	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	scene.player.cinematicStack = scene.player.cinematicStack + 1
	scene.player.y = 0

	local robotnik = scene.objectLookup.Robotnik
	local snively = scene.objectLookup.Snively
	
	snively.sprite.color[1] = 180
	snively.sprite.color[2] = 180
	snively.sprite.color[3] = 180
	
	scene.bgColor = {255,255,255,255}

	if GameState:isFlagSet("beatboss1") then
		robotnik.sprite:setAnimation("faceup")
		if scene.objectLookup.Rover then
			scene.objectLookup.Rover:remove()
			scene.objectLookup.Antoine:remove()
		end
		scene.player.x = 544
		scene.player.y = 800
		scene.objectLookup.Snively.sprite:setAnimation("computerup")
		scene.objectLookup.RBComputer.sprite:setAnimation("onprison")
		return Serial {
			Ease(scene.player, "y", 750, 0.6, "inout"),
			PlayAudio("music", "battle2", 1.0, true, true),
			MessageBox{message="Snively: Security alert! Prison block 7!", blocking=true, closeAction=Wait(2)},
			Animate(snively.sprite, "hesistantdown"),
			Parallel {
				MessageBox{message="Robotnik: GRRRAAAHHH!!!", blocking = true, closeAction=Wait(2)},
				scene:screenShake(30, 20)
			},
			MessageBox{message="Robotnik: Don't let them get away, you pathetic fool!!", blocking=true, closeAction=Wait(2)},
			Animate(snively.sprite, "lowdown"),
			MessageBox{message="Snively: Y-Y-Yes sir!!", blocking=true, closeAction=Wait(2)},
			
			Do(function()
				scene.player:run(AudioFade("music", 1, 0, 0.5))
				scene.sceneMgr:switchScene {
					class = "BasicScene",
					mapName = "maps/run1.lua",
					map = scene.maps["maps/run1.lua"],
					maps = scene.maps,
					region = scene.region,
					fadeOutSpeed = 1,
					fadeInSpeed = 1,
					images = scene.images,
					animations = scene.animations,
					audio = scene.audio,
					doingSpecialMove = false,
					cache = true
				}
			end),
		}
	end

	local antoine = BasicNPC(
		scene,
		{name = "objects"},
		{name = "antoine", x = scene.player.x - 50, y = 1100, width = scene.player.width, height = scene.player.height,
			properties = {
				ghost = true,
				sprite = "art/sprites/antoine.png"
			}
		}
	)
	scene:addObject(antoine)
	scene.objectLookup.Antoine = antoine
	
	local rover = BasicNPC(
		scene,
		{name = "objects"},
		{name = "rover", x = scene.player.x - 50, y = 1150, width = 75, height = 81,
			properties = {
				ghost = true,
				sprite = "art/sprites/rover.png"
			}
		}
	)
	scene:addObject(rover)
	rover.sprite:setAnimation("idleup")
	scene.objectLookup.Rover = rover
	
	return Serial {
	    Wait(1),
		Parallel {
			Ease(scene.player, "y", 972, 0.3, "inout"),
			Serial {
				Do(function()
					antoine.sprite:setAnimation("stepup")
				end),
				Parallel {
					Ease(antoine, "y", 1000, 0.2, "linear"),
					Ease(rover, "y", 1050, 0.2, "linear"),
				},
				Do(function()
					antoine.sprite:setAnimation("idleup")
				end),
			}
		},
	
		Wait(1),
		Animate(snively.sprite, "smiledown"),
		MessageBox{message="Well, well...", blocking=true, textSpeed = 2, closeAction=Wait(1)},
		Animate(robotnik.sprite, "spinaround"),
		Animate(robotnik.sprite, "facedowngrin"),
		PlayAudio("music", "robotnik", 1.0, true, true),
		
		MessageBox{message="What do we have here?", blocking=true, textSpeed = 2, closeAction=Wait(1)},
		Parallel {
            MessageBox{message="Antoine: Ro-{p20}ro-{p20}ro-{p20}robotnik!", blocking=true},
			Serial {
			    Ease(antoine, "y", function() return antoine.y - 50 end, 8, "linear"),
			    Ease(antoine, "y", function() return antoine.y + 50 end, 8, "linear")
			}
		},
		MessageBox{message="Antoine: I-I-I...", blocking=true},
		MessageBox{message="Antoine: I a-a-am a memberrr... {p40}of ze p-p-princess'... {p40}rrrroyal guard!!", blocking=true},
		
		Do(function()
			robotnik.sprite:setAnimation("facedownsmile")
		end),
		MessageBox{message="Robotnik: Is that so?", blocking=true, textSpeed = 2},
		
		Do(function()
			antoine.sprite:setAnimation("proud")
		end),
		MessageBox{message="Antoine: Yes that is so!", blocking=true},
		MessageBox{message="Robotnik: Then tell me{p20}.{p20}.{p20}. {p20}what brings the princess to my fair city?...", blocking=true, textSpeed = 2},
		
		Animate(antoine.sprite, "scaredhop1"),
		Wait(1),
		Animate(antoine.sprite, "idleup"),
		MessageBox{message="Antoine: I{p20}-I{p20}-I {p50}will n-n-never tell!", blocking=true},
		Do(function()
			robotnik.sprite:setAnimation("facedownangry")
		end),
		MessageBox{message="Robotnik: Now you listen to me, you pathetic little rodent! {p50}You will tell me everything I want to know!", blocking=true, textSpeed = 4},
		Do(function()
			robotnik.sprite:setAnimation("facedownsmile")
		end),
		MessageBox{message="Robotnik: ...or I will simply download it off your newly roboticized brain{p20}.{p20}.{p20}.", blocking=true, textSpeed = 2},
		MessageBox{message="Antoine: {p20}.{p20}.{p20}.", blocking=true, textSpeed=4},
		Animate(antoine.sprite, "scaredhop1"),
		MessageBox{message="Antoine: *Sonic{p40}, Sally... {p40}where are you?...*", blocking=true, textSpeed=3},
		
		Do(function()
			scene.player:run {
				Parallel {
					Ease(scene.player, "y", 400, 0.3, "inout"),
					Ease(scene.bgColor, 1, 0, 0.2, "inout"),
					Ease(scene.bgColor, 2, 0, 0.2, "inout"),
					Ease(scene.bgColor, 3, 0, 0.2, "inout"),
					Do(function()
						ScreenShader:sendColor("multColor", scene.bgColor)
					end),
					AudioFade("music", 1.0, 0.0, 0.5)
				},
				Do(function()
					scene.sceneMgr:switchScene {
						class = "BasicScene",
						mapName = "maps/forgottenstart.lua",
						map = scene.maps["maps/forgottenstart.lua"],
						maps = scene.maps,
						region = scene.region,
						fadeInSpeed = 0.5,
						images = scene.images,
						animations = scene.animations,
						audio = scene.audio,
						doingSpecialMove = false,
						cache = true
					}
				end)
			}
		end),
	}
end
