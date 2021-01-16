return function(scene)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Data Center",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"1F",
		100
	)
	
	if GameState:isFlagSet("demo_floor1_done") then
		return Serial {
			subtext,
			text,
			Parallel {
				Ease(text.color, 4, 255, 1),
				Ease(subtext.color, 4, 255, 1),
			},
			Wait(2),
			Parallel {
				Ease(text.color, 4, 0, 1),
				Ease(subtext.color, 4, 0, 1)
			}
		}
	end
	
	scene.player.cinematic = true
	scene.player.sprite.visible = false
	scene.player.sprite.color[4] = 0
	
	return Serial {
		Ease(scene.player, "y", scene.player.y - 600, 0.15, "inout"),
		Wait(0.5),
		
		Parallel {
			Ease(scene.player, "x", 192, 0.17, "inout"),
			Ease(scene.player, "y", 128, 0.17, "inout")
		},
		
		-- Cover shakes
		Repeat(Serial {
			Do(function()
				scene.audio:playSfx("bang")
			end),

			Ease(
				scene.objectLookup.Cover,
				"y",
				scene.objectLookup.Cover.y + 7,
				10
			),
			Ease(
				scene.objectLookup.Cover,
				"y",
				scene.objectLookup.Cover.y - 7,
				10
			),
			Ease(
				scene.objectLookup.Cover,
				"y",
				scene.objectLookup.Cover.y + 3,
				10
			),
			Ease(
				scene.objectLookup.Cover,
				"y",
				scene.objectLookup.Cover.y - 3,
				10
			),
			Ease(
				scene.objectLookup.Cover,
				"y",
				scene.objectLookup.Cover.y,
				10
			),
			
			Wait(1)
		}, 2),
		
		PlayAudio("sfx", "poptop", 1.0, true),
		
		Parallel {
			Ease(
				scene.objectLookup.Cover,
				"y",
				scene.objectLookup.Cover.y + 100,
				5
			),
			Serial {
				Wait(0.5),
				Ease(
					scene.objectLookup.Cover.sprite.color,
					4,
					0,
					5
				)
			}
		},		
		
		Do(function()
			scene.player.state = "headidle"
			scene.player.sprite.visible = true
			scene.player.sprite:setAnimation(scene.player.state)
			scene.player.y = scene.player.y - 10
		end),
		
		Ease(scene.player.sprite.color, 4, 200, 1),
		
		Do(function()
			scene.player.state = "headleft"
			scene.player.sprite:setAnimation(scene.player.state)
		end),
		
		Wait(0.5),
		
		Do(function()
			scene.player.state = "headright"
			scene.player.sprite:setAnimation(scene.player.state)
		end),
		
		Wait(0.5),

		Do(function()
			scene.player.state = "leapdown"
			scene.player.sprite:setAnimation(scene.player.state)
		end),
		
		Parallel {
			Ease(scene.player, "y", 188, 2),
			Ease(scene.player.sprite.color, 4, 255, 2),
		},
		
		PlayAudio("music", "robobuilding", 1.0, true),
		
		Do(function()
			scene.player.state = "idledown"
			scene.player.sprite:setAnimation(scene.player.state)
			scene.player.cinematic = false
			GameState:setFlag("demo_floor1_done")
		end),
		
		Spawn(Serial {
			subtext,
			text,
			Parallel {
				Ease(text.color, 4, 255, 1),
				Ease(subtext.color, 4, 255, 1),
			},
			Wait(2),
			Parallel {
				Ease(text.color, 4, 0, 1),
				Ease(subtext.color, 4, 0, 1)
			}
		})
	}
end
