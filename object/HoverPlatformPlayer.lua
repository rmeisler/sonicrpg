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
local YieldUntil = require "actions/YieldUntil"
local Repeat = require "actions/Repeat"

local Transform = require "util/Transform"

local HoverPlatformPlayer = class(HoverPlatformPlayer)

function HoverPlatformPlayer:construct(scene, layer, object)
	self.state = "juiceup"
	self.hoverbotOffset = 360

	self:removeSceneHandler("update", Player.update)
	self:removeSceneHandler("keytriggered", Player.keytriggered)
	
	scene.player = self
end

function HoverPlatformPlayer:update(dt)
	
end


return HoverPlatformPlayer
