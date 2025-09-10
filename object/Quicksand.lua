local BlockPlayer = require "actions/BlockPlayer"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Action = require "actions/Action"

local Player = require "object/Player"
local NPC = require "object/NPC"

local Quicksand = class(NPC)


local MIN_DIST_TO_CENTER = 5
local DEFAULT_DEPTH = 10


function Quicksand:construct(scene, layer, object)
	self.ghost = true
	self.exitObject = object.properties.exitObject
	self.exitScene = object.properties.exitScene
	self.depth = DEFAULT_DEPTH
	self.active = object.properties.active or false
	self.image = object.properties.image

	NPC.init(self)
	
	self:addSceneHandler("update", Quicksand.update)
end

function Quicksand:update(dt)
	local player = self.scene.player

	if player.teleporting or not self.active then
		return
	end

	-- Initialize quicksands
	if player.quicksands == nil then
		player.quicksands = {}
	end

	NPC.update(self, dt)

	if self.state == NPC.STATE_TOUCHING then
		if next(player.quicksands) == nil then
			player.y = player.y + self.depth
			player.sprite:setCrop(self.depth)
			player.dropShadow.hidden = true
			player.movespeed = player.baseMoveSpeed/2
		end

		-- Start pulling player toward center of quicksand
		local dx = player.x - (self.x + self.object.width/2)
		local dy = (player.y + player.height) - (self.y + self.object.height/2)
		local mag = math.sqrt(dx * dx + dy * dy)

		local stepX = -(dx / mag) * (dt/0.016)
		local stepY = -(dy / mag) * (dt/0.016)
		
		player.quicksands[tostring(self)] = self

		if mag < MIN_DIST_TO_CENTER then
			self:teleport()
		else
			player.x = player.x + stepX
			player.y = player.y + stepY
		end
	elseif player.quicksands[tostring(self)] ~= nil then
		player.quicksands[tostring(self)] = nil

		if next(player.quicksands) == nil then
			player.y = player.y - self.depth
			player.sprite:removeCrop()
			player.dropShadow.hidden = false
			player.movespeed = player.baseMoveSpeed
			self.depth = DEFAULT_DEPTH
		end
	end
end

function Quicksand:teleport()
	local player = self.scene.player
	local exitAction = Action()

	if self.exitObject then
		local exitObject = self.scene.objectLookup[self.exitObject]
		exitAction = Serial {
			Parallel {
				Ease(player, "x", exitObject.x + exitObject.object.width/2, 1),
				Ease(player, "y", exitObject.y + exitObject.object.height/2 - player.height, 1)
			},
			Parallel {
				Ease(self, "depth", 0, 4),
				Ease(player, "y", function() return player.y - 150 end, 3),
				Do(function()
					player.sprite:setCrop(self.depth)
				end)
			},
			Do(function()
				player.dropShadow.hidden = false
				player.dropShadowOverrideY = player.y + player.sprite.h + 215
			end),
			Ease(player, "y", function() return player.y + 280 end, 5),
			Do(function()
				player.teleporting = false
				player.nocollision = false
				player.dropShadowOverrideY = nil
				player.state = "idledown"
			end)
		}
	elseif self.exitScene then
		exitAction = Do(function()
			local mapName = "maps/"..self.exitScene
			self.scene:changeScene{mapName = mapName, fadeOutSpeed = 0.2, fadeInSpeed = 0.2, fadeOutMusic = true, enterDelay = 2}
		end)
	end

    player.teleporting = true
	player.nocollision = true

	self:run(BlockPlayer {
		Do(function()
			player.state = "shock"
		end),
		Parallel {
			Ease(self, "depth", function() return self.depth + player.height * 2 end, 1),
			Ease(player, "y", function() return player.y + player.height * 2 end, 1),
			Do(function()
				player.sprite:setCrop(self.depth)
			end)
		},
        exitAction
    })
end

return Quicksand
