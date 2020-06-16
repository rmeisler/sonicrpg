local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"
local Menu = require "actions/Menu"
local Action = require "actions/Action"

local Transform = require "util/Transform"
local Layout = require "util/Layout"

local NPC = require "object/NPC"

local Rotor = class(NPC)

function Rotor:construct(scene, layer, object)
	self.items = {}
	for key,file in pairs(self.object.properties) do
		if key:sub(1, string.len("item")) == "item" then
			table.insert(self.items, require(file:match(".*(data/[%w_]+/[%w_]+)%.lua")))
		end
	end
	
	self:addHandler("interact", Rotor.onInteract, self)
end

function Rotor:onInteract()
	self.scene:run(MessageBox {
		message = "Rotor: Hey Sonic! Wanna see some of my projects?",
		options = {
			{text = "Yes", callback = function(mbox, menu) self:openMenu(mbox, menu) end},
			{text = "No", callback = function(mbox, menu)
				menu:close()
				mbox:close()
				self.scene:run {menu,mbox}
			end},
		},
		closeAction = Action(),
		blocking = true
	})
end

function Rotor:openMenu(prevMbox, prevMenu)
	local rows = {}
	for _,item in pairs(self.items) do
		table.insert(
			rows,
			{
				Layout.Image(item.icon),
				Layout.Text(item.name),
				choose = function() end,
				desc = item.desc
			}
		)
	end

	prevMenu:close()
	prevMbox:close()
	self.scene:run {
		prevMenu,
		prevMbox,
		Menu {
			layout = Layout(rows),
			cancellable = true,
			transform = Transform(510, 165),
			maxCols = 2,
			maxRows = 6,
			colSpacing = 230
		}
	}
end


return Rotor
