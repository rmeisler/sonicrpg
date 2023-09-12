local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local DescBox = require "actions/DescBox"
local Wait = require "actions/Wait"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Trigger = require "actions/Trigger"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Executor = require "actions/Executor"
local YieldUntil = require "actions/YieldUntil"

local PartyMember = require "object/PartyMember"

local Scene = require "scene/Scene"

local Rect = unpack(require "util/Shapes")
local TargetType = require "util/TargetType"
local Transform = require "util/Transform"
local Layout = require "util/Layout"

return function(self, mainMenu)
	local columnTemplate = {
		Layout.Text(string.format("%10s", "")),
		Layout.Text(string.format("%2s", "")),
		choose = function() end
	}
	local layout = {
		Layout.Columns{ columnTemplate, columnTemplate },
		Layout.Columns{ columnTemplate, columnTemplate },
		Layout.Columns{ columnTemplate, columnTemplate },
	}
	local index = 0
	for _, skill in pairs(GameState:getSkills(self.id)) do
		local chooseFun
		if skill.target == TargetType.None then
			chooseFun = function(menu)
				if self.sp < skill.cost then
					self.scene.audio:playSfx("error", nil, true)
				else
					self.sp = math.max(self.sp - skill.cost, 0)
					menu:close()
					mainMenu:close()
					self.scene:run {
						Parallel {
							menu,
							mainMenu,
							skill.action(self)
						},
						-- Hack fix sfx issues
						Do(function()
							self.scene.audio:stopSfx("choose")
							self.scene.audio:stopSfx("levelup")
						end)
					}
				end
			end
		else
			chooseFun = function(menu)
				if self.sp < skill.cost then
					self.scene.audio:playSfx("error", nil, true)
				else
					local mainMenuRef = mainMenu
					self:chooseTarget(
						menu,
						skill.target,
						skill.unusable or function(_target) return false end,
						function(self, target)
							self.sp = math.max(self.sp - skill.cost, 0)
							menu:close()
							mainMenuRef:close()
							return Serial {
								Parallel {
									menu,
									mainMenuRef,
									skill.action(self, target)
								},
								-- Hack fix sfx issues
								Do(function()
									self.scene.audio:stopSfx("choose")
									self.scene.audio:stopSfx("levelup")
								end)
							}
						end
					)
				end
			end
		end
		layout[math.floor(index / 2) + 1].__columns[(index % 2) + 1] = {
			Layout.Text(string.format("%s%"..tostring(10 - skill.name:len()).."s", skill.name, "")),
			Layout.Text{text={{255,255,0}, string.format("%s%"..tostring(skill.cost >= 10 and 0 or 1).."s", skill.cost, "")}},
			choose = chooseFun,
			desc = skill.desc
		}
		index = index + 1
	end

	local menu = Menu {
		layout = Layout(layout),
		cancellable = true,
		transform = Transform(315, love.graphics.getHeight() - 85),
		color = {255,255,255,255}
	}
	
	local remainingSp = Menu {
		layout = Layout {
			{
				Layout.Text {
					text = {
						{255,255,255,255}, "Remaining SP: ",
						{255,255,0,255}, string.format("%"..tostring(self.sp >= 10 and 0 or 1).."s%s", "", self.sp)
					}
				},
				selectable = false
			}
		},
		passive = true,
		transform = Transform(menu.transform.x, menu.transform.y - 75),
		colSpacing = menu.layout.w
	}
	
	menu:addHandler("close", Menu.close, remainingSp)
	menu.withClose = remainingSp
	
	return Parallel {
		menu,
		remainingSp
	}
end
