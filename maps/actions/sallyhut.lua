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
	local SpriteNode = require "object/SpriteNode"
	local Animate = require "actions/Animate"
	local Move = require "actions/Move"

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
	
	if GameState:isFlagSet("sallysad_over") then
		scene.audio:playMusic("knotholehut", 0.8)
		scene.objectLookup.SallySad:remove()
		return Action()
	else
		scene.audio:stopMusic()
		scene.player.cinematicStack = scene.player.cinematicStack + 1
		local origMoveSpeed = scene.player.movespeed
		scene.player.movespeed = 1
		scene.player.noIdle = true
		return Serial {
			Wait(1),
			MessageBox {message="Sonic: How ya doin' Sal?"},
			MessageBox {message="Sally: Oh, hey Sonic. {p40}I'm... {p40}doin' alright."},
			MessageBox {message="Sonic: Just alright?"},
			Move(scene.player, scene.objectLookup.Waypoint, "walk"),
			Do(function()
				scene.player.sortOrder = 999
				scene.player.sprite:setAnimation("idleup")
			end),
			MessageBox {message="Sonic: What's up?", textSpeed=4},
			MessageBox {message="Sally: It's nothing, Sonic.", textSpeed=4},
			MessageBox {message="Sonic: Sal, come on, I can tell when something's up, and something is definitely up!", textSpeed=4},
			MessageBox {message="Sally: ...", textSpeed=4},
			Do(function()
				scene.player.x = scene.player.x - 15
				scene.player.y = scene.player.y - 58
				scene.player.sprite:setAnimation("sit_sad")
				scene.audio:playMusic("knotholehut", 0.8)
			end),
			MessageBox {message="Sally: *sigh*{p40} It's nothing{p40}... it's just that...{p40} so many things went wrong on our last mission...", textSpeed=4},
			MessageBox {message="Sally: We didn't end up taking out the Swatbot Factory{p40}, Antoine got captured{p40}, we were nearly killed by that Rover...", textSpeed=2},
			Do(function()
				scene.player.sprite:setAnimation("sit_smile")
			end),
			MessageBox {message="Sonic: Yeah, {p20}'and'{p20} we found some mondo cool new allies!"},
			MessageBox {message="Sonic: Heck, {p20}with B's help{p20}, I bet we could sneak into Buttnik's headquarters, no prob!"},
			MessageBox {message="Sally: We still failed the mission, Sonic."},
			MessageBox {message="Sally: It just feels like we haven't made any progress in actually taking back Mobotropolis or freeing our roboticized family members..."},
			Do(function()
				scene.player.sprite:setAnimation("sit_sad")
			end),
			MessageBox {message="Sally: When we started the Freedom Fighters-- {p40}I guess I just thought we'd be farther along by now."},
			MessageBox {message="Sally: {p20}.{p20}.{p20}.{p40}I sometimes wonder if I'm really fit to be a leader...", textSpeed=4},
			MessageBox {message="Sonic: Hold up, Sal!"},
			MessageBox {message="Sonic: Sure{p20}, there's been some failed missions, here and there{p20}, but we've also kicked some serious Robuttnik tail!"},
			Do(function()
				scene.player.sprite:setAnimation("sit_encouraging")
			end),
			MessageBox {message="Sonic: Remember when we stopped Buttnik from pulling that giant energy crystal out of the ground and destroying the Great Forest?"},
			MessageBox {message="Sally: Yes..."},
			MessageBox {message="Sonic: Or when we went all the way up into space to crash Buttnik's sattelite?"},
			MessageBox {message="Sally: Yes, Sonic."},
			MessageBox {message="Sonic: What about when we destroyed both his primary and {h backup} generators?"},
			MessageBox {message="Sonic: That set ol' lard butt back for weeks!"},
			Do(function()
				scene.objectLookup.SallySad.sprite:setAnimation("sit_laugh")
			end),
			MessageBox {message="Sally: *chuckles* Ok Sonic, I get your point."},
			Do(function()
				scene.player.sprite:setAnimation("sit_smile")
			end),
			MessageBox {message="Sonic: All I'm saying is...{p40} you're doing great.", textSpeed=4},
			MessageBox {message="Sonic: ...and you're a way past cool leader.", textSpeed=4},
			Do(function()
				scene.objectLookup.SallySad.sprite:setAnimation("sit_smile")
			end),
			MessageBox {message="Sally: Thanks Sonic. {p40}I do feel a little bit better now."},
			MessageBox {message="Sonic: Cool. {p40}Wanna go grab some fresh air?"},
			MessageBox {message="Sally: Sure, {p20}why not?"},
			Do(function()
				scene.player.cinematicStack = scene.player.cinematicStack - 1
				scene.player.movespeed = origMoveSpeed
				scene.player.noIdle = false
				scene.objectLookup.SallySad:remove()
				GameState:addToParty("sally", 3, true)
				
				GameState:setFlag("sallysad_over")
			end)
		}
	end
end
