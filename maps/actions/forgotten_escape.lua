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
	scene.player.dead = false
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	
	scene.audio:setVolume("music", 1.0)
	
	GameState:removeFromParty("antoine")
	
	local R = scene.objectLookup.R
	return While(
		function()
			return not scene.player.dead
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
				end),
				
				Repeat(Serial {
					Wait(0.2),
					Do(function()
						local sparkle = BasicNPC(
							scene,
							{name = "objects"},
							{name = "sparkle1", x = R.x + 20, y = R.y + 70, width = 11, height = 11,
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
				}, 40)
			},
			
			Do(function()
				Executor(scene):act(Serial {
					Parallel {
						Serial {
							Move(R, scene.objectLookup.Waypoint7, "dash"),
							Move(R, scene.objectLookup.Waypoint8, "dash"),
							Move(R, scene.objectLookup.Waypoint9, "dash"),
							Move(R, scene.objectLookup.Waypoint10, "dash"),
							Move(R, scene.objectLookup.Waypoint11, "dash"),
							Move(R, scene.objectLookup.Waypoint12, "dash"),
							Move(R, scene.objectLookup.Waypoint13, "dash"),
							Move(R, scene.objectLookup.Waypoint14, "dash"),
							Move(R, scene.objectLookup.Waypoint15, "dash"),
							Move(R, scene.objectLookup.Waypoint16, "dash"),
							Move(R, scene.objectLookup.Waypoint17, "dash"),
							Move(R, scene.objectLookup.Waypoint18, "dash"),
							Move(R, scene.objectLookup.Waypoint19, "dash"),
							Move(R, scene.objectLookup.Waypoint20, "dash"),
							Move(R, scene.objectLookup.Waypoint21, "dash"),
							Move(R, scene.objectLookup.Waypoint22, "dash"),
							Move(R, scene.objectLookup.Waypoint23, "dash"),
							Move(R, scene.objectLookup.Waypoint24, "dash"),
							Move(R, scene.objectLookup.Waypoint25, "dash"),
							Move(R, scene.objectLookup.Waypoint26, "dash"),
							Move(R, scene.objectLookup.Waypoint27, "dash"),
							Move(R, scene.objectLookup.Waypoint28, "dash"),
							Move(R, scene.objectLookup.Waypoint29, "dash"),
							Move(R, scene.objectLookup.Waypoint30, "dash"),
						},
						
						Repeat(Serial {
							Do(function()
								local sparkle = BasicNPC(
									scene,
									{name = "objects"},
									{name = "sparkle1", x = R.x + 20, y = R.y + 70, width = 11, height = 11,
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
							Wait(0.2),
						}, 120)
					},
					Do(function()
						print("R done")
					end)
				})
			end),
			
			Parallel {
				Ease(scene.player, "x", 800, 0.2, "inout"),
				Ease(scene.player, "y", 48032, 0.2, "inout")
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
			
			PlayAudio("music", "sonictheme", 0.5, true),
		
			MessageBox{message = "Sally: Follow the sparks!", blocking = false, closeAction = Wait(1)},

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
