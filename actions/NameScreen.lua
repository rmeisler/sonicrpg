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

local NameScreen = function(scene, prompt, expected, success, failure)
	local maxLen = string.len(expected)
	
	-- Choose a name
	local mbox = DescBox(prompt)
	
	-- Letter menu
	local letters = {
		'a','f','k','p','u','z',
		'b','g','l','q','v','',
		'c','h','m','r','w','',
		'd','i','n','s','x','',
		'e','j','o','t','y','',
	}
	
	local letterMenu = Menu {
		list = letters,
		cancellable = true,
		transform = Transform(400, 400),
		--color = {255,255,255,255},
		colSpacing = 50,
		maxCols = 6,
		maxRows = 6
	}

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

	letterMenu:addHandler('close', function(nameMenu)
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
	
	for i=0,26 do
		local letter = string.char(string.byte('a') + i)
		letterMenu:addHandler(letter, function(nameMenu)
			letter = string.lower(letter)
			scene.nameScreenName = scene.nameScreenName..letter
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
		end, nameEntry)
	end
	
	return Serial {
		Parallel {
			mbox,
			nameEntry,
			letterMenu
		}
	}
end

return NameScreen
