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
	
	if scene.nighttime then
		local prefix = "nighthide"
		for _,layer in pairs(scene.map.layers) do
			if string.sub(layer.name, 1, #prefix) == prefix then
				layer.opacity = 1.0
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
	
	if hint == "sleep" then
		scene.objectLookup.Door.object.properties.scene = "knotholeatnight.lua"
		return BlockPlayer {
			Do(function()
				scene.player.noIdle = true
				scene.player.hidekeyhints[tostring(scene.objectLookup.SonicBed)] = scene.objectLookup.SonicBed
				scene.objectLookup.SonicBed.handlers = {}
				scene.player.y = scene.player.y + 16
				scene.player.sprite:setAnimation("sleeping")
				scene.player.dropShadow.hidden = true
				GameState:removeFromParty("antoine")
				GameState:removeFromParty("sally")
			end),
			Wait(5),
			Do(function()
				scene.player.sprite:setAnimation("sleepingwat")
			end),
			Spawn(Serial {
				PlayAudio("music", "rotorsworkshop", 1.0),
				Wait(1),
				PlayAudio("music", "knotholeatnight", 0.8, true, true),
			}),
			MessageBox{message="Sonic: *yawn*{p60} what time is it?..."},
			Wait(1),
			Do(function()
				scene.player.sprite:setAnimation("shock")
				scene.player.object.properties.ignoreMapCollision = true
			end),
			Parallel {
				Serial {
					Ease(scene.player, "y", function() return scene.player.y - 180 end, 4, "linear"),
					Ease(scene.player, "y", function() return scene.player.y + 180 end, 4, "linear"),
					Ease(scene.player, "y", function() return scene.player.y - 3 end, 20, "quad"),
					Ease(scene.player, "y", function() return scene.player.y + 3 end, 20, "quad"),
					Ease(scene.player, "y", function() return scene.player.y - 2 end, 20, "quad"),
					Ease(scene.player, "y", function() return scene.player.y + 2 end, 20, "quad"),
					Ease(scene.player, "y", function() return scene.player.y - 1 end, 20, "quad"),
					Ease(scene.player, "y", function() return scene.player.y + 1 end, 20, "quad")
				},
				Ease(scene.player, "x", function() return scene.player.x - 90 end, 2.5, "linear")
			},
			MessageBox{message="Sonic: Uh oh!{p60} I slept the whole day!"},
			Do(function()
				scene.player.sprite:setAnimation("worried2")
			end),
			MessageBox{message="Sonic: Sal's not gonna be happy about this..."},
			Wait(0.5),
			Do(function()
				scene.player.noIdle = false
				scene.player.hidekeyhints[tostring(scene.objectLookup.SonicBed)] = nil
				scene.player.dropShadow.hidden = false
				scene.player.object.properties.ignoreMapCollision = false
			end)
		}
	else
		if not scene.nighttime and
		   (GameState:isFlagSet("ep3_ffmeeting") or not GameState:isFlagSet("ep3_knotholerun"))
		then
			scene.audio:playMusic("knotholehut", 0.8)
		elseif not scene.nighttime and not GameState:isFlagSet("ep3_ffmeeting") then
			scene.audio:playMusic("awkward", 1.0)
		else
			scene.objectLookup.SonicBed.handlers = {}
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
