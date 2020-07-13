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

local SparkCollector = require "object/SparkCollector"

local EscapePlayerVert = require "object/EscapePlayerVert"

local TARGET_OFFSET_X = 400

return function(scene)
	scene.player.dead = false
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	
	scene.audio:stopSfx()
	
	GameState:removeFromParty("antoine")
	
	local R = scene.objectLookup.R
	return While(
		function()
			return not scene.player.dead
		end,
		
		Serial {
			Do(function()
				scene.player.x = R.x
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
				},
				Do(function()
					scene.player.x = R.x
					scene.player.y = R.y
				end),
				
				Repeat(Serial {
					Wait(0.2),
					Do(function()
						local sparkle = SparkCollector(
							scene,
							{name = "objects"},
							{name = "sparkle1", x = R.x + 20, y = R.y + 70, width = 32, height = 32,
								properties = {
									ghost = true,
									sprite = "art/sprites/sparkle.png"
								}
							}
						)
						sparkle.sprite.transform.sx = 4
						sparkle.sprite.transform.sy = 4
						scene:addObject(sparkle)
					end),
				}, 17),
				
				Serial {
					AudioFade("music", scene.audio:getMusicVolume(), 0, 1),
					Do(function()
						scene.audio:stopMusic()
					end),
					Wait(2),
					PlayAudio("music", "sonictheme", 0.5, true)
				}
			},
			
			Spawn(Serial {
				Parallel {
					Serial {
						Move(R, scene.objectLookup.Waypoint5, "dash"),
						Move(R, scene.objectLookup.Waypoint6, "dash"),
						Move(R, scene.objectLookup.Waypoint7, "dash"),
						Move(R, scene.objectLookup.Waypoint8, "dash"),
						Move(R, scene.objectLookup.Waypoint9, "dash"),
						Move(R, scene.objectLookup.Waypoint10, "dash"),
						Move(R, scene.objectLookup.Waypoint11, "dash"),
						Move(R, scene.objectLookup.Waypoint12, "dash"),
					},
					
					Repeat(Serial {
						Do(function()
							local newSparkleY = R.y + 70
							local sparkle = SparkCollector(
								scene,
								{name = "objects"},
								{name = "sparkle", x = R.x + 20, y = newSparkleY, width = 32, height = 32,
									properties = {
										ghost = true,
										sprite = "art/sprites/sparkle.png"
									}
								}
							)
							sparkle.sprite.transform.sx = 4
							sparkle.sprite.transform.sy = 4
							scene:addObject(sparkle)
						end),
						Wait(0.2)
					}, 40)
				},
				Do(function()
					scene.objectLookup.R:remove()
				end)
			}),
			
			Parallel {
				Ease(scene.player, "x", 832, 0.23, "inout"),
				Ease(scene.player, "y", 20768, 0.23, "inout"),
				MessageBox{message = "Sonic: Hey kid! {p50}Wait up!", blocking = true, closeAction = Wait(1)},
			},
			
			Do(function()
				GameState.leader = "sonic"
				scene.player:updateSprite()
				scene.player:addSceneHandler("update", EscapePlayerVert.update)
				scene.player.sprite.visible = true
				scene.player.dropShadow.sprite.visible = true
				scene.player.sprite:setAnimation("juiceup")
			end),
			
			YieldUntil(function() return scene.player.y < 0 and not scene.player.dead end)
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
