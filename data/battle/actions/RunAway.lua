local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local BlockInput = require "actions/BlockInput"

return function(self, menu)
	-- Use run chance of strongest opponent
	local runChance = 0
	for _,opp in pairs(self.scene.opponents) do
		runChance = math.max(runChance, opp.run_chance)
	end
	menu:close()
	if runChance > 0 then
		if math.random() < runChance + (self.stats.speed/100) then
			return BlockInput {
				Parallel {
					menu,
					Serial {
						MessageBox {message="You ran away...", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
						self.scene:earlyExit(),
						Do(function()
							-- Close message box
							self:endTurn()
						end)
					}
				}
			}
		else
			return Parallel {
				menu,
				Serial {
					MessageBox {message="You were out-manuevered!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1), blocking=true},
					Do(function()
						-- Close message box
						self:endTurn()
					end)
				}
			}
		end
	else
		return Parallel {
			menu,
			Serial {
				MessageBox {message="Can't run away!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1), blocking=true},
				Do(function()
					-- Close message box
					self:endTurn()
				end)
			}
		}
	end
end
