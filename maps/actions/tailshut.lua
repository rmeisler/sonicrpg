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
	local Spawn = require "actions/Spawn"
	local BlockPlayer = require "actions/BlockPlayer"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"

	local titleText = function()
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
	end
	
	if hint == "snowday" then
		scene.objectLookup.Door.object.properties.scene = "knotholesnowday.lua"
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
	
	local undonight = function()
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

	if scene.nighttime then
		scene.objectLookup.TailsBed.sprite:setAnimation("tailssleep")

		local prefix = "nighthide"
		for _,layer in pairs(scene.map.layers) do
			if string.sub(layer.name, 1, #prefix) == prefix then
				layer.opacity = 1.0
			end
		end

		if hint == "sleep" then
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true

			scene.camPos.x = 0
			scene.camPos.y = 0

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
			
			scene.objectLookup.TailsBed.sprite:setAnimation("tailsawake")

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
				Do(function() scene.audio:stopSfx("thunder2") end),
				Spawn(scene:screenShake(35, 20, 10)),
				PlayAudio("sfx", "thunder2",0.8, true),
				Wait(1),
				MessageBox{message="Tails: Whoah! {p60}Cool!!", closeAction=Wait(1)},
				Do(function()
					scene:changeScene{map="antoineshut", fadeOutSpeed=0.5, fadeInSpeed=0.5, hint="sleep", nighttime=true}
					--scene:changeScene{map="rotorsworkshop", fadeOutSpeed=0.2, fadeInSpeed=0.08, enterDelay=3, hint="intro"}
				end)
			}
		elseif not GameState:isFlagSet("ep3_read") then
			titleText()
			scene.objectLookup.TailsBed.sprite:setAnimation("tailsawake")
			if GameState:isFlagSet("ep3_book") then
			    GameState:setFlag("ep3_read")
				scene.player.noIdle = true
				scene.objectLookup.Door.isInteractable = false
				scene.player:removeKeyHint()
				return BlockPlayer {
					Do(function()
						scene.player.object.properties.ignoreMapCollision = true
						scene.objectLookup.Door.isInteractable = false
						scene.objectLookup.Drawer.isInteractable = false
						scene.objectLookup.TailsBed.isInteractable = false
						scene.player:removeKeyHint()
						scene.player.movespeed = 2
					end),
					Wait(1),
					MessageBox {message="Sally: Tails, it's story time..."},
					MessageBox {message="Tails: Yay!"},
					Do(function()
						scene.player.sprite:setAnimation("walkdown")
					end),
					Parallel {
						Ease(scene.player, "x", function() return scene.player.x + 70 end, 1, "linear"),
						Ease(scene.player, "y", function() return scene.player.y + 70 end, 1, "linear")
					},
					Do(function()
						scene.player.sprite:setAnimation("readdown")
					end),
					MessageBox {message="Sally: 'Once upon a time...'", textspeed=1},
					Do(function()
						local tailsbed = scene.objectLookup.TailsBed
						tailsbed:run(BlockPlayer{
							scene:fadeOut(0.2),
							Animate(scene.objectLookup.TailsBed.sprite, "tailstired"),
							scene:fadeIn(0.2),
							MessageBox {message="Sally: '...as Ben came upon the clearing, he could see the vastness of the War Claw empire...'"},
							MessageBox {message="Sally: '...it was then that he realized the immensity of the task before them.'"},
							Animate(scene.objectLookup.TailsBed.sprite, "tailssleep"),
							MessageBox {message="Sally: 'If the allied forces failed to work together, they would surely be defeated.'"},
							Wait(1),
							MessageBox {message="Sally: ...{p40}Tails?"},
							Wait(1),
							MessageBox {message="Tails: zzz..."},
							Wait(1),
							Do(function()
								scene.player.sprite:setAnimation("thinking2")
							end),
							MessageBox {message="Sally: Trouble working together, huh?"},
							MessageBox {message="Sally: You and me both, Ben."},
							Do(function()
								scene.player.noIdle = false
								scene.player.sprite:setAnimation("idledown")
							end),
							MessageBox {message="Sally: *whipers* Goodnight Tails."},
							Do(undonight),
							Do(function()
								scene.objectLookup.Door.isInteractable = true
								scene.objectLookup.Drawer.isInteractable = true
								scene.objectLookup.TailsBed.isInteractable = true
								scene.player.movespeed = 4
							end)
						})
					end)
				}
			else
				titleText()
				return BlockPlayer {
					Do(function()
						scene.player.hidekeyhints[tostring(scene.objectLookup.Door)] = scene.objectLookup.Door
						scene.player:removeKeyHint()
					end),
					Wait(1),
					MessageBox {message="Tails: Hey Sally, will you read me a story?"},
					Do(function()
						scene.player.hidekeyhints[tostring(scene.objectLookup.Door)] = nil
					end)
				}
			end
		else
			scene.objectLookup.TailsBed.sprite:setAnimation("tailssleep")
		end
	end

	titleText()
	return Action()
end
