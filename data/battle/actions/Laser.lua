local Animate = require "actions/Animate"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Wait = require "actions/Wait"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"

local Transform = require "util/Transform"

return function(self, target)
	self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
	self.beamSprite.transform.sx = 0
	self.beamSprite.transform.sy = 1
	self.beamSprite.transform.ox = 0
	self.beamSprite.color = {512,512,0,255}

	local dmgAllOpponents = {}
	for _, oppo in pairs(self.scene.opponents) do
		table.insert(dmgAllOpponents, oppo:takeDamage(self.stats, true, BattleActor.shockKnockback))
	end

	return Serial {
		Do(function()
			self.sprite:setAnimation("scan")
		end),
		Animate(function()
			local xform = Transform.from(self.sprite.transform)
			xform.x = xform.x - 60
			xform.y = xform.y - 20
			return SpriteNode(self.scene, xform, {512,512,0,255}, "beamfire", nil, nil, "ui"), true
		end, "idle"),

		PlayAudio("sfx", "lasersweep", 1.0, true),

		Do(function()
			self.beamSprite.transform.x = self.sprite.transform.x - 35
			self.beamSprite.transform.y = self.sprite.transform.y
			self.beamSprite.transform.angle = -math.pi/6
		end),

		Ease(self.beamSprite.transform, "sx", -20.0, 12, "linear"),
		Ease(self.beamSprite.transform, "angle", math.pi/6, 1, "linear"),

		-- Hide beam sprite
		Do(function()
			self.beamSprite.transform.sx = 0
			self.beamSprite.transform.angle = 0
		end),

		Parallel(dmgAllOpponents),
		Do(function()
			self.sprite:setAnimation("idle")
		end)
	}
end