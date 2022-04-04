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
local EscapeBad = class(NPC)

function EscapeBad:construct(scene, layer, object)
	self.ghost = true
	NPC.init(self)
end

function EscapeBad:whileColliding(player, prevState)
	if self.hit or player.jumping then
		return
	end
	self.hit = true

	player:run {
        Do(function()
            player.extraBx = -20
        end),
        Repeat(
            Serial {
                Ease(player.sprite.color, 4, 0, 20, "quad"),
                Ease(player.sprite.color, 4, 255, 20, "quad")
            },
            10
        ),
		Do(function()
			self.hit = false
		end)
    }
end


return EscapeBad
