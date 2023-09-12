return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local Animate = require "actions/Animate"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local BlockPlayer = require "actions/BlockPlayer"
	local SpriteNode = require "object/SpriteNode"

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
	
	local doNightTime = function()
		if scene.nighttime then
			local prefix = "nighthide"
			for _,layer in pairs(scene.map.layers) do
				if string.sub(layer.name, 1, #prefix) == prefix then
					layer.opacity = 1.0
				end
			end
		end
	end
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.regionName,
		100
	)

	--scene.audio:playMusic("knotholehut", 0.8)

	if hint == "snowday" then
		scene.objectLookup.Door.object.properties.scene = "knotholesnowday.lua"
		scene.objectLookup.Sonic:remove()
		local prefix = "nighthide"
		for _,layer in pairs(scene.map.layers) do
			if string.sub(layer.name, 1, #prefix) == prefix then
				layer.opacity = 0.0
			end
		end
	elseif hint == "sleep" then
		doNightTime()
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		-- Undo ignore night
		local shine = require "lib/shine"

		scene.map.properties.ignorenight = false
		scene.originalMapDraw = scene.map.drawTileLayer
		scene.map.drawTileLayer = function(map, layer)
			if not scene.night then
				scene.night = shine.nightcolor()
			end
			scene.night:draw(function()
				scene.night.shader:send("opacity", layer.opacity or 1)
				scene.night.shader:send("lightness", 1 - (layer.properties.darkness or 0))
				scene.originalMapDraw(map, layer)
			end)
		end

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.camPos.x = 0
				scene.camPos.y = 0
			end),
			Wait(1),
			-- Flash twice
			scene:lightningFlash(),
			Wait(0.1),
			scene:lightningFlash(),
			Spawn(scene:screenShake(35, 20, 10)),
			PlayAudio("sfx", "thunder2",0.8, true),
			Wait(2),
			Do(function()
				scene:changeScene{map="tailshut", fadeOutSpeed=0.5, fadeInSpeed=0.5, hint="sleep", nighttime=true}
				--scene:changeScene{map="rotorsworkshop", fadeOutSpeed=0.2, fadeInSpeed=0.08, enterDelay=3, hint="intro"}
			end)
		}
	else
		if GameState:isFlagSet("ep4_introdone") then
			local prefix = "nighthide"
			for _,layer in pairs(scene.map.layers) do
				if string.sub(layer.name, 1, #prefix) == prefix then
					layer.opacity = 0.0
				end
			end
			scene.objectLookup.Door.object.properties.scene = "knothole.lua"
			scene.audio:playMusic("knotholehut", 0.8)
		elseif not scene.nighttime and
		   (GameState:isFlagSet("ep3_ffmeeting") or not GameState:isFlagSet("ep3_knotholerun"))
		then
			scene.audio:playMusic("knotholehut", 0.8)
		elseif not scene.nighttime and not GameState:isFlagSet("ep3_ffmeeting") then
			scene.audio:playMusic("awkward", 1.0)
		else
			doNightTime()
			scene.objectLookup.Door.object.properties.scene = "knotholeatnight.lua"
		end
	end
	
	Executor(scene):act(Serial {
		Wait(0.5),
		text,
		Ease(text.color, 4, 255, 1),
		Wait(2),
		Ease(text.color, 4, 0, 1)
	})
	return Action()
end
