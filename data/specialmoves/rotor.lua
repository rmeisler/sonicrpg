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

local RotorTrap = require "object/RotorTrap"

return function(player)
	player.basicUpdate = function(self, dt)
		if love.keyboard.isDown("lshift") then
			if not player.placeTrap then
				if player.scene.objectLookup.RotorTrap then
					player.scene.objectLookup.RotorTrap:remove()
				end
				local npc = RotorTrap(
					player.scene,
					{name = ((self.scene.currentLayerId == 1) and
						"lower" or
						("lower"..tostring(self.scene.currentLayerId)))
					},
					{
						name = "RotorTrap",
						x = player.x + 50,
						y = player.y,
						width = 64,
						height = 48,
						properties = {ghost = true, sprite = "art/sprites/rotorpad.png", alphaOverride = 100}
					}
				)
				player.scene:addObject(npc)
				player.scene.objectLookup.RotorTrap = npc
				player.placeTrap = npc
			end

			if love.keyboard.isDown("right") then
				player.state = "idleright"
			elseif love.keyboard.isDown("left") then
				player.state = "idleleft"
			elseif love.keyboard.isDown("up") then
				player.state = "idleup"
			elseif love.keyboard.isDown("down") then
				player.state = "idledown"
			end
			player.sprite:setAnimation(player.state)

			if player:isFacing("right") then
				player.placeTrap.x = player.x + 64
				player.placeTrap.y = player.y - 32
			elseif player:isFacing("left") then
				player.placeTrap.x = player.x - 158
				player.placeTrap.y = player.y - 32
			elseif player:isFacing("up") then
				player.placeTrap.x = player.x - 53
				player.placeTrap.y = player.y - 100
			else
				player.placeTrap.x = player.x - 53
				player.placeTrap.y = player.y + 64
			end
		else
			if not player.scene.objectLookup.RotorTrap then
				return
			end
			player.basicUpdate = function(self, dt) end
			local placeTrap = player.placeTrap
			player:run(Serial {
				PlayAudio("sfx", "factoryspit", 1.0, true),
				Do(function()
					player.scene.objectLookup.RotorTrap.sprite.color[4] = 255
				end),
				Do(function()
					player.basicUpdate = player.updateFun
					if placeTrap then
						placeTrap:addSceneHandler("update")
						placeTrap = nil
					end
				end),
				player.scene.objectLookup.RotorTrap:hop(),
				Animate(player.scene.objectLookup.RotorTrap.sprite, "activate"),
				Do(function()
					player.scene.objectLookup.RotorTrap.sprite:setAnimation("active")
				end)
			})
		end
	end
end