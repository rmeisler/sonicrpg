local BasicNPC = require "object/BasicNPC"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local MessageBox = require "actions/MessageBox"

local NPC = require "object/NPC"

local InfestedPlant = class(NPC)

function InfestedPlant:construct(scene, layer, object)
	NPC.init(self)
	
	self.isInfestedPlant = true
end

function InfestedPlant:postInit()
	self.plants = {}
	for _, plant in pairs(self.scene.map.objects) do
		if plant.isInfestedPlant then
			table.insert(self.plants, plant)
		end
	end
end

function InfestedPlant:spray()
	self.scene.audio:playSfx("choose", nil, true)
	GameState:setFlag(self)
	self:destroyPests()
	self:checkEndCondition()
end

function InfestedPlant:destroyPests()
	for _, pest in pairs(self.pests) do
		pest:run {
			PlayAudio("sfx", "oppdeath", 1.0, true),
			Parallel {
				Ease(pest.sprite.color, 1, 800, 5),
				Ease(pest.sprite.color, 4, 0, 5)
			},
			Do(function()
				pest:remove()
			end)
		}
	end
	self.pests = {}
	self:removeInteract(InfestedPlant.spray)
end

function InfestedPlant:update(dt)
	NPC.update(self, dt)
	
	if GameState:isFlagSet(self) then
		return
	end
	
	-- Initialize once game flag is set
	if not self.lifeState and
	   GameState:isFlagSet(self.object.properties.flag)
	then
		self.lifeState = "step1"
		self.startTime = love.timer.getTime() + self.object.properties.startSeconds
		
		self.pests = {}
	end

	if self.lifeState == "step4" and
	   love.timer.getTime() > self.startTime + 5 then
		self.sprite:setAnimation("dying3")
		self:checkEndCondition()
		GameState:setFlag(self)
	elseif self.lifeState == "step3" and
	       love.timer.getTime() > self.startTime + 3 then
		-- Spawn a third pest over plant and show plant degrade
		self:spawnPest(-5, -5)
		self.sprite:setAnimation("dying2")
		self.lifeState = "step4"
	elseif self.lifeState == "step2" and
	       love.timer.getTime() > self.startTime + 2 then
		-- Spawn a second pest over plant
		self:spawnPest(5, 5)
		self.lifeState = "step3"
	elseif self.lifeState == "step1" and
 	       love.timer.getTime() > self.startTime then
		-- Spawn a pest over plant
		self:spawnPest()
		self.sprite:setAnimation("dying1")
		self.lifeState = "step2"
		self:addInteract(InfestedPlant.spray)
	end
end

function InfestedPlant:spawnPest(offsetX, offsetY)
	local pest = BasicNPC(
		self.scene,
		{name = "objects"},
		{
			name = "pest",
			x = self.x + (offsetX or 0),
			y = self.y + (offsetY or 0) - 32,
			width = 64,
			height = 64,
			properties = {nocollision = true, sprite = "art/sprites/pest.png"}
		}
	)
	table.insert(self.pests, pest)
	self.scene:addObject(pest)
end

function InfestedPlant:checkEndCondition()
	if GameState:isFlagSet("bunnie_game_over") then
		return
	end
	
	local plantsKilled = 0
	for _, plant in pairs(self.plants) do
		if not GameState:isFlagSet(plant) then
			return
		end
		
		if plant.lifeState == "step4" then
			plantsKilled = plantsKilled + 1
		end
	end
	
	-- Game over
	GameState:setFlag("bunnie_game_over")
	self.scene.player.cinematicStack = self.scene.player.cinematicStack + 1
	self.scene:pauseEnemies(true)
	
	-- Kill remaining pests
	for _, plant in pairs(self.plants) do
		plant:destroyPests()
	end

	-- Make bunnie face sonic
	local bunnie = self.scene.objectLookup.Bunnie
	bunnie:facePlayer()
	
	local awardItem
	if plantsKilled > 4 then
		awardItem = require("data/items/GreenLeaf")
	elseif plantsKilled > 1 then
		awardItem = require("data/items/BlueLeaf")
	else
		awardItem = require("data/items/YellowLeaf")
	end

	self:run {
		PlayAudio("music", "sallyrally", 1.0),
		Parallel {
			Ease(self.scene.camPos, "x", self.scene.player.x - bunnie.x, 1),
			Ease(self.scene.camPos, "y", self.scene.player.y - bunnie.y, 1)
		},
		MessageBox {
			message = "Bunnie: Way to go suga-hog!",
			blocking = true
		},
		Animate(bunnie.sprite, "pose"),
		MessageBox {
			message = "Bunnie: Here's something special for ya!",
			blocking = true
		},
		Do(function()
			GameState:grantItem(awardItem, 1)
		end),
		MessageBox {
			message = string.format("You received a %s!", awardItem.name),
			blocking = true,
			sfx = "choose",
			textSpeed = 7
		},
		Animate(bunnie.sprite, "idledown"),
		Parallel {
			Ease(self.scene.camPos, "x", 0, 1),
			Ease(self.scene.camPos, "y", 0, 1)
		},
		Do(function()
			self.scene.player.cinematicStack = 0
			self.scene:pauseEnemies(false)
			self.scene.pausePlayer = false
			bunnie:addInteract(function()
				bunnie.scene.player.hidekeyhints[tostring(bunnie)] = bunnie
				bunnie:facePlayer()
				bunnie.scene:run {
					MessageBox {message = "Bunnie: My goodness, {p40}I sure am glad those pests are gone.", blocking = true},
					Do(function()
						bunnie:refreshKeyHint()
					end)
				}
			end)
			self.scene.audio:playMusic("knothole", 0.8)
		end)
	}
end


return InfestedPlant
