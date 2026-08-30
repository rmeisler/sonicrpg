local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local WaitForFrame = require "actions/WaitForFrame"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Move = require "actions/Move"
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

local BasicNPC = require "object/BasicNPC"
local EscapeObstacle = require "object/EscapeObstacle"
local EscapeHoverbot = require "object/EscapeHoverbot"
local EscapeIndicator = require "object/EscapeIndicator"

local SpriteNode = require "object/SpriteNode"
local EscapePlayer = require "object/EscapePlayer"

local TARGET_OFFSET_X = 400

return function(scene)
	scene.bgColor = {255,255,255,255}
	
	return While(
		function()
			return not scene.playerDead
		end,
		
		Serial {
			Wait(2),
			
			PlayAudio("music", "sonicscared2", 1.0, true),
			
			Do(function()
				scene.player.cinematic = true
				scene.player.sprite:pushOverride("juiceright", "juicescaredright")
				scene.player.sprite:pushOverride("juiceupright", "juicescaredupright")
				scene.player.sprite:pushOverride("juicedownright", "juicescareddownright")
				scene.player.sprite:setAnimation("juiceright")
				scene.player.ignoreSpecialMoveCollision = true
				scene.player:addSceneHandler("update", EscapePlayer.update)
			end),
			
			YieldUntil(function()
				return scene.player.x > 500
			end),
			
			Do(function()
				scene.player.cinematic = false
				scene.player.ignoreSpecialMoveCollision = false
			end),
			
			Wait(1),
			MessageBox{message="Sally: Sonic! {p80}You're going the wrong way!", closeAction=Wait(2)},
			
			--Wait(100),
			Wait(3),
			AudioFade("music", 1, 0, 1),
			
			Do(function()
				scene.player:removeSceneHandler("update", EscapePlayer.update)
				scene.player.sprite:setAnimation("shock")
				scene.objectLookup.Snively.hidden = false
				scene.objectLookup.Snively.sprite.sortOrderY = 10000
				scene.objectLookup.Cheetah.hidden = false
				scene.player.x = scene.objectLookup.Cheetah.x
				scene.player.y = scene.objectLookup.Cheetah.y
			end),

			Parallel {
				Ease(scene.player, "x", function() return scene.player.x + 800 end, 1, "linear"),
				Ease(scene.player, "y", function() return scene.player.y + 600 end, 0.5)
			},
			
			Wait(2),
			
			MessageBox{message="YES!!!", textSpeed=3, closeAction=Wait(2)},
			Parallel {
				Serial {
					Move(scene.objectLookup.Snively, scene.objectLookup.SnivelyWP, "walk"),
					Animate(scene.objectLookup.Snively.sprite, "idleright_smile")
				},
				Ease(scene.camPos, "x", 600, 0.2)
			},

			Wait(1),
			PlayAudio("music", "wearefucked", 1, true),
			MessageBox{message="Snively: You've done very well, my pet. {p120}The Princess\nand her hedgehog will be hopelessly trapped down there...\n{p120}in the {h robot wasteland}...", textSpeed=3, closeAction=Wait(5)},
			Wait(1),			
			Animate(scene.objectLookup.Snively.sprite, "idleright_lookleft"),
			MessageBox{message="Snively: ...{p80}can't have the big round guy finding out\nabout this, though...", textSpeed=3, closeAction=Wait(3)},
			Do(function() scene.objectLookup.Snively.sprite:setAnimation("stepback_left") end),
			Ease(scene.objectLookup.Snively, "x", function() return scene.objectLookup.Snively.x - 25 end, 1, "linear"),
			Animate(scene.objectLookup.Snively.sprite, "prep_kick"),
			Parallel {
				Animate(scene.objectLookup.Snively.sprite, "kick"),
				Ease(scene.objectLookup.Snively, "x", function() return scene.objectLookup.Snively.x + 70 end, 4),
				Serial {
					Wait(0.2),
					PlayAudio("sfx", "smack", 1, true),
					Animate(scene.objectLookup.Cheetah.sprite, "kicked"),
					Parallel {
						Ease(scene.objectLookup.Cheetah, "x", function() return scene.objectLookup.Cheetah.x + 80 end, 1, "linear"),
						Ease(scene.objectLookup.Cheetah, "y", function() return scene.objectLookup.Cheetah.y - 100 end, 3),
					},
					Ease(scene.objectLookup.Cheetah, "x", function() return scene.objectLookup.Cheetah.x + 80 end, 1.5, "linear"),
					Parallel {
						Ease(scene.objectLookup.Cheetah, "x", function() return scene.objectLookup.Cheetah.x + 80 end, 3, "linear"),
						Ease(scene.objectLookup.Cheetah, "y", function() return scene.objectLookup.Cheetah.y + 600 end, 5),
					}
				}
			},
			Do(function() scene.objectLookup.Snively.sprite:setAnimation("idleright_laugh") end),
			Wait(2),
			TypeText(
				Transform(50, 300),
				{255, 255, 255, 255},
				FontCache.Techno,
				"TO BE CONTINUED...",
				3
			),
			Wait(3),
			Do(function()
				scene.sceneMgr:pushScene {class = "CreditsSplashScene"}
			end)

			
			-- TO BE CONTINUED

			--,
			
			--[[ Target behavior
			Do(function()
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 300))
			end),
			
			Wait(5),
			
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 200))
			end),
			
			Wait(5),
			
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 400))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 100))
			end),
			
			Wait(5),
			
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 300))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 150))
			end),
			
			Wait(6),
			
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 400))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 350))
			end),
			Wait(1),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 300))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 250))
			end),
			Wait(1),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 200))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 150))
			end),
			Wait(1),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 100))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 50))
			end),
			
			
			Wait(6),
			
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 400))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 50))
			end),
			Wait(0.5),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 300))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 150))
			end),
			Wait(0.5),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene:getMapHeight() - 200))
				hoverbot2:fire(Transform(targetX(), scene:getMapHeight() - 100))
			end),
			
			Wait(4),
			
			-- Spawn obstacle props
			Do(function()
				for i=0,10 do
					local obstacle = BasicNPC(
						scene,
						{name = "objects"},
						{name = "obstacle1", x = hoverbot1.x + 900 + i * 88, y = 350, width = 88, height = 61,
							properties = {nocollision = true, sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
						}
					)
					scene:addObject(obstacle)
					
					local obstacle = BasicNPC(
						scene,
						{name = "objects"},
						{name = "obstacle1", x = hoverbot1.x + 900 + i * 88, y = 800, width = 88, height = 61,
							properties = {nocollision = true, sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
						}
					)
					scene:addObject(obstacle)
				end
			end),
			
			Wait(1),
			
			-- Spawn mock obstacle
			Do(function()
				hoverbot2.offsetX = 1
				local obstacle = EscapeObstacle(
					scene,
					{name = "objects"},
					{name = "obstacle1", x = hoverbot1.x + 4500, y = 455, width = 88, height = 61,
						properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
					}
				)
				scene:addObject(obstacle)
				scene.objectLookup.obstacle1 = obstacle
			end),
			
			YieldUntil(
				function()
					return scene.objectLookup.obstacle1.x - scene.objectLookup.obstacle1.sprite.w*2 < hoverbot2.x
				end
			),
			
			-- Hoverbot explode
			Do(function()
				scene.audio:playSfx("explosion2", 1.0)
				hoverbot2:run {
					Animate(hoverbot2.sprite, "crashright"),
					Animate(hoverbot2.sprite, "idlecrashright", true)
				}
				hoverbot2.offsetX = 0
				hoverbot2.stopMoving = true
			end),
			
			Wait(1),
			
			-- Remaining hoverbot gets serious
			Parallel {
				Do(function()
					hoverbot1.offsetX = 1
				end),
				Ease(hoverbot1, "y", hoverbot1.y - 100, 1, "linear")
			},
			Do(function()
				hoverbot1.offsetX = 0
				hoverbot1.followPlayerY = true
				scene.player.hoverbotOffset = 280
				TARGET_OFFSET_X = 350
			end),
			
			Wait(2),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			Wait(1),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			Wait(1),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				scene.indicators = {}
				table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 500))
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			-- Spawn obstacles for player
			Do(function()
				scene.audio:stopSfx("alert")
				
				for i=0,3 do
					local obstacle = EscapeObstacle(
						scene,
						{name = "objects"},
						{name = "obstacle1", x = hoverbot1.x + 900 + i*88, y = 500, width = 32, height = 32,
							properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
						}
					)
					scene:addObject(obstacle)
				end
			end),
			
			Wait(2),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			Wait(1),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			
			-- Alert ahead of obstacle		
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 650))
				table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 750))
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			-- Spawn obstacles for player
			Do(function()
				scene.audio:stopSfx("alert")
				
				for i=0,3 do
					local obstacle = EscapeObstacle(
						scene,
						{name = "objects"},
						{name = "obstacle2", x = hoverbot1.x + 900 + i*88, y = 650, width = 32, height = 32,
							properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
						}
					)
					scene:addObject(obstacle)
					
					local obstacle = EscapeObstacle(
						scene,
						{name = "objects"},
						{name = "obstacle3", x = hoverbot1.x + 900 + i*88, y = 750, width = 32, height = 32,
							properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
						}
					)
					scene:addObject(obstacle)
				end
			end),
			
			Wait(2),
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				for y=0,3 do
					table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 550 + y*61))
				end
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			-- Spawn obstacles for player
			Do(function()
				scene.audio:stopSfx("alert")
				
				for x=0,3 do
					for y=0,3 do
						local obstacle = EscapeObstacle(
							scene,
							{name = "objects"},
							{name = "obstacle4."..tostring(y), x = hoverbot1.x + 900 + x*88, y = 550 + y*61, width = 32, height = 32,
								properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
							}
						)
						scene:addObject(obstacle)
					end
				end
				
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			
			Wait(1),
			
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			
			Wait(1),
			
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				for y=0,3 do
					table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 400 + y*61))
				end
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			-- Spawn obstacles for player
			Do(function()
				scene.audio:stopSfx("alert")
				
				for x=0,3 do
					for y=0,3 do
						local obstacle = EscapeObstacle(
							scene,
							{name = "objects"},
							{name = "obstacle5."..tostring(y), x = hoverbot1.x + 900 + x*88, y = 400 + y*61, width = 32, height = 32,
								properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
							}
						)
						scene:addObject(obstacle)
					end
				end
				
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			
			Wait(1),
			
			Do(function()
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			
			Wait(1),
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				for y=0,6 do
					if y <= 2 or y >= 6 then
						table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 400 + y*61))
					end
				end
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			-- Spawn obstacles for player
			Do(function()
				scene.audio:stopSfx("alert")
				
				for x=0,3 do
					for y=0,6 do
						if y <= 2 or y >= 6 then
							local obstacle = EscapeObstacle(
								scene,
								{name = "objects"},
								{name = "obstacle5."..tostring(y), x = hoverbot1.x + 900 + x*88, y = 400 + y*61, width = 32, height = 32,
									properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
								}
							)
							scene:addObject(obstacle)
						end
					end
				end
				
				hoverbot1:fire(Transform(targetX(), scene.player.y), true)
			end),
			
			Wait(3),
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				for y=0,2 do
					table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 350 + y*61))
					table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 550 + y*61))
				end
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			-- Spawn obstacles for player
			Do(function()
				scene.audio:stopSfx("alert")
				
				for x=0,3 do
					for y=0,2 do
						local obstacle = EscapeObstacle(
							scene,
							{name = "objects"},
							{name = "obstacle6."..tostring(y), x = hoverbot1.x + 900 + x*88, y = 350 + y*61, width = 32, height = 32,
								properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
							}
						)
						scene:addObject(obstacle)
						
						local obstacle = EscapeObstacle(
							scene,
							{name = "objects"},
							{name = "obstacle6."..tostring(y), x = hoverbot1.x + 900 + x*88, y = 550 + y*61, width = 32, height = 32,
								properties = {sprite = "art/sprites/heap.png", align = BasicNPC.ALIGN_BOTLEFT}
							}
						)
						scene:addObject(obstacle)
					end
				end
			end),
			
			Wait(4),
			
			Do(function()
				scene.player.cinematic = true
				scene.player.sprite:setAnimation("juiceright")
			end),
			
			Ease(scene.player, "y", 544, 1, "inout"),
			
			Parallel {
				Animate(scene.player.sprite, "juicegrabringright"),
				Serial {
					WaitForFrame(scene.player.sprite, 3),
					Do(function()
						scene.powerring = SpriteNode(
							scene,
							Transform.relative(scene.player.sprite.transform, Transform(scene.player.sprite.w*2 - 35, scene.player.sprite.h)),
							nil,
							"powerring",
							nil,
							nil,
							"objects"
						)
					end),
					Wait(0.1),
					Do(function()
						scene.powerring.transform = Transform.relative(scene.player.sprite.transform, Transform(scene.player.sprite.w*2 - 25, scene.player.sprite.h + 5))
					end),
				}
			},
			
			Do(function()
				scene.audio:playSfx("usering", nil, true)
				hoverbot1.nofollow = true
				scene.powerring.transform = Transform.relative(scene.player.sprite.transform, Transform(scene.player.sprite.w*2 - 10, scene.player.sprite.h + 5))
			end),
			
			Parallel {
				Do(function()
					scene.player.sprite:setAnimation("juiceringright")
				end),
				Ease(scene.player, "fx", function() return scene.player.fx + 30 end, 0.5, "inout"),
				Serial {
					Parallel {
						Ease(scene.player.sprite.color, 1, 512, 0.5, "inout"),
						Ease(scene.player.sprite.color, 2, 512, 0.5, "inout")
					},
					Wait(2),
					Parallel {
						Ease(scene.player.sprite.color, 1, 255, 0.5, "linear"),
						Ease(scene.player.sprite.color, 2, 255, 0.5, "linear")
					},
			
					Do(function()
						scene.player:run {
							Parallel {
								Ease(scene.bgColor, 1, 0, 0.2, "inout"),
								Ease(scene.bgColor, 2, 0, 0.2, "inout"),
								Ease(scene.bgColor, 3, 0, 0.2, "inout"),
								Do(function()
									ScreenShader:sendColor("multColor", scene.bgColor)
								end)
							},
							
							Wait(2),
							
							Do(function()
								scene.sceneMgr:pushScene {class = "CreditsSplashScene"}
							end)
						}
					end),
				}
			},]]
		},
		
		Serial {
			scene.player:die(),
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
