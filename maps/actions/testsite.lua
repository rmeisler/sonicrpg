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
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		scene.map.properties.regionName,
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

	if hint=="battletime" then
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			PlayAudio("sfx", "elevator", 1.0, true),
			Spawn(scene:screenShake(10, 30, 10)),
			Ease(scene.objectLookup.Rotor, "y", 476, 1, "linear"),
			PlayAudio("sfx", "bang", 1.0, true),
			Animate(scene.objectLookup.Rotor.sprite, "dead"),
			Wait(1),
			Animate(scene.objectLookup.Rotor.sprite, "idleleft"),
			Wait(0.5),
			Animate(scene.objectLookup.Rotor.sprite, "shock"),
			scene.objectLookup.Rotor:hop(),
			MessageBox{message="Rotor: Uh oh!!"},
			Wait(0.5),
			Ease(scene.objectLookup.Logan, "y", 476, 1, "linear"),
			PlayAudio("sfx", "bang", 1.0, true),
			Animate(scene.objectLookup.Logan.sprite, "idleleft"),
			MessageBox{message="Logan: Leavin' me out of the action?"},
			Animate(scene.objectLookup.Firebird.sprite, "iceattack"),
			Animate(scene.objectLookup.Logan.sprite, "shock"),
			scene.objectLookup.Logan:hop(),
			MessageBox{message="Logan: Crud."},
			scene:enterBattle{
				opponents = {"firebirdv1"},
				music = "boss",
				bossBattle = true
			}
		}
	else
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Spawn(Repeat(PlayAudio("sfx", "alert", 1.0))),
			Spawn(Repeat(PlayAudio("sfx", "elevator", 1.0))),
			Spawn(scene:screenShake(10, 30, 1000)),
			Wait(1),
			Parallel {
				Serial {
					MessageBox{message="Snively: *screams* {p60}T-T-Test subject 1-0241 has b-b-broken free from its holding chamber!!"},
					MessageBox{message="Snively: All S-S-SSwatbots report to Test Room C!!\n{p60}C-C-Contain {h Project Firebird}!!"}
				},
				Ease(scene.objectLookup.Snively, "x", function() return scene.objectLookup.Snively.x + 1200 end, 0.4, "linear")
			},
			Do(function()
				scene:changeScene{map="bartcave", hint="from_testsite"}
			end)
		}
	end
end
