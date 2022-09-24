local TextNode = require "object/TextNode"
local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local Layout = class()

-- Helps describe a ui
--
-- [args] is a table of rows, where each element is a column table.
--        Each column table may contain a list of Sprites or Text objects.
--        You can then configure the Layout to determine how you want it
--        to behave when elements added to the table are different sizes.
--
-- Example: I want a menu where each option is: "Title" "Description" <Icon> "Bonus"
-- 
-- local layout = Layout {
--     {
--         Layout.Text("Title"),
--         Layout.Text("Description"),
--         Layout.Image("icon"),
--         Layout.Text("Bonus")
--     },
--     
--     alignEntryY = true,
--     minColSeparation = 10, -- Space between each column
--     maxRowWidth = 200,     -- Max width for a row
-- }
--
-- scene:run(Menu { layout = layout, ... })
--
Layout.Text = function(args)
	return function(scene)
		if type(args) == "string" then
			args = {text=args}
		end
		return TextNode(scene, nil, args.color, args.text or "", args.font or FontCache.Consolas, false, args.outline or false)
	end
end

Layout.Image = function(args)
	return function(scene)
		if type(args) == "string" then
			args = {name=args}
		end
		local node = SpriteNode(scene, Transform(0,0,2,2), args.color, args.name, nil, nil, false)
		node.drawWithNight = false
		if args.anim then
			node:setAnimation(args.anim)
		end
		if args.width then
			node.w = args.width
		end
		return node
	end
end

Layout.Columns = function(columns)
	return {__columns = columns}
end

function Layout:construct(args)
	self.rows = {}
	self.curRow = 0
	self.curCol = 0
	self.curEntry = 0
	
	self.maxRows = 0
	self.maxCols = 0
	
	--self.maxViewableRows = args.maxViewableRows
	
	self.colHeights = {}
	self.stackedEntryWidths = {}
	
	self.w = 0
	self.h = 0
	
	self.colWidth = 0
	self.colHeight = 0
	self.entryWidth = 0
	
	self.spaceBetweenEntries = 10
	self.spaceBetweenColumns = 15
	self.spaceBetweenRows = 10
	self.alignEntries = false
	
	-- First remove the special args
	for k,v in pairs(args) do
		if type(k) == "string" then
			self[k] = v
			args[k] = nil
		end
	end
	
	self.args = args
end

function Layout:removeCol(row, col)
	if not self.scene then
		error("Cannot removeRow until after setScene")
	end
	table.remove(self.rows[row], col)
	table.remove(self.metadata[row], col)
	
	if next(self.rows[row]) == nil then
		table.remove(self.rows, row)
		table.remove(self.metadata, row)
		self.maxRows = self.maxRows - 1
	end
	
	self:resize()
end

function Layout:updateCol(row, col, entries)
	if not self.scene then
		error("Cannot updateCol until after setScene")
	end
	
	-- Wipe everything in entry list first
	self.curEntry = 0
	self.rows[row][col] = {}
	if self.metadata[row] and self.metadata[row][col] then
		self.metadata[row][col] = {}
	end
	for index, entry in pairs(entries) do
		if type(index) == "number" and type(entry) == "function" then
			self:insertEntryAt(row, col, index, entry(self.scene))
		else
			if not self.metadata[row] then
				self.metadata[row] = {}
			end
			if not self.metadata[row][col] then
				self.metadata[row][col] = {}
			end
			self.metadata[row][col][index] = entry
		end
	end
	self:resize()
end

-- Layout is lazily instantiated. Only after scene is provided
function Layout:setScene(scene)
	self.scene = scene
	self.metadata = {}

	local addEntries = function(entries)
		self:pushCol()
		for index, entry in pairs(entries) do
			if type(index) == "number" and type(entry) == "function" then
				self:pushEntry(entry(scene))
			else
				if not self.metadata[self.curRow] then
					self.metadata[self.curRow] = {}
				end
				if not self.metadata[self.curRow][self.curCol] then
					self.metadata[self.curRow][self.curCol] = {}
				end
				self.metadata[self.curRow][self.curCol][index] = entry
			end
		end
	end
	
	-- Create the table from remaining args
	for _,entries in pairs(self.args) do
		self:pushRow()
		if type(entries) == "table" then
			if entries.__columns then
				for _, colEntries in pairs(entries.__columns) do
					addEntries(colEntries)
				end
			else
				addEntries(entries)
			end
		end
	end
	self.args = {}
	self:resize()
end

function Layout:resize()
	-- Calculate max entry widths based on all data
	for entryIndex=1,#self.stackedEntryWidths do
		for _,cols in ipairs(self.rows) do
			for _,entries in ipairs(cols) do
				local entry = entries[entryIndex]
				if entry then
					self.stackedEntryWidths[entryIndex] = math.max(
						self.stackedEntryWidths[entryIndex],
						(self.stackedEntryWidths[entryIndex - 1] or 0) + entry.w + self.spaceBetweenEntries
					)
					self.colWidth = math.max(
						self.colWidth,
						self.stackedEntryWidths[entryIndex] + self.spaceBetweenEntries + self.spaceBetweenColumns
					)
				end
			end
		end
	end
	
	for rowIndex,cols in ipairs(self.rows) do
		for colIndex,entries in ipairs(cols) do
			for entryIndex,entry in ipairs(entries) do
				entry.transform.x = self.colWidth * (colIndex - 1) + (self.stackedEntryWidths[entryIndex - 1] or 0) + self.spaceBetweenColumns
				entry.transform.y = self.colHeight * (rowIndex - 1) + self.spaceBetweenRows
				-- Center images
				if entry.img then
					entry.transform.y = entry.transform.y + math.max((self.colHeight - entry.h)/4, 0)
				end
			end
		end
	end
	
	self.w = self.colWidth * self.maxCols
	self.h = self.colHeight * #self.rows
end

function Layout:pushRow()
	table.insert(self.rows, {})
	self.curCol = 0
	self.curRow = self.curRow + 1
	self.maxRows = self.curRow
end

function Layout:pushCol()
	if not self.rows[self.curRow] then
		self:pushRow()
	end
	table.insert(self.rows[self.curRow], {})
	self.curEntry = 0
	self.curCol = self.curCol + 1
	if self.maxCols < self.curCol then
		self.maxCols = self.curCol
	end
end

function Layout:pushEntry(entry)
	if not self.rows[self.curRow] or not self.rows[self.curRow][self.curCol] then
		self:pushCol()
	end
	self:insertEntryAt(self.curRow, self.curCol, self.curEntry + 1, entry)
end

function Layout:insertEntryAt(row, col, entryIndex, entry)
	entryIndex = math.min(self.curEntry + 1, entryIndex)
	if entryIndex > self.curEntry then
		if not self.rows[row][col] then
			self.rows[row][col] = {}
		end
		table.insert(self.rows[row][col], entry)
		self.curEntry = entryIndex
	end

	if entryIndex > #self.stackedEntryWidths then
		table.insert(self.stackedEntryWidths, 0)
	end
	
	local colIndex = string.format("%s.%s", row, col)
	
	-- Recalculate height for this column. If its height > max height, set it to our new height
	local height = self.colHeights[colIndex] or (2 * self.spaceBetweenRows)
	height = math.max(height, entry.h)
	self.colHeights[colIndex] = height
	if height > self.colHeight then
		self.colHeight = height
	end
end

function Layout:offset(x, y)
	for _,cols in ipairs(self.rows) do
		for _,entries in ipairs(cols) do
			for _,entry in ipairs(entries) do
				entry.transform.x = entry.transform.x + x
				entry.transform.y = entry.transform.y + y
			end
		end
	end
end

function Layout:visitMetadata(fn)
	for r,cols in ipairs(self.metadata) do
		for c,entries in ipairs(cols) do
			fn(r,c,entries)
		end
	end
end

function Layout:visitEntries(fn)
	for _,cols in ipairs(self.rows) do
		for _,entries in ipairs(cols) do
			for _,entry in ipairs(entries) do
				fn(entry)
			end
		end
	end
end

function Layout:draw(page)
	for index,cols in ipairs(self.rows) do
		--if index > (page - 1) * self.maxViewableRows and
		--   index <= page * self.maxViewableRows
		--then
			for _,entries in ipairs(cols) do
				for _,entry in ipairs(entries) do
					entry:draw()
				end
			end
		--end
	end
end

function Layout:remove()
	for _,cols in ipairs(self.rows) do
		for _,entries in ipairs(cols) do
			for _,entry in ipairs(entries) do
				entry:remove()
			end
		end
	end
end


return Layout