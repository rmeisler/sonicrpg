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
	local BlockPlayer = require "actions/BlockPlayer"
	local Move = require "actions/Move"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local AudioFade = require "actions/AudioFade"
	local shine = require "lib/shine"
	
	local SpriteNode = require "object/SpriteNode"
	local BasicNPC = require "object/BasicNPC"
	local FactoryBot = require "object/FactoryBot"
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	local elevatorLayer
	local wallLayer
	for _,layer in pairs(scene.map.layers) do
		if layer.name == "elevator" then
			elevatorLayer = layer
		elseif layer.name == "RightWall" then
            wallLayer = layer
        end
		
		if elevatorLayer ~= nil and wallLayer ~= nil then
			break
		end
	end
	
	local stepAction = function()
		return Serial {
			PlayAudio("sfx", "juggerbotstep", 0.3, true),
			scene:screenShake(20, 40),
			Wait(1),
			PlayAudio("sfx", "juggerbotstep", 0.3, true),
			scene:screenShake(20, 40)
		}
	end
	
	if GameState:isFlagSet("deathegg_robotnikcinematic") then
		if not scene.steppingSfx then
			-- Continuous stepping sounds from Juggerbot in bg
			scene:run(Spawn(
				Repeat(
					Serial {
						stepAction(),
						Wait(5)
					}
				)
			))
			elevatorLayer.offsety = 0
			
			scene.objectLookup.RightEntrance.y = scene.objectLookup.RightEntranceBlock.y
			scene.objectLookup.RightEntrance.object.y = scene.objectLookup.RightEntranceBlock.y
			scene.objectLookup.RightEntrance:updateCollision()
			scene.objectLookup.RightEntranceBlock:remove()
			wallLayer.offsety = -32*3
			
			scene.steppingSfx = true
		end
		
		scene.audio:stopMusic()
		
		return Action()
	end
	
	GameState:setFlag("deathegg_robotnikcinematic")
	
	local fbot = FactoryBot(
		scene,
		{name="objects"},
		{
			name = "FactoryBot",
			x = 544,
			y = scene.objectLookup["Spawn 1"].y + 32,
			width = 64,
			height = 32,
			properties = {
				battle = "data/monsters/factorybot.lua",
				battleOnColllide = true,
				disappearAfterBattle = true,
				defaultAnim = "idleup",
				ghost = true,
				sprite = "art/sprites/factorybot.png",
				ignorePlayer = true
			}
		}
	)
	scene:addObject(fbot)
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	scene.cinematicPause = true
	
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			scene.cinematicPause = true
		end),
		
		AudioFade("music", scene.audio:getMusicVolume(), 0, 1),
		
		-- Factorybot enters from left
		-- Go to elevator computer
		-- Face up
		Move(fbot, scene.objectLookup.Waypoint),
		Animate(fbot.sprite, "idleup"),

		-- Beep boop
		PlayAudio("sfx", "lockon", 1.0),
		Wait(0.2),
		PlayAudio("sfx", "lockon", 1.0),
		Wait(0.2),
		PlayAudio("sfx", "lockon", 1.0),
		Wait(0.2),
		PlayAudio("sfx", "lockon", 1.0),
		Wait(0.5),
		PlayAudio("sfx", "nicolebeep", 1.0),
		Wait(1),
		
		Animate(fbot.sprite, "idleright"),
		
		Parallel {
			Serial {
				Wait(1),
				PlayAudio("music", "robotnik", 1.0, true, true)
			},
			Ease(scene.camPos, "x", -600, 0.3),
			Ease(scene.camPos, "y", 1500, 0.3)
		},
		
		Do(function()
			scene.player.y = scene.player.y - 1500
			scene.camPos.y = 0
		end),
		
		Parallel {
			Serial {
				Ease(elevatorLayer, "offsety", 0, 0.1),
				Wait(0.5),
				Move(fbot, scene.objectLookup.Waypoint2),
				Wait(0.5),
				PlayAudio("sfx", "openchasm", 0.8, true),
				Ease(wallLayer, "offsety", -32*3, 1),
				Do(function()
					scene.objectLookup.RightEntrance.y = scene.objectLookup.RightEntranceBlock.y
					scene.objectLookup.RightEntrance.object.y = scene.objectLookup.RightEntranceBlock.y
					scene.objectLookup.RightEntrance:updateCollision()
					scene.objectLookup.RightEntranceBlock:remove()
				end),
				Move(fbot, scene.objectLookup.Waypoint3),
				Do(function()
					fbot:remove()
				end)
			},
			
			Serial {
				Wait(8),
				PlayAudio("sfx", "elevatorend", 1.0, true)
			},
			
			Ease(scene.player, "y", 2528 - scene.player.sprite.h*2, 0.1),
			Ease(scene.objectLookup.Robotnik, "y", 2528 - scene.objectLookup.Robotnik.sprite.h*2, 0.1),

			Serial {
				Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_smile"),
				MessageBox {message="Robotnik: Those Freedom Fighters days are numbered, Snively!", textspeed=0.2},
				MessageBox {message="Snively: Y-{p20}Yes, {p30}sir..."},
				Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_devilish"),
				MessageBox {message="Robotnik: My masterpiece is almost complete. {p20}He {p10}he {p10}he {p10}he...", textspeed=0.2},

				AudioFade("music", 1.0, 0.0, 1),
				Do(function()
					scene.audio:stopMusic()
				end),
				stepAction(),

				Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_lookback1"),
				MessageBox {message="Robotnik: What... {p40}was... {p40}that?", textspeed=0.2},

				stepAction(),

				Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_lookback2"),
				MessageBox {message="Snively: I believe that would be the {h Juggerbot}, {p20}sir."},

				stepAction(),

				MessageBox {message="Snively: I took the liberty of releasing him--{p60} t-{p20}-t{p20}-to guard the Death Egg in our absence."},
				
				PlayAudio("sfx", "juggerbotroar", 0.1, true),
				scene:screenShake(10, 30, 14),
				
				Animate(scene.objectLookup.Robotnik.sprite, "grab_snively_grin"),
				Parallel {
					MessageBox {message="Robotnik: O{p5}o{p5}o{p5}h, {p80}that's good Snively. {p80}That's very good indeed.", textspeed=0.2},

					Ease(elevatorLayer, "offsety", 900, 0.2),
					Ease(scene.objectLookup.Robotnik, "y", function() return scene.objectLookup.Robotnik.y + 900 end, 0.2),
					Serial {
						Wait(2),
						Ease(scene.camPos, "x", 0, 1),
						Do(function()
							scene.player.x = 544
							scene.player.y = 2496
							scene.player.sprite.visible = true
							scene.player.dropShadow.hidden = false
							scene.player.state = "idleright"
							scene.cinematicPause = false
							
							local block = BasicNPC(
								scene,
								{name="objects"},
								{
									name = "Block",
									x = 800,
									y = 2496,
									width = 32,
									height = 192,
									properties = {}
								}
							)
							scene:addObject(block)
							scene.objectLookup.Block = block
							
							-- Continuous stepping sounds from Juggerbot in bg
							scene:run(Spawn(
								Repeat(
									Serial {
										stepAction(),
										Wait(5)
									}
								)
							))
							scene.steppingSfx = true
						end)
					}
				}
			}
		}
	}
end
