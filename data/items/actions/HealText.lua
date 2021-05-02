local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local BouncyText = require "actions/BouncyText"
local Ease = require "actions/Ease"
local Executor = require "actions/Executor"

local Transform = require "util/Transform"

return function(attribute, amount, color)
	return function (target, transform)
		local newstat = math.min(target[attribute] + amount, target.stats["max"..attribute])
		return Do(function()
			Executor(target.scene):act(Parallel {
				BouncyText(
					transform,
					color or {0, 255, 70, 255},
					FontCache.ConsolasLarge,
					tostring(amount),
					6,
					false,
					true -- outline
				),
				Ease(target, attribute, newstat, 7),
				Do(function() target[attribute] = math.floor(target[attribute]) end)
			})
		end)
	end
end
