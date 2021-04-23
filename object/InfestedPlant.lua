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
	
	-- Destroy all pests
	for _, pest in pairs(self.pests) do
		pest:run {
			PlayAudio("sfx", "oppdeath", 1.0, true),
			Parallel {
				Ease(pest.sprite.color, 1, 800, 5),
				Ease(pest.sprite.color, 4, 0, 2)
			},
			Do(function()
				pest:remove()
			end)
		}
	end
	self.pests = {}
	self:removeInteract(InfestedPlant.spray)
	self:checkEndCondition()
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
		-- Food is dead
		self:run {
			PlayAudio("sfx", "oppdeath", 1.0, true),
			Parallel {
				Ease(self.sprite.color, 1, 800, 5),
				Ease(self.sprite.color, 4, 0, 2)
			},
			Do(function()
				self.sprite.color = {255,255,255,255}
				self.sprite:setAnimation("dying3")
				
				self:checkEndCondition()
			end)
		}
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
			y = self.y + (offsetY or 0),
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
	self.scene.player.cinematicStack = self.scene.player.cinematicStack + 1
	self.scene:pauseEnemies(true)
	
	-- Make bunnie face sonic
	local bunnie = self.scene.objectLookup.Bunnie
	local player = self.scene.player
	local dx = bunnie.x + bunnie.sprite.w/2 - player.x
    local dy = bunnie.y + bunnie.sprite.h/2 - player.y

    if math.abs(dx) < math.abs(dy) then
        if dy < 0 then
            bunnie.sprite:setAnimation("idledown")
        else
            bunnie.sprite:setAnimation("idleup")
        end
    else
        if dx < 0 then
            bunnie.sprite:setAnimation("idleright")
        else
            bunnie.sprite:setAnimation("idleleft")
        end
    end
	
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
			GameState:setFlag("bunnie_game_over")
			scene.audio:playMusic("knothole", 0.8)
		end)
	}
end


return InfestedPlant
