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
	scene.player.noSonicCrash = false
	
	if (GameState:isFlagSet("b_speech") or
		GameState:isFlagSet("met_b")) and
		not scene.objectLookup.b
	then
		local placeNPC = function(id, x, y, sprite, anim, interact, height, offsetY)
			scene.objectLookup[id] = BasicNPC(
				scene,
				{name = "objects"},
				{
					name = id,
					x = x,
					y = y,
					width = 96,
					height = height or 64,
					properties = {sprite = "art/sprites/"..sprite..".png", defaultAnim = anim, align = "bottom_center", alignOffsetX = 20, alignOffsetY = -32 + (offsetY or 0)}
				}
			)
			scene:addObject(scene.objectLookup[id])
			scene.objectLookup[id]:addInteract(interact)
		end
		placeNPC(
			"b",
			1632,
			2142,
			"b",
			"idledown",
			function(b)
				scene.player:removeKeyHint()
				scene:run {
					MessageBox{message="B: I'm in your debt, Freedom Fighters.", blocking = true},
					MessageBox{message="Sonic: Yo, B. {p50}Maybe you should all come with us. {p50}You would be safe in Knothole and we could keep your guys' minds sharp.", blocking = true},
					Animate(b.sprite, "pose"),
					MessageBox{message="B: Mmm...", blocking = true},
					MessageBox{message="B: That's a very kind offer, but I can't let my people risk the journey.", blocking = true}
				}
			end,
			96,
			-32
		)
		placeNPC(
			"r",
			608,
			1888,
			"r",
			"idleright",
			function(r)
				scene.player:removeKeyHint()
				scene:run(MessageBox{message="R: Thanks for saving uncle B!{p50}\n...Can you bring us more of those \"Power Rings\"?", blocking = true})
			end
		)
		placeNPC(
			"j",
			480,
			1888,
			"p",
			"jdown",
			function(j)
				scene.player:removeKeyHint()
				scene:run {
					MessageBox{message="J: I've read about a beautiful place far away from here called the \"Great Forest\"!", blocking = true},
					MessageBox{message="J: I wanna build a little home there and go on adventures with my #1 mate, R!", blocking = true},
					Animate(scene.objectLookup.r.sprite, "idleleft"),
					MessageBox{message="R: *blush*", blocking = true},
					Animate(scene.objectLookup.r.sprite, "idleright")
				}
			end
		)
		placeNPC(
			"t",
			2880,
			1856,
			"p",
			"tleft",
			function(t)
				scene.player:removeKeyHint()
				scene:run {
					Animate(t.sprite, "tleftcross"),
					MessageBox{message="T: B is as stubborn as a goat! {p50}Even as he nearly dies from attrition, he insists that we are safer down here than anywhere else!", blocking = true},
					MessageBox{message="T: I want to migrate our people to your village of Knothole. {p50}There, we can be safe from Robotnik, and I can study the \"Power Rings\"...", blocking = true},
					MessageBox{message="T: ...{p50}if B would just listen to me...", blocking = true},
					Animate(t.sprite, "tleft")
				}
			end
		)
		placeNPC(
			"p",
			2272,
			1280,
			"p",
			"pdown",
			function(p)
				scene.player:removeKeyHint()
				scene:run {
					MessageBox{message="P: None of us can really remember our full names anymore.", blocking = true},
					MessageBox{message="P: Rather than everyone having partial names then, we all just go by the first letter of our first name--{p50} supposing we can still remember it!", blocking = true}
				}
			end
		)
		scene.objectLookup.LowerDoor.sprite:setAnimation("open")
		scene.objectLookup.LowerDoor:removeCollision()
	end
	
	if GameState:isFlagSet("b_speech") then
		return PlayAudio("music", "bhero", 1.0, true, true)
	end
	
	if GameState:isFlagSet("met_b") then
		scene.player.cinematicStack = scene.player.cinematicStack + 1
	
		return Serial {
			Spawn(Serial {
				PlayAudio("music", "bheart", 1.0),
				PlayAudio("music", "bhero", 1.0, true, true)
			}),
			MessageBox{message="B: I've uploaded maps into Nicole to get you to the cell block where I assume they are holding your friend.", blocking = true},
			
			Parallel {
				MessageBox{message="B: When you're ready to leave, just go through that door...", blocking = true},
				Ease(scene.camPos, "y", 600, 0.5, "inout")
			},
			Ease(scene.camPos, "y", 0, 1, "inout"),
			
			Do(function()
				GameState:setFlag("b_speech")
				scene.player.cinematicStack = 0
			end)
		}
	end
	
	if GameState:isFlagSet("forgotten_enter") then
		return PlayAudio("music", "forgottendiscovery", 1.0, true, true)
	end
	
	scene.player.y = scene.player.y - 340
	local walkout, walkin, sprites = scene.player:split()
	scene.player.y = scene.player.y + 340
	
	scene.player.cinematicStack = 1
	scene.player.sprite:setAnimation("walkup")
	scene.player.noIdle = true

	return Serial {
		PlayAudio("music", "forgottendiscovery", 1.0, true, true),
		
		Wait(2),
		
		Ease(scene.player, "y", scene.player.y - 280, 1, "linear"),
		Do(function()
			scene.player.noIdle = false
			scene.player.sprite:setAnimation("idleup")
		end),
		
		walkout,
		
		MessageBox{message="Sally: Which way did he go?", blocking=true},
		MessageBox{message="Sonic: Not sure... {p40}let's scout it out.", blocking=true},
		
		walkin,
		
		Do(function()
			scene.player.x = scene.player.x + 60
			scene.player.cinematicStack = 0
			GameState:setFlag("forgotten_enter")
		end)
	}
end
