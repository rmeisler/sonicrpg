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
		scene.player.cinematicStack = scene.player.cinematicStack + 1
		local origMoveSpeed = scene.player.movespeed
		scene.player.movespeed = 1
		scene.player.noIdle = true
		
		local sallydoor = scene.objectLookup.Door
		scene.player.hidekeyhints[tostring(sallydoor)] = sallydoor

		return Serial {
			Do(function()
				scene.player.hidekeyhints[tostring(sallydoor)] = sallydoor
			end),
			AudioFade("music", 1, 0, 1),
			Do(function() scene.audio:stopMusic() end),
			Wait(1),
			Move(scene.player, scene.objectLookup.Waypoint, "walk"),
			Do(function()
				scene.player.sortOrder = 999
				scene.player.sprite:setAnimation("idleup")
				scene.audio:playMusic("talkingtosally", 1.0)
			end),
			MessageBox {message="Sonic: How ya doin' Sal?"},
			MessageBox {message="Sally: Oh, hey Sonic. {p40}I'm... {p40}doin' alright."},
			MessageBox {message="Sonic: Just alright?"},
			MessageBox {message="Sonic: What's up?", textSpeed=4},
			MessageBox {message="Sally: It's nothing, Sonic.", textSpeed=4},
			MessageBox {message="Sonic: Sal, come on, I can tell when something's up, and something is definitely up!", textSpeed=4},
			MessageBox {message="Sally: ...", textSpeed=4},
			
			Do(function()
				scene.player.sprite:setAnimation("walkup")
			end),
			Ease(scene.player, "y", function() return scene.player.y - 20 end, 2, "linear"),
			Do(function()
				scene.player.x = scene.player.x - 15
				scene.player.y = scene.player.y - 38
				scene.player.sprite:setAnimation("sit_sad")
			end),
			MessageBox {message="Sally: *sigh*{p40} It's nothing{p40}... it's just that...", textSpeed=4},
			MessageBox {message="Sally: ...so many things went wrong on our last mission.", textSpeed=4},
			MessageBox {message="Sally: We didn't end up taking out the Swatbot Factory{p40}, Antoine got captured{p40}, we were nearly killed by that Rover...", textSpeed=4},
			Do(function()
				scene.player.sprite:setAnimation("sit_smile")
			end),
			MessageBox {message="Sonic: Yeah-- {p30}'and'{p30} we found some mondo cool new allies!"},
			MessageBox {message="Sonic: Heck, {p40}with B's help{p40}, I bet we could sneak all the way into Buttnik's headquarters, no prob!"},
			MessageBox {message="Sally: We still failed the mission, Sonic."},
			MessageBox {message="Sally: It just feels like we haven't made any progress in actually taking back Mobotropolis or freeing our roboticized family members..."},
			Do(function()
				scene.player.sprite:setAnimation("sit_sad")
			end),
			MessageBox {message="Sally: When we started the Freedom Fighters-- {p50}I guess I just thought we'd be farther along by now."},
			MessageBox {message="Sally: {p20}.{p20}.{p20}.{p40}I sometimes wonder if I'm really fit to be a leader...", textSpeed=4},
			MessageBox {message="Sonic: Hold up, Sal!"},
			MessageBox {message="Sonic: Sure{p20}, there have been some failed missions recently{p40}, but we've also kicked some serious Robuttnik\ntail!"},
			Do(function()
				scene.player.sprite:setAnimation("sit_encouraging")
			end),
			MessageBox {message="Sonic: Remember when we stopped Buttnik from pulling that giant energy crystal out of the ground and destroying the Great Forest?"},
			MessageBox {message="Sally: Yes..."},
			MessageBox {message="Sonic: Or when we went all the way up into space to crash his sattelite?"},
			MessageBox {message="Sally: Yes, Sonic."},
			MessageBox {message="Sonic: What about when we destroyed both the primary {p30}'and'{p30} {h backup} power generators?"},
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
			MessageBox {message="Sally: Thanks Sonic. {p40}I do feel a bit better now.", textSpeed=4},
			MessageBox {message="Sonic: Cool. {p40}Wanna grab some fresh air?", textSpeed=4},
			MessageBox {message="Sally: Sure, {p40}why not?", textSpeed=4},
			MessageBox {message="Sally joined your party!", sfx="levelup"},
			
			Do(function()
				scene.player.cinematicStack = scene.player.cinematicStack - 1
				scene.player.movespeed = origMoveSpeed
				scene.player.noIdle = false
				scene.objectLookup.SallySad:remove()
				GameState:addToParty("sally", 3, true)
				GameState.leader = "sonic"
				
				GameState:setFlag("sallysad_over")
			end)
		}
	end
end
