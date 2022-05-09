local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Trigger = require "actions/Trigger"

local DescBox = function(desc, textspeed)
	if desc == "" then
		return Action()
	end
	return MessageBox {
		message = desc,
		rect = MessageBox.HEADLINER_RECT,
		noPressX = true,
		textspeed = textspeed
	}
end

return DescBox