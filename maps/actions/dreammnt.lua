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
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Mountain of",
		100
	)
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Dreams",
		100
	)
	local titleAnim = Spawn(Serial {
		Wait(0.5),
		Parallel {
			subtext,
			text
		},
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

	local waterfallLayer1 = scene:findLayer("waterfall1")
	local waterfallLayer2 = scene:findLayer("waterfall2")
	local waterfallAnim = Spawn(
		Repeat(Serial {
			Do(function()
				waterfallLayer1.opacity = 0.7
				waterfallLayer2.opacity = 0
			end),
			Wait(0.2),
			Do(function()
				waterfallLayer1.opacity = 0
				waterfallLayer2.opacity = 0.7
			end),
			Wait(0.2),
		}, 1000000)
	)
	
	if hint == "from_cinematic" then
		local walkout, walkin, sprites = scene.player:split(nil, true)
		for k in pairs(GameState.party) do
			sprites[k].x = scene.player.x - 60
			sprites[k].y = scene.player.y - 60
		end
		
		scene.camPos.y = -50

		return BlockPlayer {
			waterfallAnim,
			walkout,
			Animate(sprites.tails.sprite, "idleup"),
			Animate(sprites.b.sprite, "idleup"),
			Animate(sprites.babyt.sprite, "idleup"),

			titleAnim,
			Wait(2),
			PlayAudio("music", "dreammountain", 1, true, true),
			Wait(1),

			MessageBox{message="Tails: In the story it looks like Ben and the Inventor Knight enter the cave right over there..."},
			
			Parallel {
				Ease(scene.camPos, "x", -1500, 0.3),
				Ease(scene.camPos, "y", 2000, 0.3)
			},
			Wait(1),
			MessageBox{message="Baby T: I've always wondered what was up with this pretty green mountain!"},
			Parallel {
				Ease(scene.camPos, "x", 0, 0.6),
				Ease(scene.camPos, "y", -50, 0.6)
			},
			Wait(1),
			Animate(sprites.b.sprite, "pose"),
			MessageBox{message="B: Listen youngsters..."},
			Animate(sprites.tails.sprite, "idleleft"),
			Animate(sprites.babyt.sprite, "idleleft"),
			MessageBox{message="B: There's a real possibility that we don't make it back from this..."},
			MessageBox{message="B: And in case I don't have another chance to say this, I want you both to know how grateful I am that I came with you on this adventure..."},
			Animate(sprites.tails.sprite, "shock"),
			Parallel {
				sprites.tails:hop(),
				MessageBox{message="Tails: Really!? {p60}You're not mad that we got you wrapped up in all this?"}
			},
			Animate(sprites.tails.sprite, "idleleft"),
			Animate(sprites.b.sprite, "idleright"),
			MessageBox{message="B: Ha ha! Not at all! {p60}On the contrary, I think all this excitement has perhaps awakened a hint as to who I used to be-- {p60}before being roboticized."},
			Animate(sprites.b.sprite, "pose"),
			MessageBox{message="B: I think... {p60}I was an adventurer..."},
			Animate(sprites.tails.sprite, "victory"),
			Parallel {
				sprites.tails:hop(),
				MessageBox{message="Tails: That's way past cool, B!! {p60}I bet you were!"}
			},
			Animate(sprites.babyt.sprite, "victory"),
			Parallel {
				sprites.babyt:hop(),
				MessageBox{message="Baby T: Whoever you used to be, {p60}we're all adventurers now!"}
			},
			MessageBox{message="Baby T: Look out Robotnik, here we come!"},
			Parallel {
				walkin,
				Ease(scene.camPos, "y", 0, 1)
			}
		}
	else
		return Serial {
			waterfallAnim,
			titleAnim,
			PlayAudio("music", "dreammountain", 1, true, true),
		}
	end
end
