local serpent = require "lib/serpent"
local ItemType = require "util/ItemType"

local GameState = class()

GameState.MAX_LEVEL_CAP = 100

function GameState:construct()
	-- A cache of eligible party members
	self.profiles = {}

	-- Characters not currently in party
	self.inactiveMembers = {}
	
	-- Characters currently in party
	self.party = {}
	
	-- The current party leader
	self.leader = nil

	-- Items in the shared inventory
	self.items = {}
	
	-- Weapons in the shared inventory
	self[ItemType.Weapon] = {}
	
	-- Armor in the shared inventory
	self[ItemType.Armor] = {}
	
	-- Leg items in the shared inventory
	self[ItemType.Legs] = {}
	
	-- Accessories in the shared inventory
	self[ItemType.Accessory] = {}
	
	-- Flags triggered by player behavior
    self.flags = {}
	
	-- Callbacks to trigger when flag is set
	self.flagCallbacks = {}
end

function GameState:calcNextXp(member, level)
	return self:calcNextStat(self.party[member], level, "startxp")
end

function GameState:calcNextStat(profile, level, stat)
	local fun = profile.growth[stat]
	local a = profile.startingstats[stat]
	local b = profile.maxstats[stat]
	local t = level/GameState.MAX_LEVEL_CAP
	return math.ceil(a + fun(t) * (b-a))
end

function GameState:loadPartyMember(member, level, new)
	level = math.max(1, level)
	if self.profiles[member] and self.profiles[member][level] then
		return self.profiles[member][level]
	end

	-- Load the static data for this character
	local profile = love.filesystem.load("data/party/"..member..".lua")()
	
	-- Scale them up to the requested level
	profile.stats = {}
	for stat,fun in pairs(profile.growth) do
		profile.stats[stat] = self:calcNextStat(profile, level-1, stat)
	end
	
	profile.level = level
	profile.hp = profile.stats.maxhp
	profile.sp = profile.stats.maxsp
	profile.xp = profile.stats.startxp
	profile.stats.maxxp = self:calcNextStat(profile, level, "startxp")
	
	-- Add items and calculate bonuses from starting equipment
	if new then
		for _,record in pairs(profile.items) do
			self:grantItem(record.item, record.count)
		end
		
		for _, equip in pairs(profile.equip) do
			for stat, bonus in pairs(equip.stats) do
				profile.stats[stat] = profile.stats[stat] + bonus
			end
		end
	end

	-- Cache profile
	if not self.profiles[member] then
		self.profiles[member] = {}
	end
	self.profiles[member][level] = profile
	
	return profile
end

function GameState:addToParty(member, level, new)
	if not self.profiles[member] or not self.profiles[member][level] then
		self:loadPartyMember(member, level, new)
	end

	if self.inactiveMembers[member] then
		self:addBackToParty(member)
	else
		self.party[member] = self.profiles[member][level]
	end
	
	self.leader = member
end

function GameState:addBackToParty(member)
    if self.inactiveMembers[member] then
		self.party[member] = self.inactiveMembers[member]
		self.inactiveMembers[member] = nil
	end
end

function GameState:removeFromParty(member)
	self.inactiveMembers[member] = self.party[member]
	self.party[member] = nil
end

function GameState:partySize()
	local count = 0
	for _ in pairs(self.party) do
		count = count + 1
	end
	return count
end

function GameState:getGatedSkill(flag, skillName)
	return function()
		if self:isFlagSet(flag) then
			return require("data/battle/skills/"..skillName)
		else
			return nil
		end
	end
end

function GameState:getEarnedSkill(flag, skillName)
	return function()
		local skillPath = "data/battle/skills/"..skillName
		if self:isFlagSet(flag) then
			skillPath = skillPath.."2"
		end
		return require(skillPath)
	end
end

function GameState:getSkills(member)
	local member = self.party[member]
	for curLevel = member.level, 1, -1 do 
		if member.levelup[curLevel] then
			local skillDefs = member.levelup[curLevel].skills
			local skills = {}
			for _, skill in pairs(skillDefs) do
				if skill ~= nil then
					if type(skill) == "function" then
						table.insert(skills, skill())
					else
						table.insert(skills, skill)
					end
					if member.id == "sally" and
					   self:isEquipped(member.id, ItemType.Accessory, "Signal Booster")
					then
						local skillCopy = table.clone(skills[#skills])
						skillCopy.cost = math.max(1, math.floor(skillCopy.cost * (1.0 - 0.25)))
						skills[#skills] = skillCopy
					end
				end
			end
			return skills
		end
	end
	return {}
end

function GameState:getObjectFlag(object)
	if type(object) == "string" then
		return object
	else
		return object:getFlag()
	end
end

function GameState:isFlagSet(object)
	return self.flags[self:getObjectFlag(object)] ~= nil
end

function GameState:setFlag(object)
	local flag = self:getObjectFlag(object)
	self.flags[flag] = 1
	
	if self.flagCallbacks[flag] then
		self.flagCallbacks[flag]()
		self.flagCallbacks[flag] = nil
	end
end

function GameState:unsetFlag(object)
	self.flags[self:getObjectFlag(object)] = nil
end

function GameState:onSetFlag(object, callback)
	self.flagCallbacks[self:getObjectFlag(object)] = callback
end

function GameState:grantItem(item, count)
	if item.type then
		for i=1,count do
			table.insert(self[item.type], item)
		end
	else
		if not (self.items[item.name]) then
			self.items[item.name] = {item = item, count = count}
		else
			local record = self.items[item.name]
			record.count = record.count + count
		end
	end
end

function GameState:hasItem(name)
	return self.items[name] ~= nil
end

function GameState:getItem(name)
	return self.items[name]
end

function GameState:getItemsOfSubtype(type)
	local items = {}
	for name, rec in pairs(self.items) do
		if rec.item.subtype == type then
			items[name] = rec
		end
	end
	return items
end

function GameState:useItem(record)
	record.count = record.count - 1
	if (record.count == 0) then
		self.items[record.item.name] = nil
	end
end

function GameState:removeItem(name)
	self.items[name] = nil
end

function GameState:isEquipped(member, itemType, itemName)
	local item = self.party[member].equip[itemType]
	if item then
		return item.name == itemName
	else
		return false
	end
end

function GameState:unequip(member, itemType)
	return self:equip(member, itemType, nil)
end

function GameState:equip(member, itemType, id)
	local noopCallback = function(_partyMember, _player) end
	local unequipCallback
	
	-- Remove stat bonuses
	local partyMem = self.party[member]
	local memStats = self.party[member].stats
	
	if self.party[member].equip[itemType] then
		for stat, bonus in pairs(self.party[member].equip[itemType].stats) do
			memStats[stat] = memStats[stat] - bonus
		end
		
		unequipCallback = self.party[member].equip[itemType].onUnequip
	end

	local item = nil
	local equipCallback
	if id ~= nil then
		item = table.remove(self[itemType], id)
		
		-- Apply stat bonuses
		local memStats = self.party[member].stats
		for stat, bonus in pairs(item.stats) do
			memStats[stat] = memStats[stat] + bonus
		end
		
		equipCallback = item.onEquip
	end
	table.insert(self[itemType], id or 1, self.party[member].equip[itemType])
	self.party[member].equip[itemType] = item
	return equipCallback or noopCallback, unequipCallback or noopCallback
end

function GameState:levelup(member)
	local member = self.party[member]
	
	member.level = member.level + 1

	-- If Sonic levels up, unset ring flag, so we can get another ring from the lake
	if member.id == "sonic" then
		self:unsetFlag("got_ring")
	end
	
	-- Scale them up to the requested level
	member.stats = {}
	for stat,fun in pairs(member.growth) do
		member.stats[stat] = self:calcNextStat(member, member.level-1, stat)
	end

	member.stats.maxxp = self:calcNextXp(member.id, member.level) - self:calcNextXp(member.id, member.level-1)

	-- Add stat bonuses from equipment
	for _, equip in pairs(member.equip) do
		for stat, bonus in pairs(equip.stats) do
			member.stats[stat] = member.stats[stat] + bonus
		end
	end
	
	-- Refill hp/sp
	member.hp = member.stats.maxhp
	member.sp = member.stats.maxsp
	
	-- Return levelup messages, if any
	if member.levelup[member.level] then
		return member.levelup[member.level].messages
	else
		return {}
	end
end

function GameState:loadSlots()
	local slots = love.filesystem.load("sage2020_game_slots.sav")
	if not slots then
		love.filesystem.write("sage2020_game_slots.sav", serpent.dump({}))
		slots = love.filesystem.load("sage2020_game_slots.sav")
	end
	return slots()
end

function GameState:save(scene, slot, spawnPoint)
	-- Save slots meta
	local maxLevel = 0
	for _, v in pairs(self.party) do
		maxLevel = math.max(maxLevel, v.level)
	end
	
	local slots = self:loadSlots()
	slots[slot] = {
		party = {},
		level = maxLevel,
		location = string.format("%s\n(%s)", scene.map.properties.sectorName, scene.map.properties.regionName)
	}
	for k, v in pairs(self.party) do
		slots[slot].party[k] = v.sprite
	end
	love.filesystem.write("sage2020_game_slots.sav", serpent.dump(slots))
	
	-- Save party members
	local data = {}
	data.party = {}
	for k, v in pairs(self.party) do
		data.party[k] = {
			hp = v.hp,
			sp = v.sp,
			xp = v.xp,
			level = v.level,
			equip = v.equip,
		}
	end
	data.leader = self.leader
	
	-- Save inactive members
	data.inactive = {}
	for k, v in pairs(self.inactiveMembers) do
		data.inactive[k] = {
			hp = v.hp,
			sp = v.sp,
			xp = v.xp,
			level = v.level,
			equip = v.equip,
		}
	end
	
	-- Save inventory and flags
	data[ItemType.Weapon] = self[ItemType.Weapon]
	data[ItemType.Armor] = self[ItemType.Armor]
	data[ItemType.Legs] = self[ItemType.Legs]
	data[ItemType.Accessory] = self[ItemType.Accessory]
	data.items = self.items
	data.flags = self.flags
	
	-- Save region, map, spawn point
	data.region = scene.region
	data.map = scene.mapName
	data.spawnPoint = spawnPoint
	data.music = scene.audio:getCurrentMusic()

	love.filesystem.write("sage2020_game"..tostring(slot)..".sav", serpent.dump(data))
end

function GameState:load(scene, slot)
	local data = love.filesystem.load("sage2020_game"..tostring(slot)..".sav")()
	
	-- Load inventory and flags
	local types = {
		ItemType.Weapon,
		ItemType.Armor,
		ItemType.Legs,
		ItemType.Accessory,
		"items"
	}
	-- Regrant all items to make sure they are using latest code
	for _, t in pairs(types) do
		if t == "items" then
			for itemName, item in pairs(data[t]) do
				local itemFile = "data/items/"..itemName:gsub("%s+", "")
				print("grant item "..itemFile)
				local status = pcall(require, itemFile)
				if status then
					self:grantItem(require(itemFile), item.count)
				end
			end
		else
			self[t] = data[t]
		end
	end
	
	self.flags = data.flags

	-- ep4 save file
	if self:isFlagSet("ep4_introdone") then
		-- Add party members, grant items, set flags
		for k, v in pairs(data.party) do
			self:addToParty(k, v.level, false)
			self.party[k].hp = v.hp
			self.party[k].sp = v.sp
			self.party[k].xp = v.xp
			self.party[k].equip = v.equip
			
			-- Add stat bonuses from equipment
			for _, equip in pairs(self.party[k].equip) do
				for stat, bonus in pairs(equip.stats) do
					self.party[k].stats[stat] = self.party[k].stats[stat] + bonus
				end
			end
		end
		for k, v in pairs(data.inactive) do
			self.inactiveMembers[k] = self:loadPartyMember(k, v.level, false)
			self.inactiveMembers[k].hp = v.hp
			self.inactiveMembers[k].sp = v.sp
			self.inactiveMembers[k].xp = v.xp
			self.inactiveMembers[k].equip = v.equip
			
			-- Add stat bonuses from equipment
			for _, equip in pairs(self.inactiveMembers[k].equip) do
				for stat, bonus in pairs(equip.stats) do
					self.inactiveMembers[k].stats[stat] = self.inactiveMembers[k].stats[stat] + bonus
				end
			end
		end
		self.leader = data.leader
		
		-- What manifest to use?...
		if self:isFlagSet("ep4_to_the_mnt") or self:isFlagSet("ep4_abominable1") then
			scene.sceneMgr:pushScene {
				class = "Region",
				manifest = "maps/northmountainsmanifest.lua",
				map = data.map,
				spawn_point = data.spawnPoint,
				nextMusic = data.music,
				hint = "fromload"
			}
		elseif self:isFlagSet("ep4_ffmeetingover") then
			scene.sceneMgr:pushScene {
				class = "Region",
				manifest = "maps/sonicdemo_manifest.lua",
				map = data.map,
				spawn_point = data.spawnPoint,
				nextMusic = data.music,
				hint = "fromload"
			}
		elseif self:isFlagSet("ep4_introdone") then
			-- Use ironlock manifest file
			scene.sceneMgr:pushScene {
				class = "Region",
				manifest = "maps/sonicdemo_manifest.lua",
				map = data.map,
				spawn_point = data.spawnPoint,
				nextMusic = data.music,
				hint = "fromload"
			}
		elseif self:isFlagSet("ironlock_intro") then
			-- Use ironlock manifest file
			scene.sceneMgr:pushScene {
				class = "Region",
				manifest = "maps/ironlock_manifest_full.lua",
				map = data.map,
				spawn_point = data.spawnPoint,
				nextMusic = data.music,
				hint = "fromload"
			}
		else
			-- Use default manifest file
			scene.sceneMgr:pushScene {
				class = "Region",
				manifest = data.region,
				map = data.map,
				spawn_point = data.spawnPoint,
				nextMusic = data.music,
				hint = "fromload"
			}
		end
	-- ep1 or ep2 or ep3 save, treat as new game+
	else
		self:addToParty("logan", 8, true)
		self.leader = "logan"
		self:setFlag("ep3_intro")
		scene.sceneMgr:switchScene {class = "ChapterSplashScene", manifest = "maps/sonicdemo_manifest.lua"}
	end
end


return GameState
