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

	hint = hint or "from_bart_room"
	if hint == "ep4_bart_dies" then
		scene.audio:stopMusic()
		scene.objectLookup.Bart.hidden = false
		scene.objectLookup.Boulder.hidden = false
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Animate(scene.objectLookup.Bart.sprite, "dying"),
			Wait(2),
			Ease(scene.objectLookup.Sonic, "y", scene.objectLookup.Bart.y + 100, 2),
			Animate(scene.objectLookup.Sonic.sprite, "idleup"),
			Wait(1.5),
			MessageBox{message="Bart: S... {p60}Sonic... {p60}is that you, m-my boy?", textSpeed=2},
			PlayAudio("music", "bartsacrifice", 1.0, true),
			MessageBox{message="Sonic: Y-{p60}Y-Yeah... {p60}it's me, doc...", textSpeed=3},
			MessageBox{message="Sonic: *tears*{p60} I-I came here to take you home...", textSpeed=3},
			MessageBox{message="Bart: H-Heh...{p60} thank you, S-Sonic... {p60}but I'm already on my way home...", textSpeed=2},
			MessageBox{message="Sonic: ...", textSpeed=3},
			MessageBox{message="Bart: L-Let Rotor know...{p60} that I... {p60}I'm s-sorry... {p60}and that I'm p-proud of him... {p60}would you?", textSpeed=2},
			Wait(1),
			Animate(scene.objectLookup.Sonic.sprite, "cry"),
			MessageBox{message="Sonic: *tears* You got it, big guy...", textSpeed=3},
			Do(function()
				scene:changeScene{
					map="knothole",
					hint="ep4_end",
					spawnPoint="Ep4EndSpawn",
					fadeOutSpeed = 0.1,
					fadeInSpeed = 0.8,
					fadeOutMusic = true,
					enterDelay = 2
				}
			end)
		}
	elseif hint == "from_testsite" then
		local trapLayer
		for _,layer in pairs(scene.map.layers) do
			if layer.name == "trap" then
				trapLayer = layer
				break
			end
		end
		scene.objectLookup.Rotor.hidden = false
		scene.objectLookup.Bart.hidden = false
		scene.objectLookup.Bart.y = scene.objectLookup.Rotor.y + 120
		scene.objectLookup.Rotor.sprite:setAnimation("idledown")
		scene.objectLookup.Bart.sprite:setAnimation("idleup")
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Spawn(Repeat(PlayAudio("sfx", "elevator", 1.0))),
			Spawn(scene:screenShake(10, 30, 1000)),
			Wait(2),
			Animate(scene.objectLookup.Rotor.sprite, "shock"),
			-- Shake cave tile
			Parallel {
				Repeat(Serial {
					Ease(trapLayer, "offsetx", -1, 20),
					Ease(trapLayer, "offsetx", 1, 20)
				}, 30),
				Serial {
					MessageBox {message="Rotor: Pop-Pop!!", closeAction=Wait(0.5)},
					Animate(scene.objectLookup.Rotor.sprite, "walkdown", true),
					Ease(scene.objectLookup.Rotor, "y", function() return scene.objectLookup.Rotor.y + 120 end, 3),
					Ease(scene.objectLookup.Bart, "y", function() return scene.objectLookup.Bart.y + 120 end, 3),
				}
			},
			Do(function() trapLayer.offsetx=0 end),
			Animate(scene.objectLookup.Rotor.sprite, "shock"),
			Wait(0.5),
			Do(function()
				scene.objectLookup.Rotor.sprite:swapLayer("trapobjects")
			end),
			Parallel {
				Ease(trapLayer, "offsety", 100, 2),
				Ease(trapLayer, "opacity", 0, 0.5),
				Ease(scene.objectLookup.Rotor, "y", function() return scene.objectLookup.Rotor.y  + 1000 end, 1)
			},
			MessageBox {message="Bart: Rotor!!"},
			Do(function()
				scene:changeScene{map="testsite", hint="battletime"}
			end)
		}
	elseif hint == "from_bart_room" then
		scene.objectLookup.Rotor.hidden = false
		scene.objectLookup.Bart.hidden = false
		scene.objectLookup.Bart.y = scene.objectLookup.Rotor.y + 260
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(2),
			MessageBox {message="Rotor: ..."},
			Wait(1),
			Do(function()
				scene.objectLookup.Bart.sprite:setAnimation("walkup")
			end),
			Ease(scene.objectLookup.Bart, "y", function() return scene.objectLookup.Bart.y - 140 end, 1, "linear"),
			Do(function()
				scene.objectLookup.Bart.sprite:setAnimation("idleup")
			end),
			MessageBox {message="Bart: Rotor..."},
			MessageBox {message="Rotor: ..."},
			Wait(1),
			PlayAudio("music", "bartsomber", 1.0, true, true),
			MessageBox {message="Rotor: Why are you doing this, Pop-Pop?"},
			Wait(1),
			MessageBox {message="Bart: ..."},
			MessageBox {message="Rotor: The Freedom Fighters will find some other way of defeating {h Project Firebird}! {p60}You don't need to\ndo this!!"},
			Wait(1),
			MessageBox {message="Bart: ..."},
			MessageBox {message="Rotor: Am I so unimportant to you that you'd rather die a martyr than live out the rest of your life in Knothole with me?"},
			scene.objectLookup.Bart:hop(),
			MessageBox {message="Bart: Of course not!"},
			scene.objectLookup.Rotor:hop(),
			Animate(scene.objectLookup.Rotor.sprite, "idledown"),
			MessageBox {message="Bart: You have it all wrong, my dear child!"},
			MessageBox {message="Bart: I have to do this because... {p60}because...", textSpeed=3},
			scene.objectLookup.Bart:hop(),
			MessageBox {message="Bart: Because I failed you! {p60}I failed everyone!"},
			Animate(scene.objectLookup.Bart.sprite, "idledown"),
			MessageBox {message="Bart: Had I stopped Julian back when you were young, you would not have had to grow up in this terrible world!"},
			MessageBox {message="Bart: You would have had a future! {p60}You would have been able to study archeology and carry on the\nfamily legacy!!"},
			Wait(1),
			MessageBox {message="Rotor: ...You know I never wanted to be an archeologist, Pop-Pop..."},
			AudioFade("music", 1.0, 0.0, 0.5),
			scene.objectLookup.Bart:hop(),
			Animate(scene.objectLookup.Bart.sprite, "pose"),
			MessageBox {message="Bart: ...{p60}Ha ha! {p60}Ah yes...{p60} you take too much after your father..."},
			Animate(scene.objectLookup.Bart.sprite, "idledown"),
			PlayAudio("music", "rotorsentimental", 1.0, true),
			MessageBox {message="Rotor: It's ok, Pop-Pop. {p60}Ya know{p60}, I've actually been able to live a pretty great life in Knothole{p60}, all things considered..."},
			MessageBox {message="Rotor: If you want to make it up to me, Pop-Pop, come home with me!"},
			Wait(2),
			Animate(scene.objectLookup.Bart.sprite, "idleup"),
			Wait(1),
			MessageBox {message="Bart: ...I--", textSpeed=3},
			Spawn(Repeat(PlayAudio("sfx", "elevator", 1.0))),
			Spawn(scene:screenShake(10, 30, 1000)),
			Wait(1),
			MessageBox {message="Rotor: Whoah! {p60}What's going on??", closeAction=Wait(1)},
			Wait(0.3),
			PlayAudio("music", "darkintro", 1.0, true, true),
			MessageBox {message="Bart: {h Project Firebird}!!", closeAction=Wait(2)},
			Do(function()
				scene:changeScene{map="testsite"}
			end)
		}
	end

	scene.audio:stopMusic()
	return Action()
end
