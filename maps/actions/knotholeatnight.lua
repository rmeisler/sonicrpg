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
	local Spawn = require "actions/Spawn"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	local BasicNPC = require "object/BasicNPC"
	local NPC = require "object/NPC"

	scene.player.dustColor = Player.FOREST_DUST_COLOR

	if GameState:isFlagSet("ep3_read") then
		scene.objectLookup.TailsHutWarmWindows:remove()
	end
	
	if hint == "intro" and not GameState:isFlagSet("ep4_introdone") then
		return BlockPlayer {
			Do(function()
				scene.player:removeKeyHint()
				local door = scene.objectLookup.WorkshopDoor
				scene.player.hidekeyhints[tostring(door)] = door
				scene.audio:stopMusic()
			end),
			Wait(1),
			PlayAudio("music", "snowday", 0.8, true, true),
			Wait(1),
			MessageBox{message="Logan: What the...?", closeAction=Wait(1)},
			Parallel {
				Ease(scene.camPos, "x", 400, 0.5),
				Ease(scene.camPos, "y", -1050, 0.5)
			},
			Ease(scene.camPos, "x", 500, 0.28, "linear"),
			Parallel {
				Ease(scene.camPos, "x", 2600, 0.5),
				Ease(scene.camPos, "y", -950, 0.5)
			},
			Ease(scene.camPos, "x", 2700, 0.28, "linear"),
			Parallel {
				Ease(scene.camPos, "x", 3900, 0.5),
				Ease(scene.camPos, "y", -1100, 0.5)
			},
			Parallel {
				Serial {
					Animate(scene.objectLookup.Tails.sprite, "joyright"),
					scene.objectLookup.Tails:hop()
				},
				Ease(scene.camPos, "x", 4000, 0.3, "linear")
			},
			Animate(scene.objectLookup.Tails.sprite, "idleright"),
			Ease(scene.camPos, "x", 6100, 0.5),
			Parallel {
				Ease(scene.camPos, "x", 6250, 0.3),
				Ease(scene.camPos, "y", -400, 0.3)
			},
			Wait(3),
			Parallel {
				Ease(scene.camPos, "x", 0, 1),
				Ease(scene.camPos, "y", 0, 1)
			},
			MessageBox{message="Logan: Ah..."},
			MessageBox{message="Logan: Welp, I'm going back inside."},
			Do(function()
				scene.player.state = "idleup"
			end),
			Wait(0.5),
			Do(function()
				scene.objectLookup.WorkshopDoor:interact()
				scene.objectLookup.Rotor.hidden = false
				scene.objectLookup.Rotor.sprite:setAnimation("pose")
			end),
			Ease(scene.player, "y", function() return scene.player.y + 32 end, 8, "linear"),
			MessageBox{message="Rotor: Oh no you don't!"},
			MessageBox{message="Logan: W-What are you doing?!"},
			Do(function()
				scene.player.state = "idleup"
			end),
			Animate(scene.objectLookup.Rotor.sprite, "idledown"),
			MessageBox{message="Rotor: You've been couped up in that room since coming here."},
			MessageBox{message="Rotor: You only come out when it's time for team meetings!"},
			Do(function()
				scene.player.state = "irritated"
			end),
			MessageBox{message="Logan: No way! {p60}I came out for the Iron Lock mission, didn't I?"},
			Animate(scene.objectLookup.Rotor.sprite, "thinking"),
			MessageBox{message="Rotor: Uh yeah{p60}, but the point is that you never take breaks!"},
			Do(function()
				scene.player.state = "idleup"
			end),
			MessageBox{message="Logan: Well... {p60}w-what does it matter anyways?!"},
			Do(function()
				scene.player.state = "angrydown"
			end),
			MessageBox{message="Logan: I-I'm doing exactly what I supposed to be doing! {p60}Working to take down Robotnik!"},
			Animate(scene.objectLookup.Rotor.sprite, "idledown"),
			MessageBox{message="Rotor: I know you're a little shy, but--"},
			Do(function()
				scene.player.state = "shock"
			end),
			Wait(1),
			Do(function()
				scene.player.state = "pose"
			end),
			MessageBox{message="Logan: Me?!{p60} Shy?!{p60} *snort*{p60} No way, I'm the least shy person you've ever met!"},
			Animate(scene.objectLookup.Rotor.sprite, "pose"),
			MessageBox{message="Rotor: Ok then{p60}, prove it."},
			Do(function()
				scene.player.state = "shock"
			end),
			MessageBox{message="Logan: Ugh!"},
			Parallel {
				Ease(scene.objectLookup.Rotor, "x", scene.player.x - scene.player.width, 2, "linear"),
				Ease(scene.objectLookup.Rotor, "y", scene.player.y - scene.player.height, 2, "linear")
			},
			Do(function()
				scene.objectLookup.Rotor:remove()
				scene.player.state = "idledown"
				scene.player.noIdle = false
				scene.player.hidekeyhints = {}
				GameState:setFlag("ep4_introdone")
				GameState:addToParty("rotor", 8, true)
				GameState.leader = "logan"
			end)
		}
	else
		scene.objectLookup.Rotor:remove()
		if GameState:isFlagSet("ep4_beat_fleet") then
			if not GameState:hasItem("Top Hat") and not GameState:isFlagSet("ep4_tails_snowman_hat") then
				GameState:grantItem(require "data/items/TopHat", 1)
				scene.audio:playMusic("snowday", 1.0, true)
				scene.player.y = scene.player.y + 50
				scene.player.state = "idleup"
				return BlockPlayer {
					Animate(scene.objectLookup.Fleet.sprite, "hatfrustrated"),
					MessageBox{message = "You received a {h Top Hat}!", sfx="levelup"},
					Animate(scene.objectLookup.Fleet.sprite, "frustrated")
				}
			end
			scene.objectLookup.Fleet.sprite:setAnimation("frustrated")
		end

		if GameState:isFlagSet("ep4_beat_sonic") then
			scene.objectLookup.Sonic.sprite:setAnimation("irritated")
		end

		-- Snowman flags
		if GameState:isFlagSet("ep4_tails_snowman_coal") then
			scene.objectLookup.SnowmanFace.sprite.color[4] = 255
		end
		if GameState:isFlagSet("ep4_tails_snowman_carrot") then
			scene.objectLookup.SnowmanNose.sprite.color[4] = 255
		end
		if GameState:isFlagSet("ep4_tails_snowman_hat") then
			scene.objectLookup.SnowmanHat.sprite.color[4] = 255
		end
		if GameState:isFlagSet("ep4_tails_snowman_scarf") then
			scene.objectLookup.SnowmanScarf.sprite.color[4] = 255
		end

		if hint == "lost_fight" then
			scene.audio:playMusic("snowday", 1.0, true)
			scene.player.y = scene.player.y + 50
			scene.player.state = "idleup"
			scene.objectLookup.Fleet.sprite:setAnimation("hatlaugh")
			return BlockPlayer {
				MessageBox{message = "Fleet: I told you... {p60}I am the master of snowball fights!"}
			}
		elseif hint == "snowboard_fail" then
			scene.audio:playMusic("snowday", 1.0, true)
			return BlockPlayer {
				MessageBox{message = "Sonic: Hey, don't feel bad...{p60} bein' this cool ain't for everyone."}
			}
		elseif hint == "snowboard_win" then
			scene.audio:playMusic("snowday", 1.0, true)
			GameState:grantItem(require "data/items/Scarf", 1)
			return BlockPlayer {
				Animate(scene.objectLookup.Sonic.sprite, "scarfirritated"),
				MessageBox{message = "Sonic: Ok, ok{p60}, a deal's a deal."},
				MessageBox{message = "You received a {h Scarf}!", sfx="levelup"},
				Animate(scene.objectLookup.Sonic.sprite, "irritated")
			}
		end
	end

	scene.audio:playMusic("snowday", 1.0, true)
	return Action()
end
