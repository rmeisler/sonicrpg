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
	player.scene.audio:playSfx("error")
end