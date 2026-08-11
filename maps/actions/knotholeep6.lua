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
			Wait(4),
			PlayAudio("music", "areyouready", 0.5, true, true),
			Animate(scene.objectLookup.SallyMtg.sprite, "planning_lookleft"),
			MessageBox{message="Sally: Rotor, Logan{p80}, status report on the computer virus?"},
			Animate(scene.objectLookup.RotorMtg.sprite, "sitright_explain"),
			MessageBox{message="Rotor: The modified computer virus is ready and thoroughly tested."},
			MessageBox{message="Rotor: Once deployed it will ensure that no bot in Robotropolis can land a shot on us."},
			Animate(scene.objectLookup.LoganMtg.sprite, "meeting_idledown_irritated_shorter"),
			MessageBox{message="Logan: Almost no bot{p60}, we've chosen not to infect our roboticized friends and family."},
			MessageBox{message="Logan: We're not sure what the virus might do to them, and we don't have time to make sure it's safe."},
			Animate(scene.objectLookup.SallyMtg.sprite, "planning_lookright"),
			MessageBox{message="Sally: Thanks, guys. {p80}Leon, can you go over assignments?"},
			Animate(scene.objectLookup.RotorMtg.sprite, "sitright"),
			Animate(scene.objectLookup.LoganMtg.sprite, "meeting_idleright_shorter"),
			Wait(0.5),
			Animate(scene.objectLookup.LeonMtg.sprite, "meeting_idleleft_nod"),
			Wait(0.5),
			MessageBox{message="Leon: Rotor and Logan{p80}, you will deal with laser grids, locked doors, access for elevators."},
			Wait(0.3),
			Parallel {
				scene.objectLookup.RotorMtg:hop(),
				scene.objectLookup.LoganMtg:hop()
			},
			Wait(0.5),
			Animate(scene.objectLookup.RotorMtg.sprite, "sitright_approve"),
			Animate(scene.objectLookup.LoganMtg.sprite, "meeting_idledown_irritated_shorter"),
			Wait(0.5),
			MessageBox{message="Leon: Ivan and Bunnie{p80}, you will deal with sealed doors or bots that attempt to engage us in melee combat."},
			Animate(scene.objectLookup.RotorMtg.sprite, "sitright"),
			Wait(0.3),
			Parallel {
				scene.objectLookup.IvanMtg:hop(),
				scene.objectLookup.BunnieMtg:hop()
			},
			Wait(0.5),
			Animate(scene.objectLookup.IvanMtg.sprite, "meeting_attitude_shorter"),
			Wait(0.5),
			MessageBox{message="Leon: Sonic and Fleet{p80}, you will be our transportation."},
			Wait(0.3),
			Parallel {
				scene.objectLookup.FleetMtg:hop(),
				scene.objectLookup.SonicMtg:hop()
			},
			Wait(0.5),
			Animate(scene.objectLookup.FleetMtg.sprite, "meeting_thinking"),
			Wait(0.5),
			Animate(scene.objectLookup.LeonMtg.sprite, "meeting_idleleft_lookforward"),
			MessageBox{message="Leon: Antoine{p80}, you will accompany the Princess and myself."},
			Wait(0.3),
			scene.objectLookup.AntoineMtg:hop(),
			Wait(1),
			Animate(scene.objectLookup.SallyMtg.sprite, "planning_smile"),
			Animate(scene.objectLookup.LeonMtg.sprite, "meeting_idleleft"),
			MessageBox{message="Sally: Perfect! {p80}Alright guys, let's recap the plan..."},
			Animate(scene.objectLookup.SallyMtg.sprite, "planning"),
			MessageBox{message="Sally: With the city's primary security forces malfunctioning, we should be able to quickly make our way\nto Robotnik's throne room--"},
			MessageBox{message="Sally: --once there, we should be able to overwhelm Robotnik, and take control of the city in a matter of hours."},
			AudioFade("music", 0.5, 0, 0.2),
			PlayAudio("music", "sallyvictory", 1, true),
			Parallel {
				scene.objectLookup.SonicMtg:hop(),
				Serial {
					MessageBox{message="Sonic: So it's really happening this time, huh...", closeAction=Wait(3)},
					MessageBox{message="Sally: Yeah it is...", closeAction=Wait(2)}
				}
			},
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_thinking"),
			MessageBox{message="Sally: By this time tomorrow, Robotnik's reign of terror will be over!!", closeAction=Wait(3)},
			Animate(scene.objectLookup.RotorMtg.sprite, "sitright_cheer"),
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
				}, 4)
			},

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
						Animate(scene.objectLookup.IvanMtg.sprite, "idleleft"),
						Wait(0.2),
						Move(scene.objectLookup.IvanMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
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
						Animate(scene.objectLookup.LoganMtg.sprite, "idleleft"),
						Wait(0.2),
						Move(scene.objectLookup.LoganMtg, scene.objectLookup.LeaveMeetingWP1, "walk"),
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
			MessageBox{message="Sally: Of course..."},
			Wait(0.5),
			MessageBox{message="B: ...and let you know that I am going to the city to bring my family back to Knothole."},
			Animate(scene.objectLookup.SallyMtg.sprite, "meeting_thinking"),
			MessageBox{message="Sally: Why not wait just one more day, B?"},
			MessageBox{message="Sally: We should have control of Robotropolis by tomorrow evening."},
			Animate(scene.objectLookup.BMtg.sprite, "pose"),
			MessageBox{message="B: I appreciate that, Princess, but I've waited much too long already."},
			MessageBox{message="B: And if I have learned anything from living here in Knothole, it's that very little goes according to plan."},
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

						GameState:addToParty("b", 10, true)
						GameState:addToParty("sally", 10, true)
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
