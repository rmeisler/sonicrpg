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
	local targetSp = target:getSprite()

	return Serial {
		Do(function() self.sprite.sortOrderY = nil end),

		-- Antoine nervous
		Animate(self.sprite, "nervous"),
		Wait(1),
		
		-- Enemy hops
		Ease(targetSp.transform, "y", targetSp.transform.y - 50, 8, "linear"),
		Ease(targetSp.transform, "y", targetSp.transform.y, 8, "linear"),

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
			targetSp:setAnimation("runright")
		end),
		Parallel {
			Ease(targetSp.transform, "x", self.sprite.transform.x + 400, 0.5),
			Ease(targetSp.transform, "y", self.sprite.transform.y, 0.5),
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
			closeAction=Wait(1)
		},
		Do(function()
			for index, mem in pairs(self.scene.party) do
				if mem.id == "antoine" then
					-- Solidify Antoine's hp/sp outside battle before you leave battle
					local partyMember = GameState.party.antoine
					partyMember.hp = mem.hp
					partyMember.sp = mem.sp
					table.remove(self.scene.party, index)
					break
				end
			end
			
			target.hp = 0
			target.state = target.STATE_DEAD
			targetSp:remove()
			target:invoke("dead")
		end)
	}
end