return function(scene, hint)
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
	
	if GameState:isFlagSet("ep3_sallynap") then
		scene.objectLookup.SallysBed.isInteractable = false
	end
	
	if scene.nighttime then
		scene.objectLookup.Door.object.properties.scene = "knotholeatnight.lua"
		local prefix = "nighthide"
		for _,layer in pairs(scene.map.layers) do
			if string.sub(layer.name, 1, #prefix) == prefix then
				layer.opacity = 1.0
			end
		end
	else
		scene.objectLookup.Door.object.properties.scene = "knothole.lua"
		local prefix = "nighthide"
		for _,layer in pairs(scene.map.layers) do
			if string.sub(layer.name, 1, #prefix) == prefix then
				layer.opacity = 0.0
			end
		end
	end

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
		scene.objectLookup.SallysBed.isInteractable = false
		Executor(scene):act(Serial {
			Wait(0.5),
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		})
		return Action()
	end

	if not scene.nighttime and
	   (GameState:isFlagSet("ep3_ffmeeting") or not GameState:isFlagSet("ep3_knotholerun"))
	then
		if hint == "night" then
			Executor(scene):act(Serial {
				Wait(0.5),
				text,
				Ease(text.color, 4, 255, 1),
				Wait(2),
				Ease(text.color, 4, 0, 1)
			})
			return Serial {
				Wait(3),
				Do(function()
					scene.audio:playMusic("knotholehut", 0.8)
				end)
			}
		else
			scene.audio:playMusic("knotholehut", 0.8)
		end
	elseif not scene.nighttime and not GameState:isFlagSet("ep3_ffmeeting") then
		scene.audio:playMusic("awkward", 1.0)
	end
	
	if not scene.nighttime and not GameState:isFlagSet("ep3_sallywakeup") then
		scene.audio:stopMusic()
		scene.objectLookup.SallysBed.isInteractable = false
		scene.player:removeKeyHint()
		return BlockPlayer {
			Do(function()
				GameState:setFlag("ep3_sallywakeup")
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.player.x = scene.objectLookup.SallysBed.x + 70
				scene.player.y = scene.objectLookup.SallysBed.y + 90
				scene.player:removeKeyHint()
			end),
			Animate(scene.objectLookup.SallysBed.sprite, "sleeping"),
			Wait(3),
			Spawn(Serial {
				PlayAudio("music", "flutter", 1.0),
				Wait(2),
				PlayAudio("music", "knotholehut", 0.8, true, true)
			}),
			Wait(5),
			Animate(scene.objectLookup.SallysBed.sprite, "wake"),
			Animate(scene.objectLookup.SallysBed.sprite, "awake"),
			Wait(1),
			Animate(scene.objectLookup.SallysBed.sprite, "sit"),
			Wait(1),
			MessageBox{message="Sally: Ahhh... {p80}a new day! {p80}And so much promise for the future!"},
			Animate(scene.objectLookup.SallysBed.sprite, "empty"),
			Do(function()
				scene.player.sprite.visible = true
				scene.player.dropShadow.hidden = false
				scene.player.x = scene.objectLookup.SallysBed.x + 70
				scene.player.y = scene.objectLookup.SallysBed.y + 95
			end),
			Wait(0.2),
			Do(function()
				scene.player.sprite:setAnimation("pose")
				scene.player.state = "pose"
				scene.player.noIdle = true
			end),
			MessageBox{message="Sally: With the Rebellion on our side{p60}, and a certificate of authenticity in-hand{p60}, Robotnik doesn't stand a chance!"},
			Do(function()
				scene.player.state = "idledown"
				scene.player.noIdle = false
			end)
		}
	else
		Executor(scene):act(Serial {
			Wait(0.5),
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		})
		
		if hint == "sleep" then
			scene.objectLookup.SallysBed.isInteractable = false
			scene.player:removeKeyHint()
			return BlockPlayer {			
				Do(function()
					scene.player.sprite.visible = false
					scene.player.dropShadow.hidden = true
					scene.player.x = scene.objectLookup.SallysBed.x + 70
					scene.player.y = scene.objectLookup.SallysBed.y + 90
					GameState:removeFromParty("sonic")
					GameState:removeFromParty("antoine")
				end),
				Animate(scene.objectLookup.SallysBed.sprite, "sleeping"),
				Wait(5),
				Spawn(Serial {
					PlayAudio("music", "rotorsworkshop", 1.0),
					Wait(1),
					PlayAudio("music", "knotholeatnight", 0.8, true, true),
				}),
				Animate(scene.objectLookup.SallysBed.sprite, "wake"),
				Animate(scene.objectLookup.SallysBed.sprite, "awake"),
				Wait(1),
				MessageBox{message="Sally: Oh dear..."},
				Animate(scene.objectLookup.SallysBed.sprite, "empty"),
				Do(function()
					scene.player.sprite.visible = true
					scene.player.x = scene.objectLookup.SallysBed.x + 70
					scene.player.y = scene.objectLookup.SallysBed.y + scene.objectLookup.SallysBed.sprite.h*2
					scene.player.object.properties.ignoreMapCollision = true
					scene.player.state = "shock"
					scene.player.sprite:setAnimation("shock")
					scene.player.hidekeyhints[tostring(scene.objectLookup.SallysBed)] = scene.objectLookup.SallysBed
				end),

				Do(function()
					scene.player.hidekeyhints[tostring(scene.objectLookup.SallysBed)] = scene.objectLookup.SallysBed
				end),
				
				MessageBox{message="Sally: I slept the whole day!"},
				
				Do(function()
					scene.player.state = "thinking"
					scene.player.sprite:setAnimation("thinking")
					scene.player.dropShadow.hidden = false
					scene.player.object.properties.ignoreMapCollision = false
				end),
				MessageBox{message="Sally: I guess I needed the rest. {p60}We've been just working non-stop since Rotor found that glitch..."},
				Do(function()
					scene.player.state = "idledown"
					scene.player.sprite:setAnimation("idledown")
				end),
				MessageBox{message="Sally: Alright, time to face the music, Sally girl...\n{p60}how embarassing."}
			}
		end
	end

	return Action()
end
