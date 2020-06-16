local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"

local HealText = require "data/items/actions/HealText"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

return function(sprite, stats)
	return function(self, target)
		local throwable = SpriteNode(
			target.scene,
			Transform.from(self.sprite.transform, Transform()),
			nil,
			sprite,
			nil,
			nil,
			"ui"
		)
		throwable.transform.ox = throwable.w
		throwable.transform.oy = throwable.h
		throwable.transform.angle = -math.pi/4
		throwable.color[4] = 0
		
		local explosionXForm = Transform()
		return Serial {
			Animate(self.sprite, "throw", true),
			Wait(0.2),
			Do(function()
				throwable.color[4] = 255
			end),
			Parallel {
				Serial {
					Ease(throwable.transform, "y", target.sprite.transform.y - 200, 3, "linear"),
					Ease(throwable.transform, "y", target.sprite.transform.y - throwable.h*2, 3, "quad")
				},
				Ease(throwable.transform, "angle", -(3*math.pi)/4, 1.5, "linear"),
				Ease(throwable.transform, "x", target.sprite.transform.x, 1.5, "linear")
			},
			
			Do(function()
				explosionXForm = throwable.transform
				throwable:remove()
			end),
			PlayAudio("sfx", "explosion", 1.0, true),
			Parallel {
				Animate(function()
					local sprite = SpriteNode(target.scene, explosionXForm, nil, "explosion", nil, nil, "ui")
					return sprite, true
				end, "explode"),
				target:takeDamage(stats, true)
			},
			Do(function()
				self.sprite:setAnimation("idle")
			end)
		}
	end
end
