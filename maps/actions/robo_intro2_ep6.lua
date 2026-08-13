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
	
	return Serial {
	
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
				end),
				Parallel {
					Ease(scene.player, "x", scene.player.x, 1, "inout"),
					Wait(1)
				}
			}
		},
		
		Do(function()
			partySprites.sally.sprite.visible = true
			partySprites.sally.x = scene.player.x - scene.player.width
			partySprites.sally.y = scene.player.y - scene.player.height
			scene.player.sprite.visible = false
			scene.player.dropShadow.sprite.visible = false
		end),
		
		Move(partySprites.sally, scene.objectLookup.IntroWaypoint2),
		Move(partySprites.sally, scene.objectLookup.IntroWaypoint3),
		
		Animate(partySprites.sally.sprite, "idledown"),
		
		Wait(0.5),

		Animate(partySprites.sally.sprite, "idleright"),
		
		MessageBox {
			message="Sally: Are you ready, Antoine?",
			blocking=true
		},
		
		Wait(0.2),
		
		MessageBox {
			message="Antoine: I was ready when I was being born, my princess!",
			blocking=true
		},
		MessageBox {
			message="Sally: Good!",
			blocking=true
		},
		
		Do(function()
			partySprites.sally.x = partySprites.sally.x - 30
			partySprites.sally.sprite.sortOrderY = scene.objectLookup.IntroWaypoint5.y + 10
		end),
		Animate(partySprites.sally.sprite, "hideleft"),
		MessageBox {
			message="Sally: Since Sonic isn't here, we'll have to be extra careful...",
			blocking=true
		},
		Wait(1),
		Do(function()
			partySprites.sally.sprite:setAnimation("peekleft")
		end),
		Ease(scene.camPos, "x", 200, 1, "inout"),
		Wait(2),
		Ease(scene.camPos, "x", 0, 1, "inout"),
		
		MessageBox {
			message="Sally: ...there seem to be a lot of bots between us and the rendevous point.",
			blocking=true
		},
		
		Wait(1),
		
		MessageBox {
			message="Sally: We can't afford any encounters with Swatbots!",
			blocking=true
		},
		
		Animate(partySprites.sally.sprite, "pose"),
		
		MessageBox {
			message="Sally: Let's do it to it!",
			blocking=true
		},
		
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
			
			GameState:setFlag("robo_intro2_done")
		end)
	}
end
