local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local BlockPlayer = require "actions/BlockPlayer"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

return function(mapQtoA)
    local options = {Layout.Text("Choose:"), selectable=false}
	for q, a in pairs(mapQtoA) do
		table.insert(options, {
			Layout.Text(q),
			choose = function(menu)
				menu:close()
				self.scene:run(BlockPlayer{
					menu,
					a
				})
			end
		})
	end
    return BlockPlayer {
	    Menu {
			layout = Layout(options),
			cancellable = true,
			selectedRow = 2,
			transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight() - 30)
		}
	}
end