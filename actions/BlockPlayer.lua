local Do = require "actions/Do"
local Serial = require "actions/Serial"

local BlockPlayer = class(Serial)

function BlockPlayer:setScene(scene)
	Serial.setScene(scene)
	
	-- Block at start, unblock at end
	self:inject(
		scene,
		Do(function()
			if scene.player then
				scene.player.cinematic = true
			end
		end)
	)
	self:add(
		scene,
		Do(function()
			if scene.player then
				scene.player.cinematic = false
			end
		end)
	)
end


return BlockPlayer
