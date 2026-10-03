local BlockPlayer = require "actions/BlockPlayer"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Action = require "actions/Action"

local Player = require "object/Player"
local NPC = require "object/NPC"

local Megamuck = class(NPC)


local DEFAULT_DEPTH = 10


function Megamuck:construct(scene, layer, object)
	self.ghost = true

	NPC.init(self)

	self:addSceneHandler("update", Megamuck.update)
end

function Megamuck:update(dt)
	local player = self.scene.player
	
	-- Initialize megamucks
	if player.megamucks == nil then
		player.megamucks = {}
	end

	NPC.update(self, dt)

	if self.state == NPC.STATE_TOUCHING then
		if next(player.megamucks) == nil then
			player.dropShadow.hidden = true
			player.movespeed = player.baseMoveSpeed/2
		end

		player.sprite:setCrop(DEFAULT_DEPTH)
		player.megamucks[tostring(self)] = self
	elseif player.megamucks[tostring(self)] ~= nil then
		player.megamucks[tostring(self)] = nil

		if next(player.megamucks) == nil then
			player.sprite:removeCrop()
			player.dropShadow.hidden = false
			player.movespeed = player.baseMoveSpeed
		end
	end
end

return Megamuck
