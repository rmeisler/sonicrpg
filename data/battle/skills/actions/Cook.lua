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
local Repeat = require "actions/Repeat"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

return function(self, target)
	local possibleItems = {
		"data/items/CarrotCake",
		"data/items/MushroomSoup",
		"data/items/SauteedOnions"
	}
	local item = require(possibleItems[math.random(#possibleItems)])
	GameState:grantItem(item, 1)
	return Serial {
		Wait(0.5),
		PlayAudio("sfx", "switchcharshort", 1.0, true),
		Repeat(
			Serial {
				Animate(self.sprite, "idledown", true),
				Wait(0.01),
				Animate(self.sprite, "idleleft", true),
				Wait(0.01),
				Animate(self.sprite, "idleup", true),
				Wait(0.01),
				Animate(self.sprite, "idleright", true),
				Wait(0.01),
				Animate(self.sprite, "idledown", true),
			},
			2
		),
		Animate(self.sprite, "chefpose"),
		MessageBox {
			rect=MessageBox.HEADLINER_RECT,
			message="Antoine: Bon Appetit!",
			textSpeed=8,
			closeAction=Wait(1)
		},
		
		MessageBox {
			rect=MessageBox.HEADLINER_RECT,
			message="You received a "..item.name.."!",
			textSpeed=8,
			sfx="levelup",
			closeAction=Wait(1)
		},
		Repeat(
			Serial {
				Animate(self.sprite, "idledown", true),
				Wait(0.01),
				Animate(self.sprite, "idleleft", true),
				Wait(0.01),
				Animate(self.sprite, "idleup", true),
				Wait(0.01),
				Animate(self.sprite, "idleright", true),
				Wait(0.01),
				Animate(self.sprite, "idledown", true),
			},
			2
		),
		Animate(self.sprite, "idle"),
		Do(function() self:endTurn() end)
	}
end