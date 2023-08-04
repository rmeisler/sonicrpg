local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local SpriteNode = require "object/SpriteNode"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local DrawableNode = require "object/DrawableNode"
local Menu = require "actions/Menu"
local Do = require "actions/Do"
local Actor = require "actions/Executor"
local MessageBox = require "actions/MessageBox"
local Trigger = require "actions/Trigger"
local PlayAudio = require "actions/PlayAudio"
local BlockInput = require "actions/BlockInput"

local Layout = require "util/Layout"
local EventType = require "util/EventType"
local ItemType = require "util/ItemType"

local PlayerStats = require "data/misc/stats"

local Subscreen = class(DrawableNode)

function Subscreen:construct(scene, transform, color, img)
	self.img = img
	self.color[4] = 0
	
	self:addSceneNode("ui")
	
	local subscreenMenu = Menu {
		layout = Layout {
			{Layout.Text("Items"),  choose = function() self:openItemMenu() end},
			{Layout.Text("Skills"), choose = function() self:choosePlayer(Subscreen.openSkillsMenu) end},
			{Layout.Text("Equip"),  choose = function() self:choosePlayer(Subscreen.openEquipMenu) end},
			{Layout.Text("Stats"),  choose = function() self:choosePlayer(Subscreen.openStatsMenu) end},
			{Layout.Text("Quit"),   choose = function() self:quit() end}
		},
		cancellable = true,
		transform = Transform(150, 100),
		colSpacing = 120,
		withClose = Serial {
			-- Fade out subscreen selection 
			Ease(self.color, 4, 0, 2),
			
			-- Remove subscreen player selection
			Do(function()
				self:remove()
				self.scene.audio:stopSfx("cursor") -- Hack, get off repeat
				self.scene.audio:stopSfx("choose") -- Hack, get off repeat
			end)
		}
	}
	
	self.scene:run(Parallel {
		-- Fade in subscreen player selection
		Ease(self.color, 4, 255, 2),

		-- Pull up subscreen menu
		subscreenMenu
	})
	
	-- Build a convenient party cache
	self.party = {}
	for k,_ in pairs(GameState.party) do
		table.insert(self.party, k)
	end
end

function Subscreen:choosePlayer(callback, ...)
	self.showCursor = true
	self.selectedPlayer = 1
	
	self:focusScene("keytriggered")
	self:addSceneHandler("keytriggered", Subscreen.choosePlayerInput, callback, ...)
end

function Subscreen:choosePlayerInput(key, uni, callback, ...)
	if key == "up" then
		self.scene.audio:playSfx("cursor", nil, true)
		self.selectedPlayer = (self.selectedPlayer == 1) and #self.party or (self.selectedPlayer - 1)
	elseif key == "down" then
		self.scene.audio:playSfx("cursor", nil, true)
		self.selectedPlayer = (self.selectedPlayer == #self.party) and 1 or (self.selectedPlayer + 1)
	end
	
	if key == "z" then
		self:unselectPlayer()
		if self.onCancelChoosePlayer then
			self.onCancelChoosePlayer()
		end
	elseif key == "x" then
		self.scene.audio:playSfx("choose", nil, true)
		callback(self, GameState.party[self.party[self.selectedPlayer]], ...)
	end
end

function Subscreen:unselectPlayer()
	self.selectedPlayer = nil
	self.showCursor = false
	self:unfocusScene("keytriggered")
	self:removeSceneHandler("keytriggered", Subscreen.choosePlayerInput)
end

function Subscreen:useItem(player, menu, record)
	if record.item.unusable and record.item.unusable(player) then
		self.scene.audio:stopSfx()
		self.scene.audio:playSfx("error", nil, true)
		return
	end
	
	GameState:useItem(record)
	
	local selected = self.selectedPlayer
			
	-- Update item menu slot
	if record.count > 0 then
		menu.layout:updateCol(
			menu.selectedRow,
			menu.selectedCol,
			self:getItemEntry(record)
		)
		menu:updateLayout()
		self:unselectPlayer()
	else
		menu.layout:removeCol(
			menu.selectedRow,
			menu.selectedCol
		)
		menu:updateLayout()
		self:unselectPlayer()
		
		-- Are we out of items? Close menu
		local itemCount = 0
		for _,record in pairs(GameState.items) do
			itemCount = itemCount + record.count
		end
		if itemCount == 0 then
			menu:close()
		end
	end
	
	player.scene = self.scene
	self.scene:run {
		PlayAudio("sfx", "choose", 1.0, true),
		record.item.menuAction()(
			player,
			Transform(320, 120 + (selected - 1) * 142)
		),
		Do(function()
			menu:show()
			self.onCancelChoosePlayer = nil
		end)
	}
end

function Subscreen:useSkill(player, skill)
	-- TODO
end

function Subscreen:runBackground(menuArgs)
	menuArgs.withClose = Parallel {
		Ease(self.color, 1, 255, 6),
		Ease(self.color, 2, 255, 6),
		Ease(self.color, 3, 255, 6)
	}
	local menu = Menu(menuArgs)
	self.scene:run(Parallel {
		Ease(self.color, 1, 200, 6),
		Ease(self.color, 2, 200, 6),
		Ease(self.color, 3, 200, 6),
		menu,
	})
end

function Subscreen:openItemMenu()
	local optionPages = {}
	--local itemsPerPage = 6
	--local curPage = 1
	for _,record in pairs(GameState.items) do
		--[[if #optionPages[curPage] == itemsPerPage then
			curPage = curPage + 1
			optionPages[curPage] = {}
		end]]
		table.insert(optionPages, self:getItemEntry(record))
	end

	local _, first = next(GameState.items)
	if not first then
		self.scene.audio:stopSfx()
		self.scene.audio:playSfx("error", nil, true)
		return -- No items, no menu
	end
	
	self:runBackground {
		layout = Layout(optionPages),
		cancellable = true,
		transform = Transform(510, 80 + (#optionPages * 28)/2),
		colSpacing = 230
		--pages = optionPages
	}
end

function Subscreen:openSkillsMenu(player)
	local columnTemplate = {
		Layout.Text(string.format("%10s", "")),
		Layout.Text(string.format("%2s", "")),
		choose = function() end
	}
	local layout = {
		Layout.Columns{ columnTemplate, columnTemplate },
		Layout.Columns{ columnTemplate, columnTemplate },
		Layout.Columns{ columnTemplate, columnTemplate }
	}
	local index = 0
	for _, skill in pairs(GameState:getSkills(player.id)) do
		layout[math.floor(index / 2) + 1].__columns[(index % 2) + 1] = {
			Layout.Text(string.format("%s%"..tostring(10 - skill.name:len()).."s", skill.name, "")),
			Layout.Text{text={{255,255,0}, string.format("%s%"..tostring(skill.cost >= 10 and 0 or 1).."s", skill.cost, "")}},
			choose = function(menu)
				if skill.usableFromMenu then
					self:choosePlayer(Subscreen.useSkill, skill)
				else
					self.scene.audio:stopSfx()
					self.scene.audio:playSfx("error", nil, true)
				end
			end,
			desc = skill.desc
		}
		index = index + 1
	end
	
	self:runBackground {
		layout = Layout(layout),
		cancellable = true,
		transform = Transform(570, 107 + (self.selectedPlayer - 1) * 142),
		withClose = Do(function() self:unselectPlayer() end)
	}
end

function Subscreen:openEquipMenu(player)
	local orderedEquip = {ItemType.Weapon, ItemType.Armor, ItemType.Legs, ItemType.Accessory}
	local layout = {}
	for _,itemType in pairs(orderedEquip) do
		table.insert(layout, self:getEquipEntry(itemType, player.equip[itemType]))
	end
	
	self:runBackground {
		layout = Layout(layout),
		cancellable = true,
		transform = Transform(570, (self.selectedPlayer * 142) - 33),
		withClose = Do(function() self:unselectPlayer() end)
	}
end

function Subscreen:openStatsMenu(player)
	local rows = {}
	for k,stat in pairs(PlayerStats) do
		local value = player.stats[k]
		if value then
			local row = {
				Layout.Text(stat.name),
				Layout.Image{name=stat.icon, color={255,255,0,255}},
				Layout.Text{text={{255,255,0,255},tostring(value)}},
				desc = stat.desc,
				choose = function() end,
			}
			rows[stat.order] = row
		end
	end
	
	-- Offset for top party member so we aren't clipped by headliner msg box
	-- Offset for bot party member so we aren't clipped by bot of screen
	local offsetY = 0
	if self.selectedPlayer == 1 then
		offsetY = 20
	elseif self.selectedPlayer == 4 then
		offsetY = -20
	end
	
	self:runBackground {
		layout = Layout(rows),
		cancellable = true,
		transform = Transform(510, (self.selectedPlayer * 142) - 33 + offsetY),
		withClose = Do(function() self:unselectPlayer() end)
	}
end

function Subscreen:getEquipTypeIndex(itemType)
	for index, t in pairs({ItemType.Weapon, ItemType.Armor, ItemType.Legs, ItemType.Accessory}) do
		if t == itemType then
			return index
		end
	end
	return nil
end

function Subscreen:getItemEntry(record)
	return {
		Layout.Image{
			name=record.item.icon,
			color=(record.item.usableFromMenu and {255,255,255,255} or {100,100,100,255})
		},
		Layout.Text{text={
			record.item.usableFromMenu and {255,255,255,255} or {100,100,100,255},
			record.item.name,
		}},
		Layout.Text{text={
			record.item.usableFromMenu and {255,255,0,255} or {100,100,100,255},
			tostring(record.count)
		}},
		choose = function(menu)
			if record.item.usableFromMenu then
				menu:hide()
				self.onCancelChoosePlayer = function() menu:show() end
				self:choosePlayer(Subscreen.useItem, menu, record)
			else
				self.scene.audio:stopSfx()
				self.scene.audio:playSfx("error", nil, true)
			end
		end,
		desc = record.item.desc
	}
end

function Subscreen:itemTypeToSlotName(itemType)
	local mapping = {
		[ItemType.Weapon] = "Hands",
		[ItemType.Armor] = "Body",
		[ItemType.Legs] = "Legs",
		[ItemType.Accessory] = "Special"
	}
	return mapping[itemType]
end

function Subscreen:getEquipEntry(itemType, item)
	local itemName = item and item.name or "None"
	local itemStats = item and item.stats or {}
	local itemEvent = item and item.event or nil
	local row = {
		Layout.Text(self:itemTypeToSlotName(itemType)), --itemType:gsub("^%l", string.upper)),
		Layout.Text{text={{255,255,0,255}, itemName}},
	}
	-- Reorder stats based on "order"
	local orderedStats = {}
	for uid, value in pairs(itemStats) do
		orderedStats[PlayerStats[uid].order] = {uid = uid, value = value}
	end
	for _,data in pairs(orderedStats) do
		local color = data.value > 0 and {255,255,0,255} or {255,0,0,255}
		data.value = data.value > 0 and "+"..tostring(data.value) or tostring(data.value)
		table.insert(row, Layout.Image{name=PlayerStats[data.uid].icon, color=color})
		table.insert(row, Layout.Text{text={color, data.value}})
	end
	if itemEvent then
		if item.event.type == EventType.X or item.showX then
			table.insert(row, Layout.Image("xevent"))
		end
		if item.event.type == EventType.Z or item.showZ then
			table.insert(row, Layout.Image("zevent"))
		end
	end
	row.choose = function(menu)
		menu:closeDesc()
		self:switch(menu, itemType)
	end
	row.desc = item and item.desc or ""
	return row
end

function Subscreen:getEquipInvEntry(equipMenu, playerName, id, item)
	local row = {
		Layout.Text(item.name)
	}
	-- Reorder stats based on "order"
	local orderedStats = {}
	for uid,value in pairs(item.stats) do
		orderedStats[PlayerStats[uid].order] = {uid = uid, value = value}
	end
	for _,data in pairs(orderedStats) do
		local color = {255,255,255,255}
		data.value = data.value > 0 and "+"..tostring(data.value) or tostring(data.value)
		table.insert(row, Layout.Image(PlayerStats[data.uid].icon))
		table.insert(row, Layout.Text{text={color, data.value}})
	end
	if item.event then
		if item.event.type == EventType.X then
			table.insert(row, Layout.Image("xevent"))
		elseif item.event.type == EventType.Z then
			table.insert(row, Layout.Image("zevent"))
		end
	end
	row.desc = item.desc
	row.choose = function(menu)
		local found = false
		for _, name in pairs(item.usableBy) do
			if name == playerName then
				found = true
				break
			end
		end
		if not found then
			self.scene.audio:stopSfx()
			self.scene.audio:playSfx("error", nil, true)
			return
		end
	
		menu:closeDesc()

		-- Swap inv/equip item
		local onEquip, onUnequip = GameState:equip(playerName, item.type, id)
		onUnequip(playerName, self.scene.player)
		onEquip(playerName, self.scene.player)
		
		-- Update equip menu slot
		equipMenu.layout:updateCol(
			self:getEquipTypeIndex(item.type),
			1,
			self:getEquipEntry(item.type, GameState.party[playerName].equip[item.type])
		)
		equipMenu:updateLayout()
		
		-- Close inv menu
		menu:close()
	end
	return row
end

function Subscreen:unequip(equipMenu, playerName, itemType)
	local _onEquip, onUnequip = GameState:unequip(playerName, itemType)
	onUnequip(playerName, self.scene.player)

	-- Update equip menu slot
	equipMenu.layout:updateCol(
		self:getEquipTypeIndex(itemType),
		1,
		self:getEquipEntry(itemType, nil)
	)
	equipMenu:updateLayout()
end

function Subscreen:switch(equipMenu, itemType)
	local playerName = self.party[self.selectedPlayer]
	local items = {}
	
	-- First option is "Unequip"
	local player = GameState.party[playerName]
	if player.equip[itemType] then
		table.insert(
			items,
			{
				Layout.Text {text = "Unequip", color = {255, 255, 0, 255}},
				choose = function(menu)
					self:unequip(equipMenu, playerName, itemType)
					
					-- Close inv menu
					menu:close()
				end
			}
		)
	end
	
	if next(GameState[itemType]) == nil and not player.equip[itemType] then
		return
	end
	
	for id,record in pairs(GameState[itemType]) do
		table.insert(items, self:getEquipInvEntry(equipMenu, playerName, id, record))
	end

	local menu = Menu {
		layout = Layout(items),
		cancellable = true,
		transform = Transform(
			equipMenu.transform.x,
			equipMenu.transform.y + 5 + (equipMenu.selectedRow - 1) * equipMenu.rowSpacing
		),
		colSpacing = 180
	}
	
	self.scene:run(menu)
end

function Subscreen:quit()
	self:runBackground {
		layout = Layout {
			{Layout.Text("Are you sure?"), selectable = false},
			{Layout.Text("Yes"), choose = love.event.quit},
			{Layout.Text("No"),  choose = function(menu) menu:close() end},
			colWidth = 200
		},
		transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
		selectedRow = 2,
		cancellable = true
	}
end

function Subscreen:draw()
	-- Avatar window background
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4] * 0.8)
	local rect = Rect(
		Transform(100, 0),
		love.graphics.getWidth() - 200 - 15,
		love.graphics.getHeight()
	)
    if self.img then
		love.graphics.draw(self.img, rect.transform.x, rect.transform.y, 0, rect.w * rect.transform.sx / self.img:getWidth(), rect.h * rect.transform.sy / self.img:getHeight())
	else
		love.graphics.rectangle("fill", rect.transform.x, rect.transform.y, rect.w * rect.transform.sx, rect.h * rect.transform.sy)
	end
	
	love.graphics.setFont(FontCache.Consolas)
	
	local avatarX = rect.transform.x + 150
	local avatarYOffset = 142
	local index = 0
	for k,v in pairs(GameState.party) do
		local alpha = self.selectedPlayer == (index + 1) and 255 or self.color[4]
		local avatar = self.scene.images[v.avatar]
		local avatarY = index * avatarYOffset + 20		
		
		-- Avatar
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.draw(avatar, avatarX, avatarY, 0, 142 * rect.transform.sx / avatar:getWidth(), 142 * rect.transform.sy / avatar:getHeight())
		
		-- Name text
		avatarY = avatarY + 20
		love.graphics.print(v.altName, avatarX + 150, avatarY)
		
		local stats = {{"hp", "maxhp"}, {"sp", "maxsp"}, {"xp", "nextxp"}}
		local progressBarColor = {
			hp = {80, 255, 80, alpha}, -- Light green
			sp = {0, 255, 255, alpha}, -- Light blue
			xp = {255, 255, 0, alpha}, -- Yellow
		}
		local statYOffset = 28

		-- Field types
		love.graphics.setColor(255, 255, 0, alpha)
		love.graphics.print('level', avatarX + 300, avatarY)
		statIndex = 1
		for _, statData in pairs(stats) do
			local name = statData[1]
			if v[name] then
				love.graphics.print(name, avatarX + 150, avatarY + statYOffset * statIndex)
				statIndex = statIndex + 1
			end
		end

		-- Current level
		love.graphics.print(tostring(v.level), avatarX + 375, avatarY)
		
		-- Field values
		local lastLevelXp = v.level == 1 and 0 or GameState:calcNextXp(k, v.level - 1)
		love.graphics.setColor(255, 255, 255, alpha)
		
		statIndex = 1
		for _, statData in pairs(stats) do
			local name = statData[1]
			if v[name] then
				local stat
				local maxstat
				-- Special case for xp
				if statData[1] == "xp" then
					stat = v[name] - lastLevelXp
					maxstat = GameState:calcNextXp(k, v.level) - lastLevelXp
				else
					stat = v[name]
					maxstat = v.stats[statData[2]]
				end
				
				local posX = avatarX + 190
				local posY = avatarY + statYOffset * statIndex
				
				-- Draw back of progress bar
				love.graphics.setColor(0, 0, 0, 100 * (alpha / 255))
				love.graphics.rectangle("fill", posX, posY + 10, 200, 10, 2, 2)

				-- Draw progress bar
				if stat > 0 then
					love.graphics.setColor(progressBarColor[name])
					love.graphics.rectangle("fill", posX, posY + 10, 200 * (stat / maxstat), 10, 2, 2)
				end
				
				local textOffset = 15
					
				-- Draw stat text with outline
				love.graphics.setColor(0,0,0,100 * (alpha / 255))
				for x=-2,2,2 do
					for y=-2,2,2 do
						love.graphics.print(string.format('%5s / %s', stat, maxstat), posX + textOffset + x, posY + y)
					end
				end
				
				love.graphics.setColor(255, 255, 255, alpha)
				love.graphics.print(string.format('%5s / %s', stat, maxstat), posX + textOffset, posY)
				
				statIndex = statIndex + 1
			end
		end
		
		index = index + 1
		
		-- Cursor (Choosing player-context for menus)
		if self.showCursor and self.selectedPlayer == index then
			love.graphics.setColor(255,255,255,255)
			local xOffset = avatarX - 15
			local yOffset = avatarY + 45
			local verts = {
				xOffset - 6,
				yOffset + 16,
				xOffset + 6,
				yOffset + 24,
				xOffset - 6,
				yOffset + 32
			}
			love.graphics.polygon("fill", verts)
		end
		love.graphics.setColor(255,255,255,self.color[4])
	end
end


return Subscreen
