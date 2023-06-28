return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local Move = require "actions/Move"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local BlockPlayer = require "actions/BlockPlayer"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"

	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.TechnoMed,
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
	
	scene.objectLookup.Leon.isInteractable = false
	scene.objectLookup.Fleet.isInteractable = false
	scene.objectLookup.Ivan.isInteractable = false

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
	
	if hint == "snowday" then
		scene.objectLookup.Door.object.properties.scene = "knotholesnowday.lua"
		return Action()
	elseif not scene.nighttime then
		if GameState:isFlagSet("ep3_ffmeeting") or
		   not GameState:isFlagSet("ep3_knotholerun")
		then
			scene.audio:playMusic("knotholehut", 0.8)
		elseif not GameState:isFlagSet("ep3_ffmeeting") then
			scene.audio:playMusic("awkward", 1.0)
		end
		scene.objectLookup.Door.object.properties.scene = "knothole.lua"
	else
		scene.objectLookup.Door.object.properties.scene = "knotholeatnight.lua"
	end

	return Do(function()
		if scene.nighttime then
			scene.objectLookup.Fleet.hidden = false
			scene.objectLookup.Fleet.ghost = false
			scene.objectLookup.Fleet.isInteractable = true
			scene.objectLookup.Fleet:updateCollision()
			scene.objectLookup.Ivan.hidden = false
			scene.objectLookup.Ivan.ghost = false
			scene.objectLookup.Ivan.isInteractable = true
			scene.objectLookup.Ivan:updateCollision()
		else
			scene.objectLookup.Leon.hidden = false
			scene.objectLookup.Leon.ghost = false
			scene.objectLookup.Leon.isInteractable = true
			scene.objectLookup.Leon:updateCollision()
		end
	end)
end
