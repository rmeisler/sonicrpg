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

local SpriteNode = require "object/SpriteNode"

return function(self)
	return Serial {
		Do(function() GameState:setFlag(self.scene.objectLookup.Door) end),
		Parallel {
			MessageBox {
				message = "Sally: Got it! {p50}We're in!",
				blocking = true
			},
			Serial {
				Wait(0.5),
				Animate(self.scene.objectLookup.Door.sprite, "opening"),
				Animate(self.scene.objectLookup.Door.sprite, "open")
			}
		}
	}
end
