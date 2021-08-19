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
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local BlockPlayer = require "actions/BlockPlayer"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	if hint ~= "frombelow" then
		return Action()
	end
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"DEATH EGG",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"2F",
		100
	)
	
	-- Find elevator layer
	local elevatorLayer
	for _,layer in pairs(scene.map.layers) do
		if layer.name == "elevator" then
			elevatorLayer = layer
			break
		end
	end
	
	elevatorLayer.offsety = 400

	return BlockPlayer {
		Spawn(Serial {
			PlayAudio("music", "mission2", 1.0, true, true),
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
		
		Do(function()
			scene.player.y = scene.player.y + 400
			scene.player.dropShadow.x = scene.player.x - 22
			scene.player.dropShadow.y = scene.player.dropShadowOverrideY or scene.player.y + scene.player.sprite.h - 15
		end),
		
		Parallel {
			Ease(elevatorLayer, "offsety", 0, 0.5, "linear"),
			Ease(scene.player, "y", function() return scene.player.y - 400 end, 0.5, "linear"),
			Do(function()
				-- Update drop shadow position
                scene.player.dropShadow.x = scene.player.x - 22
				scene.player.dropShadow.y = scene.player.dropShadowOverrideY or scene.player.y + scene.player.sprite.h - 15
			end),
			Serial {
				Wait(0.7),
				PlayAudio("sfx", "elevatorend", 1.0, true)
			}
		}
	}
	
end
