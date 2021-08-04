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
	scene.camPos.x = -580
	
	return Serial {
		Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_smile"),
		MessageBox {message="Robotnik: Those Freedom Fighters days are numbered, Snively!", textspeed=4},
		MessageBox {message="Snively: Y-{p20}Yes, {p30}sir..."},
		Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_devilish"),
		MessageBox {message="Robotnik: My masterpiece is almost complete...", textspeed=4},
		Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_lookback1"),
		MessageBox {message="Robotnik: What... {p40}was... {p40}that?", textspeed=4},
		MessageBox {message="Robotnik: ...do we have a {p20}r{p20}o{p20}d{p20}e{p20}n{p20}t{p20} infestation?{p20}.{p20}.{p20}.", textspeed=4},
		MessageBox {message="Snively: I believe that's just the {h Juggerbot}, {p20}sir."},
		MessageBox {message="Snively: I released "},
	}	
end
