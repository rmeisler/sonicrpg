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
local BlockPlayer = require "actions/BlockPlayer"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"
local Player = require "object/Player"

return function(scene)
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Robotropolis",
		100
	)
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"West Corridor",
		100
	)
	Executor(scene):act(Serial {
		Wait(0.5),
		subtext,
		text,
		Parallel {
			Ease(text.color, 4, 255, 1),
			Ease(subtext.color, 4, 255, 1),
		},
		Wait(2),
		Parallel {
			Ease(text.color, 4, 0, 1),
			Ease(subtext.color, 4, 0, 1)
		}
	})
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	scene.player.dustColor = Player.ROBOTROPOLIS_DUST_COLOR
	
	scene.player.handlers.caught = nil
	local caughtHandler
	caughtHandler = function(bot)
		scene.player.doingSpecialMove = false
		scene.player.basicUpdate = function(p, dt) end
		scene.player.sprite:setAnimation("shock")
		for k,v in pairs(scene.player.keyhints) do
			scene.player.hidekeyhints[k] = v
		end
		scene.player:removeKeyHint()
		scene.player:removeHandler("caught", caughtHandler)
		scene:run(
			BlockPlayer {
				Wait(1),
				Do(function()
					scene:restart{hint="caught", fadeOutMusic=false}
				end),
				Do(function() end)
			}
		)
	end
	scene.player:addHandler("caught", caughtHandler)

	if GameState:isFlagSet("ep6_robo_intro2_done") then
		return Do(function()
			scene.player.y = scene.player.y + 200
			scene.player.state = "idleleft"
			scene.objectLookup.SonicHide.hidden = true
			scene.objectLookup.BHide.hidden = true
			scene.objectLookup.Swatbot1.ignorePlayer = false
			scene.objectLookup.Swatbot3.ignorePlayer = false
			scene.objectLookup.IntroCambot:remove()
		end)
	end
	
	GameState:setFlag("ep6_robo_intro2_done")
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	scene.player.cinematic = true
	scene.player.cinematicStack = scene.player.cinematicStack + 1
	scene.player.dontfuckingmove = true
	
	scene.ignorePlayer = true
	
	local cambot = scene.objectLookup.IntroCambot
	local spot = scene.objectLookup.IntroHeap
	scene.player.x = spot.x + scene:getTileWidth() + (spot.object.properties.hideOffset or 0) - 7

	local origPlayerPos = Transform(scene.player.x, scene.player.y)
	local walkout, walkin, partySprites = scene.player:split()
	
	for _,v in pairs(partySprites) do
		v.hidden = true
	end
	
	return BlockPlayer {
	
		Do(function()
			scene.player.x = cambot.x
			scene.player.y = cambot.y

			GameState.leader = "sally"
			scene.player:updateSprite()
			
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			scene.player.nokeyhints = true
		end),
		
		Parallel {
			Move(cambot, scene.objectLookup.IntroWaypoint1, "idle"),
			Do(function()
				scene.player.x = cambot.x
			end),
			
			Serial {
				PlayAudio("music", "patrol", 0.0, true),
				AudioFade("music", 0.0, 1.0, 0.5)
			}
		},
		
		Wait(1),
		
		Do(function()
			cambot.sprite:setAnimation("idleup")
		end),
		
		Parallel {
			Ease(scene.player, "y", scene.player.y, 1, "inout"),
			Wait(3)
		},
	
		Do(function()
			cambot.sprite:setAnimation("idleright")
		end),
		
		Parallel {
			Do(function()
				cambot.x = cambot.x + cambot.movespeed * (love.timer.getDelta()/0.016)
			end),
			
			Serial {
				Spawn(Serial {
					Wait(0.8),
					AudioFade("music", 1.0, 0, 0.5),
					PlayAudio("music", "sallyenters", 1.0),
					PlayAudio("music", "openingmission2", 1.0, true, true),
				}),
				
				Wait(2),
				
				Do(function()
					scene.player.x = origPlayerPos.x
					scene.player.y = origPlayerPos.y
					scene.player.sprite.visible = true
					scene.player.dropShadow.sprite.visible = true
					scene.player.state = "hidedown"
					
					cambot:remove()
				end),
					
				Ease(scene.player, "x", scene.player.x - 30, 4, "inout"),
				Wait(1),
				Ease(scene.objectLookup.SonicHide, "y", function() return scene.objectLookup.SonicHide.y - 70 end, 4, "inout"),
				Wait(1),
				Do(function()
					scene.objectLookup.BHide.hidden = false
				end),
				Ease(scene.objectLookup.BHide, "y", function() return scene.objectLookup.BHide.y - 60 end, 4, "inout"),
				Wait(2),
				
				Parallel {
					Ease(scene.player, "x", scene.player.x, 4, "inout"),
					Ease(scene.objectLookup.SonicHide, "y", function() return scene.objectLookup.SonicHide.y + 70 end, 4, "inout"),
					Ease(scene.objectLookup.BHide, "y", function() return scene.objectLookup.BHide.y + 60 end, 4, "inout")
				},
				Do(function()
					scene.player.state = "idledown"
					scene.objectLookup.SonicHide.hidden = true
					scene.objectLookup.BHide.hidden = true
				end),
				Parallel {
					Ease(scene.player, "x", scene.player.x, 1, "inout"),
					Wait(1)
				}
			}
		},
		
		Do(function()
			partySprites.sally.hidden = false
			partySprites.sally.x = scene.player.x - scene.player.width
			partySprites.sally.y = scene.player.y - scene.player.height
			partySprites.sally.object.properties.ignoreMapCollision = true
			partySprites.sally.ghost = true
			
			partySprites.sonic.hidden = false
			partySprites.sonic.x = scene.player.x - scene.player.width + 50
			partySprites.sonic.y = scene.player.y - scene.player.height
			partySprites.sonic.object.properties.ignoreMapCollision = true
			partySprites.sonic.ghost = true

			partySprites.b.hidden = false
			partySprites.b.x = scene.player.x - scene.player.width + 100
			partySprites.b.y = scene.player.y - scene.player.height
			partySprites.b.object.properties.ignoreMapCollision = true
			partySprites.b.ghost = true

			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),

		Parallel {
			Move(partySprites.sally, scene.objectLookup.IntroWaypoint2),
			Move(partySprites.sonic, scene.objectLookup.IntroWaypoint0_1),
			Move(partySprites.b, scene.objectLookup.IntroWaypoint0)
		},
		Parallel {
			Move(partySprites.sally, scene.objectLookup.IntroWaypoint3),
			Move(partySprites.sonic, scene.objectLookup.IntroWaypoint4),
			Move(partySprites.b, scene.objectLookup.IntroWaypoint4_1),
			Do(function()
				scene.player.y = scene.player.y + scene.player.movespeed * (love.timer.getDelta()/0.016)
			end)
		},

		Animate(partySprites.sonic.sprite, "idleleft"),
		Animate(partySprites.b.sprite, "idleleft"),
		Animate(partySprites.sally.sprite, "idleright"),

		PlayAudio("music", "patrol", 1, true, true),
		Wait(1),
		MessageBox {message="Sally: Alright!"},
		MessageBox {message="Sally: Remember guys{p40}, our big mission is tomorrow!\n{p60}So what does that mean?"},
		Animate(partySprites.sonic.sprite, "smileleft"),
		MessageBox {message="Sonic: We {h blast in}{p40}, and {h jam out}!"},
		Animate(partySprites.sally.sprite, "thinking"),
		partySprites.sally:hop(),
		MessageBox {message="Sally: No {h blasting} or {h jamming}!!"},
		Animate(partySprites.sonic.sprite, "irritated"),
		partySprites.sonic:hop(),
		MessageBox {message="Sonic: Well what does it mean then?"},
		Animate(partySprites.sally.sprite, "idleright"),
		MessageBox {message="Sally: No engaging with any security bots!{p60} In\nother words...{p40} {h sneak don't fight}!"},
		Animate(partySprites.sonic.sprite, "idleleft"),
		MessageBox {message="Sonic: Got it."},
		
		AudioFade("music", 1, 0, 0.5),
		Wait(1),
		Animate(partySprites.b.sprite, "pose"),
		MessageBox {message="B: ..."},
		Wait(1),
		MessageBox {message="Sally: Something wrong, B?"},
		Animate(partySprites.sonic.sprite, "idleright"),
		MessageBox {message="B: ...{p40}Just gotta a feeling..."},
		Animate(partySprites.sonic.sprite, "idleright"),
		MessageBox {message="Sonic: A feeling? {p60}What kind of feeling?"},
		Animate(partySprites.b.sprite, "idleleft"),
		MessageBox {message="B: It's probably nothing. {p60}Let's go."},
		Wait(1),

		PlayAudio("music", "infiltration", 1, true, true),
		Parallel {
			Animate(partySprites.sonic.sprite, "pose"),
			Animate(partySprites.sally.sprite, "pose"),
			Animate(partySprites.b.sprite, "pose")
		},
		MessageBox {message="All: Let's do it to it!"},
		
		Wait(0.2),
		
		Do(function()
			partySprites.sally.sprite:setAnimation("walkright")
			partySprites.sonic.sprite:setAnimation("walkleft")
			partySprites.b.sprite:setAnimation("walkleft")
		end),
		Parallel {
			Do(function()
				partySprites.sally.x = partySprites.sally.x + scene.player.movespeed * (love.timer.getDelta()/0.016)
				partySprites.sonic.x = partySprites.sonic.x - scene.player.movespeed * (love.timer.getDelta()/0.016)
				partySprites.b.x = partySprites.b.x - scene.player.movespeed * (love.timer.getDelta()/0.016)
				scene.player.x = scene.player.x + scene.player.movespeed * (love.timer.getDelta()/0.016)
			end),
			
			Wait(0.3)
		},
		
		Do(function()
			scene.player.x = partySprites.sally.x
			scene.player.y = partySprites.sally.y + scene.player.height
			scene.player.sprite.visible = true
			scene.player.dropShadow.sprite.visible = true
			scene.player.state = "idleleft"
			
			for _, npc in pairs(partySprites) do
				npc:remove()
			end
		end),
		
		-- Sonic and Sally playable
		Do(function()
			scene.ignorePlayer = false
			scene.player.cinematic = false
			scene.player.dontfuckingmove = false
			scene.objectLookup.Swatbot1.ignorePlayer = false
			scene.objectLookup.Swatbot3.ignorePlayer = false
			scene.player.nokeyhints = false
			scene.player.cinematicStack = 0
		end)
	}
end
