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
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"
local EscapeObstacle = require "object/EscapeObstacle"
local EscapeHoverbot = require "object/EscapeHoverbot"
local EscapeIndicator = require "object/EscapeIndicator"

local SpriteNode = require "object/SpriteNode"
local BasicNPC = require "object/BasicNPC"
local EscapePlayer = require "object/EscapePlayer"


return function(scene)
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(2),
		MessageBox {message="Robotnik: T-T-That hedgehog!!", closeAction=Wait(1)},
		Do(function() scene.objectLookup.Robotnik.sprite:setFadeWhite(0.5) end),
		MessageBox {message="Robotnik: Wait... {p20}no... {p40}no... {p30}NO!", textSpeed=3, closeAction=Wait(0.5)},
		Ease(scene.objectLookup.Robotnik.sprite.color, 4, 0, 3),
		Wait(1),
		Do(function()
			scene:changeScene{map="boulderbay_epilogue", fadeInSpeed=1, fadeOutSpeed=1, fadeWhite=true}
		end)
	}
end
