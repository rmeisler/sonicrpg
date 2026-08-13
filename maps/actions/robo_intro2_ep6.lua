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

	if GameState:isFlagSet("robo_intro2_done") then
		return Action()
	end
	
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
		MessageBox {message="Sally: Remember guys{p60}, our final mission is\ntomorrow{p60}, so safety is our top priority."},
		MessageBox {message="Sally: This means we are going to take the long way down{p60}, utility tunnels."},
		MessageBox {message="Sally: And most importantly{p60}, no engaging with any\nsecurity bots!{p60} {h Sneak don't fight}."},
		
		AudioFade("music", 1, 0, 1),
		Animate(partySprites.b.sprite, "pose"),
		MessageBox {message="B: ..."},
		Animate(partySprites.sonic.sprite, "idleright"),
		MessageBox {message="Sally: Something wrong, B?"},
		MessageBox {message="B: ...{p60}No, it's nothing.{p60} Let's go."},
		PlayAudio("music", "infiltration", 1, true, true),
		Animate(partySprites.sonic.sprite, "pose"),
		MessageBox {message="Sonic: Let's do it to it!"},
		
		Wait(0.2),
		
		Do(function()
			partySprites.sally.sprite:setAnimation("walkright")
		end),
		Parallel {
			Do(function()
				partySprites.sally.x = partySprites.sally.x + scene.player.movespeed * (love.timer.getDelta()/0.016)
				scene.player.x = scene.player.x + scene.player.movespeed * (love.timer.getDelta()/0.016)
			end),
			
			Wait(0.4)
		},
		
		Do(function()
			scene.player.x = partySprites.sally.x + scene.player.width*2
			scene.player.y = partySprites.sally.y + scene.player.height
			scene.player.sprite.visible = true
			scene.player.dropShadow.sprite.visible = true
			
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
			scene.player.nokeyhints = false
			scene.player.cinematicStack = 0
			
			GameState:setFlag("robo_intro2_ep6_done")
		end)
	}
end
