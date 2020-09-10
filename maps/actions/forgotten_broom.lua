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
	if GameState:isFlagSet("met_b") then
		if not scene.objectLookup.B:isRemoved() then
			scene.objectLookup.B:remove()
			scene.objectLookup.R:remove()
			scene.objectLookup.T:remove()
			scene.objectLookup.P:remove()
			scene.objectLookup.J:remove()
			if scene.powerring then
				scene.powerring:remove()
			end
			for _, s in pairs(scene.splitSprites or {}) do
				s:remove()
			end
			scene.player.cinematicStack = 0
		end
		return Action()
	end

	scene.player.cinematicStack = scene.player.cinematicStack + 1
	scene.player.sprite.visible = false
	
	-- Hack to reposition split
	scene.player.y = scene.player.y - 210
	local walkout, walkin, sprites = scene.player:split()
	scene.player.y = scene.player.y + 210

	return Serial {
		AudioFade("music", 1, 0, 1),
		
		Wait(1),
		
		PlayAudio("music", "btheme", 1.0, true),	
			
		MessageBox{message="Purple Robian: {p30}.{p30}.{p30}. I'm sorry Uncle B.", blocking=true},
		
		Wait(0.5),
		
		MessageBox{message="Blue Robian: You tried your best, R...", blocking=true},
		MessageBox{message="Blue Robian: ...B's forgetting 'as just spread too quickly...", blocking=true},
		
		Wait(0.5),
		
		MessageBox{message="Yellow Robian: Yeah, B would've been proud of you, kiddo.", blocking=true},
		
		AudioFade("music", 1.0, 0.0, 2),
		Do(function()
			scene.player.sprite.visible = true
			scene.player.noIdle = true
			scene.player.state = "walkup"
			scene.player.sprite:setAnimation("walkup")
		end),
		
		Ease(scene.player, "y", scene.player.y - 150, 1.5, "linear"),
		
		Do(function()
			scene.player.noIdle = false
		end),
		
		walkout,
		
		Animate(sprites.sonic.sprite, "idleup"),
		Animate(sprites.sally.sprite, "idleup"),		
		
		-- Sonic and sally hop
		Parallel {
			Ease(sprites.sonic, "y", sprites.sonic.y - 50, 7, "linear"),
			Ease(sprites.sally, "y", sprites.sally.y - 50, 7, "linear")
		},
		Parallel {
			Ease(sprites.sonic, "y", sprites.sonic.y, 7, "linear"),
			Ease(sprites.sally, "y", sprites.sally.y, 7, "linear")
		},
		
		-- All robians hop in surprise
		Parallel {
			Ease(scene.objectLookup.R, "y", scene.objectLookup.R.y - 50, 7, "linear"),
			Ease(scene.objectLookup.T, "y", scene.objectLookup.T.y - 50, 7, "linear"),
			Ease(scene.objectLookup.P, "y", scene.objectLookup.P.y - 50, 7, "linear"),
			Ease(scene.objectLookup.J, "y", scene.objectLookup.J.y - 50, 7, "linear")
		},
		Parallel {
			Ease(scene.objectLookup.R, "y", scene.objectLookup.R.y, 7, "linear"),
			Ease(scene.objectLookup.T, "y", scene.objectLookup.T.y, 7, "linear"),
			Ease(scene.objectLookup.P, "y", scene.objectLookup.P.y, 7, "linear"),
			Ease(scene.objectLookup.J, "y", scene.objectLookup.J.y, 7, "linear")
		},
		
		Animate(scene.objectLookup.R.sprite, "idleright"),
		Animate(scene.objectLookup.T.sprite, "tdown"),
		Animate(scene.objectLookup.P.sprite, "pdown"),
		
		Wait(0.5),
		
		PlayAudio("music", "follow", 1.0, true),
		MessageBox{message="Yellow Robian: Mobians?!", blocking=true},
		
		Animate(scene.objectLookup.T.sprite, "tdowncross"),
		MessageBox{message="Green Robian: What are they doing here?!", blocking=true},
		
		MessageBox{message="Purple Robian: ...{p30}I think they followed me here.", blocking=true},
		
		AudioFade("music", 1.0, 0.0, 2),
		MessageBox{message="Green Robian: And Robotnik will no doubt follow them!", blocking=true},
		MessageBox{message="Green Robian: You Mobians must leave at once!", blocking=true},
		MessageBox{message="Sonic: Hey, hey, hey! {p40}We don't want to cause any trouble here. We just came to ask for directions.", blocking=true},
		
		MessageBox{message="Sally: Please...{p40} Robotnik captured our friend. {p40}We need to save him, before it's too late.", blocking=true},
		
		PlayAudio("music", "sonicsad", 1.0, true, true),
		MessageBox{message="Green Robian: ...", blocking=true},
		MessageBox{message="Green Robian: Unfortunately... {p30}B here is the only person with that knowledge.", blocking=true},
		MessageBox{message="Sonic: Why 'unfortunately'?", blocking=true},
		MessageBox{message="Green Robian: ...", blocking=true},
		MessageBox{message="Blue Robian: B is...", blocking=true},
		MessageBox{message="Blue Robian: He uh... {p40}W-Well we're all in the same boat actually...{p40} ya see we{p30}.{p30}.{p30}.", blocking=true, closeAction=Wait(1)},
		MessageBox{message="Purple Robian: We forget stuff.", blocking=true},
		MessageBox{message="Blue Robian: Right.", blocking=true},
		
		Animate(sprites.sonic.sprite, "thinking"),
		MessageBox{message="Sonic: Huh?", blocking=true},
		MessageBox{message="Green Robian: It's the price we pay for liberation from Robotnik's mind control.", blocking=true},
		MessageBox{message="Green Robian: We've forgotten our past lives. {p40}We have forgotten our own names. {p40}And we keep forgetting things... {p60}until we become inoperable.", blocking=true},
		
		Animate(sprites.sonic.sprite, "idleup"),
		MessageBox{message="Yellow Robian: We can delay the process a bit. {p40}By swapping out some of our old parts for newer ones, we can buy ourselves some time...", blocking=true},
		MessageBox{message="Yellow Robian: Little R here was out looking for parts for B, when you came upon him.{p50} Seems like ol' B has maybe run out of time though.", blocking=true},
		MessageBox{message="Sally: I can see this is not a good time...{p40} we're sorry to bother you, we will just be on our way then.", blocking=true},
		Wait(0.5),
		
		Parallel {
			Serial {
				Move(sprites.sally, scene.objectLookup.Waypoint2, "walk", 1),
				Animate(sprites.sally.sprite, "idledown")
			},
			Serial {
				Wait(0.5),
				Animate(sprites.sonic.sprite, "idledown"),
				MessageBox{message="Sonic: Hold up, Sal!", blocking=true, closeAction=Wait(1)}
			}
		},
		Animate(sprites.sonic.sprite, "idleup"),
		MessageBox{message="Sonic: Yo, robos! {p30}I think I might be able to help B.", blocking=true},
		
		Animate(sprites.sally.sprite, "idleup"),
		
		-- R hop
		Ease(scene.objectLookup.R, "y", scene.objectLookup.R.y - 50, 7, "linear"),
		Ease(scene.objectLookup.R, "y", scene.objectLookup.R.y, 7, "linear"),
		MessageBox{message="Purple Robian: Really?!", blocking=true},
		MessageBox{message="Green Robian: How?!", blocking=true},

		Move(sprites.sally, scene.objectLookup.Waypoint3, "walk", 1),
		Animate(sprites.sally.sprite, "idleleft"),
		MessageBox{message="Sally: *Ahem. {p40}What are you doing Sonic?*", blocking=true},
		MessageBox{message="Sonic: *Trust me on this.*", blocking=true},
		
		AudioFade("music", 1, 0, 2),
		
		Do(function()
			-- Make Sonic appear above B
			sprites.sonic.sprite.sortOrderY = 9999
		end),
		Move(sprites.sonic, scene.objectLookup.Waypoint),
		
		Animate(scene.objectLookup.R.sprite, "idleup"),
		Animate(scene.objectLookup.T.sprite, "tleftcross"),
		Animate(scene.objectLookup.P.sprite, "pleft"),
		Animate(sprites.sonic.sprite, "idleleft"),
		
		Wait(1),
		
		MessageBox{message="Sonic: *If this worked for Uncle Chuck, I bet it'll work for B.*", blocking=true, closeAction=Wait(2)},

		Animate(sprites.sonic.sprite, "getring"),
		Animate(sprites.sonic.sprite, "holdring"),
		
		Do(function()
			scene.powerring = SpriteNode(
				scene,
				Transform.relative(sprites.sonic.sprite.transform, Transform(-8, sprites.sonic.sprite.h + 6)),
				nil,
				"powerring",
				nil,
				nil,
				"objects"
			)
			scene.powerring.sortOrderY = 8888
		end),
		Animate(sprites.sonic.sprite, "sadleft"),
		Wait(0.8),
		Do(function()
			scene.powerring.transform = Transform.relative(sprites.sonic.sprite.transform, Transform(-15, sprites.sonic.sprite.h + 5))
			
			Executor(scene):act(Serial {
				Animate(scene.powerring, "shimmer"),
				Animate(scene.powerring, "idle")
			})
		end),
		Animate(sprites.sonic.sprite, "sadlefthand"),
		
		Wait(1),
		
		Parallel {
			PlayAudio("music", "bremembers", 1.0),
			
			Serial {
				Parallel {
					Ease(scene.objectLookup.B.sprite.color, 1, 512, 0.5, "linear"),
					Ease(scene.objectLookup.B.sprite.color, 2, 512, 0.5, "linear")
				},
				Wait(2),
				Parallel {
					Ease(scene.objectLookup.B.sprite.color, 1, 255, 0.5, "linear"),
					Ease(scene.objectLookup.B.sprite.color, 2, 255, 0.5, "linear")
				}
			},
			
			Serial {
				Animate(scene.objectLookup.B.sprite, "wakeup1"),
				Animate(scene.objectLookup.B.sprite, "wakeup2"),
				Animate(scene.objectLookup.B.sprite, "wakeup3"),
				Animate(scene.objectLookup.B.sprite, "wakeup4"),
				Animate(scene.objectLookup.B.sprite, "wakeup"),
				Animate(scene.objectLookup.B.sprite, "awake")
			}
		},
		MessageBox{message="B: ...", blocking=true, closeAction=Wait(1.5)},
		Do(function()
			scene.powerring.transform = Transform.relative(sprites.sonic.sprite.transform, Transform(-8, sprites.sonic.sprite.h + 6))
		end),
		Animate(sprites.sonic.sprite, "idleleft"),
		
		PlayAudio("music", "bheart", 1.0, true),
		Animate(scene.objectLookup.B.sprite, "lookright"),
		MessageBox{message="B: W-W-What happened?...{p40}Where am I?", blocking=true, closeAction=Wait(2.5)},
		
		-- All robians hop in surprise
		Parallel {
			Ease(scene.objectLookup.R, "y", scene.objectLookup.R.y - 50, 7, "linear"),
			Ease(scene.objectLookup.T, "y", scene.objectLookup.T.y - 50, 7, "linear"),
			Ease(scene.objectLookup.P, "y", scene.objectLookup.P.y - 50, 7, "linear"),
			Ease(scene.objectLookup.J, "y", scene.objectLookup.J.y - 50, 7, "linear")
		},
		Parallel {
			Ease(scene.objectLookup.R, "y", scene.objectLookup.R.y, 7, "linear"),
			Ease(scene.objectLookup.T, "y", scene.objectLookup.T.y, 7, "linear"),
			Ease(scene.objectLookup.P, "y", scene.objectLookup.P.y, 7, "linear"),
			Ease(scene.objectLookup.J, "y", scene.objectLookup.J.y, 7, "linear")
		},
		
		MessageBox{message="Purple Robian: *gasp*!", blocking=true, closeAction=Wait(1)},
		MessageBox{message="Blue Robian: Blimey!", blocking=true, closeAction=Wait(1)},
		MessageBox{message="Green Robian: Incredible!", blocking=true, closeAction=Wait(1)},
		MessageBox{message="Yellow Robian: We thought we lost ya there, B!", blocking=true, closeAction=Wait(2)},

		Do(function()
			GameState:setFlag("met_b")
			
			scene.splitSprites = sprites

			scene.sceneMgr:switchScene {
				class = "BasicScene",
				mapName = "maps/forgottenhideout.lua",
				map = scene.maps["maps/forgottenhideout.lua"],
				maps = scene.maps,
				region = scene.region,
				spawn_point = "Spawn 2",
				spawn_point_offset = Transform(),
				fadeInSpeed = 0.2,
				fadeOutSpeed = 0.2,
				images = scene.images,
				animations = scene.animations,
				audio = scene.audio,
				doingSpecialMove = false,
				cache = true
			}
		end)
	}
end
