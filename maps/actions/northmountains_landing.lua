return function(scene, hint)
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
	local TextNode = require "object/TextNode"
	local BasicNPC = require "object/BasicNPC"
	
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		scene.map.properties.regionName,
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.sectorName,
		100
	)
	local showTitle = function()
		Executor(scene):act(Serial {
			Wait(0.5),
			subtext,
			text,
			Parallel {
				Ease(subtext.color, 4, 255, 1),
			    Ease(text.color, 4, 255, 1)
			},
			Wait(2),
			Parallel {
				Ease(subtext.color, 4, 0, 1),
			    Ease(text.color, 4, 0, 1)
			}
		})
	end

	if hint == "fromregion" or hint == "fromload" then
		scene.player.hidekeyhints[tostring(scene.objectLookup.Save)] = true
		scene.camPos.y = 350
		return BlockPlayer {
			Do(function()
				scene.player.hidekeyhints[tostring(scene.objectLookup.Save)] = true
			end),
			PlayAudio("sfx", "wind", 0.5, true, true),
			Wait(3),
			Do(showTitle),
			Wait(1),
			PlayAudio("music", "snowcap", 1.0, true, true),
			Wait(3),
			Ease(scene.camPos, "y", 0, 1)
		}
	end

	return Action()
end
