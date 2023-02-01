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
local Move = require "actions/Move"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local BlockPlayer = require "actions/BlockPlayer"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"

return function(scene, hint)
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Animate(scene.objectLookup.R.sprite, "sadleft"),
		Wait(1.5),
		PlayAudio("music", "bleaves2", 1.0, true),
		scene.objectLookup.J:hop(),
		MessageBox{message="J: We'll miss you B!", closeAction=Wait(1.5)},
		scene.objectLookup.T:hop(),
		MessageBox{message="T: Stay safe out there.", closeAction=Wait(1.5)},
		scene.objectLookup.P:hop(),
		MessageBox{message="P: Take care of yourself old timer!", closeAction=Wait(1.5)},
		Wait(0.5),
		MessageBox{message="R: *sniff*", closeAction=Wait(1.5)},
		Wait(0.5),
		MessageBox{message="B: Worry not my family, I will be back before you know it.", closeAction=Wait(2)},
		MessageBox{message="B: And if what the Princess says about Knothole is true, it will be to guide us to a safer home!", closeAction=Wait(3)},
		
		MessageBox{message="Sonic: Ready, B?", closeAction=Wait(1)},
		MessageBox{message="B: Ready.", closeAction=Wait(1)},
		
		--[[Animate(sprites.sonic.sprite, "idleleft"),
		Wait(1),
		Ease(scene.objectLookup.R, "y", function() return scene.objectLookup.R.y - 50 end, 8),
		Ease(scene.objectLookup.R, "y", function() return scene.objectLookup.R.y + 50 end, 8),
		MessageBox{message="R: I-I did it!! {p60}I won!"},]]
	}
end
