local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local BlockPlayer = require "actions/BlockPlayer"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

return function(topDialogue, mapQtoA)
	topDialogue = topDialogue or "Choose:"
    local options = {{Layout.Text(topDialogue), selectable=false}}
	for _, questionAndAnswer in ipairs(mapQtoA) do
		local q, a = unpack(questionAndAnswer)
		table.insert(options, {
			Layout.Text(q),
			choose = a
		})
	end
    return Menu {
		layout = Layout(options),
		cancellable = true,
		selectedRow = 2,
		transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight() - 150)
	}
end