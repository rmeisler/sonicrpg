local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Move = require "actions/Move"
local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local AudioFade = require "actions/AudioFade"
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
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"

return function(scene)
	scene.audio:stopSfx("factoryfloor")

	if not GameState:isFlagSet("robotterminal_enter") then
		scene.player.cinematic = true
		local walkout, walkin, partySprites = scene.player:split()
		partySprites.sally.x = partySprites.sally.x + 50
		partySprites.sally.y = partySprites.sally.y - 50
		partySprites.antoine.x = partySprites.antoine.x + 50
		partySprites.antoine.y = partySprites.antoine.y - 50
		
		return Serial {
			Wait(1),
			walkout,
			MessageBox {message = "Sally: This should be our rendevous point.", blocking = true},
			MessageBox {message = "Antoine: We are having no sign of Sonic?", blocking = true},
			MessageBox {message = "Sally: Not yet. {p50}We'll have to make due.", blocking = true},
			walkin,
			Do(function()
				GameState:setFlag("robotterminal_enter")
				scene.player.cinematic = false
			end)
		}
	elseif GameState:isFlagSet("rover_boss") then
		scene.objectLookup.Door.sprite:setAnimation("open")
		scene.objectLookup.Door:removeCollision()
	
		scene.player.sprite.color[4] = 0
		scene.player.cinematic = true
		return Serial {
			Wait(1),
			Do(function()
				scene.player.state = "juicedown"
			end),
			Parallel {
				Ease(scene.player.sprite.color, 4, 255, 3),
				Ease(scene.player, "y", scene.player.y + 50, 3, "quad")
			},
			Do(function()
				scene.player.state = "idledown"
			end),
			Wait(2),
			-- Sirens
			Do(function()
				scene.player.state = "shock"
			end),
			Wait(1),
			Do(function()
				scene.player.state = "idleright"
				scene.player.ignoreSpecialMoveCollision = true
                scene.player:onSpecialMove()
			end),
			YieldUntil(function() return scene.player.x > scene:getMapWidth() end),
			Wait(1),
			Do(function()
				scene.sceneMgr:switchScene {
					class = "BasicScene",
					mapName = "maps/run1.lua",
					map = scene.maps["maps/run1.lua"],
					spawn_point = "Spawn 1",
					maps = scene.maps,
					region = scene.region,
					images = scene.images,
					animations = scene.animations,
					audio = scene.audio,
					doingSpecialMove = false,
					cache = true
				}
			end)
		}
	elseif GameState:isFlagSet("roboterminal_used") then
		scene.audio:playMusic("patrol", 1.0, true)
		scene.audio:setLooping("music", true)
		scene.objectLookup.Door.sprite:setAnimation("open")
		scene.objectLookup.Door:removeCollision()
	
		return Action()
	else
		scene.audio:playMusic("patrol", 1.0, true)
		scene.audio:setLooping("music", true)
		return Action()
	end
end
