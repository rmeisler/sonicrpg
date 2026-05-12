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
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"5 days earlier...",
		100
	)

	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Animate(scene.objectLookup.R.sprite, "sadleft"),
		Wait(1),
		Spawn(Serial {
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		}),
		Wait(4),
		PlayAudio("music", "bleaves", 1.0, true),
		scene.objectLookup.J:hop(),
		MessageBox{message="J: We'll miss you B!", closeAction=Wait(2)},
		Wait(0.5),
		scene.objectLookup.T:hop(),
		MessageBox{message="T: Stay safe out there.", closeAction=Wait(2)},
		Wait(0.5),
		scene.objectLookup.P:hop(),
		MessageBox{message="P: Take care of yourself old timer!", closeAction=Wait(2)},
		Wait(0.5),
		MessageBox{message="R: *sniff* ...", closeAction=Wait(2)},
		Wait(0.5),
		Animate(scene.objectLookup.B.sprite, "kneel_worry"),
		MessageBox{message="B: There there, my boy...", closeAction=Wait(2)},
		Wait(0.5),
		MessageBox{message="R: But what if you forget about us, Uncle B?", closeAction=Wait(3)},
		Wait(0.5),
		Animate(scene.objectLookup.B.sprite, "kneel"),
		MessageBox{message="B: Our new friends will be there to remind me.", closeAction=Wait(3)},
		Wait(1),
		Animate(scene.objectLookup.B.sprite, "idleup"),
		MessageBox{message="B: I'll be back soon, everyone. {p60}I just need to determine if {h Knothole} can be a safe place for us.", closeAction=Wait(3.5)},
		Animate(scene.objectLookup.B.sprite, "idledown"),
		Wait(0.5),
		Do(function()
			scene.objectLookup.B.sprite:setAnimation("walkdown")
		end),
		Spawn(
			Parallel {
				Move(scene.objectLookup.B, scene.objectLookup.B_WP, "walk"),
				Serial {
					Wait(1),
					Parallel {
						Move(scene.objectLookup.Sonic, scene.objectLookup.Sonic_WP, "walk"),
						Move(scene.objectLookup.Sally, scene.objectLookup.Sally_WP, "walk")
					}
				}
			}
		),
		Wait(2),
		Do(function()
			scene.exiting = true
			scene.sceneMgr:switchScene {class = "ChapterSplashScene", manifest = "maps/ep6manifest.lua", fadeInSpeed=0.2, fadeOutSpeed=0.2, fadeOutMusic=true}
		end)
	}
end