local Transform = require "util/Transform"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local YieldUntil = require "actions/YieldUntil"
local Action = require "actions/Action"
local Do = require "actions/Do"
local DescBox = require "actions/DescBox"
local BlockPlayer = require "actions/BlockPlayer"

local Menu = class(Action)

Menu.MAX_ROWS_DEFAULT = 5
Menu.MAX_COLS_DEFAULT = 2
Menu.COL_SPACING_DEFAULT = 200
Menu.ROW_SPACING_DEFAULT = 28
Menu.TEXT_ALIGN_DEFAULT = "left"
Menu.FONT_DEFAULT = FontCache.Consolas

Menu.ANIM_SPEED_DEFAULT = 3

Menu.CURSOR_TYPE_UNDER = "under"
Menu.CURSOR_TYPE_NORMAL = "normal"

function Menu:construct(args)
	self.transform = args.transform or Transform()
	self.color = args.color or {255, 255, 255, 200}
	self.alpha = self.color[4]
	self.color[4] = 0
	self.cursorType = args.cursorType or Menu.CURSOR_TYPE_NORMAL
	self.cancellable = args.cancellable
	self.cancelKeys = args.cancelKeys or {z=1}
	self.selectKeys = args.selectKeys or {x=1}
	self.maxCols = args.maxCols or Menu.MAX_COLS_DEFAULT
	self.maxRows = args.maxRows or Menu.MAX_ROWS_DEFAULT
	self.colSpacing = args.colSpacing or Menu.COL_SPACING_DEFAULT
	self.rowSpacing = args.rowSpacing or Menu.ROW_SPACING_DEFAULT
	self.textAlign = args.textAlign or Menu.TEXT_ALIGN_DEFAULT
	self.textColor = args.textColor or {255,255,255,255}
	self.font = args.font or Menu.FONT_DEFAULT
	self.type = "Menu"
	self.list = args.list
	self.layout = args.layout
	self.blocking = args.blocking == nil and true or args.blocking
	self.withClose = args.withClose or Action()
	self.curPage = 1
	self.selectedRow = args.selectedRow or 1
	self.selectedCol = args.selectedCol or 1
	self.passive = args.passive or false
	self.showCursor = not self.passive
	self.animSpeed = args.animSpeed or Menu.ANIM_SPEED_DEFAULT
	self.descBoxes = {}
	self.tag = args.tag
	self.args = args
	self.pagesContent = args.pages
	
	local list = args.list
	if list then
		self:updateList(list)
	end

	self.transform.sx = 0
	self.transform.sy = 0
	
	self.expand = Parallel {
		Ease(self.color, 4, self.alpha, self.animSpeed),
		Ease(self.transform, "sx", 1, self.animSpeed),
		Ease(self.transform, "sy", 1, self.animSpeed)
	}
	self.closing = false
end

function Menu:updateList(list)
	self.itemrows = math.min(#list, self.maxRows)
	self.itemcols = math.min(math.floor(#list / self.maxRows) + 1, self.maxCols)
	self.pages = math.floor(#list / (self.maxRows * self.maxCols)) + 1
	
	self.w = self.colSpacing * self.itemcols
	self.h = self.rowSpacing * self.itemrows
	
	-- Add spaces for text alignment; "left" requires no extra work
	self.charSpacing = 15
	if self.textAlign == "center" then
		for i,s in pairs(list) do
			local numspaces = s:len() + math.floor(((self.colSpacing / self.charSpacing) - s:len()) / 2)
			list[i] = string.format('%'..tostring(numspaces)..'s', s)
		end
	elseif self.textAlign == "right" then
		for i,s in pairs(list) do
			local numspaces = math.floor(self.colSpacing / self.charSpacing)
			list[i] = string.format('%'..tostring(numspaces)..'s', s)
		end
	end
	
	self.options = {}
	local i = 1
	for c=1,self.itemcols do
		self.options[c] = {}
		for r=1,self.itemrows + (self.pages - 1) do
			self.options[c][r] = list[i]
			i = i + 1
		end
	end
end

function Menu:updateLayout()
	self.maxRows = self.layout.maxRows
	self.maxCols = self.layout.maxCols
	self.itemrows = self.args.maxRows or self.maxRows
	self.itemcols = self.args.maxCols or self.maxCols
	self.pages = self.pagesContent and table.count(self.pagesContent) or 1 --math.floor(self.itemrows / (self.maxRows * self.maxCols)) + 1
	
	if self.selectedRow > self.itemrows then
		self.selectedRow = self.itemrows
	end
	
	if self.selectedCol >= self.itemcols then
		self.selectedCol = self.itemcols
	end
	
	self.w = self.layout.w
	self.h = self.layout.colHeight * self.itemrows
	
	self.spaceBetweenColumns = self.layout.spaceBetweenColumns
	self.spaceBetweenEntries = self.layout.spaceBetweenEntries
	
	self.colSpacing = math.max(self.layout.colWidth, self.colSpacing)
	self.rowSpacing = math.max(self.layout.colHeight, self.rowSpacing)
	
	self.layout:offset(self.transform.x - self.w/2, self.transform.y - self.h/2)
	
	self.properties = {}
	self.layout:visitMetadata(function(r, c, v)
		if not self.properties[c] then
			self.properties[c] = {}
		end
		if not self.properties[c][r] then
			self.properties[c][r] = {}
		end
		self.properties[c][r].noChooseSfx = v.noChooseSfx
		self.properties[c][r].choose = v.choose
		self.properties[c][r].change = v.change
		self.properties[c][r].desc = v.desc
		if v.selectable == false then
			self.properties[c][r].selectable = false
		else
			self.properties[c][r].selectable = true
		end
	end)
end

function Menu:setScene(scene)
	if self.scene or self.done then
		return
	end
	
	local wrapper = Serial
	if self.blocking then
		wrapper = BlockPlayer
	end
	self.action = wrapper {
		self.expand,
		YieldUntil(self, "closing"),
		Parallel {
			Ease(self.color, 4, 0, self.animSpeed),
			Ease(self.transform, "sx", 0, self.animSpeed),
			Ease(self.transform, "sy", 0, self.animSpeed),
			self.withClose,
		},
		Do(function()
			if not self.passive then
				self.scene:unfocus("keytriggered")
				self.scene:unfocus("keyreleased")
			end
		end)
	}
	
	local layout = self.layout
	if layout then
		layout:setScene(scene)
		self:updateLayout()
	end

	self.img = scene.mboxGradient
	self.scene = scene
	
	if not self.passive then
		self.scene:addHandler("keytriggered", Menu.keytriggered, self)
		self.scene:focus("keytriggered", self)
		self.scene:focus("keyreleased", self)
	end
	self.scene:addNode(self, "ui")
	
	self:showDesc()
end

function Menu:reset()
	if self.closing then
		self.scene:addHandler("keytriggered", Menu.keytriggered, self)
	end
		
	if self:isDone() then
		if not self.passive then
			self.scene:focus("keytriggered", self)
			self.scene:focus("keyreleased", self)
		end
		self.scene:addNode(self, "ui")
	end
	
	self.scene = nil
	self.done = false
	self.action:reset()
end

function Menu:isDone()
	if self.done then
		return true
	end
	if self.action:isDone() then
		self.scene:removeNode(self)
		
		for _,v in pairs(self.descBoxes) do
			v:close()
		end

		self.done = true
		return true
	end
	return false
end

function Menu:update(dt)
	if next(self.descBoxes) ~= nil then
		local topBox = self.descBoxes[1]
		if #self.descBoxes > 1 or self.closing then
			topBox:interrupt()
		end
	
		topBox:update(dt)

		if topBox:isDone() then
			table.remove(self.descBoxes, 1)
		end
	end

	self.action:update(dt)
end

function Menu:keytriggered(key)
	if not self.expand:isDone() then
		return
	end

	local prevPage = self.curPage
	local prevRow = self.selectedRow
	local prevCol = self.selectedCol
	
	self.selectedRow = math.min(self.itemrows, math.max(1, self.selectedRow))
	self.selectedCol = math.min(self.itemcols, math.max(1, self.selectedCol))

	if key == "down" then
		if (self.selectedRow % self.itemrows) == 0 then
			if self.curPage < self.pages then
				self.curPage = self.curPage + 1
			else
				self.curPage = 1
			end
			self.selectedRow = 1
			if self.layout and self.pagesContent then
				for i=1,self.itemrows do
					local row = self.pagesContent[self.curPage][i]
					if row then
						self.layout:updateCol(i, 1, row)
					else
						self.layout:updateCol(i, 1, {choose = function() end, noChooseSfx = true})
					end
				end
				self:updateLayout()
			end
		else
			self.selectedRow = self.selectedRow + 1
		end
	elseif key == "up" then
		if (self.selectedRow - 1) % self.maxRows == 0 then
			if self.curPage > 1 then
				self.curPage = self.curPage - 1
			else
				self.curPage = self.pages
			end
			self.selectedRow = self.itemrows
			if self.layout and self.pagesContent then
				for i=1,self.itemrows do
					local row = self.pagesContent[self.curPage][i]
					if row then
						self.layout:updateCol(i, 1, row)
					else
						self.layout:updateCol(i, 1, {choose = function() end, noChooseSfx = true})
					end
				end
				self:updateLayout()
			end
		else
			self.selectedRow = self.selectedRow - 1
		end
	elseif key == "right" then
		self.selectedCol = (self.selectedCol == self.itemcols) and 1 or self.selectedCol + 1
	elseif key == "left" then
		self.selectedCol = (self.selectedCol == 1) and self.itemcols or self.selectedCol - 1
	elseif self.selectKeys[key] then
		if self.options then
			self.scene.audio:playSfx("choose", nil, true)
			self:invoke((self.options[self.selectedCol] and self.options[self.selectedCol][self.selectedRow]) and self.options[self.selectedCol][self.selectedRow]:trim())
		elseif self.properties then
			if not self.properties[self.selectedCol][self.selectedRow].noChooseSfx then
				self.scene.audio:playSfx("choose", nil, true)
			end
			(self.properties[self.selectedCol][self.selectedRow].choose)(self)
		end
	elseif self.cancelKeys[key] then
		if self.cancellable then
			self:close()
		else
			self:invoke("cancel")
		end
	end

	if  self.curPage ~= prevPage or
		self.selectedRow ~= prevRow or
		self.selectedCol ~= prevCol
	then
		self.scene.audio:playSfx("cursor", nil, true)
		if self.options then
			self:invoke("change", tostring(self.options[self.selectedCol][self.selectedRow]):trim())
		elseif self.properties and
			self.properties[self.selectedCol][self.selectedRow]
		then
			local prop = self.properties[self.selectedCol][self.selectedRow]
			
			-- Recursively resolve to correct option
			if prop.selectable == false then
				self:keytriggered(key)
			end
			
			if prop.change then
				(prop.change)()
			end
			self:showDesc()
		end
	end
	
	return true
end

function Menu:closeDesc()
	for _,v in pairs(self.descBoxes) do
		v:interrupt()
	end
end

function Menu:showDesc()
	local prop = (self.properties and self.properties[self.selectedCol]) and self.properties[self.selectedCol][self.selectedRow]
	if prop and prop.desc then
		local descBox = DescBox(prop.desc)
		descBox:setScene(self.scene)
		table.insert(self.descBoxes, descBox)
	else
		self:closeDesc()
	end
end

function Menu:disable()
	self.scene:removeHandler("keytriggered", Menu.keytriggered, self)
end

function Menu:interrupt()
	while not self:isDone() do
		self.action:next()
		self:update(0)
	end
end

function Menu:close()
	self:invoke("close")
	self.closing = true
	self:disable()
end

function Menu:hide()
	if self.hidden then
		return
	end
	
	self.origAction = self.action
	self.showCursor = false
	self.hidden = true
	self.action = Serial {
		Parallel {
			Ease(self.color, 4, 0, self.animSpeed),
			Ease(self.transform, "sx", 0, self.animSpeed),
			Ease(self.transform, "sy", 0, self.animSpeed)
		},
		Do(function()
			self.action = self.origAction
		end)
	}
end

function Menu:show()
	if self.showing then
		return
	end

	self.showing = true
	self.action = Serial {
		Parallel {
			Ease(self.color, 4, 255, self.animSpeed),
			Ease(self.transform, "sx", 1, self.animSpeed),
			Ease(self.transform, "sy", 1, self.animSpeed)
		},
		Do(function()
			self.action = self.origAction
			self.showCursor = true
			self.hidden = false
			self.showing = false
		end)
	}
end

function Menu:draw()
	local center = Transform(self.transform.x - self.transform.sx * self.w/2, self.transform.y - self.transform.sy * self.h/2)

	-- Draw drop shadow for menu
	love.graphics.setColor(0,0,0, 100 * (self.color[4] / 255))
	love.graphics.rectangle(
		"fill",
		center.x - 5,
		center.y + 5,
		self.w * self.transform.sx - 5,
		(self.h + 20) * self.transform.sy,
		15,
		15
	)

	-- Menu window
	love.graphics.setColor({20, 0, 255, self.color[4]})
	love.graphics.rectangle(
		"fill",
		center.x,
		center.y,
		self.w * self.transform.sx,
		(self.h + 20) * self.transform.sy,
		15,
		15
	)
    
	-- Menu text
	local xOffset = self.colSpacing
	local yOffset = self.rowSpacing
	if self.expand:isDone() and not self.closing and not self.hidden then
		if self.layout then
			self.layout:draw(self.curPage, self.itemrows)
		else
			love.graphics.setFont(self.font)
			
			for c=1,self.itemcols do
				for r=1,self.itemrows do
					local selectedoffset = ((self.curPage-1) * self.itemrows)
					local text = self.options[c][r + selectedoffset] or ''
					local whiteText, yellowText = text:split('|')
					
					if whiteText and whiteText:len() > 0 then
						love.graphics.setColor(self.textColor)
						love.graphics.print(whiteText, center.x + 10 + ((c-1) * xOffset), center.y + 10 + ((r-1) * yOffset))
					end
					
					if yellowText and yellowText:len() > 0 then
						love.graphics.setColor(self.textColor[1], self.textColor[2], 0, self.textColor[4])
						love.graphics.print(
							yellowText,
							center.x + 10 + ((c-1) * xOffset) + (whiteText:len() * self.charSpacing),
							center.y + 10 + ((r-1) * yOffset)
						)
					end
				end
			end
		end

		love.graphics.setColor(self.textColor)
		
		-- If we have more pages below, add a down arrow in bottom right corner of menu
		if self.curPage > 1 then
			local verts = {
				self.transform.x + self.w/2 - 10,
				self.transform.y - self.h/2 + 10,
				self.transform.x + self.w/2 - 5,
				self.transform.y - self.h/2 + 5,
				self.transform.x + self.w/2,
				self.transform.y - self.h/2 + 10
			}
			love.graphics.polygon("fill", verts)
		end
		
		-- If we have more pages above, add an up arrow in top right corner of menu
		if self.curPage < self.pages then
			local verts = {
				self.transform.x + self.w/2 - 10,
				self.transform.y + self.h/2 - 10,
				self.transform.x + self.w/2 - 5,
				self.transform.y + self.h/2 - 5,
				self.transform.x + self.w/2,
				self.transform.y + self.h/2 - 10
			}
			love.graphics.polygon("fill", verts)
		end
		
		-- Cursor
		if self.showCursor then
			if self.cursorType == Menu.CURSOR_TYPE_NORMAL then
				xOffset = (self.selectedCol - 1) * xOffset
				yOffset = ((self.selectedRow - 1) % self.maxRows) * yOffset
				
				love.graphics.setColor(255,255,255,255)
				love.graphics.draw(
					CursorSprite,
					center.x + xOffset - CursorSprite:getWidth() * 1.5,
					center.y + yOffset,
					0,
					2,
					2
				)
			elseif self.cursorType == Menu.CURSOR_TYPE_UNDER then
				xOffset = 35 + (self.selectedCol - 1) * xOffset
				yOffset = (((self.selectedRow - 1) % self.maxRows) + 4) * yOffset
				
				love.graphics.setColor(255,255,255,255)
				love.graphics.draw(
					CursorSprite,
					center.x + xOffset - CursorSprite:getWidth() * 1.5,
					center.y + yOffset,
					-math.pi/2,
					2,
					2
				)
			end
		end
	end
end


return Menu