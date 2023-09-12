local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local DescBox = require "actions/DescBox"
local Wait = require "actions/Wait"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Trigger = require "actions/Trigger"
local Do = require "actions/Do"
local Action = require "actions/Action"

local PartyMember = require "object/PartyMember"

local Scene = require "scene/Scene"

local TargetType = require "util/TargetType"
local Transform = require "util/Transform"
local Layout = require "util/Layout"

return function(self, mainMenu)
	-- Build item list from data.items
	local itemCount = 0
	local pageCount = 1
	local itemsPerPage = 6
	local numberOfItems = 0
	local optionPages = {{}}
	for _, record in pairs(GameState.items) do
		itemCount = itemCount + record.count
		numberOfItems = numberOfItems + 1
		if numberOfItems % itemsPerPage == 0 then
			pageCount = pageCount + 1
			table.insert(optionPages, {})
		end

		local chooseFun
		if record.item.target == TargetType.None then
			chooseFun = function(menu)
				if record.item.usableFromBattle == false then
					self.scene.audio:playSfx("error", nil, true)
					return
				end
				
				if not self.scene.practice then
					GameState:useItem(record)
				end
				menu:close()
				mainMenu:close()
				return self.scene:run {
					Parallel {
						menu,
						mainMenu,
						record.item.battleAction()(self)
					},
					-- Hack fix sfx issues
					Do(function()
						self.scene.audio:stopSfx("choose")
						self.scene.audio:stopSfx("levelup")
					end)
				}
			end
		else
			chooseFun = function(menu)
				if record.item.usableFromBattle == false then
					self.scene.audio:playSfx("error", nil, true)
					return
				end
			
				local mainMenuRef = mainMenu
				return self:chooseTarget(
					menu,
					record.item.target,
					record.item.unusable or (function(_target) return false end),
					function(self, target)
						if not self.scene.practice then
							GameState:useItem(record)
						end
						menu:close()
						mainMenuRef:close()
						return Serial {
							Parallel {
								menu,
								mainMenuRef,
								record.item.battleAction()(self, target)
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

		table.insert(
			optionPages[pageCount],
			{
				Layout.Image(record.item.icon),
				Layout.Text(record.item.name),
				Layout.Text{text=tostring(record.count), color={255,255,0,255}},
				choose = chooseFun,
				desc = record.item.desc,
				noChooseSfx = not record.item.usableFromBattle
			}
		)
	end
	
	if itemCount == 0 then
		return Action()
	end

	return Menu {
		layout = Layout(optionPages[1]),
		cancellable = true,
		transform = Transform(300, love.graphics.getHeight() - 97),
		color = {255,255,255,255},
		colSpacing = 230,
		pages = optionPages
	}
end
