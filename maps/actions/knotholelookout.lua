return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local AudioFade = require "actions/AudioFade"
	local Animate = require "actions/Animate"
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
	local showTitle = function()
		Executor(scene):act(Serial {
			Wait(0.5),
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		})
	end

	if hint == "snowday" and not GameState:isFlagSet("ep4_tails_snowman") then
		showTitle()
		scene.objectLookup.Logan:remove()
		scene.objectLookup.Rotor:remove()
		scene.objectLookup.Entrance.object.properties.scene = "knotholesnowday.lua"
		return Action()
	end
	
	if hint == "ep4_sunset" then
		-- turn on twilight layer
		for _,layer in pairs(scene.map.layers) do
			if layer.name == "twilight" then
				layer.opacity = 1
				break
			end
		end
		GameState:setFlag("ep4_rotor_logan_lookout")
		-- make everything else darker
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(2),
			PlayAudio("music", "logantheme", 1.0, true, true),
			Wait(0.5),
			MessageBox{message="Rotor: Wow... {p60}look at that sunset...", textSpeed = 3},
			MessageBox{message="Logan: ...", textSpeed = 3},
			Wait(2),
			MessageBox{message="Logan: Rotor...", textSpeed = 3},
			MessageBox{message="Rotor: Yeah?", textSpeed = 3},
			MessageBox{message="Logan: ...{p60}I still think I would've been better off inside working, and this was a total waste of time...", textSpeed = 4},
			MessageBox{message="Logan: ...but I had fun.", textSpeed = 3},
			MessageBox{message="Rotor: *chuckle*", textSpeed = 3},
			Wait(2.5),
			MessageBox{message="Logan: ...huh...", textSpeed = 3},
			MessageBox{message="Rotor: What is it?", textSpeed = 3},
			MessageBox{message="Logan: I don't remember the last I had fun...{p60}\nmust've been way back... {p60}like...", textSpeed = 3},
			MessageBox{message="Rotor: Before Robotnik?", textSpeed = 3},
			Wait(1),
			MessageBox{message="Logan: Um{p60}, yeah...", textSpeed = 3},
			Wait(3),
			MessageBox{message="Logan: Hey...{p60} do you remember what it was like to have a mom and dad?", textSpeed = 3},
			MessageBox{message="Rotor: Huh?", textSpeed = 3},
			MessageBox{message="Logan: You heard me! {p60}I am not repeating myself!"},
			Wait(1),
			MessageBox{message="Rotor: Uh, well... {p60}to be honest... {p60}no.", textSpeed = 3},
			MessageBox{message="Rotor: I, uh... {p60}didn't really know my parents very well. {p60}I was mostly raised by my Pop-Pop.", textSpeed = 3},
			MessageBox{message="Logan: *snort* 'Pop-Pop'?", textSpeed = 3},
			MessageBox{message="Rotor: My grandpa. {p60}He was really cool. {p60}He was this amazing archeologist, always buried in his text books and research.", textSpeed = 3},
			MessageBox{message="Logan: What happened to him?", textSpeed = 3},
			MessageBox{message="Rotor: He was out on a dig when Robotnik took over. {p60}I never got a chance to warn him. {p60}I had to leave the city with the others.", textSpeed = 3},
			Wait(1),
			MessageBox{message="Logan: ...you think he might still be out there?", textSpeed = 3},
			MessageBox{message="Rotor: ...I'm not sure...{p60} but I like to think so.", textSpeed = 3},
			Wait(2),
			MessageBox{message="Rotor: What about you?", textSpeed = 3},
			MessageBox{message="Logan: Well, not that it's any of your business, but...", textSpeed = 3},
			MessageBox{message="Logan: ...during Robotnik's coup I was imprisoned with my mom and the rest of my family.", textSpeed = 3},
			MessageBox{message="Logan: I had to watch each of them get roboticized, one by one, until all that was left was just\nme and my mom.", textSpeed = 3},
			MessageBox{message="Logan: I kept expecting someone to show up. {p60}The King and his royal guard to save the day, maybe...", textSpeed = 3},
			MessageBox{message="Logan: But no one came. {p60}They took my mom away and I never saw her after that.", textSpeed = 3},
			MessageBox{message="Logan: I was alone in that cell for awhile before Leon finally found me.", textSpeed = 3},
			MessageBox{message="Logan: I'm grateful that he saved me and all... {p60}but by the time he got there, I feel like a part of me was already gone.", textSpeed = 3},
			MessageBox{message="Logan: That feeling of hope... {p60}that everything would turn out alright... {p60}I've never really felt that since I lost my mom.", textSpeed = 3},
			MessageBox{message="Rotor: Wow... {p60}I'm sorry that happened to you...", textSpeed = 3},
			Wait(2),
			MessageBox{message="Logan: Guess that's why I keep my distance from people... {p120}makes it easier to deal with when they eventually get roboticized...", textSpeed = 3},
			Wait(1),
			MessageBox{message="Rotor: Yeah, I can see that...", textSpeed = 3},
			Wait(2.5),
			MessageBox{message="Rotor: ...well{p60}, you know what I think?", textSpeed = 3},
			MessageBox{message="Logan: Some kinda empty platitude about how 'there's still hope' and 'we can do anything if we work\ntogether!'?", textSpeed = 3},
			MessageBox{message="Rotor: Ha ha{p60}, yeah pretty much.", textSpeed = 3},
			AudioFade("music", 1, 0, 1),
			Do(function()
				scene.objectLookup.Logan.x = scene.objectLookup.Logan.x - 10
			end),
			Animate(scene.objectLookup.Logan.sprite, "angrydown"),
			MessageBox{message="Logan: Yeah? {p60}Well save it for someone who cares!"},
			MessageBox{message="Logan: Robotnik will be history soon and it won't be thanks to the 'power of friendship' or whatever, it will be through good ol' fashion hard work!"},
			Do(function()
				scene.objectLookup.Logan.sprite:setAnimation("walkleft")
			end),
			Ease(scene.objectLookup.Logan, "x", function() return scene.objectLookup.Logan.x - 400 end, 1, "linear"),
			MessageBox{message="Rotor: *sigh*", textSpeed = 3},
			Do(function()
				scene:changeScene{map="knothole", fadeInSpeed = 0.5, fadeOutSpeed = 0.5, enterDelay = 3}
			end)
		}
	else
		scene.objectLookup.Logan:remove()
		scene.objectLookup.Rotor:remove()
		for _,layer in pairs(scene.map.layers) do
			if layer.name == "twilight" then
				layer.opacity = 0
				break
			end
		end
	end

	showTitle()
	if GameState:isFlagSet("ep3_ffmeeting") then
		scene.audio:playMusic("lookout", 1.0)
	end

	return Action()
end
