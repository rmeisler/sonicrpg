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

	-- Find nearest targetable
	local targets = {}
	for _, object in pairs(player.scene.map.objects) do
		if  not object:isRemoved() and
		    object.object and
			object.object.properties.loganTargetable
		then
			table.insert(targets, object)
		end
	end
	table.sort(
		targets,
		function(a,b)
			return a:distanceFromPlayerSq() < b:distanceFromPlayerSq()
		end
	)
	
	-- Pull aggro of bot
	local aggro = Wait(3)
	if targets[1] then
		aggro = Serial {
			Do(function()
				player.scene:pauseEnemies(true)
			end),
			Parallel {
				Ease(player.scene.camPos, "x", function() return player.x - targets[1].x end, 1, "inout"),
				Ease(player.scene.camPos, "y", function() return player.y - targets[1].y end, 1, "inout"),

				Serial {
					Wait(0.5),
					Do(function()
						targets[1].visibleDist = 2000
						targets[1].audibleDist = 2000
						targets[1].maxUpdateDistance = 2000
						targets[1].hearWithoutMovement = true
						player.scene:pauseEnemies(false)
						player.loganSpecialGoneTooFar = true
					end)
				}
			},
			Wait(1),
			Parallel {
				Ease(player.scene.camPos, "x", 0, 3, "linear"),
				Ease(player.scene.camPos, "y", 0, 3, "linear")
			},
			Do(function()
				player.loganSpecialGoneTooFar = false
			end)
		}
	end
	
	player:run(While(
		function()
			return love.keyboard.isDown("lshift") or player.loganSpecialGoneTooFar
		end,
		Serial {
			Do(function()
				player.sprite.sortOrderY = player.y
			end),
			Animate(player.sprite, "scan"),
			PlayAudio("sfx", "nichole", 1.0, true),
			Wait(1),
			PlayAudio("sfx", "nicholescan", 1.0, true),
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