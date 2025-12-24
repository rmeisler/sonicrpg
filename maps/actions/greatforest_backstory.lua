return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local BlockPlayer = require "actions/BlockPlayer"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local Repeat = require "actions/Repeat"
	local Animate = require "actions/Animate"
	local Move = require "actions/Move"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	if scene.player then
	    scene.player.dustColor = Player.FOREST_DUST_COLOR
	end
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"5 years ago...",
		100
	)

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(2),
		Spawn(Serial {
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		}),
		Do(function()
			scene.objectLookup.Tails.movespeed = 1
		end),
		PlayAudio("music", "sonicsad", 1, true, true),
		Move(scene.objectLookup.Tails, scene.objectLookup["Spawn 1"], "youngwalk"),
		Animate(scene.objectLookup.Tails.sprite, "youngdown"),
		Wait(2),
		Animate(scene.objectLookup.Tails.sprite, "youngdownsad"),
		MessageBox{message="Fox Boy: *sob* M-Mommy..."},
		Wait(1),
		MessageBox{message="Whoah!"},
		Animate(scene.objectLookup.Tails.sprite, "youngdownscared"),
		Do(function()
			scene.objectLookup.Sonic.movespeed = 30
		end),
		PlayAudio("sfx", "sonicrunturn", 1, true),
		Parallel {
			scene.objectLookup.Tails:hop(),
			Move(scene.objectLookup.Sonic, scene.objectLookup.SonicWP, "juiceup")
		},
		Animate(scene.objectLookup.Sonic.sprite, "idleup"),
		Wait(1),
		Animate(scene.objectLookup.Tails.sprite, "youngleapright"),
		Parallel {
			Ease(scene.objectLookup.Tails, "x", function() return scene.objectLookup.Tails.x + 100 end, 3),
			Serial {
				Ease(scene.objectLookup.Tails, "y", function() return scene.objectLookup.Tails.y - 64 end, 6),
				Ease(scene.objectLookup.Tails, "y", function() return scene.objectLookup.Tails.y + 64 end, 6)
			}
		},
		Animate(scene.objectLookup.Tails.sprite, "younglookleft"),

		Wait(1),
		Move(scene.objectLookup.Sonic, scene.objectLookup.SonicWP2, "juiceup"),
		Animate(scene.objectLookup.Sonic.sprite, "youngsmile"),
		MessageBox{message="Sonic: Hey hey hey{p60}, it's ok! {p60}I'm not gonna hurt you."},
		Ease(scene.objectLookup.Tails, "x", function() return scene.objectLookup.Tails.x - 10 end, 1),
		MessageBox{message="Sonic: My name's Sonic! {p60}What's yours?"},
		Wait(1),
		MessageBox{message="Fox Boy: ..."},
		Wait(1),
		MessageBox{message="Sonic: Not a big talker, are ya?"},
		Wait(1),
		Animate(scene.objectLookup.Sonic.sprite, "youngsurprise"),
		MessageBox{message="Sonic: Yo, {p60}are you all alone out here?"},
		Wait(1),
		MessageBox{message="Fox Boy: ..."},
		Wait(1),
		MessageBox{message="Sonic: I understand...{p60}they took my uncle away...{p60}\nwho did they take from you?"},
		Wait(1),
		MessageBox{message="Fox Boy: ...{p60}m-{p40}my {p40}mom."},
		Wait(2),
		Animate(scene.objectLookup.Sonic.sprite, "youngnice"),
		MessageBox{message="Sonic: Look-- {p60}uh... {p60}why don't ya come back to Knothole with me, lil' bro?"},
		MessageBox{message="Sonic: We got a way past cool community over there! {p60}Plenty of food{p60}, and we can even make you a hut--"},
		-- Tails hugs Sonic tight
		Ease(scene.objectLookup.Tails, "x", scene.objectLookup.Sonic.x, 5),
		Do(function()
			scene.objectLookup.Tails:remove()
		end),
		Animate(scene.objectLookup.Sonic.sprite, "younghug1"),
		Wait(2),
		Animate(scene.objectLookup.Sonic.sprite, "younghug2"),
		MessageBox{message="Sonic: Y-You'll be ok from now on."},
		Do(function() scene.sceneMgr:popScene{hint="from_flashback"} end)
	}
end
