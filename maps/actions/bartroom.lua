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

	scene.objectLookup.Bart.isInteractable = false
	scene.objectLookup.Bart.hidden = false
	scene.audio:stopMusic()
	scene.player.hidekeyhints[tostring(scene.objectLookup.Save)] = true
	return BlockPlayer {
		Wait(2),
		PlayAudio("music", "bart", 1.0, true, true),
		Do(showTitle),
		Wait(2),
		scene.objectLookup.Bart:hop(),
		Animate(scene.objectLookup.Bart.sprite, "pose"),
		MessageBox {message="Bart: Welcome to my lab!"},
		Animate(scene.objectLookup.Bart.sprite, "idledown"),
		MessageBox {message="Bart: *ahem*"},
		Do(function()
			scene.objectLookup.Bart.sprite:setAnimation("walkdown")
		end),
		Parallel {
			Ease(scene.objectLookup.Bart, "x", 300, 1, "linear"),
			Ease(scene.objectLookup.Bart, "y", 605, 1, "linear")
		},
		Do(function()
			scene.objectLookup.Bart.sprite:setAnimation("walkup")
		end),
		Parallel {
			Ease(scene.objectLookup.Bart, "x", 224, 0.5, "linear"),
			Ease(scene.objectLookup.Bart, "y", 380, 0.5, "linear")
		},
		Do(function()
			scene.objectLookup.Bart.isInteractable = true
			scene.objectLookup.Bart.sprite:setAnimation("idledown")
			scene.objectLookup.Bart.ghost = false
			scene.objectLookup.Bart:removeCollision()
			scene.objectLookup.Bart.object.x = scene.objectLookup.Bart.x
            scene.objectLookup.Bart.object.y = scene.objectLookup.Bart.y + 96
			scene.objectLookup.Bart:updateCollision()
			scene.player.hidekeyhints[tostring(scene.objectLookup.Save)] = nil
		end),
	}
end
