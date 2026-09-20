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
		MessageBox{message="Roxanne: Chuck... {p60}I need you to look after Sonic for a little while...", textSpeed=3, closeAction=Wait(3.5)},
		Animate(scene.objectLookup.Chuck.sprite, "chuck_supportiveleft"),
		Wait(2),
		Animate(scene.objectLookup.Mom.sprite, "mom_evil"),
		MessageBox{message="Roxanne: ...{p60}he's really {h slowing} me down!", textSpeed=3, closeAction=Wait(3.5)},

		staticAction(),
		Animate(scene.objectLookup.Mom.sprite, "teacher_concerned"),
		Animate(scene.objectLookup.Chuck.sprite, "chuck_surprisedleft"),
		Wait(1),
		MessageBox{message="Teacher: Sonic seems to be struggling in math and science, Sir Charles...", textSpeed=3, closeAction=Wait(3.5)},
		Animate(scene.objectLookup.Chuck.sprite, "chuck_supportiveleft"),
		Wait(2),
		Animate(scene.objectLookup.Mom.sprite, "teacher_evil"),
		MessageBox{message="Teacher: ...{p60}perhaps it's because his brain is so much {h slower} than the other children's!", textSpeed=3, closeAction=Wait(4)},

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
		end),
		Animate(scene.objectLookup.Chuck.sprite, "chuck_surprisedleft"),
		Wait(1),
		MessageBox{message="Uncle Chuck: Quick, Sonny! {p80}Turn off the roboticizer!!", closeAction=Wait(3)},
		staticAction(),
		Animate(scene.objectLookup.Chuck.sprite, "chuck_roboticized"),
		MessageBox{message="Uncle Chuck: ...{p80}too {h slow}, Sonic...", textSpeed=3, closeAction=Wait(3)},
		scene:lightningFlash(),
		Wait(0.1),
		scene:lightningFlash(),
		PlayAudio("sfx", "thunder2", 0.8, true),
	}
end
