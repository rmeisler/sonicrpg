local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"
local YieldUntil = require "actions/YieldUntil"
local Executor = require "actions/Executor"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

local Telegraph = require "data/monsters/actions/Telegraph"

return function(self, target)
	self.doneWithHologram = false
	return Serial {
		Do(function() self.sprite:setAnimation("scan") end),

		Telegraph(self, "Logan: Scanning likeness...", {255,255,255,50}),

		PlayAudio("sfx", "nicholescan", 1.0, true),
		Parallel {
			Ease(target.sprite.color, 1, 800, 0.4),
			Ease(target.sprite.color, 2, 800, 0.4),
			Ease(target.sprite.color, 3, 800, 0.4)
		},
		MessageBox {
			message="Logan: Producing hologram...",
			rect=MessageBox.HEADLINER_RECT,
			sfx="nichole",
			closeAction=Wait(0.6)
		},
		Do(function()
			local mem = self.scene:addParty(target.id)
			mem.name = "???"
			mem.isHologram = true
			mem.sprite.color = {800,800,800,0}
			Executor(self.scene):act(Serial {
				Ease(mem.sprite.color, 4, 255, 1),
				Parallel {
					Ease(mem.sprite.color, 1, 255, 0.4),
					Ease(mem.sprite.color, 2, 255, 0.4),
					Ease(mem.sprite.color, 3, 255, 0.4),
					Ease(mem.sprite.color, 4, 100, 0.4),
					Ease(target.sprite.color, 1, 255, 0.4),
					Ease(target.sprite.color, 2, 255, 0.4),
					Ease(target.sprite.color, 3, 255, 0.4)
				},
				Do(function()
					self.doneWithHologram = true
				end)
			})
		end),
		YieldUntil(self, "doneWithHologram"),
		Animate(self.sprite, "idle")
	}
end