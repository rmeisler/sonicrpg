local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local DescBox = require "actions/DescBox"
local Menu = require "actions/Menu"
local PlayAudio = require "actions/PlayAudio"
local MessageBox = require "actions/MessageBox"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Spawn = require "actions/Spawn"
local Do = require "actions/Do"
local SpriteNode = require "object/SpriteNode"

local NumScreen = function(scene, prompt, expected, success, failure)
	local maxLen = string.len(expected)
	
	-- Choose a name
	local mbox = DescBox(prompt)

	-- Name entry
	local nameEntryFun = function(name)
		local chars = {}
		for i = 1, string.len(name) do
			table.insert(chars, string.sub(name, i, i))
		end
		return chars
	end
	
	local underscores = function(num)
		local chars = {}
		for i = 1, num do
			table.insert(chars, "_")
		end
		return table.concat(chars)
	end
	
	scene.nameScreenName = ""
	local nameEntry = Menu {
		list = nameEntryFun(underscores(maxLen)),
		cancellable = false,
		transform = Transform(400, 150),
		--color = {255,255,255,255},
		colSpacing = 30,
		maxCols = 11,
		maxRows = 1,
		selectedCol = 1,
		cursorType = Menu.CURSOR_TYPE_UNDER,
		tag = "NAME ENTRY"
	}
	
	local numChooseFun = function(num)
		return function(nameMenu)
			scene.nameScreenName = scene.nameScreenName..num
			nameMenu:updateList(nameEntryFun(scene.nameScreenName..underscores(maxLen - string.len(scene.nameScreenName))))
			nameMenu.selectedCol = math.min(maxLen, string.len(scene.nameScreenName) + 1)
			if string.len(scene.nameScreenName) == maxLen then
				letterMenu:close()
				
				if scene.nameScreenName == expected then
					scene:run(Spawn(success))
				else
					scene:run(Spawn(failure))
				end
			end
		end
	end
	
	local numMenu = Menu {
		layout = Layout {
			{Layout.Text("1"), choose = numChooseFun("1")},
			{Layout.Text("2"), choose = numChooseFun("2")},
			{Layout.Text("3"), choose = numChooseFun("3")},
			{Layout.Text("4"), choose = numChooseFun("4")},
			{Layout.Text("5"), choose = numChooseFun("5")},
			{Layout.Text("6"), choose = numChooseFun("6")},
			{Layout.Text("7"), choose = numChooseFun("7")},
			{Layout.Text("8"), choose = numChooseFun("8")},
			{Layout.Text("9"), choose = numChooseFun("9")},
			maxCols = 3,
			maxRows = 3
		},
		cancellable = true,
		transform = Transform(400, 400),
		colSpacing = 50
	}

	numMenu:addHandler('close', function(nameMenu)
		if nameMenu.closing then
			return
		end
		if string.len(scene.nameScreenName) > 0 then
			if string.len(scene.nameScreenName) == 0 then
				nameMenu:updateList(nameEntryFun(underscores(maxLen)))
				nameMenu.selectedCol = 1
			else
				nameMenu:updateList(nameEntryFun(scene.nameScreenName))
				nameMenu.selectedCol = math.min(maxLen, string.len(scene.nameScreenName) + 1)
			end
		end
		nameMenu:close()
		mbox:close()
	end, nameEntry)
	
	return Serial {
		Parallel {
			mbox,
			nameEntry,
			numMenu
		}
	}
end

return NumScreen
