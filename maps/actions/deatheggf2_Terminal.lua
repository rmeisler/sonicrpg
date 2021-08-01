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
local Animate = require "actions/Animate"
local NameScreen = require "actions/NameScreen"
local Move = require "actions/Move"

local SpriteNode = require "object/SpriteNode"

return function(self)
	local descBox = DescBox("Welcome to Bot Factory (v1.23)")
	return Parallel {
		descBox,
		Menu {
			layout = Layout {
				{Layout.Text("Enter password"),
					choose = function(menu)
						menu:close()
						descBox:close()
						self.scene:run {
							Parallel {
								descBox,
								menu
							},
							NameScreen(
								self.scene,
								"Enter password",
								"rodent",
								Serial {
									Wait(0.5),
									PlayAudio("sfx", "gotit", 1.0),
									Do(function() GameState:setFlag(self.scene.objectLookup.Door) end),
									Parallel {
										MessageBox {
											message = "Sally: Got it! {p50}We're in!",
											blocking = true
										},
										Serial {
											Wait(0.5),
											Animate(self.scene.objectLookup.Door.sprite, "opening"),
											Animate(self.scene.objectLookup.Door.sprite, "open")
										}
									}
								},
								Serial {
									Wait(0.5),
									PlayAudio("sfx", "error", 1.0)
								}
							)
						}
					end},
				{Layout.Text("Forgot password"),
					choose = function(menu)
						menu:close()
						descBox:close()
						self.scene:run {
							Parallel {
								descBox,
								menu
							},
							MessageBox {
								message = "Hint: What is the hedgehog (6 letters)",
								blocking = true
							}
						}
					end},
				{Layout.Text("Quit"),
					choose = function(menu)
						menu:close()
					end},
				colWidth = 200
			},
			transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
			cancellable = true,
			withClose = Do(function() descBox:close() end),
			blocking = true
		}
	}
end
