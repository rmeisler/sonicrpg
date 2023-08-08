local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local While = require "actions/While"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Telegraph = require "data/monsters/actions/Telegraph"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

return function(self, target)
	local yeti = SpriteNode(
		self.scene,
		Transform.from(self.sprite.transform),
		{255,255,255,255},
		"abominable",
		nil,
		nil,
		self.sprite.layer
	)
	yeti.transform.x = 800
	yeti.transform.y = 150
	local damageAllMonsters = {}
	for _,mem in pairs(self.scene.opponents) do
		table.insert(damageAllMonsters, mem:takeDamage({attack = 30, speed = 100, luck = 0}))
    end

	return Serial {
		Do(function() yeti:setAnimation("idleleft") end),
		Wait(1),
		Animate(yeti, "leap_left"),
		Parallel {
			Ease(yeti.transform, "x", function() return yeti.transform.x - 400 end, 3, "linear"),
			Ease(yeti.transform, "y", function() return yeti.transform.y - 200 end, 3, "linear")
		},
		Parallel {
			Ease(yeti.transform, "x", function() return yeti.transform.x - 400 end, 4, "linear"),
			Ease(yeti.transform, "y", function() return yeti.transform.y + 200 end, 4, "quad")
		},
		Do(function() yeti:setAnimation("idleleft") end),
		self.scene:screenShake(20, 30, 1),
		Parallel(damageAllMonsters),
		Animate(yeti, "leap_left"),
		Parallel {
			Ease(yeti.transform, "x", function() return yeti.transform.x - 300 end, 3, "linear"),
			Ease(yeti.transform, "y", function() return yeti.transform.y - 200 end, 3, "linear")
		},
		Parallel {
			Ease(yeti.transform, "x", function() return yeti.transform.x - 300 end, 4, "linear"),
			Ease(yeti.transform, "y", function() return yeti.transform.y + 200 end, 4, "quad")
		},
		Do(function() yeti:remove() end)
	}
end
