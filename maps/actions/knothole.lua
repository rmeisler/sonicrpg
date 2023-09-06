return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local Animate = require "actions/Animate"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Repeat = require "actions/Repeat"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local BlockPlayer = require "actions/BlockPlayer"
	local Do = require "actions/Do"
	local Move = require "actions/Move"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	local BasicNPC = require "object/BasicNPC"
	
	local hop = function(obj)
		return Serial {
			Ease(obj, "y", function() return obj.y - 30 end, 8),
			Ease(obj, "y", function() return obj.y + 30 end, 8, "quad"),
			Ease(obj, "y", function() return obj.y - 5 end, 20, "quad"),
			Ease(obj, "y", function() return obj.y + 5 end, 20, "quad"),
			Ease(obj, "y", function() return obj.y - 2 end, 20, "quad"),
			Ease(obj, "y", function() return obj.y + 2 end, 20, "quad")
		}
	end
	local dblhop = function(obj)
		return Serial {
			Ease(obj, "y", function() return obj.y - 30 end, 8),
			Ease(obj, "y", function() return obj.y + 30 end, 8, "quad"),
			Ease(obj, "y", function() return obj.y - 30 end, 8),
			Ease(obj, "y", function() return obj.y + 30 end, 8, "quad"),
			Ease(obj, "y", function() return obj.y - 5 end, 20, "quad"),
			Ease(obj, "y", function() return obj.y + 5 end, 20, "quad"),
			Ease(obj, "y", function() return obj.y - 2 end, 20, "quad"),
			Ease(obj, "y", function() return obj.y + 2 end, 20, "quad")
		}
	end
	
	local knotholeIntro = function()
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
		
		if GameState:isFlagSet("ep3_ffmeeting") then
			scene.audio:playMusic("knothole", 0.8, true)
		end
	end

	scene.player.dustColor = Player.FOREST_DUST_COLOR
	
	scene.objectLookup.SallySad.hidden = true

	scene.objectLookup.AntoineEp4End.hidden = true
	scene.objectLookup.BunnieEp4End.hidden = true
	scene.objectLookup.RotorEp4End.hidden = true
	scene.objectLookup.SallyEp4End.hidden = true
	scene.objectLookup.TailsEp4End.hidden = true
	scene.objectLookup.SonicEp4End.hidden = true
	scene.objectLookup.BEp4End.hidden = true
	scene.objectLookup.LoganEp4End.hidden = true
	scene.objectLookup.IvanEp4End.hidden = true
	scene.objectLookup.LeonEp4End.hidden = true
	scene.objectLookup.FleetEp4End.hidden = true

	if hint == "ep4_end" then
		scene.objectLookup.AntoineEp4End.hidden = false
		scene.objectLookup.BunnieEp4End.hidden = false
		scene.objectLookup.RotorEp4End.hidden = false
		scene.objectLookup.TailsEp4End.hidden = false
		scene.objectLookup.SonicEp4End.hidden = false
		scene.objectLookup.BEp4End.hidden = false
		scene.objectLookup.LoganEp4End.hidden = false
		scene.objectLookup.IvanEp4End.hidden = false
		scene.objectLookup.LeonEp4End.hidden = false
		scene.objectLookup.FleetEp4End.hidden = false

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.objectLookup.SallyEp4End.hidden = true
				scene.objectLookup.RotorEp4End.sprite:setAnimation("hug")
			end),
			PlayAudio("music", "rotorsok", 1.0, true, true),
			MessageBox{message="Sally: Thank goodness you're ok, Rotor!"},
			MessageBox{message="Sally: I'm so sorry I wasn't more supportive...", textSpeed=3},
			MessageBox{message="Rotor: It's alright, Sally."},
			Do(function()
				scene.objectLookup.SallyEp4End.hidden = false
				scene.objectLookup.SallyEp4End.x = scene.objectLookup.SallyEp4End.x + 16
				scene.objectLookup.RotorEp4End.sprite:setAnimation("idleright")
			end),
			MessageBox{message="Bunnie: So that nasty ol' Project Firebird's really gone?"},
			Animate(scene.objectLookup.RotorEp4End.sprite, "idleup"),
			MessageBox{message="Rotor: That's what it seems like, Bunnie... {p60}thanks to Pop-Pop..."},
			Wait(1),
			scene.objectLookup.FleetEp4End:hop(),
			MessageBox{message="Fleet: Logan!! {p60}What are you trying to do{p30}, give me a heart attack!?"},
			MessageBox{message="Logan: ...{p60}Sorry Fleet...", textSpeed=3},
			MessageBox{message="Ivan: I am glad you have returned unharmed."},
			MessageBox{message="Logan: T-Thanks Ivan...", textSpeed=3},
			MessageBox{message="Leon: It would seem that life here in Knothole is making you lose your sense of discipline, Logan...", textSpeed=3},
			MessageBox{message="Logan: I-I'm sorry, sir. {p60}It won't happen again.", textSpeed=3},
			MessageBox{message="Leon: See that it doesn't.", textSpeed=3},
			Wait(1),
			Do(function()
				scene:changeScene {
					map = "rotorsworkshop",
					fadeOutSpeed = 0.2,
					fadeInSpeed = 0.2,
					fadeOutMusic = true,
					hint = "ep4_end"
				}
			end)
		}
	end

	if hint == "ep4_sally_see_rotor" then
		scene.objectLookup.SonicBicker:remove()
		scene.objectLookup.FleetBicker:remove()
		scene.objectLookup.AntoineBicker:remove()
		scene.objectLookup.IvanBicker:remove()
		scene.objectLookup.LoganBicker:remove()
		scene.objectLookup.RotorBicker:remove()
		scene.objectLookup.Tails:remove()
		scene.objectLookup.HockeyPost1:remove()
		scene.objectLookup.HockeyPost2:remove()

		scene.objectLookup.SallySad.hidden = false
		scene.audio:stopMusic()
		return BlockPlayer {
			Do(function()
				local door = scene.objectLookup.WorkshopDoor
				scene.player.hidekeyhints[tostring(door)] = door
				scene.audio:stopMusic()
			end),
			Wait(2),
			PlayAudio("music", "sadintrospect", 1.0, true),
			MessageBox{message="Sally: Rotor?...", textSpeed=3},
			Wait(2),
			MessageBox{message="Sally: Are you in there, Rotor?", textSpeed=3},
			Wait(2),
			Animate(scene.objectLookup.SallySad.sprite, "sadleft"),
			MessageBox{message="Sally: *sigh*", textSpeed=3},
			Do(function()
				GameState:setFlag("ep4_to_the_mnt")
				scene:changeScene{
					map = "northmountains_landing",
					fadeOutSpeed = 0.2,
					fadeInSpeed = 0.2,
					fadeOutMusic = true,
					enterDelay = 2,
					hint = "fromregion",
					manifest = "northmountainsmanifest"
				}
			end)
		}
	end

	if hint == "fromworldmap" then
		knotholeIntro()
		if not GameState:isFlagSet("ep3_ffmeetingover") then
			scene.audio:playMusic("awkward", 1.0, true)
		else
			scene.objectLookup.SonicBicker:remove()
			scene.objectLookup.FleetBicker:remove()
			scene.objectLookup.AntoineBicker:remove()
			scene.objectLookup.IvanBicker:remove()
			scene.objectLookup.LoganBicker:remove()
			scene.objectLookup.RotorBicker:remove()
			scene.objectLookup.Tails:remove()
			scene.objectLookup.HockeyPost1:remove()
			scene.objectLookup.HockeyPost2:remove()
			
			scene.audio:playMusic("knothole", 0.8, true)
		end
		return BlockPlayer {
			Parallel {
				Do(function()
					local cart = scene.objectLookup.CartBG
					scene.player.x = cart.x + cart.sprite.w
					scene.player.y = cart.y + cart.sprite.h
				end),
				Move(scene.objectLookup.CartBG, scene.objectLookup.CartWaypoint2),
				Move(scene.objectLookup.Cart, scene.objectLookup.CartWaypoint2)
			}
		}
	elseif GameState:isFlagSet("ep4_introdone") and
		not GameState:isFlagSet("ep4_ffmeetingover")
	then
		GameState:setFlag("ep4_ffmeetingover")

		scene.audio:stopMusic()

		scene.objectLookup.SonicMtg.hidden = false
		scene.objectLookup.RotorMtg.hidden = false
		scene.objectLookup.AntoineMtg.hidden = false
		scene.objectLookup.SallyMtg.hidden = false
		scene.objectLookup.BunnieMtg.hidden = false
		scene.objectLookup.FleetMtg.hidden = false
		scene.objectLookup.LoganMtg.hidden = false
		scene.objectLookup.IvanMtg.hidden = false
		scene.objectLookup.LeonMtg.hidden = false
		
		local sally = scene.objectLookup.SallyMtg
		local antoine = scene.objectLookup.AntoineMtg
		local sonic = scene.objectLookup.SonicMtg
		local rotor = scene.objectLookup.RotorMtg
		local bunnie = scene.objectLookup.BunnieMtg

		local fleet = scene.objectLookup.FleetMtg
		local logan = scene.objectLookup.LoganMtg
		local ivan = scene.objectLookup.IvanMtg
		local leon = scene.objectLookup.LeonMtg

		leon.x = scene.objectLookup.RotorMtg.x - 40
		leon.y = scene.objectLookup.RotorMtg.y
		leon.sprite:setAnimation("idleright")

		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			Do(function()
				scene.player.x = scene.objectLookup.BunnieMtg.x
				scene.player.y = scene.objectLookup.BunnieMtg.y + 64
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.player.cinematic = true
			end),

			Wait(2),
			PlayAudio("music", "project", 1.0, true, true),
			MessageBox {message="Sally: Let me save you all the suspense{p60}, Leon and I have discovered that Robotnik was behind yesterday's snow storm."},
			MessageBox {message="Leon: Our current data suggests that Robotnik has relocated\n{h Project Firebird} to the Northern Mountains and is\nconducting field tests in the area..."},
			MessageBox {message="Leon: And that the storm we experienced was the result of those field tests..."},
			hop(bunnie),
			MessageBox {message="Bunnie: My goodness! {p60}If that's what field testing looks like..."},
			hop(antoine),
			MessageBox {message="Antoine: {h P-P-Project Firebird}!?"},
			hop(sonic),
			MessageBox {message="Sonic: Yo Sal{p40}, how can these storms be coming all the way here from the Nothern Mountains? {p60}Aren't they mondo far away?"},
			MessageBox {message="Sally: The Northern Mountains are about 800 miles from Knothole. {p60}Which means that Project Firebird is just as dangerous as we predicted..."},
			MessageBox {message="Sonic: Uh oh."},
			Animate(ivan.sprite, "meeting_idledown_attitude"),
			MessageBox {message="Ivan: 'Uh oh', indeed."},
			Animate(fleet.sprite, "meeting_lookright"),
			MessageBox {message="Fleet: ..."},
			MessageBox {message="Leon: How close are we to deploying the computer virus?"},
			Animate(logan.sprite, "meeting_idledown_attitude"),
			MessageBox {message="Logan: We've got at least two weeks of work ahead of us..."},
			MessageBox {message="Rotor: ... yeah{p60}...and four weeks of testing..."},
			Animate(leon.sprite, "idlerightsad"),
			MessageBox {message="Leon: ..."},
			Wait(1),
			AudioFade("music", 1.0, 0.0, 0.5),
			Wait(1),
			Animate(leon.sprite, "idleright"),
			MessageBox {message="Sally: There's something else."},
			PlayAudio("music", "bartsomber", 1.0, true, true),
			MessageBox {message="Sally: We picked up a distress signal in the area. {p60}It seems like it's been on repeat for a long time..."},
			Animate(logan.sprite, "meeting_idledown"),
			Animate(ivan.sprite, "meeting_idledown"),
			Animate(fleet.sprite, "meeting_idledown"),
			MessageBox {message="Sally: ...it's requesting assistance from the Kingdom of Mobotropolis..."},
			Parallel {
				hop(sonic),
				hop(bunnie),
				hop(antoine)
			},
			MessageBox {message="Sally: You're gonna want to hear this, Rotor."},
			MessageBox {message="Sally: Nicole. {p60}Play audio."},
			MessageBox {message="Nicole: Playing{p60}, Sally.", sfx="nichole"},
			Wait(1),
			MessageBox {message="*zzzz* {p60}{h Sir Bartholomew Walrus} reporting from site \nC231-090 *zzzz* {p60}requesting transport back to Mobotropolis\n*zzzz*"},
			Parallel {
				AudioFade("music", 1.0, 0.0, 0.5),
				MessageBox {message="Nicole: End of message.", sfx="nichole"}
			},
			PlayAudio("music", "rotormsg", 1.0, true),
			Animate(rotor.sprite, "sitrightupset"),
			MessageBox {message="Rotor: Pop-Pop! {p60}That's my Pop-Pop, Sally!", closeAction=Wait(2.5)},
			Animate(sally.sprite, "meeting_thinking"),
			MessageBox {message="Sally: I know...", closeAction=Wait(2.5)},
			MessageBox {message="Rotor: He's alive! {p60}He needs our help!", closeAction=Wait(3)},
			MessageBox {message="Sally: It could be a trap, Rotor.", closeAction=Wait(2.5)},
			MessageBox {message="Rotor: Maybe so, {p60}but we still gotta go, right?", closeAction=Wait(3.5)},
			MessageBox {message="Rotor: If he's out there{p60}, who knows how long he's been in trouble! {p100}We gotta save him!", closeAction=Wait(4)},
			Animate(sally.sprite, "meeting_thinking3"),
			MessageBox {message="Sally: Well...", closeAction=Wait(2)},
			Wait(1),
			Animate(leon.sprite, "idlerightshakehead"),
			Wait(1),
			-- Sally looks at Leon. He shakes his head no.
			Animate(sally.sprite, "meeting_sadleft"),
			MessageBox {message="Sally: I'm sorry Rotor{p60}, it's just too dangerous.", closeAction=Wait(4)},
			Do(function()
				-- If not set from ep 3 save file, set this
				GameState:setFlag("ep3_ffmeetingover")
				GameState:setFlag("ep3_knotholerun")
				scene:changeScene{map="rotorsworkshop", hint="ep4_aftermeeting", fadeInSpeed = 0.2, fadeOutSpeed = 0.2, enterDelay = 3}
			end)
		}
	elseif GameState:isFlagSet("ep3_intro") and
		not GameState:isFlagSet("ep3_knotholerun")
	then
		knotholeIntro()
		scene.audio:playMusic("knothole", 0.8, true)
		return Action()
	elseif GameState:isFlagSet("ep3_intro") and
		GameState:isFlagSet("ep3_ffmeeting") and
		not GameState:isFlagSet("ep3_ffmeetingover")
	then
		GameState:setFlag("ep3_ffmeetingover")
		
		scene.audio:stopMusic()

		scene.objectLookup.SonicMtg.hidden = false
		scene.objectLookup.RotorMtg.hidden = false
		scene.objectLookup.AntoineMtg.hidden = false
		scene.objectLookup.SallyMtg.hidden = false
		scene.objectLookup.BunnieMtg.hidden = false
		scene.objectLookup.GriffMtg.hidden = false
		scene.objectLookup.FleetMtg.hidden = false
		scene.objectLookup.LoganMtg.hidden = false
		scene.objectLookup.IvanMtg.hidden = false
		scene.objectLookup.LeonMtg.hidden = false
		
		local sally = scene.objectLookup.SallyMtg
		local antoine = scene.objectLookup.AntoineMtg
		local sonic = scene.objectLookup.SonicMtg
		local rotor = scene.objectLookup.RotorMtg
		local bunnie = scene.objectLookup.BunnieMtg
		local griff = scene.objectLookup.GriffMtg
		griff.sprite.sortOrderY = 0
		
		local fleet = scene.objectLookup.FleetMtg
		local logan = scene.objectLookup.LoganMtg
		local ivan = scene.objectLookup.IvanMtg
		local leon = scene.objectLookup.LeonMtg

		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			Do(function()
				scene.player.x = scene.objectLookup.BunnieMtg.x
				scene.player.y = scene.objectLookup.BunnieMtg.y + 64
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.player.cinematic = true
			end),

			Wait(2),

			PlayAudio("music", "royalwelcome", 1.0, true, true),
			Animate(sally.sprite, "planning_smile"),
			MessageBox {message="Sally: To start off, I'd like to welcome the Rebellion to Knothole Village! {p60}I am sure many of you have already become acquainted--"},
			hop(sonic),
			MessageBox {message="Sonic: Oh, we're acquainted alright."},
			Animate(fleet.sprite, "meeting_smirk"),
			MessageBox {message="Fleet: Ha ha, amazing how so much attitude can come from such a small creature."},
			dblhop(sonic),
			MessageBox {message="Sonic: I'll show you, small!"},
			Do(function()
				fleet.sprite:setAnimation("meeting_laugh")
			end),
			Animate(sally.sprite, "planning_irritated"),
			MessageBox {message="Sally: Sonic, {p20}stop!"},
			MessageBox {message="Sonic: Hmph! Whatever."},
			Animate(fleet.sprite, "meeting_idleright"),
			Animate(sally.sprite, "planning"),
			MessageBox {message="Sally: As I was saying..."},
			Animate(sally.sprite, "planning_smile"),
			MessageBox {message="Sally: I'm honored to welcome Commander Leon and his esteemed officers to our home!"},
			MessageBox {message="Sally: I'm certain that if we unite our efforts to take down Robotnik, we will be unstoppable!"},
			Animate(ivan.sprite, "meeting_idleleft"),
			AudioFade("music", 1.0, 0, 0.5),
			Animate(fleet.sprite, "meeting_lookright"),
			Animate(sally.sprite, "planning"),
			MessageBox {message="Fleet: Princess, with all due respect{p40}, the Rebellion is an elite military force, combining undoubtedly the smartest and strongest in all of\nMobius..."},
			MessageBox {message="Fleet: Meanwhile, the Freedom Fighters are...{p60} how do I put this?..."},
			PlayAudio("music", "tense2", 1.0, true, true),
			Animate(ivan.sprite, "meeting_idledown_attitude"),
			MessageBox {message="Ivan: Inexperienced?", closeAction=Wait(1)},
			Animate(logan.sprite, "meeting_idledown_attitude"),
			MessageBox {message="Logan: Incompetent?", closeAction=Wait(1)},
			Animate(fleet.sprite, "meeting_smirk"),
			MessageBox {message="Fleet: Right{p60}, inexperienced incompetent teenagers!"},
			Animate(sonic.sprite, "shock"),
			Animate(bunnie.sprite, "shock"),
			Animate(antoine.sprite, "shock"),
			Animate(rotor.sprite, "shock"),
			Animate(sally.sprite, "meeting_shock"),
			Wait(1.5),
			Animate(antoine.sprite, "sitlookforward"),
			Animate(sonic.sprite, "sitlookforward"),
			Animate(rotor.sprite, "sitright"),
			Animate(bunnie.sprite, "sitlookforward"),
			Animate(sally.sprite, "meeting_thinking"),
			MessageBox {message="Fleet: Point is, {p60}while I'm sure you \"Freedom Fighters\" have had fun playing your little games..."},
			MessageBox {message="Fleet: ...maybe you should just let the grown ups take it from here."},
			Do(function()
				fleet.sprite:setAnimation("meeting_laugh")
			end),
			Animate(sally.sprite, "meeting_thinking3"),
			MessageBox {message="Sally: Excuse me?"},
			hop(antoine),
			MessageBox {message="Antoine: I have never been so insulted in all of my life!!"},
			hop(sonic),
			MessageBox {message="Sonic: Hey! {p60}We've been doing this for a long time, bird brain!"},
			hop(bunnie),
			MessageBox {message="Bunnie: How do y'all call that \"inexperienced\"! {p60}How rude can ya get!?"},
			Animate(fleet.sprite, "meeting_smirk"),
			MessageBox {message="Fleet: Ok then."},
			Animate(fleet.sprite, "meeting_smirkright"),
			MessageBox {message="Fleet: Tell me, Princess... {p60}have you ever really come close to defeating Robotnik?"},
			Animate(sally.sprite, "meeting_thinking2"),
			MessageBox {message="Sally: Well no, but--"},
			MessageBox {message="Fleet: Have you taken back control over \"any\" part of the city?"},
			Animate(sally.sprite, "meeting_thinking"),
			MessageBox {message="Sally: No--"},
			MessageBox {message="Fleet: Surely, you've at least found the rightful ruler of Mobotropolis and safely brought him to Knothole Village-- {p60}your very own {h father}?"},
			Animate(sally.sprite, "meeting_sadleft"),
			MessageBox {message="Sally: ...I--"},
			Do(function()
				fleet.sprite:setAnimation("meeting_laugh")
			end),
			MessageBox {message="Fleet: Amazing, you've actually made my point for me!"},
			MessageBox {message="Fleet: Go on Princess, {p20}just admit it..."},
			Wait(1),
			AudioFade("music", 1, 0, 1),
			PlayAudio("sfx", "leonroar", 0.7, true),
			Animate(fleet.sprite, "meeting_shock"),
			MessageBox {message="That's enough!"},
			PlayAudio("music", "leonenters", 1.0, true),
			Parallel {
				Serial {
					MessageBox {message="Fleet: B-but--", closeAction=Wait(1)},
					MessageBox {message="Leon: It is precisely because the Freedom Fighters lack formal training{p40}, and yet{p40}, have somehow become a formidable enough foe to Robotnik that he knows them by\nname{p40}, that they deserve our utmost respect."},
					Animate(fleet.sprite, "meeting_idleleft"),
					Animate(logan.sprite, "meeting_idleleft"),
					Animate(ivan.sprite, "meeting_idleleft"),
					MessageBox {message="Leon: I see no reason why they should cease operations."},
				},
				Serial {
					Move(leon, scene.objectLookup.LeonWaypoint, "walk"),
					Animate(leon.sprite, "idleright")
				}
			},
			Animate(sally.sprite, "meeting_thinking"),
			Wait(1),
			PlayAudio("music", "standup", 0.9, true),
			MessageBox {message="Sally: Look, we may not be trained military officers, but we've been fighting Robotnik for most of our\nlives...", textspeed=2},
			Animate(fleet.sprite, "meeting_lookright"),
			Animate(ivan.sprite, "meeting_idleleft"),
			Animate(logan.sprite, "meeting_idleright"),
			MessageBox {message="Sally: ...and we're not going to stop fighting now.", textspeed=2},
			Wait(1),
			MessageBox {message="Leon: You really are your father's daughter.", textspeed=2},
			MessageBox {message="Sally: Th-{p20}thank you Leon.", textspeed=2},
			Wait(3),
			Parallel {
				AudioFade("music", 1.0, 0.0, 0.5),
				Ease(scene.camPos, "y", -180, 0.3),
				PlayAudio("sfx", "griffvehicle", 1.0, true),
				Parallel {
					Move(griff, scene.objectLookup.GriffWaypoint),
					Do(function()
						if not griff.dustTime or griff.dustTime > 0.005 then
							griff.dustTime = 0
						elseif griff.dustTime < 0.005 then
							griff.dustTime = griff.dustTime + love.timer.getDelta()
							return
						end
						
						local dust = BasicNPC(
							scene,
							{name = "objects"},
							{
								name = "griffdust",
								x = griff.x,
								y = griff.y,
								width = 40,
								height = 36,
								properties = {nocollision = true, sprite = "art/sprites/dust.png"}
							}
						)
						scene:addObject(dust)
						dust.sprite.color[1] = 255
						dust.sprite.color[2] = 255
						dust.sprite.color[3] = 200
						dust.sprite.color[4] = 255
						dust.sprite.sortOrderY = 10000
						
						dust.sprite.transform.sx = 4
						dust.sprite.transform.sy = 4
						dust.x = dust.x + griff.sprite.w*2
						dust.sprite:setAnimation("left")
						
						dust.y = dust.sprite.transform.y - 10
						
						dust.sprite.animations[dust.sprite.selected].callback = function()
							local ref = dust
							ref:remove()
						end
						
						griff.dustTime = griff.dustTime + love.timer.getDelta()
					end)
				}
			},
			Animate(logan.sprite, "meeting_idledown"),
			Animate(ivan.sprite, "meeting_idledown"),
			Animate(fleet.sprite, "meeting_idledown"),
			Animate(leon.sprite, "idledown"),
			Animate(antoine.sprite, "idledown"),
			Animate(sonic.sprite, "idledown"),
			Animate(bunnie.sprite, "idledown"),
			Animate(rotor.sprite, "idledown"),
			Animate(griff.sprite, "idleleft_lookup"),
			Animate(sally.sprite, "meeting_shock"),
			MessageBox {message="Sally: Griff?! {p60}What are you doing here?"},
			Animate(sally.sprite, "meeting_idledown"),
			MessageBox {message="Griff: I found something... {p60}Something big."},
			MessageBox {message="Griff: You guys need to see this."},
			Do(function()
				scene.player.cinematic = true
				sally:run(BlockPlayer {
					scene:fadeOut(0.2),
					Do(function()
						scene.camPos.y = 0
						griff.sprite:setAnimation("emptyleft")
						scene.objectLookup.GriffMtg2.hidden = false

						local gx = scene.objectLookup.GriffMtg2.x

						scene.objectLookup.GriffMtg2.x = sally.x - 3
						
						sally.sprite:setAnimation("meeting_idledown")
						sally.x = gx + 8
						ivan.x = ivan.x + 16
						
						leon.x = scene.objectLookup.RotorMtg.x - 40
						leon.y = scene.objectLookup.RotorMtg.y
						leon.sprite:setAnimation("idleright")
						
						scene.objectLookup.NicoleMtg.hidden = false
						scene.objectLookup.NicoleMtg.sprite.sortOrderY = 99999
					end),
					Wait(1),
					Animate(logan.sprite, "meeting_idledown"),
					Animate(ivan.sprite, "meeting_idleleft"),
					Animate(fleet.sprite, "meeting_idleright"),
					Animate(leon.sprite, "idleright"),
					Animate(antoine.sprite, "sitlookforward"),
					Animate(sonic.sprite, "sitlookforward"),
					Animate(bunnie.sprite, "sitlookforward"),
					Animate(rotor.sprite, "sitright"),
					scene:fadeIn(0.5),
					MessageBox {message="Sally: Nicole{p60}, play file."},
					Animate(scene.objectLookup.NicoleMtg.sprite, "lit"),
					MessageBox {message="Nicole: Playing{p60}, Sally.", sfx="nichole"},
					Do(function()
						scene.objectLookup.NicoleMtg.sprite:setAnimation("project")
						scene.objectLookup.ProjectionMtg.hidden = false
						scene.objectLookup.ProjectionMtg.sprite.sortOrderY = 99999
					end),
					Wait(1),
					PlayAudio("music", "project", 1.0, true, true),
					Do(function()
						scene.objectLookup.ProjectionMtg.sprite:setAnimation("body")
					end),
					Wait(1),
					hop(antoine),
					MessageBox {message="Antione: Eep! W-w-w-what is zat!?"},
					MessageBox {message="Griff: {h Project Firebird}."},
					hop(bunnie),
					MessageBox {message="Bunnie: Well ain't that just the stuff o' nightmares!"},
					Animate(ivan.sprite, "meeting_idledown_attitude"),
					MessageBox {message="Ivan: Elaboration is required."},
					Animate(scene.objectLookup.GriffMtg2.sprite, "meeting_idledown_lookright"),
					MessageBox {message="Griff: ...{p60}who is this guy?"},
					hop(sonic),
					MessageBox {message="Sonic: It's a long story{p60}, just tell us what the heck that is!"},
					Animate(scene.objectLookup.GriffMtg2.sprite, "meeting_idledown"),
					MessageBox {message="Griff: Some kind of new bot... {p60}the only intell I have on it is from Robotnik's field testing{p60}, and the results are not pretty..."},
					MessageBox {message="Griff: ...according to the data... {p60}if Robotnik finishes this thing{p60}, he could destroy the entire ecosystem in a matter of days..."},
					Animate(sonic.sprite, "shock"),
					Animate(bunnie.sprite, "shock"),
					Animate(antoine.sprite, "shock"),
					Animate(rotor.sprite, "shock"),
					Animate(sally.sprite, "meeting_shock"),
					MessageBox {message="Antoine: *screams*", closeAction=Wait(1)},
					Animate(antoine.sprite, "sitlookforward"),
					Animate(sonic.sprite, "sitlookforward"),
					Animate(rotor.sprite, "sitright"),
					Animate(bunnie.sprite, "sitlookforward"),
					Animate(sally.sprite, "meeting_idledown"),
					MessageBox {message="Griff: There's a prototype being developed outside the city limits, in a top-secret location known as {h Iron Lock}."},
					Animate(sally.sprite, "meeting_thinking2"),
					MessageBox {message="Sally: Iron Lock?!"},
					MessageBox {message="Leon: The old prison complex?"},
					Animate(sally.sprite, "meeting_thinking"),
					MessageBox {message="Sally: We've been there before...{p60} I found a message from my father there... {p60}there was so much more I wanted to investigate, but our visit was cut short."},
					hop(sonic),
					MessageBox {message="Sonic: Yeah, thanks to ol' Robuttnik's monster machine."},
					MessageBox {message="Griff: Well don't expect this time to be much easier..."},
					MessageBox {message="Griff: ...reports say Robotnik's got this place locked down. {p60}Maximum security."},
					hop(sonic),
					MessageBox {message="Sonic: Mondo problemo{p60}, but what about our current\noperation?"},
					MessageBox {message="Sonic: Ya know{p60}, the {h computer virus} that could \nbring down Buttnik's whole army?"},
					MessageBox {message="Sally: This has to take priority.{p60} We need to find out what Robotnik's got up his sleeve."},
					hop(sonic),
					MessageBox {message="Sonic: Ok. {p60}Then we break into Iron Lock{p60}, trash this porker{p60}, and get back to business!"},
					MessageBox {message="Sally: Agreed."},
					AudioFade("music", 1.0, 0.0, 1),
					Wait(1),
					Animate(sally.sprite, "planning_smile"),
					MessageBox {message="Sally: Well...{p80} I'd say that this is a great opportunity for our first joint mission!"},				
					PlayAudio("music", "royalwelcome", 1.0, true, true),
					hop(sonic),
					MessageBox {message="Sonic: Say wha?"},
					Animate(sally.sprite, "planning"),
					MessageBox {message="Sally: If {h Project Firebird} is as dangerous as\nGriff says it is, then we are going to have to put\naside our differences and work together!"},
					MessageBox {message="Leon: That sounds like a wonderful idea."},
					MessageBox {message="Leon: Fleet, Logan, and Ivan{p60}, you will accompany Sally's away team."},
					hop(sonic),
					MessageBox {message="Sonic: The bird's comin? {p60}Oh brother."},
					-- annoyed
					Animate(fleet.sprite, "meeting_lookright"),
					MessageBox {message="Fleet: *mumbles* Great{p60}, countless years of training and I'm relegated to babysitting..."},
					
					MessageBox {message="Sally: Perfect!"},
					Animate(sally.sprite, "planning_smile"),
					MessageBox {message="Sally: Then it's settled...{p60} tomorrow, alongside the Rebellion{p60}, Sonic, Antoine, and I will return to Iron Lock!"},
					Animate(antoine.sprite, "shock"),
					MessageBox {message="Antoine: Me!?"},
					Animate(antoine.sprite, "nauseated"),
					Do(function()
						antoine.sprite.transform.ox = antoine.sprite.w/2
						antoine.sprite.transform.oy = antoine.sprite.h
						antoine.x = antoine.x + antoine.sprite.w
						antoine.y = antoine.y + antoine.sprite.h*2
					end),
					Ease(antoine.sprite.transform, "angle", math.pi/48, 3),
					Ease(antoine.sprite.transform, "angle", -math.pi/48, 3),
					Ease(antoine.sprite.transform, "angle", math.pi/48, 4),
					Ease(antoine.sprite.transform, "angle", -math.pi/48, 4),
					Animate(antoine.sprite, "dead"),
					
					Wait(2),
					
					Parallel {
						scene:fadeOut(0.2),
						AudioFade("music", 0.6, 0.0, 0.2)
					},
					Do(function()
						scene.player.sprite.visible = true
						scene.player.dropShadow.hidden = false
						
						GameState:addToParty("sonic", 6, true)
						GameState:addToParty("antoine", 6, true)
						GameState.leader = "sally"
						scene.player:updateSprite()
						
						local cart = scene.objectLookup.Cart
						scene.player.hidekeyhints[tostring(cart)] = cart
						
						scene.player.x = scene.objectLookup.CartWaypoint2.x + 64 - 50
						scene.player.y = scene.objectLookup.CartWaypoint2.y + 50 - 50
						
						local walkout, walkin, sprites = scene.player:split {
							GameState.party.sonic,
							GameState.party.antoine,
							GameState.party.sally
						}
						
						scene.player.x = scene.objectLookup.CartWaypoint2.x + 94
						scene.player.y = scene.objectLookup.CartWaypoint2.y + 50
						
						scene.player.cinematic = false

						scene.player:run(BlockPlayer {
							scene:fadeIn(0.2),
							Wait(0.5),
							walkout,
							Do(function()
								scene.objectLookup.SonicBicker:remove()
								scene.objectLookup.FleetBicker:remove()
								scene.objectLookup.AntoineBicker:remove()
								scene.objectLookup.IvanBicker:remove()
								scene.objectLookup.LoganBicker:remove()
								scene.objectLookup.RotorBicker:remove()
								scene.objectLookup.Tails:remove()
								scene.objectLookup.HockeyPost1:remove()
								scene.objectLookup.HockeyPost2:remove()
								
								scene.objectLookup.SonicMtg.hidden = true
								scene.objectLookup.RotorMtg.hidden = true
								scene.objectLookup.AntoineMtg.hidden = true
								scene.objectLookup.SallyMtg.hidden = true
								scene.objectLookup.BunnieMtg.hidden = true
								scene.objectLookup.GriffMtg.hidden = true
								scene.objectLookup.GriffMtg2.hidden = true
								scene.objectLookup.FleetMtg.hidden = true
								scene.objectLookup.LoganMtg.hidden = true
								scene.objectLookup.IvanMtg.hidden = true
								scene.objectLookup.LeonMtg.hidden = true
								scene.objectLookup.NicoleMtg.hidden = true
								scene.objectLookup.ProjectionMtg.hidden = true

								scene.audio:playMusic("knothole", 0.8)
								scene.objectLookup.Cart.isInteractable = true
							end),
							MessageBox{message="Sally: When you're ready to go we'll ride this pulley cart out of Knothole and head east to\nthe {h Dark Swamp}."},
							walkin
						})
					end)
				})
			end)
		}
	else
		knotholeIntro()
		
		if GameState:isFlagSet("ep3_ffmeetingover") then
			scene.objectLookup.SonicBicker:remove()
			scene.objectLookup.FleetBicker:remove()
			scene.objectLookup.AntoineBicker:remove()
			scene.objectLookup.IvanBicker:remove()
			scene.objectLookup.LoganBicker:remove()
			scene.objectLookup.RotorBicker:remove()
			scene.objectLookup.Tails:remove()
			scene.objectLookup.HockeyPost1:remove()
			scene.objectLookup.HockeyPost2:remove()
			scene.objectLookup.Cart.isInteractable = true
			
			scene.audio:playMusic("knothole", 1.0, true)
		end

		return Action()
	end
end
