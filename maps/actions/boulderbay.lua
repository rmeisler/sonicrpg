return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local Repeat = require "actions/Repeat"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local BlockPlayer = require "actions/BlockPlayer"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Boulder Bay",
		100
	)
	
	hint = "from_cinematic"
	if hint == "from_cinematic" then
		-- Reset hint
		scene.hint = nil

		GameState:addToParty("babyt", 3, true)
		GameState.leader = "tails"
		GameState:removeFromParty("babyt")
		
		local waterLayer1 = scene:findLayer("wateroverlay1")
		local waterLayer2 = scene:findLayer("wateroverlay2")

		return BlockPlayer {
			Spawn(
				Repeat(Serial {
					Do(function()
						waterLayer1.opacity = 0.5
						waterLayer2.opacity = 0
					end),
					Wait(2),
					Do(function()
						waterLayer1.opacity = 0
						waterLayer2.opacity = 0.5
					end),
					Wait(2)
				}, 10000)
			),
			Do(function()
				scene.player.state = "dead"
			end),
			Wait(2),

			Wait(0.5),
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1),

			MessageBox{message="Tails: ..."},
			MessageBox{message="Tails: Ugh."},
			Do(function()
				scene.player.state = "idleleft"
			end),
			MessageBox{message="Tails: Baby T?"},
			Do(function()
				scene.player.state = "idleright"
			end),
			MessageBox{message="Tails: B?"},
			Do(function()
				scene.player.state = "idledown"
			end),
			MessageBox{message="Tails: Where is everybody?..."},
		}
	end
end
