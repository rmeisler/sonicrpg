local Transform = require "util/Transform"
local Layout = require "util/Layout"

local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local DescBox = require "actions/DescBox"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local NameScreen = require "actions/NameScreen"
local Move = require "actions/Move"
local BlockInput = require "actions/BlockInput"
local BlockPlayer = require "actions/BlockPlayer"

local SpriteNode = require "object/SpriteNode"

return function(self)
	return BlockPlayer {
		Do(function()
			self.scene.player.sprite:setAnimation("thinking")
			self.scene.player.noIdle = true
		end),
		MessageBox {message = "Sally: No--{p40} This is too direct. {p60}We need to find another way in."},
		Wait(1),
		Do(function()
			self.scene.player.sprite:setAnimation("idledown")
			self.scene.player.noIdle = false
		end)
	}
end
