local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"
local Move = require "actions/Move"

local BasicNPC = require "object/BasicNPC"
local EscapeObstacle = require "object/EscapeObstacle"
local EscapeHoverbot = require "object/EscapeHoverbot"
local EscapeIndicator = require "object/EscapeIndicator"

local EscapePlayerVert = require "object/EscapePlayerVert"

local TARGET_OFFSET_X = 400

return function(scene)
	scene.playerDead = false
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	
	GameState:removeFromParty("antoine")
	
	local R = scene.objectLookup.R
	return While(
		function()
			return not scene.playerDead
		end,
		
		Serial {
			Do(function()
				scene.player.x = R.x + 50
				scene.player.y = R.y
				R.movespeed = 25
			end),
			
			Wait(1),
			
			Parallel {
				Serial {
					Move(R, scene.objectLookup.Waypoint1, "dash"),
					Move(R, scene.objectLookup.Waypoint2, "dash"),
					Move(R, scene.objectLookup.Waypoint3, "dash"),
					Move(R, scene.objectLookup.Waypoint4, "dash"),
					Move(R, scene.objectLookup.Waypoint5, "dash"),
					Move(R, scene.objectLookup.Waypoint6, "dash"),
				},
				Do(function()
					scene.player.x = R.x + 50
					scene.player.y = R.y
				end)
			},
			
			Parallel {
				Move(R, scene.objectLookup.Waypoint7, "dash"),
				Ease(scene.player, "x", 800, 0.2, "inout"),
				Ease(scene.player, "y", 22368, 0.2, "inout")
			},
			
			MessageBox{message = "Sonic: Ready or not... {p50}here I come!", blocking = true, textSpeed = 4},
			
			Do(function()
				scene.objectLookup.R:remove()
				
				GameState.leader = "sonic"
				scene.player:updateSprite()
				scene.player:addSceneHandler("update", EscapePlayerVert.update)
				scene.player.sprite.visible = true
				scene.player.dropShadow.sprite.visible = true
				scene.player.sprite:setAnimation("juiceup")
			end),
			
			PlayAudio("music", "sonictheme", 0.8, true),

			Wait(1000)
		},
		
		Serial {
			Do(function()
				scene.player:removeSceneHandler("update", EscapePlayerVert.update)
			end),
			Menu {
				layout = Layout {
					{Layout.Text("Try again?"), selectable = false},
					{Layout.Text("Yes"),
						choose = function(menu)
							menu:close()
							scene:restart()
						end},
					{Layout.Text("No"),
						choose = function(menu)
							menu:close()
							scene.sceneMgr:backToTitle()
						end},
					colWidth = 200
				},
				transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
				selectedRow = 2
			}
		}
	)
end
