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

		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(3),
			MessageBox{message="Rotor: The modified computer virus is ready and thoroughly tested."},
			MessageBox{message="Rotor: Once deployed it will ensure that no bot in Robotropolis can land a shot on us."},
			MessageBox{message="Logan: Almost no bot{p60}, we've chosen not to infect our roboticized friends and family."},
			MessageBox{message="Logan: We're not sure what the virus might do to them, and we don't have time to make sure it's safe."},
			MessageBox{message="Sally: Thank you for the recap, Rotor and Logan."},
			PlayAudio("music", "areyouready", 0.8, true, true),
			MessageBox{message="Sally: With the city's primary security forces malfunctioning, we should be able to quickly make our way\nto Robotnik's throne room{p60}, overwhelm Robotnik{p60}, and take\ncontrol of the entire city in a matter of hours."},
			MessageBox{message="Sally: Sonic and Fleet{p60}, you will help us get to the command center as quickly as possible."},
			MessageBox{message="Sally: Rotor and Logan{p60}, you will deal with static\nsecurity{p60}; laser grids, locked doors, access for elevators."},
			MessageBox{message="Sally: Ivan and Bunnie{p60}, you will deal with physical barriers{p60}; sealed doors or bots that attempt to engage us in melee combat."},
			MessageBox{message="Sally: Antoine{p60}, you will accompany Leon and I."},
			AudioFade("music", 1, 0, 1),
			scene.objectLookup.SonicMtg:hop(),
			MessageBox{message="Sonic: Hold on a Sonic second!{p60} This all sounds too easy! {p60}What's the catch?"},
			MessageBox{message="Sally: There's no catch, Sonic. {p60}Even by our most conservative predictions, Nicole is estimating a\n95% chance of mission success."},
			PlayAudio("music", "sallyvictory", 1, true),
			Parallel {
				scene.objectLookup.SonicMtg:hop(),
				scene.objectLookup.BunnieMtg:hop(),
				scene.objectLookup.AntoineMtg:hop(),
				scene.objectLookup.RotorMtg:hop(),
				scene.objectLookup.LoganMtg:hop(),
				scene.objectLookup.IvanMtg:hop(),
				scene.objectLookup.FleetMtg:hop()
			},
			MessageBox{message="Antoine: This is magnifique!!", closeAction=Wait(1)},
			MessageBox{message="Bunnie: My stars, Sally girl, I'd bet the farm on that!", closeAction=Wait(1)},
			MessageBox{message="Ivan: Incredible.", closeAction=Wait(1)},
			Wait(1),
			MessageBox{message="Sally: We've all been working very hard to prepare for this...", closeAction=Wait(2)},
			MessageBox{message="Sally: By this time tomorrow, Robotnik's reign of terror will be over!!", closeAction=Wait(2)},

			scene:fadeOut(),

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

				scene.player.sprite.visible = true
				scene.player.dropShadow.hidden = false
			end),

			scene:fadeIn()
		}
	end

	scene.audio:playMusic("ffmedley", 1.0)

	return Action()
end
