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
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	
	local text = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TehnoSmall,
		"Sonic's Room",
		100
	)
	
	Executor(scene):act(Serial {
		Wait(0.5),
		text,
		Ease(text.color, 4, 255, 1),
		Wait(2),
		Ease(text.color, 4, 0, 1)
	})
	
	scene.audio:playMusic("knotholehut", 1.0)
	
	scene:addHandler(
		"update",
		function(dt)
			-- This update function defines and enforces eliptical collision 
			-- for the interior walls of knothole huts. This is implemented
			-- as just two separate point-to-circle collision checks,
			-- one for the top half of the room, one for the bottom half.
			local px = scene.player.x
			local py = scene.player.y + scene.player.height
			local cx = 400
			local cy = 370
			local cr = 200
			
			-- Player is above center of screen, use lower circle rather than higher circle
			if py < love.graphics.getWidth()/2 then
				cy = 435
			end
			
			local dx = px - cx
			local dy = py - cy
			
			-- If player is outside the circle
			if (dx*dx) + (dy*dy) > cr*cr then
				-- Determine the angle between their position and the center of the circle
				local radians = math.asin(dy / math.sqrt((dx*dx) + (dy*dy)))
				local inv = px > cx and 1 or -1

				-- Use that angle to reposition them at the outer edge of the collision circle
				scene.player.x = cx + inv * (math.cos(radians) * cr)
				scene.player.y = cy - scene.player.height + math.sin(radians) * cr
			end
		end
	)

	return Action()
end
