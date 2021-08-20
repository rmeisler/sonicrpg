local Transform = require "util/Transform"
local Layout = require "util/Layout"

local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local DescBox = require "actions/DescBox"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local Do = require "actions/Do"
local BlockPlayer = require "actions/BlockPlayer"
local SpriteNode = require "object/SpriteNode"
local NumScreen = require "actions/NumScreen"

return function(self)
	local descBox = DescBox("Elevator Control Interface")
	return BlockPlayer {
		Parallel {
			descBox,
			Menu {
				layout = Layout {
					{Layout.Text("Up"),
						choose = function(menu)
							menu:close()
							self.scene:run {
								menu,
								MessageBox {message = "Computer: Enter access code for floor 47."},
								NumScreen(
								    self.scene,
									"Enter access code",
									"1668",
									MessageBox {message = "Computer: Access granted."},
									MessageBox {message = "Computer: Access denied"}
								)
							}
						end},
					{Layout.Text("Down"),
						choose = function(menu)
							menu:close()
							self.scene:run {
								menu,
								MessageBox {message = "Computer: Enter access code for floor 45."}
							}
						end},
					{Layout.Text("Cancel"),
						choose = function(menu)
							menu:close()
						end},
					colWidth = 200
				},
				transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
				cancellable = true,
				withClose = Do(function() descBox:close() end)
			}
		}
	}
end
