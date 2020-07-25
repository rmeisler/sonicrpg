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
	player.origUpdate = player.basicUpdate
	player.basicUpdate = function(self, dt) end
	
	-- Find nearest bot
	local bots = {}
	for _, object in pairs(player.scene.map.objects) do
		if object.isBot and not object:isRemoved() and object:distanceFromPlayerSq() < 1000000 then
			print("Found acceptable bot "..object.name)
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
		print("here's yer bot")
		aggro = Serial {
			Parallel {
				Ease(player.scene.camPos, "x", bots[1].x - player.x, 1, "inout"),
				Ease(player.scene.camPos, "y", player.y - bots[1].y, 1, "inout")
			},
			Do(function()
				bots[1].visibleDist = 1500
			end),
			Wait(1.5),
			Parallel {
				Ease(player.scene.camPos, "x", 0, 1, "inout"),
				Ease(player.scene.camPos, "y", 0, 1, "inout")
			}
		}
	end
	
	player:run(While(
		function()
			return love.keyboard.isDown("lshift")
		end,
		Serial {
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
				player.basicUpdate = player.origUpdate
			end)
		},
		Parallel {
			AudioFade("sfx", 1.0, 0, 2),
			Ease(player, "y", player.y, 7, "linear"),
			Parallel {
				Ease(player.scene.camPos, "x", 0, 1, "inout"),
				Ease(player.scene.camPos, "y", 0, 1, "inout")
			},
			Do(function()
				player.basicUpdate = player.origUpdate
			end)
		}
	))
end