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
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Lookout",
		100
	)
	Executor(scene):act(Serial {
		Wait(0.5),
		text,
		Ease(text.color, 4, 255, 1),
		Wait(2),
		Ease(text.color, 4, 0, 1)
	})

	if hint == "snowday" then
		scene.objectLookup.Entrance.object.properties.scene = "knotholesnowday.lua"
		return Action()
	end
	
	if true then
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		scene.camPos.x = 800
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(2),
			PlayAudio("music", "logantheme", 1.0, true, true),
			Ease(scene.camPos, "x", 0, 0.2),
			Wait(0.5),
			MessageBox{message="Rotor: Wow... {p60}look at that sunset..."},
			MessageBox{message="Logan: ..."},
			Wait(2),
			MessageBox{message="Logan: Rotor..."},
			MessageBox{message="Rotor: Yeah?"},
			MessageBox{message="Logan: ...{p60}I still think I would've been better off inside working, and this was a total waste of time...{p60} but... {p60}I had fun."},
			MessageBox{message="Rotor: *chuckle*"},
			Wait(2.5),
			MessageBox{message="Logan: ...huh..."},
			MessageBox{message="Rotor: What is it?"},
			MessageBox{message="Logan: I don't remember the last I had fun...{p60} must've been way back... {p60}like..."},
			MessageBox{message="Rotor: Before Robotnik?"},
			Wait(1),
			MessageBox{message="Logan: Um, yes..."},
			Wait(3),
			MessageBox{message="Logan: Hey...{p60} do you remember what it was like to have a mom and dad?"},
			MessageBox{message="Rotor: Huh?"},
			MessageBox{message="Logan: You heard me! {p60}I am not repeating myself!"},
			Wait(1),
			MessageBox{message="Rotor: Uh, well... {p60}to be honest... {p60}no."},
			MessageBox{message="Rotor: I, uh... didn't really know my parents very well. {p60}I was mostly raised by my Pop-Pop."},
			MessageBox{message="Logan: *snort* 'Pop-Pop'?"},
			MessageBox{message="Rotor: My grandpa. {p60}He was really cool. {p60}He was this amazing archeologist, always buried in his text books and research."},
			MessageBox{message="Logan: What happened to him?"},
			MessageBox{message="Rotor: He was out on a dig when Robotnik took over. {p60}I never got a chance to warn him. {p60}I had to leave the city with the others."},
			Wait(1),
			MessageBox{message="Logan: ...you think he might still be out there?"},
			MessageBox{message="Rotor: ...I'm not sure...{p60} but I like to think so."},
			MessageBox{message="Rotor: What about you?"},
			MessageBox{message="Logan: Well, it's none of your business...{p60} but..."},
			MessageBox{message="Logan: ...during Robotnik's coup I was imprisoned with my mom and the rest of my family."},
			MessageBox{message="Logan: I had to watch each of them get roboticized, one by one, until all that was left was just\nme and my mom."},
			MessageBox{message="Logan: I kept expecting someone to show up. {p60}The King and his royal guard to save the day, maybe..."},
			MessageBox{message="Logan: But no one came. {p60}They took my mom away and I never saw her after that."},
			MessageBox{message="Logan: I was alone in that cell for awhile before Leon finally found me."},
			MessageBox{message="Logan: I'm grateful that he saved me and all... {p60}but by the time he got there, I feel like a part of me was already gone."},
			MessageBox{message="Logan: That feeling of hope... {p60}that everything would turn out alright... {p60}I've never really felt that since I lost my mom."},
			Wait(1.5),
			MessageBox{message="Rotor: I...{p60}I'm sorry."},
			Wait(2),
			MessageBox{message="Logan: Guess that's why I keep my distance from people... {p60}makes it easier to deal with when they eventually get roboticized..."},
			Wait(1),
			MessageBox{message="Rotor: Yeah, I can see that..."},
			Wait(2.5),
			MessageBox{message="Rotor: ...well{p60}, you know what I think?"},
			MessageBox{message="Logan: Some kinda empty platitude about how 'there's still hope' and 'we can do anything if we work\ntogether!'?"},
			MessageBox{message="Rotor: Ha ha{p60}, yeah pretty much."},
			MessageBox{message="Logan: Yeah? Well save it for someone who cares!"},
			MessageBox{message="Logan: Robotnik will be history soon and it won't be thanks to the 'power of friendship' or whatever, it will be through good ol' fashion hard work!"},
		}
	end

	if GameState:isFlagSet("ep3_ffmeeting") then
		scene.audio:playMusic("lookout", 1.0)
	end

	return Action()
end
