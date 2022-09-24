local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local NPC = require "object/NPC"
local EscapeJumpTrigger = class(NPC)

function EscapeJumpTrigger:construct(scene, layer, object)
	self.ghost = true
	NPC.init(self)
	
	self:addInteract(EscapeJumpTrigger.jump)
end

function EscapeJumpTrigger:jump()
	self:run {
		Do(function()
			self.scene.player.jumping = true
		end),
		self.scene.player:dodgeLaser(),
		Do(function()
			self.scene.player.jumping = false
		end)
	}
end


return EscapeJumpTrigger
