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

return function(scene)
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	-- TV Static shader
	local shine = require "lib/shine"
	local tvstatic = shine.tvstatic()
	scene.tvstatic = tvstatic
	scene.tvstatic_time = 0
	
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

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
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
