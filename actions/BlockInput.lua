local Do = require "actions/Do"
local Serial = require "actions/Serial"

local BlockInput = class(Serial)

function BlockInput:setScene(scene)
	Serial.setScene(scene)
	
	-- Block at start, unblock at end
	self:inject(
		scene,
		Do(function()
			scene:focus("keytriggered", {})
		end)
	)
	self:add(
		scene,
		Do(function()
			scene:unfocus("keytriggered")
		end)
	)
end


return BlockInput
