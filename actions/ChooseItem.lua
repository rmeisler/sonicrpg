local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local DescBox = require "actions/DescBox"
local Wait = require "actions/Wait"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Trigger = require "actions/Trigger"
local Do = require "actions/Do"
local Spawn = require "actions/Spawn"
local BlockPlayer = require "actions/BlockPlayer"
local Action = require "actions/Action"

local PartyMember = require "object/PartyMember"

local Scene = require "scene/Scene"

local TargetType = require "util/TargetType"
local Transform = require "util/Transform"
local Layout = require "util/Layout"

return function(scene, prompt, expectedItem, successAction, failureAction)
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

		local chooseFun = function(menu)
			menu:close()
			if record.item.name == expectedItem then
				scene:run(Spawn(BlockPlayer {
					successAction
				}))
			else
				scene:run(Spawn(BlockPlayer {
					failureAction
				}))
			end
		end

		table.insert(
			optionPages[pageCount],
			{
				Layout.Image(record.item.icon),
				Layout.Text(record.item.name),
				Layout.Text{text=tostring(record.count), color={255,255,0,255}},
				choose = chooseFun,
				noChooseSfx = true
			}
		)
	end
	
	if itemCount == 0 then
		return Action()
	end
	
	local descBox = DescBox(prompt)
	local menu = Menu {
		layout = Layout(optionPages[1]),
		cancellable = true,
		transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2),
		color = {255,255,255,255},
		colSpacing = 230,
		pages = optionPages
	}
	menu:addHandler("close", function() descBox:close() end)

	return Parallel {
		descBox,
		menu
	}
end
