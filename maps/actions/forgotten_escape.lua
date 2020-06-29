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

local BasicNPC = require "object/BasicNPC"
local EscapeObstacle = require "object/EscapeObstacle"
local EscapeHoverbot = require "object/EscapeHoverbot"
local EscapeIndicator = require "object/EscapeIndicator"

local EscapePlayerVert = require "object/EscapePlayerVert"

local TARGET_OFFSET_X = 400

return function(scene)
	local targetX = function()
		--[[if hoverbot1.x > scene.player.x then
			return hoverbot1.x + TARGET_OFFSET_X
		else
			return math.max(scene.player.x, hoverbot1.x + TARGET_OFFSET_X)
		end]]
		return 0
	end
	
	scene.dead = false
	
	GameState.leader = "sonic"
	scene.player:updateSprite()
	
	return While(
		function()
			return not scene.playerDead
		end,
		
		Serial {
			Wait(2),
			
			Do(function()
				scene.player.cinematic = true
				scene.player.sprite:setAnimation("juiceup")
				scene.player.ignoreSpecialMoveCollision = true
				scene.player:addSceneHandler("update", EscapePlayerVert.update)
			end),
			
			Wait(0.5),
			
			Do(function()
				scene.audio:setMusicVolume(1.0)
			end),
			PlayAudio("music", "sonictheme", 1.0, true),
			
			Do(function()
				scene.player.cinematic = false
				scene.player.ignoreSpecialMoveCollision = false
			end),
			
			Do(function()
				scene.audio:setMusicVolume(1.0)
			end),
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				scene.indicators = {}
				--table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 500))
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			Wait(2),
			
			-- Alert ahead of obstacle		
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				--table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 650))
				--table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 750))
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			Wait(2),
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				for y=0,3 do
					--table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 550 + y*61))
				end
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			
			Wait(1),
			
			
			Wait(1),
			
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				for y=0,3 do
					--table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 400 + y*61))
				end
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
			
			Wait(1),
			
			
			Wait(1),
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				for y=0,6 do
					if y <= 2 or y >= 6 then
						--table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 400 + y*61))
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
			
			
			Wait(3),
			
			-- Alert ahead of obstacle
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				for y=0,2 do
					--table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 350 + y*61))
					--table.insert(scene.indicators, EscapeIndicator.place(scene, hoverbot1.layer, 550 + y*61))
				end
			end),
			Wait(1),
			Do(function()
				for _, indicator in pairs(scene.indicators) do
					indicator:remove()
				end
				scene.indicators = {}
			end),
			
		},
		
		Serial {
			--scene.player:die(),
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
