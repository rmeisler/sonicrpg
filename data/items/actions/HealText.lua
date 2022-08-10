local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local BouncyText = require "actions/BouncyText"
local Ease = require "actions/Ease"
local Executor = require "actions/Executor"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"
local TargetType = require "util/TargetType"

return function(attribute, amount, color)
	return function (target, transform)
		-- Double healing amount if chef's hat equipped
		if  target.side == TargetType.Party and 
			GameState:isEquipped(target.id, ItemType.Accessory, "Chef's Hat")
		then
			amount = amount * 2
		end
		
		return Do(function()
			local maxVal
			if attribute == "xp" then
				maxVal = GameState:calcNextXp(target.id, target.level)
			else
				maxVal = target.stats["max"..attribute]
			end
			local newstat = math.min(target[attribute] + amount, maxVal)
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
