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
			MessageBox{message="Sally: Sonic, what are you doing?!{p80} You're going the wrong way!", closeAction=Wait(2)},
			
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
