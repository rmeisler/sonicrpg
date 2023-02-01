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
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"

return function(scene)
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	return Serial {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(3),
		Ease(scene.objectLookup.R, "y", scene.objectLookup.R.y - 100, 1, "linear"),
		Animate(scene.objectLookup.R.sprite, "idleup"),
		Animate(scene.objectLookup.B.sprite, "packupidle"),
		Animate(scene.objectLookup.B.sprite, "packupstand"),
		Wait(0.5),
		Animate(scene.objectLookup.B.sprite, "idledown"),
		MessageBox{message="B: Oh{p40}, hello R."},
		Do(function()
			scene.objectLookup.R.sprite:setAnimation("walkup")
		end),
		Parallel {
			Ease(scene.objectLookup.R, "x", scene.objectLookup.R.x + 15, 1, "linear"),
			Ease(scene.objectLookup.R, "y", scene.objectLookup.R.y - 280, 1, "linear")
		},
		Animate(scene.objectLookup.B.sprite, "lookdown"),
		Animate(scene.objectLookup.R.sprite, "hug"),
		PlayAudio("music", "bleaves", 1.0, true),
		MessageBox{message="B: R! {p40}What's gotten into you?", closeAction=Wait(2)},
		MessageBox{message="R: Please... {p60}don't go...", textspeed=1, closeAction=Wait(2.5)},
		MessageBox{message="B: ...R... {p60}I assure you, you will be alright.", closeAction=Wait(2.5)},
		MessageBox{message="R: I'm not worried about me, I'm worried about you!", closeAction=Wait(2)},
		MessageBox{message="R: What if something happens to you on your way to\nKnothole? {p40}What if Robotnik captures you and the\nFreedom Fighters?", closeAction=Wait(2)},
		MessageBox{message="R: What if...{p60} what if he makes you forget us...", textspeed=1, closeAction=Wait(3)},
		Do(function()
			scene.objectLookup.B.x = scene.objectLookup.B.x - 30
			scene.objectLookup.B.y = scene.objectLookup.B.y + 6
		end),
		Animate(scene.objectLookup.B.sprite, "kneelright"),
		Animate(scene.objectLookup.R.sprite, "sadleft"),
		MessageBox{message="B: R{p40}, no matter what that evil dictator does to me, I will never forget you.", textspeed=3, closeAction=Wait(3)},
		MessageBox{message="R: *sniff* {p60}You promise?", textspeed=1, closeAction=Wait(2)},
		Parallel
		{
			MessageBox{message="B: You have my word.", textspeed=1, closeAction=Wait(3)},
			Serial {
				Wait(2),
				Do(function()
					scene:changeScene{map="forgottenhideout", fadeOutSpeed=0.1, fadeInSpeed=0.5}
				end)
			}
		}
	}
end
