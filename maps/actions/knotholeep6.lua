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
	local Spawn = require "actions/Spawn"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
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
	
	if hint == "fromworldmap" then
        scene.audio:playMusic("ffmedley", 1.0)
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
	end

	if not GameState:isFlagSet("ep6meeting") then
		GameState:setFlag("ep6meeting")

		scene.objectLookup.SonicMtg.hidden = false
		scene.objectLookup.SallyMtg.hidden = false
		scene.objectLookup.RotorMtg.hidden = false
		scene.objectLookup.AntoineMtg.hidden = false
		scene.objectLookup.BunnieMtg.hidden = false
		scene.objectLookup.LeonMtg.hidden = false
		scene.objectLookup.LoganMtg.hidden = false
		scene.objectLookup.FleetMtg.hidden = false
		scene.objectLookup.IvanMtg.hidden = false
		scene.objectLookup.BMtg.hidden = false

		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(3),
			PlayAudio("music", "areyouready", 0.5, true, true),
			Animate(scene.objectLookup.RotorMtg.sprite, "sitright_explain"),
			MessageBox{message="Rotor: The modified computer virus is ready and\nthoroughly tested."},
			MessageBox{message="Rotor: Once deployed it will ensure that no bot in\nRobotropolis can land a shot on us."},
			Animate(scene.objectLookup.LoganMtg.sprite, "meeting_idledown_irritated_shorter"),
			Animate(scene.objectLookup.RotorMtg.sprite, "sitright"),
			MessageBox{message="Logan: Almost no bot{p60}, we've chosen not to infect\nour roboticized friends and family."},
			MessageBox{message="Logan: We're not sure what the virus might do to\nthem, and we don't have time to make sure it's safe."},
			Wait(1),
			Animate(scene.objectLookup.LoganMtg.sprite, "meeting_idleright_shorter"),
			MessageBox{message="Sally: Alright guys, let's recap the plan..."},
			Animate(scene.objectLookup.SallyMtg.sprite, "planning"),
			MessageBox{message="Sally: With the city's primary security forces\nmalfunctioning, we should be able to quickly make\nour way to Robotnik's throne room--"},
			MessageBox{message="Sally: --once there, we'll overwhelm Robotnik and use his master terminal to take control of the city."},
			AudioFade("music", 0.5, 0, 0.2),
			PlayAudio("music", "sallyvictory", 1, true),
			Parallel {
				scene.objectLookup.SonicMtg:hop(),
				Serial {
					MessageBox{message="Sonic: It's really happening this time, huh...", closeAction=Wait(3)},
					Animate(scene.objectLookup.SallyMtg.sprite, "meeting_thinking"),
					MessageBox{message="Sally: Yeah it is...", closeAction=Wait(2)}
				}
			},
			MessageBox{message="Sally: By this time tomorrow, Robotnik's reign of terror will be over!!", closeAction=Wait(3)},
			Animate(scene.objectLookup.RotorMtg.sprite, "sitright_cheer"),
			Animate(scene.objectLookup.LoganMtg.sprite, "meeting_idledown_irritated_shorter"),
			Animate(scene.objectLookup.FleetMtg.sprite, "meeting_thinking"),
			Animate(scene.objectLookup.IvanMtg.sprite, "meeting_idledown_attitude"),
			Parallel {
				MessageBox{message="Freedom! {p50}Freedom! {p50}Freedom!", closeAction=Wait(3)},
				Repeat(Serial {
					Parallel {
						scene.objectLookup.SonicMtg:hop(),
						scene.objectLookup.BunnieMtg:hop(),
						scene.objectLookup.AntoineMtg:hop(),
						scene.objectLookup.RotorMtg:hop()
					},
					Wait(0.8)
				}, 5)
			},
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_thinking"),
			MessageBox{message="Sally: Meeting adjourned."},
			Wait(1),
			Parallel {
				Serial {
					Wait(2),
					MessageBox{message="Sonic: Hey{p60}, is it lunch time yet?", closeAction=Wait(1)},
					MessageBox{message="Fleet: I could eat.", closeAction=Wait(1)},
				},
				Serial {
					Spawn(Serial {
						Animate(scene.objectLookup.RotorMtg.sprite, "idleleft"),
						Wait(0.2),
						Move(scene.objectLookup.RotorMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
						Move(scene.objectLookup.RotorMtg, scene.objectLookup.LeaveMeetingWP2, "walk"),
						Move(scene.objectLookup.RotorMtg, scene.objectLookup.LeaveMeetingWP3, "walk"),
						Do(function()
							scene.objectLookup.RotorMtg.hidden = true
						end),
					}),
					Wait(0.2),
					Spawn(Serial {
						Animate(scene.objectLookup.IvanMtg.sprite, "meeting_idleleft"),
						Wait(0.2),
						Do(function()
							scene.objectLookup.IvanMtg.sprite:pushOverride("walkleft", "meeting_walkleft")
						end),
						Parallel {
							Move(scene.objectLookup.IvanMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
							Serial {
								Wait(0.1),
								Do(function()
									scene.objectLookup.IvanMtg.sprite:popOverride("walkleft")
								end)
							}
						},
						Move(scene.objectLookup.IvanMtg, scene.objectLookup.LeaveMeetingWP2, "walk"),
						Move(scene.objectLookup.IvanMtg, scene.objectLookup.LeaveMeetingWP3, "walk"),
						Do(function()
							scene.objectLookup.IvanMtg.hidden = true
						end),
					}),
					Spawn(Serial {
						Animate(scene.objectLookup.SonicMtg.sprite, "idleleft"),
						Wait(0.2),
						Move(scene.objectLookup.SonicMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
						Move(scene.objectLookup.SonicMtg, scene.objectLookup.LeaveMeetingWP2, "walk"),
						Move(scene.objectLookup.SonicMtg, scene.objectLookup.LeaveMeetingWP3, "walk"),
						Do(function()
							scene.objectLookup.SonicMtg.hidden = true
						end),
					}),
					Wait(0.2),
					Spawn(Serial {
						Animate(scene.objectLookup.LoganMtg.sprite, "meeting_idleleft"),
						Wait(0.2),
						Do(function()
							scene.objectLookup.LoganMtg.sprite:pushOverride("walkleft", "meeting_walkleft")
						end),
						Parallel {
							Move(scene.objectLookup.LoganMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
							Serial {
								Wait(0.1),
								Do(function()
									scene.objectLookup.LoganMtg.sprite:popOverride("walkleft")
								end)
							}
						},
						Move(scene.objectLookup.LoganMtg, scene.objectLookup.LeaveMeetingWP2, "walk"),
						Move(scene.objectLookup.LoganMtg, scene.objectLookup.LeaveMeetingWP3, "walk"),
						Do(function()
							scene.objectLookup.LoganMtg.hidden = true
						end),
					}),
					Spawn(Serial {
						Animate(scene.objectLookup.BunnieMtg.sprite, "idleleft"),
						Wait(0.2),
						Move(scene.objectLookup.BunnieMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
						Move(scene.objectLookup.BunnieMtg, scene.objectLookup.LeaveMeetingWP2, "walk"),
						Move(scene.objectLookup.BunnieMtg, scene.objectLookup.LeaveMeetingWP3, "walk"),
						Do(function()
							scene.objectLookup.BunnieMtg.hidden = true
						end),
					}),
					Wait(0.2),
					Spawn(Serial {
						Do(function()
							scene.objectLookup.AntoineMtg.y = scene.objectLookup.AntoineMtg.y + 6
						end),
						Animate(scene.objectLookup.AntoineMtg.sprite, "idleleft"),
						Wait(0.2),
						Move(scene.objectLookup.AntoineMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
						Move(scene.objectLookup.AntoineMtg, scene.objectLookup.LeaveMeetingWP2, "walk"),
						Move(scene.objectLookup.AntoineMtg, scene.objectLookup.LeaveMeetingWP3, "walk"),
						Do(function()
							scene.objectLookup.AntoineMtg.hidden = true
						end),
					}),
					Wait(0.2),
					Spawn(Serial {
						Wait(0.2),
						Animate(scene.objectLookup.FleetMtg.sprite, "idleleft"),
						Do(function()
							scene.objectLookup.FleetMtg.y = scene.objectLookup.FleetMtg.y + 64
						end),
						Move(scene.objectLookup.FleetMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
						Move(scene.objectLookup.FleetMtg, scene.objectLookup.LeaveMeetingWP2, "walk"),
						Move(scene.objectLookup.FleetMtg, scene.objectLookup.LeaveMeetingWP3, "walk"),
						Do(function()
							scene.objectLookup.FleetMtg.hidden = true
						end),
					})
				}
			},
			
			Wait(2.5),
			Do(function() scene.objectLookup.BMtg.sprite:pushOverride("walkup", "walkright") end),
			Move(scene.objectLookup.BMtg, scene.objectLookup.LeaveMeetingWP2, "walk"),
			Move(scene.objectLookup.BMtg, scene.objectLookup.LeaveMeetingWP4, "walk"),
			Move(scene.objectLookup.BMtg, scene.objectLookup.LeaveMeetingWP5, "walk"),
			Animate(scene.objectLookup.BMtg.sprite, "idleright"),
			
			Wait(1),
			PlayAudio("music", "bheart2", 1, true, true),
			MessageBox{message="B: Princess..."},
			Wait(0.5),
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_idleleft"),
			MessageBox{message="Sally: B?"},
			Wait(0.5),
			MessageBox{message="B: I just wanted to thank you for all you've done for me..."},
			Wait(0.5),
			MessageBox{message="B: ...and let you know that I am going to the city to bring my family back to Knothole."},
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_thinking"),
			MessageBox{message="Sally: Why not wait just one more day, B? {p60}We should\nhave control of Robotropolis by tomorrow evening."},
			Animate(scene.objectLookup.BMtg.sprite, "pose"),
			MessageBox{message="B: I appreciate that, Princess, but I've waited much too long already.{p80} And if I have learned anything from living here in Knothole, it's that very little goes according to plan."},
			Animate(scene.objectLookup.LeonMtg.sprite, "meeting_idleleft_lookdown"),
			MessageBox{message="Leon: He's right, Princess. {p80}We have not done right by B."},
			Wait(1),
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_idleright"),
			Animate(scene.objectLookup.LeonMtg.sprite, "meeting_idleleft"),
			MessageBox{message="Leon: When Tails went missing, you and Sonic took off after him-- {p80}fully understanding the risks in doing so."},
			Wait(1),
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_thinking"),
			MessageBox{message="Sally: I recall you telling me that I was being reckless..."},
			MessageBox{message="Leon: It was the right thing to do."},
			Wait(1),
			MessageBox{message="Leon: And if it was the right thing to do for Tails, then it is the right thing to do for B's family,\ntoo..."},
			Wait(1),
			MessageBox{message="B: ...{p60}Thank you, Commander..."},
			Wait(1),
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_worriedleft"),
			MessageBox{message="Sally: Y-You're right, Leon. {p80}I'm sorry we let this go on so long, B."},
			Wait(1),
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_idleleft"),
			MessageBox{message="Sally: Sonic and I will help bring your family back to Knothole before tomorrow's mission!"},

			Do(function()
				scene.objectLookup.SonicMtg:run(BlockPlayer {
					Wait(0.2),
					Parallel {
						scene:fadeOut(0.2),
						AudioFade("music", 1, 0, 0.2)
					},

					Do(function()
						scene.objectLookup.SonicMtg.hidden = true
						scene.objectLookup.SallyMtg.hidden = true
						scene.objectLookup.RotorMtg.hidden = true
						scene.objectLookup.AntoineMtg.hidden = true
						scene.objectLookup.BunnieMtg.hidden = true
						scene.objectLookup.LeonMtg.hidden = true
						scene.objectLookup.LoganMtg.hidden = true
						scene.objectLookup.FleetMtg.hidden = true
						scene.objectLookup.IvanMtg.hidden = true
						scene.objectLookup.BMtg.hidden = true

						GameState:removeFromParty("sonic")
						GameState:addToParty("b", 10, true)
						GameState:addToParty("sally", 10, true)
						GameState:addToParty("sonic", 10, true)
						GameState.leader = "sally"

						scene.player.sprite.visible = true
						scene.player.dropShadow.hidden = false
						scene.player:updateSprite()
						
						scene.objectLookup.BMtg.sprite:popOverride("walkup")
					end),
					Wait(0.5),

					scene:fadeIn(0.2),
					
					PlayAudio("music", "ffmedley", 1, true, true)
				})
			end)
		}
	end

	scene.audio:playMusic("ffmedley", 1.0)

	return Action()
end
