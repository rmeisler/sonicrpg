return function(scene, hint)
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
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local BlockPlayer = require "actions/BlockPlayer"
	local Move = require "actions/Move"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"
	
	local FactoryBot = require "object/FactoryBot"

	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	if GameState:isFlagSet("deathegg:sneak1_done") then
		return Action()
	end

	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	scene.cinematicPause = true

	scene.player.handlers.caught = nil
	
	local caughtHandler
	caughtHandler = function(bot)
		scene.player.noIdle = true
		scene.player.sprite:setAnimation("shock")
		scene.player.state = "shock"
		scene.player:removeKeyHint()
		scene.player:removeHandler("caught", caughtHandler)
		scene:run(
			BlockPlayer {
				Wait(1),
				Do(function()
					scene:restart{hint="caught", fadeOutMusic=false}
				end),
				Do(function() end)
			}
		)
	end
	scene.player:addHandler("caught", caughtHandler)

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			scene.cinematicPause = true
			
			scene.player.doingSpecialMove = false
			scene.player.basicUpdate = scene.player.origUpdate or scene.player.basicUpdate

			if hint == "caught" then
				scene.player.x = scene.player.x + 20
				scene.player.y = scene.player.y + 50
			end
		end),
		
		Wait(1),
		
		Do(function()
			print("factory bot created")
			local fbot = FactoryBot(
				scene,
				{name="objects"},
				{
					name = "FactoryBot",
					x = scene.objectLookup.FStart.x,
					y = scene.objectLookup.FStart.y,
					width = 64,
					height = 32,
					properties = {
						defaultAnim = "idleright",
						ghost = true,
						sprite = "art/sprites/factorybot.png",
						follow = "FWaypoint1,FWaypoint2,FWaypoint3,FWaypoint4,FWaypoint5",
						removeAfterFollow = true,
						viewRange = "FVisibility1,FVisibility2,FVisibility3,FVisibility4",
						ignorePlayer = true,
						noMusic = true
					}
				}
			)
			scene:addObject(fbot)
			fbot:postInit()
			scene.objectLookup.FBot = fbot
		end),
		
		Wait(2),
		
		Do(function()
			scene.player.sprite.visible = true
			scene.player.dropShadow.hidden = false
			scene.cinematicPause = false
			scene.objectLookup.FBot.ignorePlayer = false
		end)
	}
end
