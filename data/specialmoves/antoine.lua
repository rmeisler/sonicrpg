local Transform = require "util/Transform"

local Player = require "object/Player"
local NPC = require "object/NPC"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Action = require "actions/Action"
local Repeat = require "actions/Repeat"

return function(player)
	-- Remember basic movement controls
	player.basicUpdate = function(self, dt) end
	
	-- Find nearest bot
	local bots = {}
	local maxDistance = 2000*2000
	for _, object in pairs(player.scene.map.objects) do
		if  object.isBot and
			not object:isRemoved() and
			not object.object.properties.notAntoineTargetable and
			object:distanceFromPlayerSq(true) < maxDistance
		then
			table.insert(bots, object)
		end
	end
	table.sort(
		bots,
		function(a,b)
			return a:distanceFromPlayerSq() < b:distanceFromPlayerSq()
		end
	)
	
	-- Pull aggro of bot
	local aggro = Wait(3)
	if bots[1] then
		aggro = Serial {
			Do(function()
				player.scene:pauseEnemies(true)
			end),
			Parallel {
				Ease(player.scene.camPos, "x", function() return player.x - bots[1].x end, 1, "inout"),
				Ease(player.scene.camPos, "y", function() return player.y - bots[1].y end, 1, "inout"),

				Serial {
					Wait(0.5),
					Do(function()
						bots[1].visibleDist = 2000
						bots[1].audibleDist = 2000
						bots[1].maxUpdateDistance = 2000
						bots[1].hearWithoutMovement = true
						player.scene:pauseEnemies(false)
						player.antoineSpecialGoneTooFar = true
					end)
				}
			},
			Wait(1),
			Parallel {
				Ease(player.scene.camPos, "x", 0, 3, "linear"),
				Ease(player.scene.camPos, "y", 0, 3, "linear")
			},
			Do(function()
				player.antoineSpecialGoneTooFar = false
			end)
		}
	end
	
	player:run(While(
		function()
			return love.keyboard.isDown("lshift") or player.antoineSpecialGoneTooFar
		end,
		Serial {
			Do(function()
				player.sprite.sortOrderY = player.y
			end),
			PlayAudio("sfx", "antoinescared", 1.0, true),
			Animate(player.sprite, "scaredhop1"),
			Wait(0.1),
			Animate(player.sprite, "tremble"),
			Animate(player.sprite, "scaredhop2"),
			Ease(player, "y", player.y - 50, 7, "linear"),
			Animate(player.sprite, "scaredhop3"),
			Ease(player, "y", player.y, 7, "linear"),
			Animate(player.sprite, "scaredhop4"),
			Wait(0.1),
			Animate(player.sprite, "scaredhop5"),
			aggro,
			Do(function()
				player.basicUpdate = player.updateFun
				player.sprite.sortOrderY = nil
			end)
		},
		Serial {
			Parallel {
				AudioFade("sfx", 1.0, 0, 2),
				Ease(player, "y", player.y, 7, "linear"),
				Ease(player.scene.camPos, "x", 0, 3, "linear"),
				Ease(player.scene.camPos, "y", 0, 3, "linear")
			},
			Do(function()
				player.basicUpdate = player.updateFun
				player.sprite.sortOrderY = nil
				player.scene:pauseEnemies(false)
			end)
		}
	))
end