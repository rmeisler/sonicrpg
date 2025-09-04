return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
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
		"Great Jungle",
		100
	)
	
	if scene.player then
	    scene.player.dustColor = Player.FOREST_DUST_COLOR
	end
	
	if hint == "from_knothole" then
		return BlockPlayer {
			Wait(1),
			Do(function()
			    scene.player.noIdle = true
				scene.player.sprite:setAnimation("walkdown")
			end),
			Ease(scene.player, "y", function() return scene.player.y + 200 end, 1, "linear"),
			Do(function()
				scene.player.noIdle = false
			end),
			MessageBox{message="Tails: Great Jungle, here I come!"},
			PlayAudio("music", "greatjungle", 0.5, true, true),
			Spawn(
				Serial {
					Wait(0.5),
					text,
					Ease(text.color, 4, 255, 1),
					Wait(2),
					Ease(text.color, 4, 0, 1)
				}
			)
		}
	end
	
	return PlayAudio("music", "greatjungle", 0.5, true, true)
end
