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
	scene.player.cinematicStack = scene.player.cinematicStack + 1
	scene.player.sprite.visible = false

	return Serial {
		AudioFade("music", 1, 0, 1),
		
		Wait(1),
		
		PlayAudio("music", "btheme", 1.0, true),
		MessageBox{message="Child Robian: {p30}.{p30}.{p30}. I'm sorry B.", blocking=true},
		
		Wait(0.5),
		
		MessageBox{message="Green Robian: You tried your best R...", blocking=true},
		MessageBox{message="...B's forgetting has just spread too quickly...", blocking=true},
		
		Wait(0.5),
		
		MessageBox{message="Yellow Robian: Yeah, B would've been proud of you, kiddo.", blocking=true},
		
		Do(function()
			scene.player.sprite.visible = true
			scene.player.noIdle = true
			scene.player.state = "walkup"
		end),
		
		Ease(scene.player, "y", scene.player.y - 100, 1.5, "linear"),
		
		Do(function()
			scene.player.noIdle = false
		end),
		
		-- All robians hop in surprise
		
		MessageBox{message="Yellow Robian: Mobians?!", blocking=true},
		
		MessageBox{message="Green Robian: Why are you here?", blocking=true},
		
		MessageBox{message="Child Robian: ...I think they followed me here.", blocking=true},
		
		MessageBox{message="Green Robian: --And Robotnik may follow them!", blocking=true},
		MessageBox{message="You Mobians must leave at once!", blocking=true},
		
		MessageBox{message="Sonic: Hey, hey, hey! {p30}We don't want to cause any trouble here.", blocking=true},
		MessageBox{message="Sally: We aren't trying to hide here from Robotnik-- we just need help figuring out how to get back to the surface.", blocking=true},
		
		MessageBox{message="Green Robian: ...", blocking=true},
		MessageBox{message="Unfortunately... {p30}our friend B is the only person with that knowledge.", blocking=true},
		MessageBox{message="Sonic: Why 'unfortunately'?", blocking=true},
		MessageBox{message="Green Robian: ...", blocking=true},
		MessageBox{message="Yellow Robian: B's not feeling so well.", blocking=true},
		MessageBox{message="He... {p30}well we're all in the same boat actually...{p30} ya see...", blocking=true},
		MessageBox{message="Child Robian: We forget stuff.", blocking=true},
		
		Animate(scene.player.sprite, "thinking"),
		MessageBox{message="Sonic: Huh?", blocking=true},
		MessageBox{message="Green Robian: The price we pay for liberation from Robotnik's mind control.", blocking=true},
		MessageBox{message="We have forgotten our past lives. We have forgotten our own names. And overtime, we continue to forget things, until we become inoperable.", blocking=true},
		MessageBox{message="Yellow Robian: We can delay the process by swapping out some of our old parts for newer ones...", blocking=true},
		MessageBox{message="That's what little R was out doing. Looking for parts for B.{p30} Seems B has run out of time though.", blocking=true},
		MessageBox{message="Green Robian: So now you understand the problem.{p30} Only B knows how to get back to the surface.", blocking=true},
		--MessageBox{message="", blocking=true},

		Do(function()
			scene.player.cinematicStack = scene.player.cinematicStack - 1
		end)
	}
end
