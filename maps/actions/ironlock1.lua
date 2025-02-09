return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local TextNode = require "object/TextNode"
	local BasicNPC = require "object/BasicNPC"
	
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	
	scene.player.sprite.color[1] = 150
	scene.player.sprite.color[2] = 150
	scene.player.sprite.color[3] = 150
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Iron Lock",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.sectorName,
		100
	)
	
	local showTitle = function()
		Executor(scene):act(Serial {
			Wait(0.5),
			subtext,
			text,
			Parallel {
				Ease(subtext.color, 4, 255, 1),
			    Ease(text.color, 4, 255, 1)
			},
			Wait(2),
			Parallel {
				Ease(subtext.color, 4, 0, 1),
			    Ease(text.color, 4, 0, 1)
			}
		})
	end

	--GameState:setFlag("ironlock_intro")
	if not GameState:isFlagSet("ironlock_intro") then
		GameState:setFlag("ironlock_intro")
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		return BlockPlayer {
			PlayAudio("music", "darkintro", 0.8, true, true),
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.objectLookup.Snively.sprite:setAnimation("walkright")
				scene.objectLookup.Swatbot1.sprite:setAnimation("walkright")
				scene.objectLookup.Swatbot2.sprite:setAnimation("walkright")
				scene.objectLookup.Swatbot3.sprite:setAnimation("walkright")
			end),
			Parallel {
				Do(function()
					scene.player.x = scene.objectLookup.Snively.x
				end),
				Ease(scene.objectLookup.Snively, "x", scene.objectLookup.Snively.x + 1500, 0.15, "linear"),
				Ease(scene.objectLookup.Swatbot1, "x", scene.objectLookup.Swatbot1.x + 1500, 0.15, "linear"),
				Ease(scene.objectLookup.Swatbot2, "x", scene.objectLookup.Swatbot2.x + 1500, 0.15, "linear"),
				Ease(scene.objectLookup.Swatbot3, "x", scene.objectLookup.Swatbot3.x + 1500, 0.15, "linear"),
				Repeat(Serial {
					Wait(0.3),
					PlayAudio("sfx", "swatbotstep", 1.0, true)
				}, 20),
				Ease(scene.objectLookup.Cambot2, "x", scene.objectLookup.Cambot2.x - 1500, 0.15, "linear")
			},
			Do(function()
				scene.objectLookup.Snively.sprite:setAnimation("idleright_lookright")
				scene.objectLookup.Swatbot1.sprite:setAnimation("idleright")
				scene.objectLookup.Swatbot2.sprite:setAnimation("idleright")
				scene.objectLookup.Swatbot3.sprite:setAnimation("idleright")
				scene.objectLookup.Cambot2:remove()
			end),
			Wait(0.5),
			MessageBox{message="Snively: Security report."},
			MessageBox{message="Swatbot: zzz. {p60}All clear."},
			Animate(scene.objectLookup.Snively.sprite, "angryright"),
			Ease(scene.objectLookup.Snively, "y", function() return scene.objectLookup.Snively.y - 50 end, 8, "linear"),
			Ease(scene.objectLookup.Snively, "y", function() return scene.objectLookup.Snively.y + 50 end, 8, "linear"),
			MessageBox{message="Snively: Check again!!{p60} This project is at a sensitive stage of development!"},
			Wait(0.5),
			Animate(scene.objectLookup.Snively.sprite, "idleright_lookleft"),
			MessageBox{message="Snively: We can't have any of those filthy Freedom Fighters interfering..."},
			MessageBox{message="Swatbot: Yes sir."},
			Do(function()
				scene.objectLookup.Swatbot4.sprite:setAnimation("walkright")
			end),
			Parallel {
				Ease(scene.objectLookup.Swatbot4, "x", scene.objectLookup.Swatbot4.x + 500, 0.2, "linear"),
				Repeat(Serial {
					Wait(0.3),
					PlayAudio("sfx", "swatbotstep", 1.0, true)
				}, 9),
				Serial {
					Wait(1.2),
					MessageBox{message="Snively: *My pompous fool of an uncle...*"},
					MessageBox{message="Snively: *Sending me to this mound of rubble with a fleet of substandard legacy bots to guard his precious {h Project Firebird}!*"},
					MessageBox{message="Snively: *We'll see who has the last laugh, Julian...*"}
				}
			},
			Do(function()
				scene.objectLookup.Swatbot4:remove()
			end),
			Wait(1),
			Do(function()
				scene.objectLookup.Snively.sprite:setAnimation("walkright")
				scene.objectLookup.Swatbot1.sprite:setAnimation("walkright")
				scene.objectLookup.Swatbot2.sprite:setAnimation("walkright")
				scene.objectLookup.Swatbot3.sprite:setAnimation("walkright")
			end),
			Parallel {
				Ease(scene.objectLookup.Snively, "x", function() return scene.objectLookup.Snively.x + 750 end, 0.3, "linear"),
				Ease(scene.objectLookup.Swatbot1, "x", function() return scene.objectLookup.Swatbot1.x + 750 end, 0.3, "linear"),
				Ease(scene.objectLookup.Swatbot2, "x", function() return scene.objectLookup.Swatbot2.x + 750 end, 0.3, "linear"),
				Ease(scene.objectLookup.Swatbot3, "x", function() return scene.objectLookup.Swatbot3.x + 750 end, 0.3, "linear"),
				Repeat(Serial {
					Wait(0.3),
					PlayAudio("sfx", "swatbotstep", 1.0, true)
				}, 10),
				AudioFade("music", 1.0, 0.0, 0.3)
			},
			Wait(2.5),
			PlayAudio("sfx", "openchasm", 1.0, true),
			Animate(scene.objectLookup.TrapDoor.sprite, "opening"),
			Animate(scene.objectLookup.TrapDoor.sprite, "open"),
			Wait(2),
			Do(function()
				for _,layer in pairs(scene.map.layers) do
					if layer.name == "hidden" then
						layer.opacity = 1.0
						break
					end
				end
				scene.objectLookup.Sonic.sprite.color[4] = 255
				scene.objectLookup.Sally.sprite.color[4] = 255
				scene.objectLookup.Antoine.sprite.color[4] = 255
			end),
			Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y - 15 end, 1),
			Animate(scene.objectLookup.Sonic.sprite, "headleft"),
			Wait(1.5),
			Animate(scene.objectLookup.Sonic.sprite, "headright"),
			Wait(1.5),
			Animate(scene.objectLookup.Sonic.sprite, "headsmile"),
			MessageBox{message="Sonic: It's cool, guys."},
			Animate(scene.objectLookup.Sally.sprite, "leapright"),
			Animate(scene.objectLookup.Sonic.sprite, "leapright"),
			Animate(scene.objectLookup.Antoine.sprite, "leapright"),
			Parallel {
				Ease(scene.objectLookup.Sally, "x", 2048, 4, "linear"),
				Serial {
					Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y - 140 end, 8),
					Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y + 42 end, 8)
				},
				Ease(scene.objectLookup.Sonic, "x", 2048 - 64, 4, "linear"),
				Serial {
					Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y - 140 end, 8),
					Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y + 42 end, 8)
				},
				Ease(scene.objectLookup.Antoine, "x", 2048 - 128, 4, "linear"),
				Serial {
					Ease(scene.objectLookup.Antoine, "y", function() return scene.objectLookup.Antoine.y - 140 end, 8),
					Ease(scene.objectLookup.Antoine, "y", function() return scene.objectLookup.Antoine.y + 42 end, 8)
				}
			},
			
			Animate(scene.objectLookup.Sally.sprite, "idleleft"),
			Animate(scene.objectLookup.Sonic.sprite, "idledown"),
			Animate(scene.objectLookup.Antoine.sprite, "idleright"),
			PlayAudio("sfx", "openchasm", 1.0, true),
			Animate(scene.objectLookup.TrapDoor.sprite, "closing"),
			Animate(scene.objectLookup.TrapDoor.sprite, "closed"),
			Wait(1),
			Animate(scene.objectLookup.Antoine.sprite, "hideleft"),
			Animate(scene.objectLookup.Sally.sprite, "pose"),
			MessageBox{message="Sally: We made it!"},
			MessageBox{message="Sally: Now let's trash this science experiment!"},
			Do(function()
				scene.objectLookup.Sally.sprite:setAnimation("walkleft")
				scene.objectLookup.Antoine.sprite:setAnimation("walkright")
			end),
			Parallel {
				Ease(scene.objectLookup.Sally, "x", function() return scene.objectLookup.Sally.x - 64 end, 3, "linear"),
				Ease(scene.objectLookup.Antoine, "x", function() return scene.objectLookup.Antoine.x + 64 end, 3, "linear")
			},
			Do(function()
				scene.objectLookup.Antoine:remove()
				scene.objectLookup.Sonic:remove()
				scene.objectLookup.Sally:remove()
				scene.player.x = scene.player.x + 42
				scene.player.y = scene.player.y + 42

				for _,layer in pairs(scene.map.layers) do
					if layer.name == "hidden" then
						layer.opacity = 0.0
						break
					end
				end

				scene.player.sprite.visible = true
				scene.player.dropShadow.hidden = false
				scene.player.state = "idledown"
				showTitle()
				
				scene.objectLookup.Snively:remove()
				scene.objectLookup.Swatbot1:remove()
				scene.objectLookup.Swatbot2:remove()
				scene.objectLookup.Swatbot3:remove()
			end),
			PlayAudio("music", "ironlock", 1.0, true, true)
		}
	end
	
	scene.objectLookup.Snively:remove()
	scene.objectLookup.Swatbot1:remove()
	scene.objectLookup.Swatbot2:remove()
	scene.objectLookup.Swatbot3:remove()
	scene.objectLookup.Swatbot4:remove()
	scene.objectLookup.Cambot2:remove()
	scene.objectLookup.Antoine:remove()
	scene.objectLookup.Sonic:remove()
	scene.objectLookup.Sally:remove()
	
	showTitle()
	return PlayAudio("music", "ironlock", 1.0, true, true)
end
