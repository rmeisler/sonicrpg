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
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	
	GameState:addToParty("sonic", 99, true)
	GameState.leader = "sonic"
	
	scene.objectLookup.R.stopMoving = true
	
	return While(
		function()
			return not scene.playerDead
		end,
		
		Serial {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Animate(scene.objectLookup.Sally.sprite, "thinking_laugh"),

			Wait(2),
			
			Animate(scene.objectLookup.Sonic.sprite, "prepare_race"),
			MessageBox {message="Sonic: Wish me luck!", closeAction=Wait(0.5)},
			Parallel {
				MessageBox {message="J: On your mark... {p80}get set... {p80}{h GO}!", closeAction=Wait(1)},
				Serial {
					Wait(1),
					Do(function() scene.objectLookup.R.sprite:setAnimation("dashright_goggles") end),
					Wait(1),
					PlayAudio("sfx", "sonicrun", 1.0, true, false, true),
					PlayAudio("music", "sonicrace", 1.0, true, true),
					Animate(scene.objectLookup.Sonic.sprite, "chargerun1"),
					Do(function() scene.objectLookup.Sonic.sprite:setAnimation("chargerun2") end),
					Wait(1.2),
			
					Do(function()
						scene.player:addSceneHandler("update", EscapePlayer.update)
						scene.player.x = scene.objectLookup.Sonic.x + scene.player.width
						scene.player.y = scene.objectLookup.Sonic.y + scene.player.height
						scene.player.sprite.visible = true
						scene.player.dropShadow.hidden = false
						scene.player.bx = 10

						scene.objectLookup.R.stopMoving = false
						scene.objectLookup.R.bx = -20
						scene.objectLookup.Sonic:remove()
					end)
				}
			},
			
			--[[YieldUntil(function()
				return scene.player.x > 500
			end),]]
			
			Wait(100)
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
