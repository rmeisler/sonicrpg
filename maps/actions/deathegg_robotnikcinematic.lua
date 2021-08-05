return function(scene)
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
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	if GameState:isFlagSet("deathegg_robotnikcinematic") then
		return Action()
	end
	
	GameState:setFlag("deathegg_robotnikcinematic")
	
	local layerActions = {}
	for _,layer in pairs(scene.map.layers) do
		if layer.name == "elevator" or
		   layer.name == "elevatorobjects"
		then
			table.insert(layerActions, Ease(layer, "offsety", 0, 0.1))
		end
	end
	
	local stepAction = function()
		return Serial {
			PlayAudio("sfx", "juggerbotstep", 0.1, true),
			scene:screenShake(10, 40),
			Wait(1),
			PlayAudio("sfx", "juggerbotstep", 0.1, true),
			scene:screenShake(10, 40)
		}
	end
	
	return Parallel {
		Serial(layerActions),

		Serial {
			Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_smile"),
			MessageBox {message="Robotnik: Those Freedom Fighters days are numbered, Snively!", textspeed=0.2},
			MessageBox {message="Snively: Y-{p20}Yes, {p30}sir..."},
			Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_devilish"),
			MessageBox {message="Robotnik: My masterpiece is almost complete. {p20}He he he he", textspeed=0.2},

			stepAction(),

			Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_lookback1"),
			MessageBox {message="Robotnik: What... {p40}was... {p40}that?", textspeed=0.2},

			stepAction(),

			Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_lookback2"),
			MessageBox {message="Snively: I believe that would be the {h Juggerbot}, {p20}sir."},

			stepAction(),

			MessageBox {message="Snively: I took the liberty of releasing him--{p60} t-{p20}-t{p20}-to guard the central mainframe computer in our absence."},
			
			PlayAudio("sfx", "juggerbotroar", 0.1, true),
			scene:screenShake(10, 30, 14),
			
			Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_grin"),
			MessageBox {message="Robotnik: O{p5}o{p5}o{p5}h, {p80}that's good Snively. {p80}That's very good indeed.", textspeed=0.2},
		}
	}
end
