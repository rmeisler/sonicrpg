return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local TextNode = require "object/TextNode"
	local BasicNPC = require "object/BasicNPC"
	local NPC = require "object/NPC"
	
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		scene.map.properties.regionName,
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.sectorName,
		100
	)
	local showTitle = function()
		Executor(scene):act(Serial {
			Wait(0.5),
			subtext,
			text,
			Parallel {
				Ease(subtext.color, 4, 255, 1),
			    Ease(text.color, 4, 255, 1)
			},
			Wait(2),
			Parallel {
				Ease(subtext.color, 4, 0, 1),
			    Ease(text.color, 4, 0, 1)
			}
		})
	end
	
	if scene.reenteringFromBattle then
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		scene.objectLookup.Firebird.sprite:setAnimation("hurt")
		scene.objectLookup.Rotor.sprite:setAnimation("idleleft")
		scene.objectLookup.Logan.sprite:setAnimation("idleleft")
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Spawn(Repeat(Serial {
				Ease(scene.objectLookup.Firebird, "x", function() return scene.objectLookup.Firebird.x - 2 end, 20),
				Ease(scene.objectLookup.Firebird, "x", function() return scene.objectLookup.Firebird.x + 2 end, 20)
			})),
			MessageBox{message="Logan: It won't be disabled for long!"},
			Wait(1),
			PlayAudio("sfx", "elevator", 1.0, true),
			Spawn(scene:screenShake(10, 30, 40)),
			Ease(scene.objectLookup.Boulder1, "y", function() return scene.objectLookup.Rotor.y end, 3),
			PlayAudio("sfx", "explosion", 1.0, true),
			Animate(scene.objectLookup.Rotor.sprite, "idleright"),
			Wait(0.5),
			Ease(scene.objectLookup.Boulder2, "y", function() return scene.objectLookup.Rotor.y + 20 end, 3),
			PlayAudio("sfx", "explosion", 1.0, true),
			Ease(scene.objectLookup.Boulder3, "y", function() return scene.objectLookup.Rotor.y - 20 end, 3),
			PlayAudio("sfx", "explosion", 1.0, true),
			Spawn(scene:screenShake(10, 30, 40)),
			AudioFade("music", 1.0, 0.0, 1),
			-- Sonic and Fleet arrive on the scene
			Parallel {
				Serial {
					Wait(0.2),
					PlayAudio("sfx", "sonicrunturn", 1.0, true)
				},
				Serial {
					Parallel {
						Ease(scene.objectLookup.Sonic, "x", function() return scene.objectLookup.Rotor.x - 150 end, 1),
						Repeat(Do(function()
							local sonic = scene.objectLookup.Sonic
							if not sonic.dustTime or sonic.dustTime > 0.005 then
								sonic.dustTime = 0
							elseif sonic.dustTime < 0.005 then
								sonic.dustTime = sonic.dustTime + love.timer.getDelta()
								return
							end
							
							local dustObject = BasicNPC(
								scene,
								{name = "upper"},
								{name = "dust", x = sonic.x, y = sonic.y, width = 40, height = 36,
									properties = {nocollision = true, sprite = "art/sprites/dust.png", align = NPC.ALIGN_BOTLEFT}
								}
							)
							dustObject.sprite.color = {130, 130, 200, 255}
							dustObject.x = dustObject.x - sonic.sprite.w*2 - dustObject.sprite.w - 5
							dustObject.y = dustObject.y + sonic.sprite.h*1.5 - dustObject.sprite.h*2
							dustObject.sprite.transform.sx = 4
							dustObject.sprite.transform.sy = 4
							dustObject.sprite:setAnimation("right")
							
							dustObject.sprite.animations[dustObject.sprite.selected].callback = function()
								local ref = dustObject
								ref:remove()
							end
							scene:addObject(dustObject)
							sonic.dustTime = sonic.dustTime + love.timer.getDelta()
						end), 20),
					},
					Animate(scene.objectLookup.Sonic.sprite, "idleright"),
				},
				Serial {
					Animate(scene.objectLookup.Fleet.sprite, "flyright"),
					Do(function()
						scene.objectLookup.Fleet.sprite.transform.angle = math.pi/6
					end),
					Ease(scene.objectLookup.Fleet, "x", function() return scene.objectLookup.Rotor.x - 100 end, 1),
					Animate(scene.objectLookup.Fleet.sprite, "idleright"),
					Do(function()
						scene.objectLookup.Fleet.sprite.transform.angle = 0
					end),
				}
			},
			Animate(scene.objectLookup.Rotor.sprite, "idleleft"),
			Parallel {
				scene.objectLookup.Rotor:hop(),
				scene.objectLookup.Logan:hop()
			},
			Animate(scene.objectLookup.Fleet.sprite, "smirk"),
			MessageBox{message="Fleet: Staying out of trouble, I see?"},
			Animate(scene.objectLookup.Sonic.sprite, "irritated"),
			scene.objectLookup.Sonic:hop(),
			MessageBox{message="Sonic: Hey! {p60}I'm the one who delivers the quippy lines around here!"},
			PlayAudio("sfx", "elevator", 1.0, true),
			Spawn(scene:screenShake(10, 30, 40)),
			MessageBox{message="Rotor: Sonic! {p60}Fleet!"},
			Animate(scene.objectLookup.Logan.sprite, "irritated"),
			MessageBox{message="Logan: Took you long enough!"},
			scene.objectLookup.Rotor:hop(),
			MessageBox{message="Rotor: Sonic, we gotta get my Pop-Pop! {p60}He's on the floor above!"},
			Spawn(scene:screenShake(10, 30, 40)),
			PlayAudio("sfx", "sonicrun", 1.0, true),
			Animate(scene.objectLookup.Sonic.sprite, "chargerun1"),
			Do(function() scene.objectLookup.Sonic.sprite:setAnimation("chargerun2") end),
			MessageBox{message="Sonic: I'm on it, Rote!"},
			Do(function() scene.objectLookup.Sonic.sprite:setAnimation("juiceright") end),
			Parallel {
				Ease(scene.objectLookup.Sonic, "x", function() return scene.objectLookup.Sonic.x + 900 end, 2),
				Repeat(Do(function()
					local sonic = scene.objectLookup.Sonic
					if not sonic.dustTime or sonic.dustTime > 0.01 then
						sonic.dustTime = 0
					elseif sonic.dustTime < 0.01 then
						sonic.dustTime = sonic.dustTime + love.timer.getDelta()
						return
					end
					
					local dustObject = BasicNPC(
						scene,
						{name = "upper"},
						{name = "dust", x = sonic.x, y = sonic.y, width = 40, height = 36,
							properties = {nocollision = true, sprite = "art/sprites/dust.png", align = NPC.ALIGN_BOTLEFT}
						}
					)
					dustObject.sprite.color = {130, 130, 200, 255}
					dustObject.x = dustObject.x - sonic.sprite.w*2 - dustObject.sprite.w - 5
					dustObject.y = dustObject.y + sonic.sprite.h*1.5 - dustObject.sprite.h*2
					dustObject.sprite.transform.sx = 4
					dustObject.sprite.transform.sy = 4
					dustObject.sprite:setAnimation("right")
					
					dustObject.sprite.animations[dustObject.sprite.selected].callback = function()
						local ref = dustObject
						ref:remove()
					end
					scene:addObject(dustObject)
					sonic.dustTime = sonic.dustTime + love.timer.getDelta()
				end), 100),
			},
			Do(function()
				scene:changeScene{map="bartcave", hint="ep4_bart_dies", spawnPoint="DownPath", fadeInSpeed=0.2, fadeOutSpeed=0.2}
			end)
		}
	end

	if hint == "battletime" then
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			PlayAudio("sfx", "elevator", 1.0, true),
			Spawn(scene:screenShake(10, 30, 10)),
			Ease(scene.objectLookup.Rotor, "y", 476, 1, "linear"),
			PlayAudio("sfx", "bang", 1.0, true),
			Animate(scene.objectLookup.Rotor.sprite, "dead"),
			Wait(1),
			Animate(scene.objectLookup.Rotor.sprite, "idleleft"),
			Wait(0.5),
			Animate(scene.objectLookup.Rotor.sprite, "shock"),
			scene.objectLookup.Rotor:hop(),
			MessageBox{message="Rotor: Uh oh!!"},
			Wait(0.5),
			Ease(scene.objectLookup.Logan, "y", 476, 1, "linear"),
			PlayAudio("sfx", "bang", 1.0, true),
			Animate(scene.objectLookup.Logan.sprite, "idleleft"),
			MessageBox{message="Logan: Leavin' me out of the action?"},
			Animate(scene.objectLookup.Firebird.sprite, "iceattack"),
			Animate(scene.objectLookup.Logan.sprite, "shock"),
			scene.objectLookup.Logan:hop(),
			MessageBox{message="Logan: Crud."},
			scene:enterBattle{
				opponents = {"firebirdv1"},
				music = "boss",
				bossBattle = true
			}
		}
	else
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Spawn(Repeat(PlayAudio("sfx", "alert", 1.0))),
			Spawn(Repeat(PlayAudio("sfx", "elevator", 1.0))),
			Spawn(scene:screenShake(10, 30, 1000)),
			Wait(1),
			Parallel {
				Serial {
					MessageBox{message="Snively: *screams* {p60}Test subject has broken free from its holding chamber!!"},
					MessageBox{message="Snively: All Swatbots report to Test Room C!!\n{p60}Contain {h Project Firebird}!!"}
				},
				Ease(scene.objectLookup.Snively, "x", function() return scene.objectLookup.Snively.x + 1200 end, 0.4, "linear")
			},
			Do(function()
				scene:changeScene{map="bartcave", hint="from_testsite"}
			end)
		}
	end
end
