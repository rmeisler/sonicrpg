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

	scene.player.dustColor = Player.FOREST_DUST_COLOR

	if GameState:isFlagSet("ep3_read") then
		scene.objectLookup.TailsHutWarmWindows:remove()
	end
	
	if hint == "intro" then
		return BlockPlayer {
			Do(function()
				scene.player:removeKeyHint()
				local door = scene.objectLookup.WorkshopDoor
				scene.player.hidekeyhints[tostring(door)] = door
				scene.audio:stopMusic()
			end),
			PlayAudio("music", "snowday", 1.0, true, true),
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
				Ease(scene.camPos, "x", 4000, 0.28, "linear")
			},
			Animate(scene.objectLookup.Tails.sprite, "idleright"),
			Ease(scene.camPos, "x", 6100, 0.5),
			Spawn(Parallel {
				Repeat(Do(function()
					if not scene.objectLookup.Sonic.dustTime or scene.objectLookup.Sonic.dustTime > 0.036 then
						scene.objectLookup.Sonic.dustTime = 0
					elseif scene.objectLookup.Sonic.dustTime < 0.036 then
						scene.objectLookup.Sonic.dustTime = scene.objectLookup.Sonic.dustTime + love.timer.getDelta()
						return
					end
					local dust = BasicNPC(
						scene,
						{name = "objects"},
						{
							name = "snowdust",
							x = scene.objectLookup.Sonic.x + scene.objectLookup.Sonic.sprite.w,
							y = scene.objectLookup.Sonic.y - scene.objectLookup.Sonic.sprite.h/2,
							width = 40,
							height = 36,
							properties = {defaultAnim = "updown", nocollision = true, sprite = "art/sprites/snowdust.png"}
						}
					)
					scene:addObject(dust)
					dust.sprite:onAnimationComplete(function()
						local ref = dust
						if ref then
							ref:remove()
						end
					end)
					scene.objectLookup.Sonic.dustTime = scene.objectLookup.Sonic.dustTime + love.timer.getDelta()
				end), 200),
				Ease(scene.objectLookup.Sonic, "x", 600, 0.4),
				Ease(scene.objectLookup.Sonic, "y", 2100, 0.4)
			}),
			Parallel {
				Ease(scene.camPos, "x", 6250, 0.3),
				Ease(scene.camPos, "y", -400, 0.3)
			},
			Wait(2.5),
			Parallel {
				Ease(scene.camPos, "x", 0, 1),
				Ease(scene.camPos, "y", 0, 1)
			},
			MessageBox{message="Logan: Ah...", closeAction=Wait(1)},
			Wait(0.5),
			Do(function()
				scene.player.state = "idleup"
			end),
			MessageBox{message="Logan: Welp, I'm going back inside.", closeAction=Wait(1)},
			Do(function()
				scene.player.noIdle = false
				scene.player.hidekeyhints = {}
				GameState:setFlag("ep4_introdone")
				GameState:addToParty("rotor", 8, true)
			end)
		}
	end

	scene.audio:playMusic("snowday", 1.0, true)
	return Action()
end
