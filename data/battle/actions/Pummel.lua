local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"
local Do = require "actions/Do"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

local OnHitEvent = require "data/battle/actions/OnHitEvent"

local LeapBackward = function(self, target)
	return Serial {
		Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w - 5, 1),
		
		-- Leap backward
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 3),
			Serial {
				Ease(self.sprite.transform, "y", target.sprite.transform.y - self.sprite.h * 2, 4),
				Ease(self.sprite.transform, "y", self.sprite.transform.y, 6)
			}
		},
			
		Animate(self.sprite, "crouch"),
		Wait(0.2),
		Animate(self.sprite, "idle", false, {}, false)
	}
end

local KnockbackCallback = function(target, impact, direction)
	local leftSmackPositions = {
		{-5, 0},
		{-7, 3},
		{-5, 5},
	}
	local rightSmackPositions = {
		{10, -5},
		{7, -3},
		{5, 0},
	}
	return Repeat(Serial {
		Do(function()
			Executor(target.scene):act(
				Parallel {
					Animate(function()
						local xform = Transform.from(target.sprite.transform)
						local offset = table.remove(leftSmackPositions)
						xform.x = xform.x + offset[1]
						xform.y = xform.y + offset[2]
						return SpriteNode(target.scene, xform, nil, "smack", nil, nil, "ui"), true
					end, "idle"),
					PlayAudio("sfx", target.hurtSfx, 0.5, true),
					Serial {
						Wait(0.05),
						Animate(function()
							local xform = Transform.from(target.sprite.transform)
							local offset = table.remove(rightSmackPositions)
							xform.x = xform.x + offset[1]
							xform.y = xform.y + offset[2]
							return SpriteNode(target.scene, xform, nil, "smack", nil, nil, "ui"), true
						end, "idle"),
						PlayAudio("sfx", target.hurtSfx, 0.5, true),
					}
				}
			)
		end),
		Ease(target.sprite.transform, "x", target.sprite.transform.x + (impact/3 * direction), 30, "quad"),
		Ease(target.sprite.transform, "x", target.sprite.transform.x - (impact/3 * direction), 30, "quad"),
		Ease(target.sprite.transform, "x", target.sprite.transform.x + (impact/6 * direction), 30, "quad"),
		Ease(target.sprite.transform, "x", target.sprite.transform.x - (impact/6 * direction), 30, "quad"),
		Ease(target.sprite.transform, "x", target.sprite.transform.x, 30, "linear")
	}, 3)
end

return function(self, target)
	return Serial {
		-- Leap
		Animate(self.sprite, "leap", true),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + math.abs(target.sprite.transform.x - self.sprite.transform.x)/2, 4, "linear"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y - self.sprite.h * 2, 6, "linear"),
		},
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w, 4, "linear"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h + 1, 4, "linear")
		},
		
		-- Punching!
		Animate(self.sprite, "pummel", true),
		WaitForFrame(self.sprite, 3),
		
		OnHitEvent(
			self,
			target,
			LeapBackward(self, target),
			KnockbackCallback
		)
	}
end
