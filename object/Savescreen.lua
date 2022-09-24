local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local SpriteNode = require "object/SpriteNode"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Menu = require "actions/Menu"
local YieldUntil = require "actions/YieldUntil"
local Do = require "actions/Do"
local Actor = require "actions/Executor"
local MessageBox = require "actions/MessageBox"
local Trigger = require "actions/Trigger"
local Executor = require "actions/Executor"
local Action = require "actions/Action"

local Layout = require "util/Layout"
local EventType = require "util/EventType"
local ItemType = require "util/ItemType"

local PlayerStats = require "data/misc/stats"

function Savescreen(args)
	local scene = args.scene
	local spawnPoint = args.spawnPoint
	local forLoading = args.forLoading

	local slots = GameState:loadSlots()
	local rows = {colWidth = 600, colHeight = 150, spaceBetweenRows = 10, spaceBetweenEntries = 10}
	for i=1,3 do
		local row = {
			choose = function(menu)
				if forLoading then
					chooseSlot(doLoad, scene, i, args.onLoad)
				else
					chooseSlot(doSave, scene, i, spawnPoint)
				end
			end
		}
		if slots[i] then
			table.insert(row, Layout.Text(string.format("Level %d\n%s", slots[i].level, slots[i].location)))
			for _,sprite in pairs(slots[i].party) do
				table.insert(row, Layout.Image {name=sprite, anim="idleleft", width=70})
			end
			table.insert(rows, row)
		else
			table.insert(row, Layout.Text {text="Empty", color={255, 255, 0, 255}})
			if forLoading then
				row.choose = function()
					scene.audio:playSfx("error", nil, true)
				end
				row.noChooseSfx = true
			end
			table.insert(rows, row)
		end
	end
	
	scene.subscreen = Menu {
		layout = Layout(rows),
		cancellable = true,
		transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2),
		withClose = Do(function()
			scene.subscreen = nil
		end)
	}
	return scene.subscreen
end

function doSave(menu, index, spawnPoint)
	menu:close()
	menu.scene.subscreen:close()

	GameState:save(menu.scene, index, spawnPoint)
	
	-- Wait for menu and then pull up "Saved!" msg
	menu.scene:run(Parallel {
		menu,
		menu.scene.subscreen,
		MessageBox {message="Saved!", rect=MessageBox.HEADLINER_RECT, blocking = true, sfx="levelup", closeAction=Wait(0.6)}	
	})
end

function doLoad(menu, index, onLoad)
	if onLoad then
		onLoad()
	end
	GameState:load(menu.scene, index)
	menu:disable()
end

function doClose(menu)
	menu:close()
end

function chooseSlot(callback, scene, ...)
	local args = {...}
	scene:run {
		Menu {
			layout = Layout {
				{
					Layout.Text("Are you sure?"),
					selectable = false,
				},
				{
					Layout.Text("Yes"),
					choose = function(menu)
						callback(menu, unpack(args))
					end
				},
				{
					Layout.Text("No"), 
					choose = doClose
				},
				colWidth = 200
			},
			transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
			selectedRow = 2,
			cancellable = true
		}
	}
end


return Savescreen
