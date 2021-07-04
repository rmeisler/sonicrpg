local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"

local Telegraph = require "data/monsters/actions/Telegraph"

return function(self, target)
	local name = {
		Swatbot = "Swatbutt",
		Ratbot = "Ratbutt"
	}
	return Serial {
		Do(function()
			self.sprite:setAnimation("tease")
			
			local selfIdx = 1
			for i,p in pairs(self.scene.party) do
				if p == self then
					selfIdx = i
					break
				end
			end
			
			-- Override target for three turns
			table.insert(target.targetOverrideStack, selfIdx)
			table.insert(target.targetOverrideStack, selfIdx)
			table.insert(target.targetOverrideStack, selfIdx)
		end),
		MessageBox {
			message="Sonic: Hey! {p30}Over here, "..(name[target.name] or "bot-brain").."!",
			rect=MessageBox.HEADLINER_RECT,
			textSpeed=8,
			closeAction=Wait(0.8)
		},
		Telegraph(target, target.name.." feels compelled to attack Sonic!", {255,255,255,50}),
		Do(function()
			self.sprite:setAnimation("idle")
		end)
	}
end