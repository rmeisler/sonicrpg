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
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local SpriteNode = require "object/SpriteNode"
	local Animate = require "actions/Animate"
	local Move = require "actions/Move"
	local BlockInput = require "actions/BlockInput"
	local Spawn = require "actions/Spawn"
	local BlockPlayer = require "actions/BlockPlayer"

	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.regionName,
		100
	)

	Executor(scene):act(Serial {
		Wait(0.5),
		text,
		Ease(text.color, 4, 255, 1),
		Wait(2),
		Ease(text.color, 4, 0, 1)
	})

	if not scene.updateHookAdded then
		scene.updateHookAdded = true
		scene:addHandler(
			"update",
			function(dt)
				if not scene.player then
					return
				end
				
				-- This update function defines and enforces eliptical collision 
				-- for the interior walls of knothole huts. This is implemented
				-- as just two separate point-to-circle collision checks,
				-- one for the top half of the room, one for the bottom half.
				local px = scene.player.x
				local py = scene.player.y + scene.player.height
				local cx = 400
				local cy = scene.map.properties.lowerCollisionCircleY or 370
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
					local radians = math.atan(dy / dx)
					local inv = px > cx and 1 or -1

					-- Use that angle to reposition them at the outer edge of the collision circle
					scene.player.x = cx + inv * (math.cos(radians) * cr)
					scene.player.y = cy - scene.player.height + inv * (math.sin(radians) * cr)
				end
			end
		)
	end
	
	if GameState:isFlagSet("ep3_intro") and not GameState:isFlagSet("ep3_introdone") then
		GameState:setFlag("ep3_introdone")
		scene.objectLookup.Door.sprite:setAnimation("open")
		scene.objectLookup.SallyPensive.movespeed = 2
		scene.bgColor2 = {255,255,255,255}
		
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.player.cinematic = true
			end),
			Wait(2),

			Animate(scene.objectLookup.Door.sprite, "closing"),
			Animate(scene.objectLookup.Door.sprite, "closed"),
			PlayAudio("sfx", "door", 1.0),
			
			Wait(2),
			PlayAudio("music", "ep3transition", 0.6, true),
			Move(scene.objectLookup.SallyPensive, scene.objectLookup.Waypoint1, "walk"),
			Animate(scene.objectLookup.SallyPensive.sprite, "idledown"),
			Wait(2),
			Animate(scene.objectLookup.SallyPensive.sprite, "thinking2"),
			MessageBox {message="Sally: What a day...", textSpeed=2, closeAction=Wait(2.5)},
			Wait(3),
			Animate(scene.objectLookup.SallyPensive.sprite, "idleright"),
			Wait(2),
			MessageBox {message="Sally: ...", textSpeed=1, closeAction=Wait(2.5)},
			Wait(2),
			Animate(scene.objectLookup.SallyPensive.sprite, "thinking"),
			Wait(3),
			Move(scene.objectLookup.SallyPensive, scene.objectLookup.Waypoint2, "walk"),
			Do(function()
				scene.objectLookup.SallyPensive.sprite.sortOrderY = 99999
			end),
			Animate(scene.objectLookup.SallyPensive.sprite, "sit_computer"),
			Wait(1),

			MessageBox {message="Sally: Nicole, {p30}open a new file.", textspeed=2},
			MessageBox {message="Nicole: File open, {p30}Sally.", sfx="nicolebeep"},
			PlayAudio("music", "ep3intro", 0.9, true),
			MessageBox {message="> I know I haven't sent one of these in a long while... {p60}I don't even know if you receive them...", textspeed=1, closeAction=Wait(2.5)},
			MessageBox {message="> ...but I have big news that I just had to tell you...", textspeed=1, closeAction=Wait(2)},
			MessageBox {message="> I can hardly believe I'm writing this, {p60}but it seems like we may be on the verge of defeating Robotnik.", textspeed=1, closeAction=Wait(2.5)},
			MessageBox {message="> I wish I could take all of the credit, but Rotor was the one who found the software glitch that we'll use to disable Robotnik's army.", textspeed=1, closeAction=Wait(3)},
			MessageBox {message="> I haven't felt this hopeful about the future in a long time-- {p100}but I'm trying to stay level-headed, like you taught me.", textspeed=1, closeAction=Wait(3)},
			MessageBox {message="> Once we take back the city, {p60}I won't rest until I find you and bring you home.", textspeed=1, closeAction=Wait(3)},
			MessageBox {message="> Just hold on a little longer, daddy.", textspeed=1, closeAction=Wait(3)},
			MessageBox {message="> Love, Sally", textspeed=1, closeAction=Wait(2.5)},
			Animate(scene.objectLookup.SallyPensive.sprite, "sit_sad"),
			MessageBox {message="Sally: *sniff* Close file, Nicole.", textspeed=2, closeAction=Wait(2)},
			MessageBox {message="Sally: Encrypt message. {p60}Passcode 'Bean'. {p80}Send on all available frequencies.", textspeed=3, closeAction=Wait(2.5)},
			MessageBox {message="Nicole: Sending, {p40}Sally.", textspeed=3, closeAction=Wait(1)},
			Wait(1),
			Do(function()
				scene:changeScene{map="sallyshut", fadeOutSpeed=0.05, fadeInSpeed=0.1, fadeOutMusic=true, nighttime=false}
			end)
		}
	end
end
