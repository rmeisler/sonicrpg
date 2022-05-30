local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

return function(self, target)
	local prevMusic = self.scene.audio:getCurrentMusic()

	return Serial {
		-- Antoine nervous
		Animate(self.sprite, "nervous"),
		Wait(1),
		
		-- Enemy hops
		Ease(target.sprite.transform, "y", target.sprite.transform.y - 50, 8, "linear"),
		Ease(target.sprite.transform, "y", target.sprite.transform.y, 8, "linear"),

		-- Antoine scared hop
		PlayAudio("sfx", "antoinescared", 1.0, true),
		Animate(self.sprite, "scaredhop1"),
		Wait(0.1),
		Animate(self.sprite, "tremble"),
		Animate(self.sprite, "scaredhop2"),
		Ease(self.sprite.transform, "y", self.sprite.transform.y - 50, 7, "linear"),
		Animate(self.sprite, "scaredhop3"),
		Ease(self.sprite.transform, "y", self.sprite.transform.y, 7, "linear"),
		Animate(self.sprite, "scaredhop4"),
		Wait(0.1),
		Animate(self.sprite, "scaredhop5"),
		
		Wait(1),
		
		-- Starts running toward him
		Do(function()
			target.sprite:setAnimation("runright")
		end),
		Parallel {
			Ease(target.sprite.transform, "x", self.sprite.transform.x + 400, 0.5),
			Ease(target.sprite.transform, "y", self.sprite.transform.y, 0.5),
			Serial {
				-- Antoine runs away with enemy
				Do(function()
					self.sprite:setAnimation("runscared")
				end),
				Wait(0.5),
				Ease(self.sprite.transform, "x", self.sprite.transform.x + 400, 1)
			}
		},
		MessageBox {
			message="Antoine and "..target.name.." have left the battle!",
			rect=MessageBox.HEADLINER_RECT,
			closeAction=Wait(0.6)
		},
		Do(function()
			for index, mem in pairs(self.scene.party) do
				if mem.id == "antoine" then
					table.remove(self.scene.party, index)
					return
				end
			end
		end)
	}
end