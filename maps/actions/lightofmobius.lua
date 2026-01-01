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
	return BlockPlayer {
		Do(function()
			scene.player.noIdle = true
		end),
		Do(function() scene.player.sprite:setAnimation("idleup") end),
		Wait(3),
		MessageBox {message="Tails: I made it! {p60}I think..."},
		Wait(1),
		PlayAudio("music", "talkingtolight", 1, true, true),
		MessageBox {message="Tails: Is this..."},
		MessageBox {message="Tails: The {h Light of Mobius}?..."},
		Wait(2),
		PlayAudio("sfx", "thelight", 1, true),
		MessageBox {message="Yes.", textSpeed=3},
		Do(function() scene.player.sprite:setAnimation("shock") end),
		
		Ease(scene.player, "y", function() return scene.player.y - 50 end, 8),
		Ease(scene.player, "y", function() return scene.player.y + 50 end, 8),
		
		Wait(2),
		Do(function() scene.player.sprite:setAnimation("sadleft") end),
		MessageBox {message="Tails: This doesn't feel real... {p60}it's like I'm dreaming..."},
		Wait(1),
		MessageBox {message="You are dreaming, {p60}and it is also real.", textSpeed=3},
		Wait(2),
		MessageBox {message="Tails: ..."},
		Wait(2),
		MessageBox {message="You are filled with doubt.", textSpeed=3},
		
		Ease(scene.player, "y", function() return scene.player.y - 50 end, 8),
		Ease(scene.player, "y", function() return scene.player.y + 50 end, 8),

		MessageBox {message="Tails: Of course I am! {p60}This is too much responsibility for a kid!"},
		
		Wait(2),
		MessageBox {message="Tails: I thought I could use your power to wish Robotnik away, but I can't!"},
		MessageBox {message="Tails: My friend, Baby T{p60}, he was only born seven years ago..."},
		MessageBox {message="Tails: If I stop Robotnik's coup from happening ten years ago{p60}, it could prevent Baby T from ever being born!"},
		MessageBox {message="Tails: Maybe then I never meet Sonic or Sally--"},
		MessageBox {message="Tails: Maybe the War Claws win the Great War,{p60} and instead of everyone being roboticized they are\njust gone forever..."},
		
		Ease(scene.player, "y", function() return scene.player.y - 50 end, 8),
		Ease(scene.player, "y", function() return scene.player.y + 50 end, 8),
		
		MessageBox {message="Tails: Ugh! {p60}This is so complicated! {p60}This was supposed to be simpler than Sally's computer virus plan!"},

		Wait(3),
		MessageBox {message="No.", textSpeed=3},
		Do(function() scene.player.sprite:setAnimation("saddown") end),
		MessageBox {message="Tails: Huh?"},
		Wait(1),
		PlayAudio("sfx", "thelight", 1, true),
		MessageBox {message="No to the question you have been dreaming of, but are too afraid to ask.", textSpeed=3},
		Do(function() scene.player.sprite:setAnimation("crydown") end),
		MessageBox {message="Tails: You mean... {p60}'Is my mom still alive?'... {p60}*sniff*"},
		MessageBox {message="She died shortly after her capture.", textSpeed=3},
		MessageBox {message="Tails: O-Oh n-no..."},
		MessageBox {message="It was her wish that you survive.", textSpeed=3},
		MessageBox {message="You fulfilled her dreams by finding family in Knothole.", textSpeed=3},
		Wait(2),
		MessageBox {message="Tails: *sniff* Family..."},
		Do(function() scene.player.sprite:setAnimation("idleup") end),
		Wait(3),
		MessageBox {message="Tails: I know what my wish will be."},
		Wait(2),
		MessageBox {message="Tails: I thought I could use your power to make everything better...{p60} to bring our families back..."},
		MessageBox {message="Tails: But the trials taught me that the bigger the wish I make, the bigger the risk that things could go wrong..."},
		MessageBox {message="Tails: I may not be able to save everyone, but at least I can save Baby T's family..."},
		Wait(2),
		Do(function() scene.player.sprite:setAnimation("pose") end),
		Ease(scene.player, "y", function() return scene.player.y - 50 end, 8),
		Ease(scene.player, "y", function() return scene.player.y + 50 end, 8),
		MessageBox {message="Tails: I wish for Boulder Bay and everyone in it to be returned to the state it was in before Robotnik showed up!"},
		Do(function() scene.player.sprite:setAnimation("idledown") end),
		Wait(2),
		MessageBox {message="It is done.", textSpeed=3},
		MessageBox {message="Something something something the end! EPILOGUE TO BE DONE SOON", textSpeed=3},
	}
end
