return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local Animate = require "actions/Animate"
	--local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
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
	
	local knotholeIntro = function()
		--[[local subtext = TypeText(
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
		
		scene.audio:playMusic("knothole", 0.8)]]
	end
	
	scene.player.dustColor = Player.FOREST_DUST_COLOR

	if hint == "fromworldmap" then
		knotholeIntro()
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
	elseif GameState:isFlagSet("ep3_intro") and
		not GameState:isFlagSet("ep3_introknothole")
	then
		GameState:setFlag("ep3_introknothole")
		GameState:setFlag("sallysad_over")
		scene.audio:stopMusic()
		return BlockPlayer {
			PlayAudio("music", "knothole", 1.0, true, true),
			Do(function()
				scene.player.noIdle = true
				scene.player.sprite:setAnimation("thinking2")
			end),
			Wait(3),
			MessageBox {message="Sally: Ahhh...", textspeed=1},
			Do(function()
				scene.player.noIdle = true
				scene.player.sprite:setAnimation("pose")
			end),
			MessageBox {message="Sally: Nothing like a breath of that fresh, morning air to clear your head...", textspeed=1},
			AudioFade("music", 1.0, 0.0, 1),
			Wait(1),
			MessageBox {message="Fleet: Awww, {p20}getting tired?", closeAction=Wait(1)},
			Do(function()
				scene.player.sprite:setAnimation("idleright")
			end),
			MessageBox {message="Sally: ?", closeAction=Wait(0.5)},
			MessageBox {message="Sonic: Dream on, featherweight!", closeAction=Wait(1)},
			Wait(1),
			PlayAudio("music", "awkward", 1.0, true, true),
			-- Sonic/Fleet blast past Sally
			Do(function()
				scene.objectLookup.FleetEp3Run.hidden = false
				scene.objectLookup.SonicEp3Run.hidden = false
				scene.objectLookup.FleetEp3Run.movespeed = 30
				scene.objectLookup.SonicEp3Run.movespeed = 30
				scene.objectLookup.FleetEp3Run.sprite.transform.ox = scene.objectLookup.FleetEp3Run.sprite.w/2
				scene.objectLookup.FleetEp3Run.sprite.transform.oy = scene.objectLookup.FleetEp3Run.sprite.h/2
				scene.objectLookup.FleetEp3Run.sprite.transform.angle = -math.pi/6
			end),
			Parallel {
				Move(scene.objectLookup.FleetEp3Run, scene.objectLookup.Ep3Waypoint, "fly"),
				Serial {
					Wait(0.2),
					Do(function()
						scene.player.sprite:setAnimation("idleleft")
					end)
				}
			},
			Wait(1),
			Parallel {
				Move(scene.objectLookup.SonicEp3Run, scene.objectLookup.Ep3Waypoint, "juice"),
				Serial {
					Wait(0.2),
					scene.player:spin(3, 0.01)
				}
			},
			Do(function()
				scene.objectLookup.FleetEp3Run:remove()
				scene.objectLookup.SonicEp3Run:remove()
				scene.player.sprite:setAnimation("shock")
			end),
			Wait(1),
			Do(function()
				scene.player.sprite:setAnimation("frustrateddown")
			end),
			MessageBox {message="Sally: Sonic!!"},
			Do(function()
				scene.player.sprite:setAnimation("thinking")
			end),
			Wait(1),
			Do(function()
				scene.player.noIdle = false
			end)
		}
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
		scene.objectLookup.FleetMtg.hidden = false
		scene.objectLookup.LoganMtg.hidden = false
		scene.objectLookup.IvanMtg.hidden = false
		
		local sally = scene.objectLookup.SallyMtg
		local antoine = scene.objectLookup.AntoineMtg
		local sonic = scene.objectLookup.SonicMtg
		local rotor = scene.objectLookup.RotorMtg
		local bunnie = scene.objectLookup.BunnieMtg
		
		local fleet = scene.objectLookup.FleetMtg
		local logan = scene.objectLookup.LoganMtg
		local ivan = scene.objectLookup.IvanMtg
		
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

			Wait(4),
			
			--PlayAudio("music", "doittoit", 1.0, true, true),
			MessageBox {message="Sally: To start off, I'd like to welcome the Rebellion to Knothole Village! I am sure many of you have already become acquainted--"},
			Animate(sonic.sprite, "irritated"),
			MessageBox {message="Sonic: Oh, we're acquainted alright."},
			MessageBox {message="Fleet: Ha ha, amazing how so much attitude can come from such a small creature."},
			MessageBox {message="Sonic: I'll show you, small!"},
			--hop(antoine),
			MessageBox {message="Sally: Sonic, {p20}stop!"},
			MessageBox {message="Sonic: Hmph! Whatever."},
			MessageBox {message="Sally: As I was saying..."},
			MessageBox {message="Sally: I'm honored to welcome Commander Leon and his esteemed officers to our home! {p40}I believe if we unite our efforts to take down Robotnik, we can--"},
			AudioFade("music", 1, 0, 1),
			Animate(fleet.sprite, "meeting_lookright"),
			MessageBox {message="Fleet: Princess{p60}, with all due respect{p60}, the Rebellion is an elite military force{p20}, combining undoubtedly the smartest and strongest minds in all of Mobius! {p60}While the Freedom Fighters are...{p60} how do I put this?..."},
			PlayAudio("music", "tense2", 1.0, true),
			--Animate(ivan.sprite, "meeting_idleup_lookleft"),
			MessageBox {message="Ivan: Inexperienced?"},
			--Animate(logan.sprite, "meeting_idleup_lookleft"),
			MessageBox {message="Logan: Incompetent?"},
			Animate(fleet.sprite, "meeting_smirkright"),
			MessageBox {message="Fleet: Right{p60}, inexperienced incompetent teenagers! {p60}Point is, {p20}while I'm sure you \"Freedom Fighters\" have fun playing your little games{p20}, maybe you should just let the grown ups take it from here..."},
			Animate(sonic.sprite, "shock"),
			Animate(bunnie.sprite, "shock"),
			Animate(antoine.sprite, "shock"),
			Animate(rotor.sprite, "shock"),
			MessageBox {message="Sally: Excuse me?"},
			Animate(fleet.sprite, "meeting_lookright"),
			Animate(antoine.sprite, "sitlookforward"),
			Animate(sonic.sprite, "sitlookforward"),
			Animate(rotor.sprite, "sitright"),
			Animate(bunnie.sprite, "sitlookforward"),
			MessageBox {message="Antoine: Well, I have never been so insulted in my life!!"},
			MessageBox {message="Sonic: Hey! {p20}We've been doing this for a long time, bird brain!"},
			MessageBox {message="Rotor: Yeah! We've been fighting Robotnik since we were kids!"},
			MessageBox {message="Bunnie: How do y'all call that \"inexperienced\"! How rude can ya get!?"},
			MessageBox {message="Fleet: Ok then."},
			PlayAudio("music", "tense", 1.0, true),
			Animate(fleet.sprite, "meeting_smirkright"),
			MessageBox {message="Fleet: Tell me, Princess... {p60}have you ever really come close to defeating Robotnik?"},
			Animate(fleet.sprite, "meeting_lookright"),
			MessageBox {message="Sally: Well no, but--"},
			Animate(fleet.sprite, "meeting_smirkright"),
			MessageBox {message="Fleet: Have you taken back control over \"any\" part of the city?"},
			Animate(fleet.sprite, "meeting_lookright"),
			MessageBox {message="Sally: No--"},
			Animate(fleet.sprite, "meeting_smirkright"),
			MessageBox {message="Fleet: Surely, {p20}you've at least found the rightful ruler of Mobotropolis and safely brought him to Knothole Village-- {p60}your very own father?"},
			Animate(sally.sprite, "meeting_sadleft"),
			MessageBox {message="Sally: ...I--"},
			MessageBox {message="Fleet: Amazing, you've actually made my point for me! {p60}Go on Princess, {p20}just admit it..."},
			MessageBox {message="Leon: *roars* That's enough!!"},
			hop(sonic),
			MessageBox {message="Sonic: Yeah! {p60}Are we having dinner after this? {p40}I'm starving!"},
			Animate(sally.sprite, "planning_irritated"),
			MessageBox {message="Sally: Sonic! {p40}Be serious!"},
			MessageBox {message="Sonic: I never joke about dinner, Sal!"},
			MessageBox {message="Sally: Fine. {p60}We'll have dinner immediately after this meeting."},
			Animate(sally.sprite, "planning"),
			MessageBox {message="Sally: Are there any \"real\" questions?"},
			hop(bunnie),
			MessageBox {message="Bunnie: Who ya got in mind for the mission?"},
			MessageBox {message="Sally: I wanna keep the team small, but versatile. {p40}\nYou, me, and Sonic."},
			MessageBox {message="Bunnie: You got it, sugah!"},
			AudioFade("music", 1.0, 0.0, 0.5),
			Wait(1),
			Animate(sally.sprite, "planning_smile"),
			PlayAudio("music", "exciting", 1.0, true),
			MessageBox {message="Sally: Alright guys. {p60}This is the opportunity we've all been waiting for..."},
			MessageBox {message="Sally: Let's do it to it!"},
			Do(function()
				scene.player.cinematic = true
				sally:run(BlockPlayer {
					Parallel {
						Serial {
							scene:fadeOut(0.2),
							Wait(1)
						},
						AudioFade("music", 1.0, 0.0, 0.2)
					},
					Do(function()
						scene.player.sprite.visible = true
						scene.player.dropShadow.hidden = false
						
						sally.hidden = true
						rotor.hidden = true
						bunnie.hidden = true
						sonic.hidden = true
						antoine.hidden = true
						
						GameState:addToParty("bunny", 3, true)
						GameState.leader = "sonic"
						scene.player:updateSprite()
						
						local cart = scene.objectLookup.Cart
						scene.player.hidekeyhints[tostring(cart)] = cart
						
						scene.player.x = scene.objectLookup.CartWaypoint2.x + 64 - 50
						scene.player.y = scene.objectLookup.CartWaypoint2.y + 50 - 50
						
						local walkout, walkin, sprites = scene.player:split {
							GameState.party.sonic,
							GameState.party.bunny,
							GameState.party.sally
						}
						
						scene.player.x = scene.objectLookup.CartWaypoint2.x + 94
						scene.player.y = scene.objectLookup.CartWaypoint2.y + 50
						
						scene.player.cinematicStack = scene.player.cinematicStack + 1
						scene.player.cinematic = false
						
						scene.objectLookup.Bunnie:remove()
						scene.objectLookup.PestExample:remove()

						sonic:run(BlockPlayer {
							scene:fadeIn(0.5),
							Wait(0.5),
							walkout,
							Do(function()
								scene.audio:playMusic("knothole", 0.8)
							end),
							MessageBox{message="Sally: When you're both ready to go, we can just ride this pulley cart out of Knothole."},
							walkin
						})
					end)
				})
			end)
		}
	else
		knotholeIntro()
		return Action()
	end
end
