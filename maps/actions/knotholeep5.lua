return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local Animate = require "actions/Animate"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local MessageBox = require "actions/MessageBox"
	local AudioFade = require "actions/AudioFade"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Great Forest",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Knothole",
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
	
	if hint == "epilogue_leon" then
		scene.objectLookup.Leon_Epilogue2.hidden = false
		scene.objectLookup.Fleet_Epilogue2.hidden = false
		scene.objectLookup.Ivan_Epilogue2.hidden = false
		
		scene.objectLookup.Leon_Epilogue2.movespeed = 1.5
		scene.objectLookup.Fleet_Epilogue2.movespeed = 2
		scene.objectLookup.Ivan_Epilogue2.movespeed = 2

		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Parallel {
				Move(scene.objectLookup.Fleet_Epilogue2, scene.objectLookup.FleetWP1, "walk"),
				Move(scene.objectLookup.Ivan_Epilogue2, scene.objectLookup.IvanWP1, "walk")
			},
			Animate(scene.objectLookup.Fleet_Epilogue2.sprite, "idleup"),
			Animate(scene.objectLookup.Ivan_Epilogue2.sprite, "idleup"),
			MessageBox{message="Leon: Why if it isn't my two greatest soldiers...{p60} or who I thought were my two greatest soldiers..."},
			Parallel {
				scene.objectLookup.Fleet_Epilogue2:hop(),
				scene.objectLookup.Ivan_Epilogue2:hop(),
			},
			Animate(scene.objectLookup.Fleet_Epilogue2.sprite, "idleleft"),
			Animate(scene.objectLookup.Ivan_Epilogue2.sprite, "idleleft"),
			Move(scene.objectLookup.Leon_Epilogue2, scene.objectLookup.LeonWP1, "walk"),
			Animate(scene.objectLookup.Leon_Epilogue2.sprite, "idleright"),
			MessageBox{message="Ivan: Sir."},
			MessageBox{message="Fleet: Sir, I can explain--"},
			MessageBox{message="Leon: It seems that the anarchy of this quaint little hamlet has been rubbing off on you..."},
			MessageBox{message="Leon: You no longer respect my orders--"},
			Parallel {
				scene.objectLookup.Fleet_Epilogue2:hop(),
				MessageBox{message="Fleet: No, sir--"}
			},
			Animate(scene.objectLookup.Leon_Epilogue2.sprite, "glareright"),
			MessageBox{message="Leon: Do not interrupt me, lieutenant!"},
			Wait(1),
			PlayAudio("music", "leonintro", 0.8, true, true),
			MessageBox{message="Leon: ...you were nothing when I found you! {p60}Never forget that!"},
			Wait(1),
			Move(scene.objectLookup.Leon_Epilogue2, scene.objectLookup.LeonWP2, "walk"),
			Animate(scene.objectLookup.Leon_Epilogue2.sprite, "idleright"),
			MessageBox{message="Leon: Did Logan, put you up to this?"},
			Animate(scene.objectLookup.Ivan_Epilogue2.sprite, "attitude"),
			MessageBox{message="Ivan: Sir--"},
			Animate(scene.objectLookup.Fleet_Epilogue2.sprite, "thinking"),
			MessageBox{message="Fleet: It was my idea, sir. {p60}I felt it necessary to keep an eye on the Princess."},
			MessageBox{message="Leon: ...{p60}A wise decision..."},
			Animate(scene.objectLookup.Leon_Epilogue2.sprite, "glareright"),
			MessageBox{message="Leon: But a decision you did not have the authority to make."},
			MessageBox{message="Fleet: Y-Yes sir{p60}, I'm sorry sir."},
			MessageBox{message="Leon: Do not forget why we are here..."},
			Do(function()
				scene:changeScene{map="ep5intro", fadeOutSpeed=0.5, fadeInSpeed=0.5, hint="epilogue2", fadeOutMusic=true}
			end)
		}
	end
	
	if hint == "ep5_epilogue" then
		scene.objectLookup.Sally_Epilogue.hidden = false
		scene.objectLookup.Sonic_Epilogue.hidden = false
		scene.objectLookup.Fleet_Epilogue.hidden = false
		scene.objectLookup.Ivan_Epilogue.hidden = false
		scene.objectLookup.B_Epilogue.hidden = false
		scene.objectLookup.Tails_Epilogue.hidden = false
		scene.objectLookup.Firefly:remove()
		scene.objectLookup.IntroTrigger:remove()

		scene.objectLookup.Sally_Epilogue.sprite:setFadeWhite(4)
		scene.objectLookup.Sonic_Epilogue.sprite:setFadeWhite(4)
		scene.objectLookup.Fleet_Epilogue.sprite:setFadeWhite(4)
		scene.objectLookup.Ivan_Epilogue.sprite:setFadeWhite(4)
		scene.objectLookup.B_Epilogue.sprite:setFadeWhite(4)
		scene.objectLookup.Tails_Epilogue.sprite:setFadeWhite(4)
		scene.objectLookup.Sally_Epilogue.sprite.color[4] = 0
		scene.objectLookup.Sonic_Epilogue.sprite.color[4] = 0
		scene.objectLookup.Fleet_Epilogue.sprite.color[4] = 0
		scene.objectLookup.Ivan_Epilogue.sprite.color[4] = 0
		scene.objectLookup.B_Epilogue.sprite.color[4] = 0
		scene.objectLookup.Tails_Epilogue.sprite.color[4] = 0
		
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(3),
			Parallel {
				Ease(scene.objectLookup.Sally_Epilogue.sprite.color, 4, 255, 1),
				Ease(scene.objectLookup.Sonic_Epilogue.sprite.color, 4, 255, 1),
				Ease(scene.objectLookup.Fleet_Epilogue.sprite.color, 4, 255, 1),
				Ease(scene.objectLookup.Ivan_Epilogue.sprite.color, 4, 255, 1),
				Ease(scene.objectLookup.B_Epilogue.sprite.color, 4, 255, 1),
				Ease(scene.objectLookup.Tails_Epilogue.sprite.color, 4, 255, 1),
			},
			Do(function()
				scene.objectLookup.Sally_Epilogue.sprite:setFadeWhite(-1,1)
				scene.objectLookup.Sonic_Epilogue.sprite:setFadeWhite(-1,1)
				scene.objectLookup.Fleet_Epilogue.sprite:setFadeWhite(-1,1)
				scene.objectLookup.Ivan_Epilogue.sprite:setFadeWhite(-1,1)
				scene.objectLookup.B_Epilogue.sprite:setFadeWhite(-1,1)
				scene.objectLookup.Tails_Epilogue.sprite:setFadeWhite(-1,1)
			end),
			MessageBox{message="Fleet: What the- {p60}how did we get back to Knothole?"},
			Animate(scene.objectLookup.B_Epilogue.sprite, "pose"),
			MessageBox{message="B: Tails must have made it to the Light!"},
			PlayAudio("sfx", "bang", 1, true),
			Animate(scene.objectLookup.Tails_Epilogue.sprite, "dead"),
			Wait(0.5),
			Parallel {
				scene.objectLookup.Sonic_Epilogue:hop(),
				scene.objectLookup.Sally_Epilogue:hop(),
				scene.objectLookup.Fleet_Epilogue:hop(),
				scene.objectLookup.Ivan_Epilogue:hop(),
				scene.objectLookup.B_Epilogue:hop()
			},
			Animate(scene.objectLookup.B_Epilogue.sprite, "idleright"),
			Animate(scene.objectLookup.Sonic_Epilogue.sprite, "sadright"),
			Animate(scene.objectLookup.Sally_Epilogue.sprite, "sadright"),
			PlayAudio("music", "sonicsad", 1, true, true),
			MessageBox{message="Sonic & Sally: Tails!"},
			Parallel {
				Serial {
					Move(scene.objectLookup.Sonic_Epilogue, scene.objectLookup.EpilogueWP2, "walk"),
					Animate(scene.objectLookup.Sonic_Epilogue.sprite, "worrieddown")
				},
				Serial {
					Move(scene.objectLookup.Sally_Epilogue, scene.objectLookup.EpilogueWP3, "walk"),
					Animate(scene.objectLookup.Sally_Epilogue.sprite, "sadleft")
				},
				Serial {
					Move(scene.objectLookup.B_Epilogue, scene.objectLookup.EpilogueWP1, "walk"),
					Animate(scene.objectLookup.B_Epilogue.sprite, "idleright")
				}
			},
			Animate(scene.objectLookup.Fleet_Epilogue.sprite, "sadleft"),
			Animate(scene.objectLookup.Ivan_Epilogue.sprite, "attitude"),
			MessageBox{message="Sonic: W-What happened to him?!"},
			Animate(scene.objectLookup.Sally_Epilogue.sprite, "nicholedown"),
			Animate(scene.objectLookup.Sonic_Epilogue.sprite, "sadright"),
			MessageBox{message="Sally: Nicole?!"},
			MessageBox{message="Nicole: According to legend{p60}, those who communicate with the Light of Mobius undergo extreme physical\nstress{p40}, Sally.", sfx="nicolebeep"},
			Animate(scene.objectLookup.Sonic_Epilogue.sprite, "worrieddown"),
			MessageBox{message="Sonic: Tails{p60}, please wake up lil' bro... {p60}I can't lose you..."},
			Animate(scene.objectLookup.Fleet_Epilogue.sprite, "idledown"),
			scene.objectLookup.Fleet_Epilogue:hop(),
			MessageBox{message="Fleet: Alright now{p60}, out of the way!"},
			Parallel {
				Move(scene.objectLookup.Fleet_Epilogue, scene.objectLookup.EpilogueWP2, "walk"),
				Move(scene.objectLookup.Sonic_Epilogue, scene.objectLookup.EpilogueWP4, "walk"),
				Move(scene.objectLookup.B_Epilogue, scene.objectLookup.EpilogueWP7, "walk")
			},
			Animate(scene.objectLookup.Sonic_Epilogue.sprite, "sadright"),
			Animate(scene.objectLookup.Fleet_Epilogue.sprite, "kneeldown"),
			Animate(scene.objectLookup.B_Epilogue.sprite, "idleright"),
			Animate(scene.objectLookup.Sally_Epilogue.sprite, "sadleft"),
			Do(function()
				scene.objectLookup.Fleet_Epilogue.x = scene.objectLookup.Fleet_Epilogue.x + 20
				scene.objectLookup.Fleet_Epilogue.y = scene.objectLookup.Fleet_Epilogue.y + 10
			end),
			MessageBox{message="Fleet: Look, he's got a pulse. {p60}He's still with us."},
			MessageBox{message="Fleet: Ivan, can you take him inside?{p60} I'll need my\nmed-kit..."},
			Animate(scene.objectLookup.Ivan_Epilogue.sprite, "idledown"),
			scene.objectLookup.Ivan_Epilogue:hop(),
			MessageBox{message="Ivan: Affirmative."},
			Parallel {
				Move(scene.objectLookup.Ivan_Epilogue, scene.objectLookup.EpilogueWP6, "walk"),
				Move(scene.objectLookup.Sally_Epilogue, scene.objectLookup.EpilogueWP5, "walk"),
			},
			Animate(scene.objectLookup.Ivan_Epilogue.sprite, "carry_tails"),
			Animate(scene.objectLookup.Fleet_Epilogue.sprite, "idledown"),
			Do(function() scene.objectLookup.Tails_Epilogue:remove() end),
			Animate(scene.objectLookup.Sally_Epilogue.sprite, "sadleft"),
			Animate(scene.objectLookup.Sonic_Epilogue.sprite, "thinking"),
			scene.objectLookup.Sonic_Epilogue:hop(),
			MessageBox{message="Sonic: Wait-- {p60}you--{p60} a medic?"},
			Animate(scene.objectLookup.Fleet_Epilogue.sprite, "thinking"),
			MessageBox{message="Fleet: That's right. {p60}Got a problem with that?"},
			Animate(scene.objectLookup.Sonic_Epilogue.sprite, "earnestright"),
			MessageBox{message="Sonic: No no no{p60}, it's cool."},
			Animate(scene.objectLookup.Fleet_Epilogue.sprite, "idledown"),
			MessageBox{message="Fleet: Right. {p60}Let's get to work, Ivan!"},
			Do(function()
				scene:changeScene{map="ep5intro", fadeOutSpeed=0.5, fadeInSpeed=0.5, hint="epilogue1"}
			end)
		}
	end
	
	if hint == "meanwhile_1" then
		scene.objectLookup.Sally_Meanwhile1.hidden = false
		scene.objectLookup.Sonic_Meanwhile1.hidden = false
		scene.objectLookup.Fleet_Meanwhile1.hidden = false
		scene.objectLookup.Ivan_Meanwhile1.hidden = false
		scene.objectLookup.Logan_Meanwhile1.hidden = false

		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true

				scene.camPos.x = -260
				scene.objectLookup.Sonic_Meanwhile1.movespeed = 20
			end),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "idleright"),
			Wait(3),
			PlayAudio("music", "concerning", 1, true),
			Parallel {
				Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "shoutupright"),
				MessageBox{message="Sally: Tails!"}
			},
			Wait(2),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "shoutdownleft"),
			MessageBox{message="Sally: Taaaails!"},
			Wait(1),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "worriedleft"),
			MessageBox{message="Sally: Where could that boy be..."},
			Wait(1),
			-- Sonic races onto screen
			PlayAudio("sfx", "sonicrunturn", 1, true),
			Move(scene.objectLookup.Sonic_Meanwhile1, scene.objectLookup.Sonic_Meanwhile1_WP, "juice"),
			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "idledown"),
			MessageBox{message="Sonic: Yo Sal! {p60}I found this piece of Tails' fur in the Great Jungle."},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "idleup"),
			scene.objectLookup.Sally_Meanwhile1:hop(),
			MessageBox{message="Sally: The Great Jungle?..."},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "thinking"),
			MessageBox{message="Sally: Now why would he...", closeAction=Wait(1)},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "shock"),
			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "worrieddown"),
			Parallel {
				scene.objectLookup.Sally_Meanwhile1:hop(),
				MessageBox{message="Sally: Oh no, Sonic... {p60}he's going to Boulder Bay to try to find the {h Light of Mobius}!"}
			},
			Wait(0.5),
			MessageBox{message="Fleet: So the kid's headed out on his own adventure, huh?"},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "idleleft"),
			Ease(scene.camPos, "x", 0, 1),
			PlayAudio("music", "introspection", 1, true),
			Wait(1),
			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "irritated"),
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "irritated"),
			MessageBox{message="Logan: Fleet."},
			Parallel {
				Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "shock"),
				scene.objectLookup.Fleet_Meanwhile1:hop()
			},
			Wait(0.5),
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "lookleft"),
			MessageBox{message="Fleet: What? {p40}Now that you're all buddy-buddy with the walrus, you can't take a joke?"},
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "blush"),
			MessageBox{message="Logan: *blush*"},
			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "attitude"),
			MessageBox{message="Sonic: This is serious bird-brain! {p60}Tails could be in mondo trouble!"},
			Wait(0.5),
			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "idleleft"),
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "idledown"),
			Animate(scene.objectLookup.Ivan_Meanwhile1.sprite, "attitude"),
			MessageBox{message="Ivan: From my research, Boulder Bay has been a peaceful land since the end of the Great War. {p40}The child may be missing, but it is unlikely that he is harmed."},
			Wait(0.5),
			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "attitude"),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "idleup"),
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "idleright"),
			MessageBox{message="Sonic: Oh yeah? {p60}Well, guess what else I saw..."},
			MessageBox{message="Sonic: Swatbots!{p60} The place is crawling with them! {p60}Along with other Robuttnik junk..."},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "shock"),
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "shock"),
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "shock"),
			Parallel {
				scene.objectLookup.Sally_Meanwhile1:hop(),
				scene.objectLookup.Fleet_Meanwhile1:hop(),
				scene.objectLookup.Logan_Meanwhile1:hop(),
			},
			Wait(1),
			MessageBox{message="Ivan: That is indeed shocking news."},
			Wait(0.5),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "idleleft"),
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "lookleft"),
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "sadleft"),
			MessageBox{message="Logan: ...{p60}and he's out there all alone?..."},
			Wait(0.5),

			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "smileleft"),
			MessageBox{message="Sonic: Yeah! So we better juice!"},
			MessageBox{message="Sonic: Ivan{p60}, Logan{p60}, bird-brain{p60}-- you comin'?"},
			Wait(0.5),
			Animate(scene.objectLookup.Ivan_Meanwhile1.sprite, "idleright"),
			MessageBox{message="Ivan: We have strict orders from our Commander to stay put."},
			Wait(0.5),
			MessageBox{message="Fleet: Seems to be a whole lot of \"not my problem\", {p60}so I think that I'll just--"},
			Wait(0.5),
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "attitude"),
			MessageBox{message="Logan: You two should go with them. {p60}I need to stay to help finalize the virus."},
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "idleup"),
			Parallel {
				scene.objectLookup.Fleet_Meanwhile1:hop(),
				MessageBox{message="Fleet: What!? {p60}But Leon said--", closeAction=Wait(1)}
			},
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "irritated"),
			MessageBox{message="Logan: Look, I know you're loyal to Leon... {p60}but this kid needs our help."},
			Parallel {
				Serial {
					MessageBox{message="Logan: Could you at least just tag along... {p60}for me?"},
					scene.objectLookup.Fleet_Meanwhile1:hop(),
					Wait(2),
					Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "frustrated"),
					MessageBox{message="Fleet: Ugh, fine!"},
					Wait(0.5),
					Animate(scene.objectLookup.Ivan_Meanwhile1.sprite, "attitude"),
					MessageBox{message="Ivan: Affirmative, we will accompany you."}
				},
				PlayAudio("music", "rotorsentimental", 1)
			},
			PlayAudio("music", "royalwelcome", 1, true, true),
			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "smileleft"),
			MessageBox{message="Sonic: Way past! {p60}Alright, let's do it to it!"},
			Wait(0.5),
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "smirkright"),
			MessageBox{message="Fleet: Yeah, I mean, couldn't let only you two head off. {p60}After all, with a slowpoke like you as his only help, that kid might as well be doomed."},
			Animate(scene.objectLookup.Sonic_Meanwhile1.sprite, "crouchleft"),
			MessageBox{message="Sonic: We'll see about that!"},
			Wait(0.5),
			MessageBox{message="Sonic: Race ya to Boulder Bay!"},
			MessageBox{message="Fleet: You're on, hog!"},
			Wait(0.5),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "thinking2"),
			MessageBox{message="Sally: Yours' always like this too?"},
			MessageBox{message="Ivan: You have no idea..."},
			Do(function()
				-- Change scene to Boulder Bay
				local mapName = "maps/boulderbay1.lua"
				scene.sceneMgr:switchScene {
					class = "BasicScene",
					map = scene.maps[mapName],
					mapName = mapName,
					maps = scene.maps,
					images = scene.images,
					region = scene.region,
					animations = scene.animations,
					audio = scene.audio,
					hint = "from_cinematic",
					tutorial = false,
					fadeOutSpeed = 0.2,
					fadeInSpeed = 0.2,
					fadeOutMusic = true,
					cache = false,
					nighttime = false,
					enterDelay = 1
				}
			end)
		}
	end

	if not GameState:isFlagSet("ep5_knothole_firefly_trigger") and not GameState:isFlagSet("ep5_knothole_meeting_trigger") then
		scene.audio:playMusic("knothole", 1.0)
	end

	return Action()
end
