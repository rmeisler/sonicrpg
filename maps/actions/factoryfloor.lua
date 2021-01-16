return function(scene)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local Move = require "actions/Move"
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Swatbot Factory",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Assembly",
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

	scene.audio:playSfx("factoryfloor", 0.1)
	scene.audio:setLooping("sfx", true)
	
	local musicAction
	if scene.reentering then
		musicAction = PlayAudio("music", "factory", 1.0, true, true)
	else
		musicAction = Serial {
			AudioFade("music", 1.0, 0.0, 1),
			Do(function()
				scene.audio:stopMusic()
			end),
			PlayAudio("music", "factory", 1.0, true, true)
		}
	end
	
	local door = scene.objectLookup.Door2
	if GameState:isFlagSet(door) then
		door.sprite:setAnimation("open")
        door:removeCollision()
	end
	
	return Serial {
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
		}),
		
		musicAction
	}
end
