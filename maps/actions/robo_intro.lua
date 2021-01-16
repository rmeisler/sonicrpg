local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"

return function(scene)
	--[[local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Robotropolis",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Inner City",
		100
	)
	
	local bg = SpriteNode(
		scene,
		Transform(0,0,1.5,1.5),
		{255,255,255,255},
		"RobotropolisBG",
		nil,
		nil,
		"objects"
	)
	
	local bg2 = SpriteNode(
		scene,
		Transform(0,0,1.6,1.6),
		{255,255,255,0},
		"robobase",
		nil,
		nil,
		"objects"
	)
	local bg2Overlay = SpriteNode(
		scene,
		Transform(0,0,1.3,1.3),
		{255,255,255,0},
		"robobasepillar",
		nil,
		nil,
		"objects"
	)
	
	local bg3 = SpriteNode(
		scene,
		Transform(-300,-300,1.5,1.5),
		{255,255,255,0},
		"robointro1",
		nil,
		nil,
		"objects"
	)
	
	local bg4 = SpriteNode(
		scene,
		Transform(0,0,1,1),
		{255,255,255,0},
		"genericforwardbg",
		nil,
		nil,
		"objects"
	)
	bg4.sortOrderY = -9999
	
	local behindBg4 = SpriteNode(
		scene,
		Transform(0,0,1,1),
		{255,255,255,0},
		"genericforwardbg2",
		nil,
		nil,
		"objects"
	)
	behindBg4.sortOrderY = -10000
	
	local hoverbot = SpriteNode(
		scene,
		Transform(800,-500,8,8),
		{255,255,255,255},
		"hoverbotopening",
		nil,
		nil,
		"objects"
	)
	
	local rotor = SpriteNode(
		scene,
		Transform(0,0,2,2),
		{255,255,255,0},
		"sprites/rotor",
		nil,
		nil,
		"objects"
	)
	rotor.transform.ox = rotor.w/2
	rotor.transform.oy = rotor.h/2

	local bunny = SpriteNode(
		scene,
		Transform(0,0,2,2),
		{255,255,255,0},
		"sprites/bunny",
		nil,
		nil,
		"objects"
	)
	bunny.transform.ox = bunny.w/2
	bunny.transform.oy = bunny.h/2

	local antoine = SpriteNode(
		scene,
		Transform(0,0,2,2),
		{255,255,255,0},
		"sprites/antoine",
		nil,
		nil,
		"objects"
	)
	antoine.transform.ox = antoine.w/2
	antoine.transform.oy = antoine.h/2
	
	-- moving ground sprites
	local movingSprites = {}
	for i = 1, 80 do
		local sprite = SpriteNode(
			scene,
			Transform(
				i * 10,
				420 - 30 * math.sin(i * (math.pi / 80)) + 20 * math.random(),
				2,
				2 + 5 * math.random()
			),
			{255,255,255,255},
			"sprites/movingground",
			nil,
			nil,
			"objects"
		)
		sprite.sortOrderY = 1
		sprite.transform.ox = sprite.w/2
		sprite.transform.oy = sprite.h/2
		sprite.transform.angle = math.pi
		sprite.visible = false
		table.insert(movingSprites, sprite)
	end
	
	scene.player.sprite.visible = false
	scene.player.cinematic = true
	scene.player.dontfuckingmove = true
	
	hoverbot:setAnimation("backward")
	hoverbot.sortOrderY = 9999
	bg2Overlay.sortOrderY = 10000]]
	
	return Serial {
		--[[Wait(2),
		Parallel {
			Serial {
				Wait(1.2),
				PlayAudio("music", "majorplan", 1.0, true)
			},
		
			Serial {
				Parallel {
					Ease(bg.transform, "x", -1000, 0.4, "inout"),
					Ease(bg.transform, "sx", 1, 0.2, "inout"),
					Ease(bg.transform, "sy", 1, 0.2, "inout")
				},
				
				Parallel {
					Serial {
						Wait(0.5),
						subtext,
						text,
						Parallel {
							Ease(text.color, 4, 255, 1),
							Ease(subtext.color, 4, 255, 1),
						},
						Wait(1.8),
						Parallel {
							Ease(text.color, 4, 0, 0.5),
							Ease(subtext.color, 4, 0, 0.5)
						}
					},
					Serial {
						Wait(2.5),
						
						Parallel {
							Ease(hoverbot.transform, "sx", 0.25, 0.4, "inout"),
							Ease(hoverbot.transform, "sy", 0.25, 0.4, "inout"),
							Ease(hoverbot.transform, "x", 150, 0.4, "inout"),
							Ease(hoverbot.transform, "y", 450, 0.4, "inout"),
						},
						Animate(hoverbot, "forwardright"),
						
						Parallel {
							Ease(hoverbot.transform, "sx", 0.05, 0.6, "linear"),
							Ease(hoverbot.transform, "sy", 0.05, 0.6, "linear"),
							Ease(hoverbot.transform, "x", 430, 0.6, "linear"),
							Ease(hoverbot.transform, "y", 300, 0.6, "linear")
						}
					}
				},
			},
			Ease(bg.transform, "y", -800, 0.8, "inout"),
		},
		
		Animate(hoverbot, "right"),
		Do(function()
			bg.color[4] = 0
			
			bg2.color[4] = 255
			bg2Overlay.color[4] = 255
			hoverbot.transform.x = -200
			hoverbot.transform.y = 300
			hoverbot.transform.sx = 1
			hoverbot.transform.sy = 1
		end),
		
		Parallel {
			Ease(bg2.transform, "sx", 1, 0.3, "inout"),
			Ease(bg2.transform, "sy", 1, 0.3, "inout"),
			
			Ease(bg2Overlay.transform, "sx", 1, 0.3, "inout"),
			Ease(bg2Overlay.transform, "sy", 1, 0.3, "inout"),
			
			Ease(hoverbot.transform, "sx", 0.6, 0.3, "inout"),
			Ease(hoverbot.transform, "sy", 0.6, 0.3, "inout"),
			
			Serial {
				Wait(0.5),
				Ease(hoverbot.transform, "x", 800, 0.4, "quad")
			}
		},
		
		Wait(1.4),
		
		Do(function()
			bg3.color[4] = 255
			hoverbot.color[4] = 0
			hoverbot.transform.x = 100
			hoverbot.transform.y = 260
			hoverbot.transform.sx = 0.1
			hoverbot.transform.sy = 0.1
		end),
		Parallel {
			Ease(bg2.transform, "x", -200, 0.9, "quad"),
			Ease(bg2.transform, "y", 0, 0.9, "quad"),
			Ease(bg2.transform, "sx", 1.25, 0.9, "quad"),
			Ease(bg2.transform, "sy", 1.25, 0.9, "quad"),
			
			Ease(bg2Overlay.transform, "x", -500, 0.9, "quad"),
			Ease(bg2Overlay.transform, "y", 150, 0.9, "quad"),
			Ease(bg2Overlay.transform, "sx", 1.25, 0.9, "quad"),
			Ease(bg2Overlay.transform, "sy", 1.25, 0.9, "quad"),
			
			Serial {
				Wait(2),
				Parallel {
					Ease(bg3.transform, "sx", 1, 0.15, "inout"),
					Ease(bg3.transform, "sy", 1, 0.15, "inout"),
					Ease(bg3.transform, "x", 0, 0.15, "inout"),
					Ease(bg3.transform, "y", 0, 0.15, "inout"),
					
					Serial {
						Ease(bg2.color, 4, 0, 0.3, "inout"),
						Do(function()
							bg2Overlay.color[4] = 0
						end),
					},
					
					Serial {
						Wait(1.6),
						Animate(hoverbot, "straight"),
						Parallel {
							Ease(hoverbot.color, 4, 255, 1, "inout"),
							Ease(hoverbot.transform, "x", 50, 0.3, "quad"),
							Ease(hoverbot.transform, "y", 320, 0.3, "quad"),
							Ease(hoverbot.transform, "sx", 2, 0.3, "quad"),
							Ease(hoverbot.transform, "sy", 2, 0.3, "quad"),
						},
						Parallel {
							Ease(hoverbot.transform, "x", 1300, 1.2, "quad"),
							Ease(hoverbot.transform, "sx", 8, 1, "quad"),
							Ease(hoverbot.transform, "sy", 8, 1, "quad"),
							Ease(hoverbot.transform, "y", -450, 1.2, "quad"),
							
							Serial {
								Wait(0.2),
								Animate(hoverbot, "upright")
							}
						},
					}
				},
			}
		},
		
		Animate(hoverbot, "straight"),
		Do(function()
			hoverbot.transform.x = 400 - (hoverbot.w/2) * 5
			hoverbot.transform.y = 400 
			hoverbot.transform.sx = 5
			hoverbot.transform.sy = 5
			hoverbot.color[4] = 0
			bg4.color[4] = 255
			behindBg4.color[4] = 255
			
			for _, sprite in pairs(movingSprites) do
				sprite.visible = true
			end
		end),
		
		Parallel {
			Ease(bg3.color, 4, 0, 0.25, "inout"),
			Ease(hoverbot.color, 4, 255, 0.25),
			
			Serial {
				Parallel {
					Ease(hoverbot.transform, "sx", 2, 0.15, "inout"),
					Ease(hoverbot.transform, "sy", 2, 0.15, "inout"),
					Ease(hoverbot.transform, "x", 400 - hoverbot.w, 0.15, "inout"),
					Ease(hoverbot.transform, "y", 300 - hoverbot.h, 0.15, "inout")	
				},
				
				Wait(2),
				
				Do(function()
					antoine.transform.x = hoverbot.transform.x + hoverbot.w - 50
					antoine.transform.y = hoverbot.transform.y + hoverbot.h - 20
					antoine:setAnimation("idledown")
					
					bunny.transform.x = hoverbot.transform.x + hoverbot.w + 50
					bunny.transform.y = hoverbot.transform.y + hoverbot.h - 20
					bunny:setAnimation("idledown")
					
					rotor.transform.x = hoverbot.transform.x + hoverbot.w + 10
					rotor.transform.y = hoverbot.transform.y + hoverbot.h + 30
					rotor:setAnimation("idledown")			
				end),
				Parallel {
					Ease(hoverbot.color, 4, 0, 0.5),
					Ease(rotor.color, 4, 255, 0.5),
					Ease(bunny.color, 4, 255, 0.5),
					Ease(antoine.color, 4, 255, 0.5),
				},
				
				Wait(1),
				
				Animate(antoine, "scaredhop1"),
				
				MessageBox {
					message="Antoine: I am not having very good feelings about this!!",
					textSpeed=4,
					closeAction=Wait(2)
				},
				
				Animate(bunny, "idleleft"),
				
				MessageBox {
					message="Bunny: You just stick by me suga' and you'll be fine!",
					textSpeed=4,
					closeAction=Wait(2)
				},
				
				Animate(antoine, "idledown"),
				Animate(bunny, "idledown"),
				
				MessageBox {
					message="Rotor: We're almost there!",
					textSpeed=4,
					closeAction=Wait(1)
				}
			},
			
			Ease(behindBg4.transform, "y", -160, 0.042, "linear")
		},]]
		
		Do(function()
			scene.sceneMgr:switchScene {
				class = "BasicScene",
				mapName = "maps/robo_opening2.lua",
				map = scene.maps["maps/robo_opening2.lua"],
				maps = scene.maps,
				region = scene.region,
				spawn_point = "Spawn 1",
				spawn_point_offset = Transform(),
				fadeInSpeed = 20,
				fadeOutSpeed = 20,
				--fadeOutMusic = self.object.properties.fade_out_music,
				images = scene.images,
				animations = scene.animations,
				audio = scene.audio,
				doingSpecialMove = scene.player.doingSpecialMove,
				cache = true
			}
		end)
	}
end
