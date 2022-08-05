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
local Move = require "actions/Move"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local BlockPlayer = require "actions/BlockPlayer"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"

return function(scene, hint)
	if hint == "fromworldmap" then
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
			"B's Hideout",
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
	end
	
	if hint == "fromrace" then
		local walkout, walkin, sprites = scene.player:split()
		scene.player.state = "idleleft"
		scene.objectLookup.R.sprite:setAnimation("idleright")
		scene.objectLookup.J.sprite:setAnimation("jright")
		return BlockPlayer {
			PlayAudio("music", "forgottenhideout2", 1.0, true, true),
			walkout,
			Animate(sprites.sonic.sprite, "idleleft"),
			Animate(sprites.sally.sprite, "idleleft"),
			Animate(sprites.antoine.sprite, "idleleft"),
			Wait(1),
			Ease(scene.objectLookup.R, "y", function() return scene.objectLookup.R.y - 50 end, 8),
			Ease(scene.objectLookup.R, "y", function() return scene.objectLookup.R.y + 50 end, 8),
			MessageBox{message="R: I-I did it!! {p60}I won!"},
			MessageBox{message="J: I knew you could do it, mate!!"},
			MessageBox{message="R: *whisper* Hey Sonic... {p60}I know ya did that to help me with J..."},
			Animate(sprites.sonic.sprite, "earnestleft"),
			MessageBox{message="Sonic: *whisper* Was it that obvious?"},
			MessageBox{message="R: *whisper* And umm... {p60}I think I feel better about going to Knothole now..."},
			MessageBox{message="R: *whisper* This race helped me see that I can count on me! {p60}Even though it's scary to move away{p60}, it'll be ok! {p60}Right?"},			
			Animate(sprites.sonic.sprite, "smileleft"),
			MessageBox{message="Sonic: *whisper* You got it, little buddy!"},
			Ease(scene.objectLookup.R, "y", function() return scene.objectLookup.R.y - 50 end, 8),
			Ease(scene.objectLookup.R, "y", function() return scene.objectLookup.R.y + 50 end, 8),
			MessageBox{message="R: You can tell B that I'm in too!"},
			PlayAudio("sfx", "levelup", 1.0, true),
			Ease(scene.objectLookup.J, "y", function() return scene.objectLookup.J.y - 50 end, 8),
			Ease(scene.objectLookup.J, "y", function() return scene.objectLookup.J.y + 50 end, 8),
			MessageBox{message="J: Wow! {p60}Alright R! {p60}You won't regret it mate!"},
			Animate(scene.objectLookup.R.sprite, "idleleft"),
			Wait(1),
			Animate(sprites.sally.sprite, "idleup"),
			MessageBox{message="Sally: I saw you slow down at the end there. {p60}For such a 'way past' guy, you sure are a softie."},
			Animate(sprites.sonic.sprite, "idledown"),
			MessageBox{message="Sonic: Say wha? {p60}I ain't no softie! {p60}Maybe I'm just not as fast as I used to be..."},
			Animate(sprites.sally.sprite, "thinking_laugh"),
			MessageBox{message="Sally: *chuckles* Whatever you say, Sonic Hedgehog."},
			walkin,
			Do(function()
				scene.player.x = scene.player.x + 60
				scene.player.y = scene.player.y + 60
			end)
		}
	end
	
	return PlayAudio("music", "forgottenhideout2", 1.0, true, true)
end
