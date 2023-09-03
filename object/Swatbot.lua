local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial" 
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Move = require "actions/Move"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local Bot = require "object/Bot"
local BasicNPC = require "object/BasicNPC"
local Player = require "object/Player"

local Swatbot = class(Bot)

function Swatbot:construct(scene, layer, object)
	if self:isRemoved() then
		return
	end
	self.ghost = true
	Bot.init(self, true)
	
	self.collision = {}
	
	self.hotspotOffsets = {
		right_top = {x = -20, y = self.sprite.h + 30},
		right_bot = {x = -20, y = 0},
		left_top  = {x = 20, y = self.sprite.h + 30},
		left_bot  = {x = 20, y = 0}
	}
	
	self.stepSfx = "swatbotstep"
end

return Swatbot
