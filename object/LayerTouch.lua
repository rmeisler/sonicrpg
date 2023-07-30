local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

local LayerTouch = class(NPC)

function LayerTouch:construct(scene, layer, object)
	self.ghost = true
	self.fromLayer = object.properties.fromLayer
	self.toLayer = object.properties.toLayer
	NPC.init(self)
end

function LayerTouch:onCollision(prevState)
    NPC.onCollision(self, prevState)

	local curObjectLayer = "objects"..tostring(self.fromLayer)
	if  (self.scene.player.onlyInteractWithLayer ~= nil and
	     self.scene.player.onlyInteractWithLayer ~= curObjectLayer) or
		self.scene.player.doingSpecialMove --or
		--next(self.scene.player.ladders) ~= nil
	then
		return
	end

	self.scene:swapLayer(self.toLayer)
	self.scene.player.movespeed = 4
end


return LayerTouch
