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
	scene.player.noSonicCrash = true
	
	if (GameState:isFlagSet("b_speech") or
		GameState:isFlagSet("met_b")) and
		not scene.objectLookup.B
	then
		local placeNPC = function(id, x, y, interact)
			scene.objectLookup[id] = BasicNPC(
				scene,
				{name = "objects"},
				{
					name = id,
					x = x,
					y = y,
					width = 64,
					height = 32,
					properties = {sprite = "art/sprites/"..id..".png", align = "bottom_center", defaultAnim = "idledown"}
				}
			)
			scene:addObject(scene.objectLookup[id])
			scene.objectLookup[id]:addInteract(interact)
		end
		placeNPC(
			"b",
			1632,
			2176,
			function(b)
				scene:run {
					MessageBox{message="B: I'm in your debt, Freedom Fighters.", blocking = true},
					MessageBox{message="Sonic: Yo, {p40}we'll be back too. {p40}Ya know you'd all be a lot safer back in Knothole.", blocking = true},
					Animate(b.sprite, "thinking"),
					Wait(1),
					MessageBox{message="B: You may be right about that, {p40}but it's much too risky a journey for us.", blocking = true},
					Animate(b.sprite, "idledown"),
				}
			end
		)
		placeNPC(
			"r",
			1632,
			2176,
			function(r)
				scene:run {
					MessageBox{message="B: I'm in your debt, Freedom Fighters.", blocking = true},
					MessageBox{message="Sonic: Yo, {p40}we'll be back too. {p40}Ya know you'd all be a lot safer back in Knothole.", blocking = true},
					Animate(r.sprite, "thinking"),
					Wait(1),
					MessageBox{message="B: You may be right about that, {p40}but it's much too risky a journey for us.", blocking = true},
					Animate(r.sprite, "idledown"),
				}
			end
		)
		placeNPC(
			"j",
			1632,
			2176,
			function(j)
				scene:run {
					MessageBox{message="B: I'm in your debt, Freedom Fighters.", blocking = true},
					MessageBox{message="Sonic: Yo, {p40}we'll be back too. {p40}Ya know you'd all be a lot safer back in Knothole.", blocking = true},
					Animate(r.sprite, "thinking"),
					Wait(1),
					MessageBox{message="B: You may be right about that, {p40}but it's much too risky a journey for us.", blocking = true},
					Animate(r.sprite, "idledown"),
				}
			end
		)
		placeNPC(
			"t",
			1632,
			2176,
			function(t)
				scene:run {
					MessageBox{message="B: I'm in your debt, Freedom Fighters.", blocking = true},
					MessageBox{message="Sonic: Yo, {p40}we'll be back too. {p40}Ya know you'd all be a lot safer back in Knothole.", blocking = true},
					Animate(r.sprite, "thinking"),
					Wait(1),
					MessageBox{message="B: You may be right about that, {p40}but it's much too risky a journey for us.", blocking = true},
					Animate(r.sprite, "idledown"),
				}
			end
		)
		placeNPC(
			"p",
			1632,
			2176,
			function(p)
				scene:run {
					MessageBox{message="B: I'm in your debt, Freedom Fighters.", blocking = true},
					MessageBox{message="Sonic: Yo, {p40}we'll be back too. {p40}Ya know you'd all be a lot safer back in Knothole.", blocking = true},
					Animate(r.sprite, "thinking"),
					Wait(1),
					MessageBox{message="B: You may be right about that, {p40}but it's much too risky a journey for us.", blocking = true},
					Animate(r.sprite, "idledown"),
				}
			end
		)
	end
	
	if GameState:isFlagSet("b_speech") then
		return PlayAudio("music", "bhero", 1.0, true, true)
	end
	
	if GameState:isFlagSet("met_b") then
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
			end)
		}
	end
	
	if GameState:isFlagSet("forgotten_enter") then
		return PlayAudio("music", "forgottendiscovery", 1.0, true, true)
	end
	
	scene.player.y = scene.player.y - 340
	local walkout, walkin, sprites = scene.player:split()
	scene.player.y = scene.player.y + 340

	return Serial {
		PlayAudio("music", "forgottendiscovery", 1.0, true, true),
		
		Wait(2),
		
		Do(function()
			scene.player.noIdle = true
			scene.player.state = "walkup"
		end),
		Ease(scene.player, "y", scene.player.y - 280, 1, "linear"),
		Do(function()
			scene.player.noIdle = false
		end),
		
		walkout,
		
		MessageBox{message="Sally: Which way did he go?", blocking=true},
		MessageBox{message="Sonic: Not sure... {p40}let's scout it out.", blocking=true},
		
		walkin,
		
		Do(function()
			scene.player.x = scene.player.x + 60
			GameState:setFlag("forgotten_enter")
		end)
	}
end
