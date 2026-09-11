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
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"

return function(scene)
	if not GameState:isFlagSet("robotterminal2_enter") then
		GameState:setFlag("robotterminal2_enter")
		local walkout, walkin, partySprites = scene.player:split()
		for k,v in pairs(partySprites) do
			v.x = v.x + 60
			v.y = v.y - 100
		end
		
		return BlockPlayer {
			Do(function()
				scene.player.blocked = true
			end),
			Wait(0.5),
			walkout,
			MessageBox {message = "B: Where to now?"},
			MessageBox {message = "Sally: We need to find an entrance into the air ducts."},
			walkin,
			Do(function()
				scene.player.blocked = false
			end),
		}
	else
		scene.audio:stopSfx("factoryfloor")
		if GameState:isFlagSet(scene.objectLookup.Door) then
			scene.objectLookup.Door.sprite:setAnimation("open")
			scene.objectLookup.Door:removeCollision()
		end
		if GameState:isFlagSet(scene.objectLookup.Fan1) then
			scene.objectLookup.Switch1.sprite:setAnimation("on")
		end
		scene.objectLookup.Boulder.x = 1536
		scene.objectLookup.Boulder.y = 896 - 64
		scene.objectLookup.Boulder.object.x = scene.objectLookup.Boulder.x
		scene.objectLookup.Boulder.object.y = scene.objectLookup.Boulder.y
		scene.objectLookup.Boulder:updateCollision()

		scene.objectLookup.Boulder2.x = 384
		scene.objectLookup.Boulder2.y = 896 - 64
		scene.objectLookup.Boulder2.object.x = scene.objectLookup.Boulder2.x
		scene.objectLookup.Boulder2.object.y = scene.objectLookup.Boulder2.y
		scene.objectLookup.Boulder2:updateCollision()

		scene.objectLookup.Boulder3.x = 96
		scene.objectLookup.Boulder3.y = 864 - 64
		scene.objectLookup.Boulder3.object.x = scene.objectLookup.Boulder3.x
		scene.objectLookup.Boulder3.object.y = scene.objectLookup.Boulder3.y
		scene.objectLookup.Boulder3:updateCollision()

		scene.objectLookup.Boulder4.x = 1888
		scene.objectLookup.Boulder4.y = 896 - 64
		scene.objectLookup.Boulder4.object.x = scene.objectLookup.Boulder4.x
		scene.objectLookup.Boulder4.object.y = scene.objectLookup.Boulder4.y
		scene.objectLookup.Boulder4:updateCollision()

		return PlayAudio("music", "infiltration", 1.0, true, true)
	end
end
