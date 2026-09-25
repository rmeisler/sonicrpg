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
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"

return function(scene)
	if not GameState:isFlagSet("robot_wastland_intro") then
		GameState:setFlag("robot_wastland_intro")
		scene.player.state = "dead2"
		
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
			"RobotWasteland",
			100
		)

		return BlockPlayer {
			Do(function()
				scene.player.state = "dead2"
			end),
			PlayAudio("ambient", "lightrain", 1, true, true),
			Wait(2),
			MessageBox{message="Sally: Sonic! {p60}Can you hear me?"},
			Do(function()
				scene.player.state = "dead3"
			end),
			Wait(2),
			Do(function()
				scene.player.state = "dead3_wake"
			end),
			Wait(1),
			Do(function()
				scene.player.state = "dead4"
			end),
			MessageBox{message="Sonic: {p60}...W-{p60}What?"},

			Do(function()
				scene.player.state = "dead3_pain"
			end),
			MessageBox{message="Sonic: Arg!! {p60}My leg!!"},
			MessageBox{message="Sally: It might be broken..."},

			Do(function()
				scene.player.state = "dead4"
			end),
			MessageBox{message="Sonic: W-What?! {p60}No no no no--{p60} it can't be! {p60}I gotta get us outta here!"},

			Do(function()
				scene.player.state = "dead3_pain"
			end),
			MessageBox{message="Sonic: ACK!!"},
			MessageBox{message="Sally: We'll find a way out later. {p60}I'm just happy you're alive!"},
			Do(function()
				scene.player.state = "dead4"
			end),

			Wait(3),
			Animate(scene.objectLookup.B.sprite, "pose"),
			MessageBox{message="B: Excuse me, miss. {p60}Will you be taking me home, soon?"},
			Wait(2),
			MessageBox{message="Sonic: ..."},
			Animate(scene.objectLookup.Sally.sprite, "thinking"),
			Wait(2),
			Animate(scene.objectLookup.Sally.sprite, "worriedleft"),
			MessageBox{message="Sally: Soon. {p80}We're just taking a little detour right now."},
			Wait(2),
			MessageBox{message="Sonic: Guess we're really cooked this time, huh?"},
			Wait(1),
			Animate(scene.objectLookup.Sally.sprite, "thinking"),
			MessageBox{message="Sally: We can't think like that. {p60}We need to get to some place safe..."},
			
			Do(function()
				GameState:removeFromParty("sonic")
				GameState:removeFromParty("b")
				GameState.leader = "sally"
				scene.player.state = "idledown"
				scene.player:updateSprite()
				scene.objectLookup.Sally:remove()
				scene.objectLookup.B:remove()
			end),
			
			Spawn(Serial {
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
			}),
		}
	else
		return PlayAudio("sfx", "lightrain", 1, true, true)
	end
end
