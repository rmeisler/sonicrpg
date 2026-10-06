local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local While = require "actions/While"
local PlayAudio = require "actions/PlayAudio"
local IfElse = require "actions/IfElse"

local HealText = require "data/items/actions/HealText"
local PressZ = require "data/battle/actions/PressZ"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

return function(sprite, stats, reflectable, noThrowAnimation)
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
		
		local reflectAction = Action()
		if reflectable then
			reflectAction = Serial {
				Wait(0.2),
				PressZ(
					self,
					target,
					Serial {
						PlayAudio("sfx", "pressx", 1.0, true),
						Do(function() self.reflected = true end),
						Animate(target.sprite, "reflect")
					},
					Do(function()
					
					end)
				)
			}
		end
	
		local explosionXForm = Transform()
		return Serial {
			not noThrowAnimation and Animate(self.sprite, "throw", true) or Action(),
			Wait(0.2),
			Do(function()
				throwable.color[4] = 255
				throwable.transform.x = self.sprite.transform.x
				throwable.transform.y = self.sprite.transform.y
				
				if self.throwXForm then
					throwable.transform.x = throwable.transform.x + self.throwXForm.x
					throwable.transform.y = throwable.transform.y + self.throwXForm.y
				end
			end),
			
			While(
				function() return not self.reflected end,
				Parallel {
					reflectAction,
					Serial {
						Ease(throwable.transform, "y", function() return target.sprite.transform.y - 200 end, 3, "linear"),
						Ease(throwable.transform, "y", function() return target.sprite.transform.y - throwable.h*2 end, 3, "quad")
					},
					Ease(throwable.transform, "angle", -(3*math.pi)/4, 1.5, "linear"),
					Ease(throwable.transform, "x", function() return target.sprite.transform.x end, 1.5, "linear")
				},
				Serial {
					Do(function()
						throwable.transform.x = target.sprite.transform.x
						throwable.transform.y = target.sprite.transform.y - throwable.h*2
					end),
					Parallel {
						Ease(throwable.transform, "x", function() return self.sprite.transform.x + self.sprite.w end, 5, "linear"),
						Ease(throwable.transform, "y", function() return self.sprite.transform.y - self.sprite.h end, 5, "linear")
					}
				}
			),
			
			Do(function()
				explosionXForm = throwable.transform
				explosionXForm.y = explosionXForm.y + 100
				throwable:remove()
			end),
			PlayAudio("sfx", "explosion", 1.0, true),
			Parallel {
				Animate(function()
					local sprite = SpriteNode(target.scene, explosionXForm, nil, "explosion2", nil, nil, "ui")
					return sprite, true
				end, "explode"),
				target.scene:screenShake(),

				IfElse(
					function() return self.reflected end,
					self:takeDamage(stats, true, nil, target),
					target:takeDamage(stats, true, nil, self)
				)
			},
			Do(function()
				if self.reflected then
					target.sprite:setAnimation("idle")
				else
					self.sprite:setAnimation("idle")
				end

				self.reflected = false
			end)
		}
	end
end
