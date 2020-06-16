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
			Wait(3),
			Do(function()
				player.basicUpdate = player.origUpdate
			end)
		},
		Parallel {
			AudioFade("sfx", 1.0, 0, 2),
			Ease(player, "y", player.y, 7, "linear"),
			Do(function()
				player.basicUpdate = player.origUpdate
			end)
		}
	))
end