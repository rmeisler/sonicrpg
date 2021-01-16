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
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local AudioFade = require "actions/AudioFade"

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
		"Inner City",
		100
	)
	
	if GameState:isFlagSet("demo_intro_done") then
		return PlayAudio("music", "robointro", 1.0, true)
	end
	
	scene.player.sprite.visible = false
	scene.player.dontfuckingmove = true
	scene.player.cinematic = true
	
	-- Split
	local walkOut, walkIn, sprites = scene.player:split()
	
	--[[local projection = SpriteNode(
		scene,
		Transform(
			sprites.sally.transform.x,
			sprites.sally.transform.y + 50,
			2,
			2
		),
		{255,255,255,0},
		"nicholeprojection",
		nil,
		nil,
		sprites.sally.layer
	)]]
	
	return Serial {
		Parallel {
			Serial {
				Wait(2),
				subtext,
				text,
				Parallel {
					Ease(text.color, 4, 255, 1),
					Ease(subtext.color, 4, 255, 1),
				},
				Wait(2),
				PlayAudio("music", "sonicenters", 1.0, true),
				Parallel {
					Ease(text.color, 4, 0, 1),
					Ease(subtext.color, 4, 0, 1)
				},
			},
			
			Ease(scene.player, "x", 300, 0.15, "linear")
		},
		Do(function()
			-- Sonic runs in from off screen
			scene.player.state = "idleright"
			scene.player.x = -200
			scene.player.sprite.visible = true
			scene.player.skipChargeSpecialMove = true
			scene.player.ignoreSpecialMoveCollision = true
			scene.player:onSpecialMove()
			
			scene.audio:playSfx("sonicrunturn")
		end),
		Wait(1.45),
		Do(function()
			scene.player.slowDown = true
			scene.player.skipChargeSpecialMove = false
			scene.player.ignoreSpecialMoveCollision = false
		end),
		Wait(1),
		
		Spawn(Serial {
			AudioFade("music", 1.0, 0, 0.5),
			PlayAudio("music", "robointro", 1.0, true)
		}),
		
		Do(function()
			scene.player.slowDown = false
			scene.player.state = "idleright"
		end),
		Wait(0.5),
		Do(function()
			scene.player.state = "lookleft"
		end),
		Wait(0.5),
		Do(function()
			scene.player.state = "idleright"
		end),
		
		MessageBox {
			message="Sonic: It's cool, ladies.",
			textSpeed=4
		},
		
		--walkOut,
		
		Wait(0.5),
		
		Do(function()
			sprites.sonic:setAnimation("idleup")
			--sprites.bunny:setAnimation("idleup")
		end),
		
		MessageBox {
			message="Bunny: What's the plan, Sally girl?",
			textSpeed=4
		},
		
		Wait(0.2),
		
		Parallel {
			Do(function()
				--sprites.sally:setAnimation("idleup")
			end),
		
			MessageBox {
				message="Sally: Up ahead is the Data Center.",
				textSpeed=4,
				closeAction=Wait(2)
			},
			Serial {
				Parallel {
					Ease(scene.player, "y", scene.player.y - 200, 1, "linear"),
					
					-- Hack, need to shift sprites with camera
					Ease(sprites.sonic.transform, "y", sprites.sonic.transform.y + 200, 1, "linear"),
					--Ease(sprites.sally.transform, "y", sprites.sally.transform.y + 140, 1, "linear"),
					--Ease(sprites.bunny.transform, "y", sprites.bunny.transform.y + 200, 1, "linear")
				},
				Wait(2),
				Parallel {
					Ease(scene.player, "y", scene.player.y, 1, "linear"),
					
					-- Hack, need to shift sprites with camera
					Ease(sprites.sonic.transform, "y", sprites.sonic.transform.y + 10, 1, "linear"),
					--Ease(sprites.sally.transform, "y", sprites.sally.transform.y - 50, 1, "linear"),
					--Ease(sprites.bunny.transform, "y", sprites.bunny.transform.y + 10, 1, "linear")
				}
			}
		},
		
		--Animate(sprites.sally, "nichole_project_start"),
		Do(function()
			--sprites.sally:setAnimation("nichole_project_idle")
			sprites.sonic:setAnimation("idledown")
			--sprites.bunny:setAnimation("idledown")
		end),
		
		Parallel {
			Serial {
				MessageBox {
					message="Sally: We'll need to find the \"root terminal\".",
					textSpeed=4
				},
				
				MessageBox {
					message="Sally: Once we find it, I'll install the virus--",
					textSpeed=4
				},
				
				MessageBox {
					message="Sally: --we'll then need to get out of there fast, before Robotnik finds out.",
					textSpeed=4
				},
			},
			--Ease(projection.color, 4, 220, 5),
		},
		
		scene.player:spin(2, 0.01, sprites.sonic),
		
		Do(function()
			sprites.sonic:setAnimation("pose")
			--sprites.bunny:setAnimation("idleleft")
		end),
		
		MessageBox {
			message="Sonic: That's where I come in!",
			textSpeed=4
		},
		
		MessageBox {
			message="Sally: Right!",
			textSpeed=4,
			closeAction=Wait(0.5)
		},
		
		Spawn(Serial {
			AudioFade("music", 1.0, 0, 0.5),
			PlayAudio("music", "sonicready", 1.0, true)
		}),
		
		Do(function()
			--sprites.sally:setAnimation("nicholedown")
		end),
		
		--Ease(projection.color, 4, 0, 5),
		
		Wait(2),
		
		Do(function()
			--sprites.sally:setAnimation("pose")
			sprites.sonic:setAnimation("idleup")
			--sprites.bunny:setAnimation("idleup")
		end),
		
		Wait(0.5),
		
		MessageBox {
			message="Sally: Alright guys!",
			textSpeed=4,
			closeAction=Wait(0.6)
		},
		
		Do(function()
			sprites.sonic:setAnimation("pose")
			--sprites.bunny:setAnimation("pose")
		end),
		
		MessageBox {
			message="All: Let's do it to it!",
			textSpeed=4
		},
		
		--walkIn,
		
		Spawn(Serial {
			Wait(6),
			AudioFade("music", 1.0, 0, 0.2),
			PlayAudio("music", "robointro", 1.0, true)
		}),
		
		Do(function()
			scene.player.dontfuckingmove = false
			
			-- Set flag symbolizing that we finished intro sequence
			GameState:setFlag("demo_intro_done")
		end),
	}
end
