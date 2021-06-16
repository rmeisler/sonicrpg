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
	local BlockPlayer = require "actions/BlockPlayer"
	local SpriteNode = require "object/SpriteNode"

	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.regionName,
		100
	)

	--scene.audio:playMusic("knotholehut", 0.8)

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
	
	if GameState:isFlagSet("sonichut_intro") then
		scene.audio:playMusic("knotholehut", 0.8)
		Executor(scene):act(Serial {
			Wait(0.5),
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		})
		return Action()
	end
	
	scene.camPos.y = 400

	return BlockPlayer {
		Do(function()
			scene.player.noIdle = true
			scene.player.sprite:setAnimation("sleeping")
			scene.player.state = "sleeping"
			scene.player.dropShadow.hidden = true
		end),
		Parallel {
			Ease(scene.camPos, "y", 0, 0.1),
			Serial {
				Wait(0.5),
				PlayAudio("music", "transition", 1.0, true)
			}
		},
		Wait(2.5),
		Do(function()
			Executor(scene):act(Serial {
				Wait(0.5),
				text,
				Ease(text.color, 4, 255, 1),
				Wait(2),
				Ease(text.color, 4, 0, 1)
			})
		end),
		Wait(4),
		Parallel {
			Serial {
				PlayAudio("sfx", "alarm", 1.0),
				Do(function()
					scene.objectLookup.AlarmClock.sprite:setAnimation("idle")
				end)
			},
			Serial {
				Do(function()
					scene.objectLookup.AlarmClock.sprite:setAnimation("ring")
				end),
				Wait(1),
				Do(function()
					scene.player.state = "sleepingangry"
					scene.player.sprite:setAnimation("sleepingangry")
				end),
				Wait(3),
				Do(function()
					scene.player.state = "sleepingwat"
					scene.player.sprite:setAnimation("sleepingwat")
				end),
				MessageBox{message="Sonic: Ugh. {p50}How does anyone wake up before noon?"},
				Do(function()
					scene.audio:stopSfx()
					scene.objectLookup.AlarmClock.sprite:setAnimation("idle")
				end)
			}
		},
		
		Wait(0.5),

		Do(function()
			scene.player.state = "saw"
			scene.player.sprite:setAnimation("saw")
			local alarm = scene.objectLookup.AlarmClock
			scene.player.hidekeyhints[tostring(alarm)] = alarm
		end),
		
		PlayAudio("sfx", "jump", 0.5, true),
		Parallel {
			Ease(scene.player, "x", scene.player.x - 64, 3),
			Serial {
				Ease(scene.player, "y", scene.player.y - 170, 4),
				Ease(scene.player, "y", scene.player.y + 32, 6)
			},
		},
		
		Do(function()
			scene.player.noIdle = false
			scene.player.dropShadow.hidden = false
			scene.player.state = "idledown"
			scene.player.sprite:setAnimation("idledown")
		end),
		
		Wait(0.5),
		
		-- Jump out of bed
		Do(function()
			scene.audio:playMusic("knotholehut", 0.8)

			scene.objectLookup.AlarmClock:refreshKeyHint()
			GameState:setFlag("sonichut_intro")
		end)
	}
end
