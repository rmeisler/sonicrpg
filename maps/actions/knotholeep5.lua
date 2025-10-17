return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local Animate = require "actions/Animate"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local BlockPlayer = require "actions/BlockPlayer"
	local MessageBox = require "actions/MessageBox"
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
			end),
			Wait(2),
			PlayAudio("music", "concerning", 1, true),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "shoutupright"),
			MessageBox{message="Sally: Tails!"},
			Wait(1),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "shoutdownleft"),
			MessageBox{message="Sally: Taaaails!"},
			Wait(1),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "worriedleft"),
			MessageBox{message="Sally: Where could that boy be..."},
			Wait(2),
			-- Sonic races onto screen
			MessageBox{message="Sonic: Yo Sal! {p60}I found this piece of Tails' fur in the Great Jungle."},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "thinking"),
			MessageBox{message="Sally: The Great Jungle? {p60}Now why would he...", closeAction=Wait(1)},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "shock"),
			MessageBox{message="Sally: Oh no, Sonic..."},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "idleup"),
			MessageBox{message="Sally: He's going to Boulder Bay to try to find the {h Light of Mobius}!"},
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "smirkright"),
			MessageBox{message="Fleet: So the kid's headed out on his own adventure, huh?"},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "idleleft"),
			Wait(0.5),
			MessageBox{message="Logan: Fleet."},
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "shock"),
			Wait(0.5),
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "lookleft"),
			MessageBox{message="Fleet: What? {p40}Now that you're all buddy-buddy with the walrus, you can't take a joke?"},
			MessageBox{message="Sonic: This is serious bird-brain! {p60}Tails could be in mondo trouble!"},
			Wait(0.5),
			Animate(scene.objectLookup.Ivan_Meanwhile1.sprite, "attitude"),
			MessageBox{message="Ivan: From my research, Boulder Bay has been a peaceful land since the end of the Great War. {p40}The child may be missing, but it is unlikely that he is harmed."},
			Wait(0.5),
			MessageBox{message="Sonic: Oh yeah? {p60}Well, guess what else I saw... {p60}Swatbots!{p60} The place is crawling with them, along with other Robuttnik junk!"},
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "shock"),
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "shock"),
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "shock"),
			Wait(0.5),
			MessageBox{message="Ivan: That is shocking news."},
			Wait(0.5),
			Animate(scene.objectLookup.Sally_Meanwhile1.sprite, "thinking"),
			Animate(scene.objectLookup.Fleet_Meanwhile1.sprite, "lookleft"),
			Animate(scene.objectLookup.Logan_Meanwhile1.sprite, "attitude"),
			MessageBox{message="Logan: ...{p60}and he's out there all alone?..."},
			Wait(0.5),
			MessageBox{message="Sonic: Yeah! So we better juice!"},
			MessageBox{message="Sonic: Ivan, Logan, bird-brain– you comin'?"},
			Wait(0.5),
			MessageBox{message="Ivan: We have strict orders from our Commander to stay put."},
			Wait(0.5),
			MessageBox{message="Fleet: Seems to be a whole lot of \"not my problem\"{p60}, so I think that I'll just--"},
			Wait(0.5),
			MessageBox{message="Logan: You two should go with them. {p60}I need to stay to help finalize the virus."},
			MessageBox{message="Fleet: What!? {p60}But Leon said--", closeAction=Wait(1)},
			MessageBox{message="Logan: Look, I know you're loyal to Leon... {p60}but this kid needs our help. {p60}Could you at least just tag along... {p60}for me?"},
			Wait(0.5),
			MessageBox{message="Fleet: Ugh, fine!"},
			Wait(0.5),
			MessageBox{message="Ivan: Affirmative, we will accompany you."},
			MessageBox{message="Sonic: Way past! {p60}Alright, let's do it to it!"},
			Wait(0.5),
			MessageBox{message="Fleet: Yeah, I mean, couldn't let only you two head off. {p60}After all, with a slowpoke like you as his only help, that kid might as well be doomed."},
			MessageBox{message="Sonic: We'll see about that!"},
			Wait(0.5),
			MessageBox{message="Sonic: Race ya to Boulder Bay!"},
			MessageBox{message="Fleet: You're on, hog!"},
			Wait(0.5),
			PlayAudio("music", "sonicfanfare2", 1, true),
			Parallel {
				MessageBox{message="Sally: Yours always like this too?", closeAction=Wait(2)},
				MessageBox{message="Ivan: You have no idea...", closeAction=Wait(2)}
			},
			Do(function()
				-- Change scene to Boulder Bay
			end)
		}
	end

	if not GameState:isFlagSet("ep5_knothole_firefly_trigger") and not GameState:isFlagSet("ep5_knothole_meeting_trigger") then
		scene.audio:playMusic("knothole", 1.0)
	end

	return Action()
end
