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
	scene.audio:stopSfx("factoryfloor")

	if not GameState:isFlagSet("robotterminal_enter") then
		scene.player.cinematic = true
		local walkout, walkin, partySprites = scene.player:split()
		partySprites.sally.x = partySprites.sally.x + 50
		partySprites.sally.y = partySprites.sally.y - 50
		partySprites.antoine.x = partySprites.antoine.x + 50
		partySprites.antoine.y = partySprites.antoine.y - 50
		
		return Serial {
			Wait(1),
			walkout,
			MessageBox {message = "Sally: This should be our rendevous point.", blocking = true},
			MessageBox {message = "Antoine: We are having no sign of Sonic?", blocking = true},
			MessageBox {message = "Sally: Not yet. {p50}We'll have to make due.", blocking = true},
			Ease(scene.camPos, "y", scene.camPos.y + 250, 1, "inout"),
			MessageBox {message = "Sally: This is the entrance to the Swatbot factory.", blocking = true},
			Ease(scene.camPos, "x", scene.camPos.x + 150, 1, "inout"),
			MessageBox {message = "Sally: I need access to that terminal to get us in, but we need to get rid of the guard somehow...", blocking = true},
			Parallel {
				Ease(scene.camPos, "x", 0, 1, "inout"),
				Ease(scene.camPos, "y", 0, 1, "inout")
			},
			walkin,
			Do(function()
				scene.player.x = scene.player.x + 60
				scene.player.y = scene.player.y + 60
				GameState:setFlag("robotterminal_enter")
				scene.player.cinematic = false
			end)
		}
	elseif GameState:isFlagSet("roboterminal_openeddoor") then
		scene.player:removeKeyHint()
		scene.player.sprite:setAnimation("idledown")
		scene.player.cinematicStack = scene.player.cinematicStack + 1
		scene.player.noIdle = false
		local walkout, walkin, sprites = scene.player:split()

		return Serial {
			PlayAudio("music", "patrol", 1.0, true, true),
			walkout,
							
			MessageBox {message="Sally: That was a close one.", blocking = true},
			MessageBox {message="Sonic: Mighta bit off more than we can chew on this one, Sal. {p30}Should we abort?", blocking = true},
			
			MessageBox {message="Antoine: I will be voting yes on that!", blocking = true},
			
			Animate(sprites.sally.sprite, "thinking"),
			MessageBox {message="Sally: Hmmm{p20}.{p20}.{p20}. {p50}I think we should keep going.", blocking = true},
			
			Animate(sprites.antoine.sprite, "scaredhop1"),
			
			MessageBox {message="Sally: We're almost there, and this could really hurt Robotnik!", blocking = true},
			
			Animate(sprites.sonic.sprite, "idledown"),
			MessageBox {message="Sonic: Your call.", blocking = true},
			
			Animate(sprites.sonic.sprite, "thinking"),
			
			MessageBox {message="Sonic: Since when am I the cautious one?", blocking = true},
			
			Animate(sprites.antoine.sprite, "idledown"),
			MessageBox {message="Antoine: Sacre bleu...", textSpeed = 4, blocking = true},
			
			walkin,
			Do(function()
				scene.player.x = scene.player.x + 80
				scene.player.y = scene.player.y + 70
				
				scene.player.cinematicStack = 0
				scene.player.disableScan = false
			end)
		}
	elseif GameState:isFlagSet("roboterminal_used") then
		scene.objectLookup.Door.sprite:setAnimation("open")
		scene.objectLookup.Door:removeCollision()
	
		if scene.reentering then
			return Serial {
				AudioFade("music", 1.0, 0.0, 2),
				Do(function()
					scene.audio:stopMusic()
				end),
				PlayAudio("music", "patrol", 1.0, true, true)
			}
		else
			return PlayAudio("music", "patrol", 1.0, true, true)
		end
	else
		if scene.reentering then
			return Serial {
				AudioFade("music", 1.0, 0.0, 2),
				Do(function()
					scene.audio:stopMusic()
				end),
				PlayAudio("music", "patrol", 1.0, true, true)
			}
		else
			return PlayAudio("music", "patrol", 1.0, true, true)
		end
	end
end
