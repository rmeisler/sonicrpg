return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"
	local ItemType = require "util/ItemType"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local Repeat = require "actions/Repeat"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local BlockPlayer = require "actions/BlockPlayer"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Move = require "actions/Move"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),

		Wait(2),
		
		PlayAudio("music", "concerning", 1, true),
		Animate(scene.objectLookup.Sonic.sprite, "peekup"),
		MessageBox{message="Sonic: Tails!"},
		
		Wait(1),
		
		Animate(scene.objectLookup.Sally.sprite, "shoutupright"),
		MessageBox{message="Sally: Taaails!"},
		
		Wait(2),
		
		Animate(scene.objectLookup.Sonic.sprite, "sadleft"),
		MessageBox{message="Sonic: Little buddy{p60}, where are you?..."},
		
		Wait(2),
		MessageBox{message="*snoring*"},
		Animate(scene.objectLookup.Sonic.sprite, "idleup"),
		scene.objectLookup.Sonic:hop(),
		
		-- Pan to tree
		Parallel {
			AudioFade("music", 1, 0, 1),
			Ease(scene.camPos, "x", function()
				return -(scene.objectLookup.PalmTree_Fleet.x - scene.objectLookup["Spawn 1"].x) - scene.objectLookup.PalmTree_Fleet.sprite.w
			end, 1),
			Ease(scene.camPos, "y", function()
				return -(scene.objectLookup.PalmTree_Fleet.y - scene.objectLookup["Spawn 1"].y) - scene.objectLookup.PalmTree_Fleet.sprite.h
			end, 1),
		},
		
		MessageBox{message="Fleet: ..."},
		PlayAudio("music", "rotorsworkshop", 1, true),
		MessageBox{message="Sonic: Hey!"},
		Animate(scene.objectLookup.Fleet.sprite, "sleeping_wake"),
		MessageBox{message="Fleet: H-Huh?"},
		MessageBox{message="Sonic: Think you can maybe try a little harder, bird brain?"},
		MessageBox{message="Fleet: O-Oh uh..."},
		Animate(scene.objectLookup.Fleet.sprite, "sleeping_attitude"),
		MessageBox{message="Fleet: He's not behind this tree."},
		
		Parallel {
			Ease(scene.camPos, "x", 0, 1),
			Ease(scene.camPos, "y", 0, 1),
		},

		Animate(scene.objectLookup.Sonic.sprite, "irritated"),
		MessageBox{message="Sonic: Fantastic."},
		
		Animate(scene.objectLookup.Sally.sprite, "thinking"),
		MessageBox{message="Sally: *sigh*"},
		
		Parallel {
			Ease(scene.camPos, "x", function() return -(scene.objectLookup.Ivan.x - scene.objectLookup["Spawn 1"].x) end, 1),
			Ease(scene.camPos, "y", function() return -(scene.objectLookup.Ivan.y - scene.objectLookup["Spawn 1"].y) end, 1),
		},

		Wait(1),
		Animate(scene.objectLookup.Ivan.sprite, "idleup_lookleft"),
		Wait(1),
		Animate(scene.objectLookup.Ivan.sprite, "idleup_lookright"),
		Wait(2),
		Animate(scene.objectLookup.Ivan.sprite, "attitude"),
		MessageBox{message="Ivan: From my observations,{p60} the small fox boy is likely not here."},
		
		MessageBox{message="Sonic: Oh yeah, gazing around like that is a biiig help."},

		Parallel {
			Ease(scene.camPos, "x", 0, 1),
			Ease(scene.camPos, "y", 0, 1),
		},
		Wait(1),
		PlayAudio("music", "trouble", 1, true, true),
		Parallel {
			MessageBox{message="zzz. Freedom Fighters sighted."},
			Serial {
				Animate(scene.objectLookup.Sonic.sprite, "shock"),
				Animate(scene.objectLookup.Sally.sprite, "shock"),
				Parallel {
					scene.objectLookup.Sonic:hop(),
					scene.objectLookup.Sally:hop(),
				},
				Wait(0.5),
				Parallel {
					Ease(scene.camPos, "x", function() return -(scene.objectLookup.Swatbot1.x - scene.objectLookup["Spawn 1"].x) end, 1),
					Ease(scene.camPos, "y", function() return -(scene.objectLookup.Swatbot1.y - scene.objectLookup["Spawn 1"].y) - 100 end, 1),
				}
			}
		},
		Wait(1),
		Parallel {
			MessageBox{message="Fleet: Ivan{p60}, throw Logan's whachamacallit at em."},
			Ease(scene.camPos, "x", function()
				return -(scene.objectLookup.PalmTree_Fleet.x - scene.objectLookup["Spawn 1"].x) - scene.objectLookup.PalmTree_Fleet.sprite.w
			end, 1),
			Ease(scene.camPos, "y", function()
				return -(scene.objectLookup.PalmTree_Fleet.y - scene.objectLookup["Spawn 1"].y) - scene.objectLookup.PalmTree_Fleet.sprite.h
			end, 1),
		},
		Wait(0.5),
		Parallel {
			AudioFade("music", 1, 0, 1),
			MessageBox{message="Ivan: Affirmative."},
			Ease(scene.camPos, "x", function() return -(scene.objectLookup.Ivan.x - scene.objectLookup["Spawn 1"].x) end, 1),
			Ease(scene.camPos, "y", function() return -(scene.objectLookup.Ivan.y - scene.objectLookup["Spawn 1"].y) end, 1),
		},
		Wait(0.5),
		-- Throw animation
		Animate(scene.objectLookup.Ivan.sprite, "throwright"),
		Wait(1),
		Parallel {
			PlayAudio("sfx", "cyclopsstep", 1),
			PlayAudio("sfx", "explosion2", 1),
			scene:screenShake(20, 30, 15)
		},

		-- Fleet flies down next to Sonic and Sally
		Do(function()
			scene.objectLookup.Fleet.hidden = true
			scene.objectLookup.Fleet2.hidden = false
			scene.objectLookup.Sonic.movespeed = 40

			scene.camPos.y = -(scene.objectLookup.Ivan.y - scene.objectLookup["Spawn 1"].y)
		end),
		Move(scene.objectLookup.Sonic, scene.objectLookup.SonicWP2, "juicecrouch"),
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		Wait(1),
		Parallel {
			Ease(scene.camPos, "x", function() return -(scene.objectLookup.Fleet2.x - scene.objectLookup["Spawn 1"].x) end, 1),
			Ease(scene.camPos, "y", 0, 1),
			Ease(scene.objectLookup.Fleet2, "y", function() return scene.objectLookup.Fleet2.y + 270 end, 0.5)
		},
		Animate(scene.objectLookup.Fleet2.sprite, "fleetland"),
		Wait(0.5),
		Do(function()
			scene.objectLookup.Fleet2.hidden = true
			scene.objectLookup.Fleet.hidden = false
			scene.objectLookup.Fleet.x = scene.objectLookup.Fleet2.x + scene.objectLookup.Fleet2.sprite.w/2 - 10
			scene.objectLookup.Fleet.y = scene.objectLookup.Fleet2.y + scene.objectLookup.Fleet2.sprite.h/2 - 20
			scene.objectLookup.Fleet.sprite:setAnimation("laugh")
			scene.objectLookup.Sonic.sprite.sortOrderY = 1
		end),
		MessageBox{message="Fleet: And once again, the Rebellion save your Freedom Fighter butts."},
		PlayAudio("music", "sadintrospect", 1, true),
		Animate(scene.objectLookup.Sonic.sprite, "worrieddown"),
		MessageBox{message="Sonic: Oh no."},
		PlayAudio("sfx", "sonicrunturn", 1, true),
		Move(scene.objectLookup.Sonic, scene.objectLookup.SonicWP1, "juicecrouch"),
		Animate(scene.objectLookup.Fleet.sprite, "smirk"),
		MessageBox{message="Fleet: What's he so worried about? {p60}We--"},
		Animate(scene.objectLookup.Ivan.sprite, "idleleft"),
		Animate(scene.objectLookup.Sally.sprite, "frustratedright"),
		MessageBox{message="Sally: --threw around an experimental bomb when Tails could be nearby?! {p80}Do you realize how reckless that was?!"},
		Animate(scene.objectLookup.Fleet.sprite, "lookleft"),
		PlayAudio("sfx", "sonicrunturn", 1, true),
		Move(scene.objectLookup.Sonic, scene.objectLookup.SonicWP3, "juicecrouch"),
		Animate(scene.objectLookup.Sonic.sprite, "worried2"),
		MessageBox{message="Sonic: H{p20}-He wasn't there..."},
		Animate(scene.objectLookup.Sally.sprite, "thinking2"),
		MessageBox{message="Fleet: See? {p60}No problem. {p60}Quit making a big deal outta noth--"},
		Animate(scene.objectLookup.Sonic.sprite, "worried"),
		MessageBox{message="Sonic: For crying out loud, can you be serious for one second?!"},
		MessageBox{message="Sonic: When you agreed to come along{p60}, for a minute there I actually thought that maybe you two cared about something more than just yourselves..."},
		MessageBox{message="Sonic: 'Guess I was wrong."},
		Animate(scene.objectLookup.Ivan.sprite, "attitude"),
		Animate(scene.objectLookup.Fleet.sprite, "sadleft"),
		MessageBox{message="Ivan: ..."},
		MessageBox{message="Fleet: We were just--"},
		Do(function()
			scene.objectLookup.Sonic.sprite:setAnimation("foottap")
		end),
		PlayAudio("music", "sonicupset", 1, true),
		MessageBox{message="Sonic: I don't wanna hear it!"},
		MessageBox{message="Sonic: Looks like I'll just have to find Tails myself, {p60}before you two blow him to pieces!"},
		PlayAudio("sfx", "sonicrunturn", 1, true),
		Animate(scene.objectLookup.Sally.sprite, "sadright"),
		Parallel {
			Move(scene.objectLookup.Sonic, scene.objectLookup.SonicWP1, "juicecrouch"),
			MessageBox{message="Sally: Sonic, wait!"},
		},
		MessageBox{message="Sally: ...{p60}he never acts like this..."},
		Animate(scene.objectLookup.Ivan.sprite, "idleleft"),
		MessageBox{message="Ivan: ..."},
		MessageBox{message="Fleet: I didn't think he'd--"},
		Animate(scene.objectLookup.Sally.sprite, "frustratedright"),
		MessageBox{message="Sally: Ok, listen up! {p80}If all you two are going to do is cause trouble, then you can just head back to Knothole right now!"},
		Wait(0.5),
		PlayAudio("music", "royalwelcome", 1, true, true),
		Animate(scene.objectLookup.Sally.sprite, "thinking"),
		MessageBox{message="Sally: If you want to stay, {p60}you need to get serious about helping us find Tails!"},
		Wait(1),
		Animate(scene.objectLookup.Ivan.sprite, "attitude"),
		MessageBox{message="Ivan: We will stay."},
		Animate(scene.objectLookup.Fleet.sprite, "thinking"),
		MessageBox{message="Fleet: Yeah..."},
	}
end
