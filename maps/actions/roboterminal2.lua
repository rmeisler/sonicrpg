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
	if not GameState:isFlagSet("robotterminal2_enter") then
		GameState:setFlag("robotterminal2_enter")
		scene.player.cinematicStack = scene.player.cinematicStack + 1
		local walkout, walkin, partySprites = scene.player:split()
		for k,v in pairs(partySprites) do
			v.x = v.x + 60
			v.y = v.y - 100
		end
		
		return Serial {
			Wait(2),
			walkout,
			MessageBox {message = "B: Where to now?", blocking = true},
			MessageBox {message = "Sally: We need to find an entrance into the air ducts.", blocking = true},
			walkin,
			Do(function()
				scene.player.cinematicStack = 0
			end)
		}
	else
		scene.audio:stopSfx("factoryfloor")
		scene.objectLookup.Door.sprite:setAnimation("open")
		scene.objectLookup.Door:removeCollision()
		return PlayAudio("music", "infiltration", 1.0, true, true)
	end
end
