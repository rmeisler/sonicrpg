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
		
		scene.audio:playMusic("knothole", 0.8)
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
	elseif GameState:isFlagSet("rotorreveal_done") and
		not GameState:isFlagSet("ffmeeting")
	then
		GameState:setFlag("ffmeeting")
		
		scene.audio:stopMusic()
		scene.player.x = scene.objectLookup.BunnieMtg.x
		scene.player.y = scene.objectLookup.BunnieMtg.y

		scene.objectLookup.SonicMtg.hidden = false
		scene.objectLookup.RotorMtg.hidden = false
		scene.objectLookup.AntoineMtg.hidden = false
		scene.objectLookup.SallyMtg.hidden = false
		scene.objectLookup.BunnieMtg.hidden = false
		
		local sally = scene.objectLookup.SallyMtg

		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			PlayAudio("music", "meettherebellion", 1.0, true, true),
			MessageBox {message="Sally: Alright everyone-- {p40}here's the plan."},
			Animate(sally.sprite, "planning_lookdown"),
			MessageBox {message="Sally: We will first enter Robotropolis from the western corridor."},
			Animate(sally.sprite, "planning_lookdown_point"),
			MessageBox {message="Sally: From there, we'll meet up with B, who has already agreed to escort us into the Death Egg..."},
			Animate(sally.sprite, "planning_lookdown"),
			MessageBox {message="Sally: Once inside, we'll need to find a master terminal. {p60}Only master terminals are capable of producing a certificate of authenticity--"},
			MessageBox {message="Antoine: Ahem. {p60}I am having a question."},
			Animate(sally.sprite, "planning"),
			MessageBox {message="Sally: Go ahead, Antoine."},
			MessageBox {message="Antoine: Once you are inside zee Egg of Death, how are you to know where zis terminal even is?"},
			MessageBox {message="Sally: Good question, Antoine."},
			MessageBox {message="Sally: Unfortunately, intel on the internal layout of the Death Egg is sparse. {p60}We won't know exactly where B will take us, nor where the closest master terminal will be."},
			MessageBox {message="Sally: We will have to timebox our search of course, but it could take several hours."},
			MessageBox {message="Sally: Any other questions?"},
			MessageBox {message="Sonic: Yeah! {p60}Are we having dinner after this? {p40}I'm starving!"},
			Animate(sally.sprite, "planning_irritated"),
			MessageBox {message="Sally: Sonic! {p40}Be serious!"},
			MessageBox {message="Sonic: I never joke about dinner, Sal!"},
			MessageBox {message="Sally: Fine. {p60}We'll have dinner immediately after this meeting."},
			Animate(sally.sprite, "planning"),
			MessageBox {message="Sally: Are there any \"real\" questions?"},
			MessageBox {message="Bunnie: Who ya got in mind for the strike team, Sally-girl?"},
			MessageBox {message="Sally: I wanna keep the team small, but versatile. {p40}\nYou, me, and Sonic."},
			MessageBox {message="Bunnie: You got it, sugah."},
			Animate(sally.sprite, "planning_smile"),
			MessageBox {message="Sally: Alright guys. {p60}This is the opportunity we've all been waiting for..."},
			MessageBox {message="Sally: Let's do it to it!"},
			Do(function()
				GameState:addToParty("bunny", 3, true)
				GameState.leader = "sonic"
				scene.player:updateSprite()
				scene.player.x = scene.objectLookup.CartWaypoint2.x + 64 - 50
				scene.player.y = scene.objectLookup.CartWaypoint2.y - 50
				local walkout, walkin, sprites = scene.player:split {
					GameState.party.sonic,
					GameState.party.bunny,
					GameState.party.sally
				}
				scene:run(BlockPlayer {
					Parallel {
						Serial {
							scene:fadeOut(0.5),
							Wait(1)
						},
						AudioFade("music", 1.0, 0.0, 0.5)
					},
					Do(function()
						scene.player.sprite.visible = true
						scene.player.dropShadow.hidden = false
						scene.player.x = scene.objectLookup.CartWaypoint2.x + 64
						scene.player.y = scene.objectLookup.CartWaypoint2.y
					end),
					scene:fadeIn(),
					Wait(0.5),
					walkout,
					MessageBox{message="Sally: When you're both ready to go, we can just ride the pulley cart out of Knothole."},
					walkin
				})
			end)
		}
	else
		knotholeIntro()
		return Action()
	end
end
