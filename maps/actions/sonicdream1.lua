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
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"

return function(scene, hint)
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	
	-- TODO REMOVE
	hint="dream2"

	-- TV Static shader
	local shine = require "lib/shine"
	local tvstatic = shine.tvstatic()
	
	local staticAction = function(duringFun)
		return Serial {
			PlayAudio("sfx", "static", 0.2, true),
			Do(function()
				scene.tvstatic = tvstatic
				duringFun = duringFun or function() end
				duringFun()
			end),
			Parallel {
				Wait(1),
				Do(function()
					scene.tvstatic_time = scene.tvstatic_time + love.timer.getDelta()
					scene.tvstatic.shader:send("time", scene.tvstatic_time)
				end)
			},
			Do(function()
				-- Disable tv static shader
				scene.tvstatic = nil
			end)
		}
	end

	if hint == "dream2" then
		scene.objectLookup.Rover.sprite.color = {255,255,255,0}
		scene.objectLookup.Swatbot1.sprite.color = {255,255,255,0}
		scene.objectLookup.Swatbot2.sprite.color = {255,255,255,0}
		scene.objectLookup.Hoverbot1.sprite.color = {255,255,255,0}
		scene.objectLookup.Hoverbot2.sprite.color = {255,255,255,0}
		scene.objectLookup.Cheetah.sprite.color = {255,255,255,0}

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.objectLookup.Chuck.hidden = true
				scene.objectLookup.Sonic.hidden = true
				scene.objectLookup.Mom.hidden = true
				scene.objectLookup.Chalkboard.hidden = true
				scene.objectLookup.Chalkboard.x = scene.objectLookup.Chalkboard.x - 96
				scene.objectLookup.Mom.x = scene.objectLookup.Mom.x - 96
				scene.objectLookup.Cheetah.x = scene.objectLookup.Cheetah.x - 96
			end),
			Wait(1),
			MessageBox{message="Sonic!", closeAction=Wait(2)},
			Do(function()
				scene.objectLookup.Sonic.hidden = false
				scene.objectLookup.Mom.hidden = false
				scene.objectLookup.Chalkboard.hidden = false
				scene.tvstatic = tvstatic
				scene.tvstatic_time = 0
			end),
			Animate(scene.objectLookup.Sonic.sprite, "veryyoungdesksleep"),
			Animate(scene.objectLookup.Mom.sprite, "teacher_concerned"),
			staticAction(),
			Parallel {
				MessageBox{message="Teacher: Sonic! {p80}Are you listening?", textSpeed=3, closeAction=Wait(2)},
				Serial {
					Wait(0.5),
					PlayAudio("music", "ep6trapped", 1, true, true),
					Animate(scene.objectLookup.Sonic.sprite, "veryyoungdesksurprise"),
					scene.objectLookup.Sonic:hop()
				}
			},
			Animate(scene.objectLookup.Sonic.sprite, "veryyoungdesklookaway"),
			Wait(1),
			Animate(scene.objectLookup.Sonic.sprite, "veryyoungdesk"),
			MessageBox{message="Teacher: This is going to be on the test...", textSpeed=3, closeAction=Wait(2)},

			Wait(1),
			Do(function()
				scene.objectLookup.Cheetah.hidden = false
			end),
			Ease(scene.objectLookup.Cheetah.sprite.color, 4, 255, 1, "linear"),
			PlayAudio("sfx", "cheetabreathe", 1, true),
			scene.objectLookup.Sonic:hop(),
			Animate(scene.objectLookup.Sonic.sprite, "veryyoungdeskscared"),
			Wait(1),
			MessageBox{message="Teacher: The {h Cheetah Bot}, features the latest in\nhyper speed technology! {p60}The {h Super Sonic microchip}!", textSpeed=3, closeAction=Wait(4)},
			Animate(scene.objectLookup.Sonic.sprite, "veryyoungdesksurprise"),
			MessageBox{message="Teacher: With this {h microchip},{p60} any robot will able to\noutrun even the {h fastest hedgehog}!", textSpeed=3, closeAction=Wait(5)},
			Wait(1),
			Animate(scene.objectLookup.Mom.sprite, "teacher_evil"),
			Do(function()
				scene.objectLookup.Rover.hidden = false
				scene.objectLookup.Swatbot1.hidden = false
				scene.objectLookup.Swatbot2.hidden = false
				scene.objectLookup.Hoverbot1.hidden = false
				scene.objectLookup.Hoverbot2.hidden = false
			end),
			Parallel {
				MessageBox{message="Teacher: Soon{p60}, every bot in Robotropolis will have one!", textSpeed=3, closeAction=Wait(4)},
				
				Serial {
					Wait(2),
					Do(function()
						scene.objectLookup.Sonic.sprite:setAnimation("veryyoungdesksweating")
					end),
					Parallel {
						Ease(scene.objectLookup.Rover.sprite.color, 4, 255, 0.5, "linear"),
						Ease(scene.objectLookup.Swatbot1.sprite.color, 4, 255, 0.5, "linear"),
						Ease(scene.objectLookup.Swatbot2.sprite.color, 4, 255, 0.5, "linear"),
						Ease(scene.objectLookup.Hoverbot1.sprite.color, 4, 255, 0.5, "linear"),
						Ease(scene.objectLookup.Hoverbot2.sprite.color, 4, 255, 0.5, "linear")
					}
				}
			},
			Wait(2.5),
			PlayAudio("sfx", "battlestart", 1, true),
			Do(function()
				scene:changeScene{map="sonicshut", hint="scrapheap", fadeOutSpeed=2, fadeInSpeed=2, fadeOutMusic=true}
			end)
		}
	end
	
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			scene.tvstatic = tvstatic
			scene.tvstatic_time = 0
		end),
		staticAction(),
		Wait(1),
		
		PlayAudio("music", "ep6trapped", 1, true, true),
		MessageBox{message="Mom: Chuck... {p60}I need you to look after Sonic for a little while...", textSpeed=3, closeAction=Wait(3.5)},
		staticAction(),
		Animate(scene.objectLookup.Mom.sprite, "mom_evil"),
		Animate(scene.objectLookup.Chuck.sprite, "chuck_supportiveleft"),
		MessageBox{message="Mom: Having to take care of Sonic is really\n{h slowing} me down!", textSpeed=3, closeAction=Wait(4)},

		staticAction(),
		Animate(scene.objectLookup.Mom.sprite, "teacher_concerned"),
		Animate(scene.objectLookup.Chuck.sprite, "chuck_surprisedleft"),
		Wait(1),
		MessageBox{message="Teacher: Sonic seems to be struggling in math and science,\nSir Charles...", textSpeed=3, closeAction=Wait(3.5)},
		staticAction(),
		Animate(scene.objectLookup.Mom.sprite, "teacher_evil"),
		Animate(scene.objectLookup.Chuck.sprite, "chuck_supportiveleft"),
		MessageBox{message="Teacher: Sonic seems to be a much {h slower} learner than\nthe other children!", textSpeed=3, closeAction=Wait(4)},

		staticAction(function()
			scene.objectLookup.Mom.sprite:remove()
			scene.objectLookup.Mom.sprite = SpriteNode(
				scene,
				Transform(288+96, 288+96, 2, 2),
				{255,255,255,255},
				"switch4",
				nil,
				nil,
				"objects"
			)
			scene.objectLookup.Mom.sprite:setAnimation("on")
			scene.objectLookup.Tube.hidden = false
			scene.objectLookup.Sonic.x = scene.objectLookup.Sonic.x + 8
		end),
		Animate(scene.objectLookup.Chuck.sprite, "chuck_surprisedleft"),
		Animate(scene.objectLookup.Sonic.sprite, "veryyoungscared"),
		Wait(1),
		MessageBox{message="Uncle Chuck: Quick, Sonny! {p80}Turn off the roboticizer!!", closeAction=Wait(3)},
		staticAction(),
		Animate(scene.objectLookup.Chuck.sprite, "chuck_roboticized"),
		MessageBox{message="Uncle Chuck: ...{p40}too {h slow}, Sonic...", textSpeed=3, closeAction=Wait(2.5)},
		Wait(0.5),
		Do(function()
			scene.audio:stopMusic()
		end),
		scene:lightningFlash(),
		Wait(0.1),
		Do(function()
			scene.objectLookup.Chuck:remove()
			scene.objectLookup.Mom:remove()
			scene.objectLookup.Tube:remove()
			scene.objectLookup.Sonic:remove()
		end),
		PlayAudio("sfx", "thunder2", 0.8, true),
		Do(function()
			scene:changeScene{map="robot_wasteland1", fadeWhite=true, fadeOutSpeed=2, fadeInSpeed=2}
		end)
	}
end
