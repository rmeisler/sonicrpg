local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local Repeat = require "actions/Repeat"
local While = require "actions/While"

local NPC = require "object/NPC"

local RaceSquare = class(NPC)

function RaceSquare:construct(scene, layer, object)
	self.ghost = true
	self.specialHintPlayer = "sonic"
	
	self.hotspotOffsets = {
		left_top = {x = 10, y = 10},
		left_bot = {x = 10, y = -10},
		right_top = {x = -10, y = 10},
		right_bot = {x = -10, y = -10},
	}
	
	NPC.init(self, false)
	
	self.isSquare = true
end

function RaceSquare:postInit()
	self.squares = {}
	for _, sq in pairs(self.scene.map.objects) do
		if sq.isSquare then
			table.insert(self.squares, sq)
		end
	end
	
	self.subject = self.scene.objectLookup[self.object.properties.subject]
	if GameState:isFlagSet(self.scene.mapName..".squares_complete") then
		self.scene.squareNumber = 0
	else
		self.scene.squareNumber = #self.squares
	end
	
	self.scene.totalSquares = #self.squares
	for _, sq in pairs(self.squares) do
		sq.sprite:setAnimation(tostring(self.scene.squareNumber))
	end
	
	self:addSceneHandler("exit", RaceSquare.exit)
end

function RaceSquare:exit()
	if not GameState:isFlagSet(self.scene.mapName..".squares_complete") then
		self.scene.squareNumber = #self.squares
		for _, sq in pairs(self.squares) do
			sq.sprite:setAnimation(tostring(self.scene.squareNumber))
		end
	end
end

function RaceSquare:update(dt)
	if not self.scene.player then
		return
	end
	
	local cx = self.hotspots.left_top.x
	local cy = self.hotspots.left_top.y
	local cw = self.hotspots.right_top.x - cx
	local ch = self.hotspots.right_bot.y - cy
	if self.scene.player:isTouching(cx, cy, cw, ch) then
		self.state = NPC.STATE_TOUCHING
		self:invoke("collision")
		self:onCollision()
	end
end

function RaceSquare:onCollision(prevState)
    NPC.onCollision(self, prevState)

	if  self.activated or
		GameState:isFlagSet(self.scene.mapName..".squares_complete")
	then
		return
	end
	
	self.activated = true
	
	-- The first square touched... start the timer!
	if self.scene.squareNumber == self.scene.totalSquares then
		self:run(While(
			function()
				return not GameState:isFlagSet(self.scene.mapName..".squares_complete")
			end,
			Serial {
				Repeat(
					Serial {
						PlayAudio("sfx", "tick", 1.0, true),
						Wait(0.5),
						PlayAudio("sfx", "tick", 1.0, true),
						Wait(0.5)
					},
					self.scene.totalSquares
				),

				Do(function()
					self.scene.player.cinematicStack = self.scene.player.cinematicStack + 1
					self.scene.player.cinematicStack = 0
					self.scene.squareNumber = self.scene.totalSquares
					for _, sq in pairs(self.squares) do
						sq.sprite:setAnimation(tostring(self.scene.squareNumber))
						sq.activated = false
					end
				end),

				PlayAudio("sfx", "error", 1.0)
			},
			Do(function()
			
			end)
		))
	end
	
	self.scene.squareNumber = self.scene.squareNumber - 1
	for _, sq in pairs(self.squares) do
		sq.sprite:setAnimation(tostring(self.scene.squareNumber))
	end
	
	if self.scene.squareNumber == 0 then
		GameState:setFlag(self.scene.mapName..".squares_complete")
		
		self.scene.player.cinematicStack = self.scene.player.cinematicStack + 1
		self.scene:pauseEnemies(true)
		self.scene.pausePlayer = true
		
		local prevMusic = self.scene.audio:getCurrentMusic()
		local subjWidth = self.subject.sprite and self.subject.sprite.w*2 or self.subject.object.width
		local subjHeight = self.subject.sprite and self.subject.sprite.h*2 or self.subject.object.height/2
		self.scene.player:run {
			PlayAudio("music", "puzzlesolve", 1.0, true),
			Wait(4),
			
			Parallel {
				Ease(self.scene.camPos, "x", function() return self.scene.player.x - (self.subject.x + subjWidth/2) end, 1, "inout"),
				Ease(self.scene.camPos, "y", function() return self.scene.player.y - (self.subject.y + subjHeight) end, 1, "inout"),
			},
			
			self.subject:onPuzzleSolve(),
			
			Wait(1),
			
			Parallel {
				Ease(self.scene.camPos, "x", 0, 1, "inout"),
				Ease(self.scene.camPos, "y", 0, 1, "inout"),
			},
			
			PlayAudio("music", prevMusic, 1.0, true, true),
			
			Do(function()
				self.scene.player.cinematicStack = 0
				self.scene:pauseEnemies(false)
				self.scene.pausePlayer = false
			end),
		}
	end
end


return RaceSquare
