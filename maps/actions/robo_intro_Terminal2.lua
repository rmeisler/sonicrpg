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
			self.disabled = true -- Disable computer

			-- Remove collision around door
			self.scene.objectLookup.Door:removeCollision()
			self.scene.player.disableScan = true
		end),
		Wait(0.5),
		Animate(self.scene.objectLookup.Door.sprite, "opening"),
		Animate(self.scene.objectLookup.Door.sprite, "open")
	}
end
