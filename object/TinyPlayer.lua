local DrawableNode = require "object/DrawableNode"
local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local Player = require "object/Player"
local NPC = require "object/NPC"
local BasicNPC = require "object/BasicNPC"

local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local WaitForFrame = require "actions/WaitForFrame"
local While = require "actions/While"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local Action = require "actions/Action"
local Executor = require "actions/Executor"
local Ease = require "actions/Ease"

local TinyPlayer = class(Player)

function TinyPlayer:construct(scene, layer, object)
	-- Set scene reference to this player
	scene.player = self
	
	self.sprite.transform.sx = 1.45
	self.sprite.transform.sy = 1.45
	self.noSpecialMove = true
	--self.noChangeChar = true
	self.movespeed = 2
	self.dropShadow:remove()
	
	self:updateHotspots()
end

function TinyPlayer:updateHotspots()
	self.hotspots = {
		right_top = {x = self.x + 6, y = self.y + self.halfHeight/2 + 2},
		right_bot = {x = self.x + 6, y = self.y + self.halfHeight},
		left_top  = {x = self.x - 7, y = self.y + self.halfHeight/2 + 2},
		left_bot  = {x = self.x - 7, y = self.y + self.halfHeight}
	}
	return self.hotspots
end


return TinyPlayer
