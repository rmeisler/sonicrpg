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
	local TextNode = require "object/TextNode"
	local Move = require "actions/Move"
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Mobius",
		100
	)
	
	local musicAction = PlayAudio("music", "worldmap", 1.0, true, true)
	
	-- Add ui elements
	scene.pressXText = TextNode(
		scene,
		Transform(80, 550),
		{255,255,255,255},
		"enter",
		FontCache.Consolas,
		"ui",
		false
	)
	scene.pressX = SpriteNode(
		scene,
		Transform(50, 550, 2, 2),
		{255,255,255,255},
		"pressx",
		12,
		12,
		"ui"
	)
	scene.pressX:setAnimation("nopress")
	
	scene.pressZText = TextNode(
		scene,
		Transform(200, 550),
		{255,255,255,255},
		"menu",
		FontCache.Consolas,
		"ui",
		false
	)
	scene.pressZ = SpriteNode(
		scene,
		Transform(170, 550, 2, 2),
		{255,255,255,255},
		"pressz",
		12,
		12,
		"ui"
	)
	scene.pressZ:setAnimation("nopress")
	
	--[[return Serial {
		Spawn(Serial {
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		}),
		
		musicAction
	}]]
	return musicAction
end
