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
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local BlockPlayer = require "actions/BlockPlayer"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local Animate = require "actions/Animate"
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
	
	if hint == "after_battle" then
		scene.objectLookup.Swatbot1:permanentRemove()
		scene.objectLookup.Swatbot2:permanentRemove()
		scene.player.x = scene.objectLookup.B.x - 64
		scene.player.y = scene.objectLookup.B.y + 55

		local walkout, walkin, sprites = scene.player:split()
		for k in pairs(GameState.party) do
			sprites[k].x = scene.player.x - 60
			sprites[k].y = scene.player.y - 60
		end
		
		scene.camPos.x = 0
		scene.audio:stopMusic()

		return BlockPlayer {
			walkout,
			Animate(sprites.tails.sprite, "idleright"),
			sprites.tails:hop(),
			PlayAudio("music", "concerning", 1, true),
			MessageBox{message="Tails: B! {p60}Can ya hear us, B?!"},
			Wait(2),

			Animate(sprites.tails.sprite, "sadright"),
			Animate(sprites.babyt.sprite, "sadright"),
			MessageBox{message="Tails: Oh no, Baby T! *sniff* {p60}B has fallen under Robotnik's control again!"},
			Wait(1),
			
			Do(function()
			    scene.objectLookup.B.sprite:setAnimation("blink_back")
			end),
			AudioFade("music", 1, 0, 1),
			Wait(1),
			PlayAudio("music", "bhero", 1, true, true),
			Animate(scene.objectLookup.B.sprite, "idleleft"),
			MessageBox{message="B: No need to fret, child! {p60}I'm just fine!"},
			MessageBox{message="B: I was merely making myself appear to be under Robotnik's control to avoid being captured."},

			Animate(sprites.tails.sprite, "idleright"),
			Animate(sprites.babyt.sprite, "idleright"),
			Parallel {
				sprites.tails:hop(),
				sprites.babyt:hop(),
				MessageBox{message="Tails: Oh phew!"}
			},
			MessageBox{message="B: After rescuing you{p60}, I brought you both here to the beach. {p60}I was hoping that the wide open view might help me navigate back to Knothole..."},
			Animate(scene.objectLookup.B.sprite, "pose"),
			MessageBox{message="B: But alas... {p60}my memory is too limited to find the way..."},
			
			Parallel {
				sprites.tails:hop(),
				AudioFade("music", 1, 0, 1),
				MessageBox{message="Tails: It's ok, B! {p60}If we--", closeAction=Wait(1)}
			},
			
			-- Pan to see Swatbots surrounding caged Terrapods
		}
	end
	
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
			Wait(0.5),
			Do(function()
				scene.player.state = "idleleft"
			end),
			MessageBox{message="Tails: Baby T?"},
			Wait(0.5),
			Do(function()
				scene.player.state = "idleright"
			end),
			MessageBox{message="Tails: B?"},
			Wait(0.5),
			Do(function()
				scene.player.state = "idledown"
			end),
			MessageBox{message="Tails: Where is everybody?..."},
		}
	end
end
