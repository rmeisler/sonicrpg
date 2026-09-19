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

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		PlayAudio("sfx", "static", 0.2, true),
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
		end),
		PlayAudio("music", "sonicdream", 1, true, true),
		Wait(1),
		MessageBox{message="Roxeanne: Chuck... {p100}I need you to take care of Sonic..."},
		MessageBox{message="Roxeanne: I gotta go away for a little while, and he's just... {p80}{h slowing} me down."},

		PlayAudio("sfx", "static", 0.2, true),
		Do(function() scene.tvstatic = tvstatic end),
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
		end),
		Animate(scene.objectLookup.Mom.sprite, "teacher_concerned"),
		Wait(1),
		MessageBox{message="Teacher: Sir Charles{p100}, your nephew is struggling in math and science..."},
		MessageBox{message="Teacher: I'm not sure the reason{p80}, he may be just be a little {h slower} than the other children..."},

		AudioFade("music", 1, 0, 1),
		PlayAudio("sfx", "static", 0.2, true),
		Do(function() scene.tvstatic = tvstatic end),
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
		end),
		PlayAudio("music", "sonicscared", 1, true, true),
		Wait(1),
		Do(function()
			scene.objectLookup.Mom.sprite:remove()
			scene.objectLookup.Mom.sprite = SpriteNode(
				scene,
				Transform(288+64, 288+32, 2, 2),
				{255,255,255,255},
				"switch4",
				nil,
				nil,
				"objects"
			)
			scene.objectLookup.Mom.sprite:setAnimation("on")
		end),
		MessageBox{message="Uncle Chuck: Quick, Sonny! {p80}Turn off the roboticizer!!"},
		MessageBox{message="Uncle Chuck: Ahh!!!"},
		MessageBox{message="Uncle Chuck: ...{p80}too {h slow}, Sonic..."}
	}
end
