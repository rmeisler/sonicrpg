local Transform = require "util/Transform"

local Player = require "object/Player"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Action = require "actions/Action"
local Executor = require "actions/Executor"

return function(player)
	-- Remember basic movement controls
	player.basicUpdate = function(self, dt) end
	
	local balloon = SpriteNode(
		player.scene,
		Transform.from(player.sprite.transform),
		player.sprite.color,
		"blueballoon",
		nil,
		nil,
		"objects"
	)
	balloon.transform.ox = balloon.w/2
	balloon.transform.oy = balloon.h/2
	balloon.sortOrderY = player.sprite.transform.y + player.sprite.h*2
	
	local dir
	local keyFrames = {}
	local angles = {}
	player.state = Player.ToIdle[player.state]
	if player.state == Player.STATE_IDLEUP then
		dir = "up"
		keyFrames = {
			Transform(
				player.sprite.transform.x + 32 - balloon.w,
				player.sprite.transform.y - balloon.h
			),
			Transform(
				player.sprite.transform.x - balloon.w * 2,
				player.sprite.transform.y + 12 - balloon.h
			),
			Transform(
				player.sprite.transform.x - 100,
				player.sprite.transform.y + player.sprite.h
			)
		}
		balloon.transform.angle = -math.pi/2
	elseif player.state == Player.STATE_IDLEDOWN then
		dir = "down"
		keyFrames = {
			Transform(
				player.sprite.transform.x + 32 - balloon.w,
				player.sprite.transform.y - balloon.h
			),
			Transform(
				player.sprite.transform.x - balloon.w * 2,
				player.sprite.transform.y + 12 - balloon.h
			),
			Transform(
				player.sprite.transform.x - 100,
				player.sprite.transform.y + player.sprite.h
			)
		}
		balloon.transform.angle = math.pi/2
	elseif player.state == Player.STATE_IDLELEFT then
		dir = "left"
		balloon.transform.x = balloon.transform.x + 98
		balloon.transform.y = balloon.transform.y + 84
		keyFrames = {
			Transform(
				player.sprite.transform.x + 32 - balloon.w,
				player.sprite.transform.y - balloon.h
			),
			Transform(
				player.sprite.transform.x - balloon.w * 2,
				player.sprite.transform.y + 12 - balloon.h
			),
			Transform(
				player.sprite.transform.x - 200,
				player.sprite.transform.y + player.height/2
			),
			Transform(
				player.sprite.transform.x - 250,
				player.sprite.transform.y + player.height*2
			)
		}
		angles = {
			math.pi/4,
			math.pi/6,
			0
		}
		balloon.transform.angle = math.pi/2
	elseif player.state == Player.STATE_IDLERIGHT then
		dir = "right"
		balloon.transform.x = balloon.transform.x + 36
		balloon.transform.y = balloon.transform.y + 84
		keyFrames = {
			Transform(
				player.sprite.transform.x + player.width*2 - 32 + balloon.w,
				player.sprite.transform.y - balloon.h
			),
			Transform(
				player.sprite.transform.x + player.width*2 + balloon.w * 2,
				player.sprite.transform.y + 12 - balloon.h
			),
			Transform(
				player.sprite.transform.x + player.width*2 + 200,
				player.sprite.transform.y + player.height/2
			),
			Transform(
				player.sprite.transform.x + player.width*2 + 250,
				player.sprite.transform.y + player.height*2
			)
		}
		angles = {
			math.pi/2 + math.pi/4,
			math.pi/2 + math.pi/3,
			math.pi
		}
		balloon.transform.angle = math.pi/2
	end
	
	player.basicUpdate = function(self, dt)
		if love.keyboard.isDown("lshift") then
			player.sprite:setAnimation("aim"..dir)
		else
			player.basicUpdate = function(self, dt) end
			player:run(Serial {
				Animate(player.sprite, "throw"..dir, true),
				
				Animate(balloon, "throw", true),
				
				Parallel {
					Ease(balloon.transform, "x", keyFrames[1].x, 7, "linear"),
					Ease(balloon.transform, "y", keyFrames[1].y, 7, "linear"),
					Ease(balloon.transform, "angle", angles[1], 7, "linear"),
				},
				Parallel {
					Ease(balloon.transform, "x", keyFrames[2].x, 7, "linear"),
					Ease(balloon.transform, "y", keyFrames[2].y, 7, "linear"),
					Ease(balloon.transform, "angle", angles[2], 7, "linear"),
				},
				Parallel {
					Ease(balloon.transform, "x", keyFrames[3].x, 5, "linear"),
					Ease(balloon.transform, "y", keyFrames[3].y, 5, "linear"),
					Ease(balloon.transform, "angle", angles[3], 6, "linear"),
				},
				Parallel {
					Ease(balloon.transform, "x", keyFrames[4].x, 5, "linear"),
					Ease(balloon.transform, "y", keyFrames[4].y, 5, "linear")
				},
				
				PlayAudio("sfx", "splash", 1.0, true),
				
				Parallel {
					Animate(balloon, "explode"),
					
					Animate(function()
						local npc = BasicNPC(
							player.scene,
							{name = "objects"},
							{
								name = "waterspot",
								x = balloon.transform.x + player.x - love.graphics.getWidth()/2,
								y = balloon.transform.y + player.y - love.graphics.getHeight()/2,
								width = 64,
								height = 64,
								properties = {nocollision = true, sprite = "art/sprites/waterspot.png"}
							}
						)
						npc.sprite.transform.ox = 32
						npc.sprite.transform.oy = 32
						npc.sprite.sortOrderY = -100
						player.scene:addObject(npc)
						
						Executor(player.scene):act(Serial {
							Wait(1),
							Ease(npc.sprite.color, 4, 0, 0.5, "linear"),
							Do(function()
								npc.sprite:remove()
							end)
						})
						
						return npc.sprite
					end, "splash"),
					
					Animate(function()
						local splashXform = Transform(balloon.transform.x, balloon.transform.y, 2, 2)
						splashXform.ox = 32
						splashXform.oy = 32
						return SpriteNode(player.scene, splashXform, nil, "waterblast", nil, nil, "objects"), true
					end, "splash")
				},

				Do(function()
					balloon:remove()
					player.basicUpdate = player.updateFun
				end)
			})
		end
	end
end