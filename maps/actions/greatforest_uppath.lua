return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local Animate = require "actions/Animate"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local BlockPlayer = require "actions/BlockPlayer"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Great Forest",
		100
	)
	
	if hint == "fromworldmap" then
		Executor(scene):act(Serial {
			Wait(0.5),
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		})
	end
	
	scene.audio:playMusic("greatforest", 1.0)
	
	scene.player.dustColor = Player.FOREST_DUST_COLOR
	return BlockPlayer {
		Parallel {
			Serial {
				Do(function()
					scene.player.noIdle = true
					scene.player.sprite:setAnimation("walkup")
				end),
				Ease(scene.player, "y", function() return scene.player.y - 200 end, 1, "linear"),
				Do(function()
					scene.player.noIdle = false
					scene.player.sprite:setAnimation("idleup")
				end),
				Wait(1),
				Do(function()
					local walkout, walkin, sprites = scene.player:split()
					scene.player:run(BlockPlayer {
						PlayAudio("music", "rotor2", 1.0, true, true),
						Ease(scene.camPos, "y", 450, 1),
						MessageBox {message="Rotor: There it is!"},
						Ease(scene.camPos, "y", 0, 1),
						Do(function()
							sprites.rotor.x = sprites.rotor.x - 60
							sprites.logan.x = sprites.logan.x - 60
							sprites.rotor.y = sprites.rotor.y - 60
							sprites.logan.y = sprites.logan.y - 60
						end),
						walkout,
						Animate(sprites.logan.sprite, "irritated"),
						MessageBox {message="Logan: Wow! {p60}What a junker!"},
						Animate(sprites.rotor.sprite, "shock"),
						sprites.rotor:hop(),
						Wait(1),
						Animate(sprites.rotor.sprite, "idleright"),
						MessageBox {message="Rotor: Hey! {p60}I put in a lot of hours into this!"},
						Animate(sprites.rotor.sprite, "explaining_right1"),
						MessageBox {message="Rotor: Besides{p60}, it's flight tested! {p60}This oughtta get us to the Northern Mountains, no problem!"},
						MessageBox {message="Logan: If you say so..."},
						walkin,
						Do(function()
							scene.player.x = scene.player.x + 20
						end)
					})
				end)
			},
			AudioFade("music", 1.0, 0.0, 0.5)
		}
	}
end
