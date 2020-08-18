local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"

local NPC = require "object/NPC"

local RaceSquare = class(NPC)

function RaceSquare:construct(scene, layer, object)
	self.ghost = true
	
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
	
	self.scene.squareNumber = #self.squares
	for _, sq in pairs(self.squares) do
		sq.sprite:setAnimation(tostring(self.scene.squareNumber))
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

	if self.activated then
		return
	end
	
	self.activated = true

	self.scene.squareNumber = self.scene.squareNumber - 1
	for _, sq in pairs(self.squares) do
		sq.sprite:setAnimation(tostring(self.scene.squareNumber))
	end
	
	if self.scene.squareNumber == 0 then
		local prevMusic = self.scene.audio:getCurrentMusic()
		self.scene:run {
			Do(function()
				self.scene.player.cinematicStack = self.scene.player.cinematicStack + 1
			end),
			
			Parallel {
				Ease(self.scene.camPos, "x", self.scene.player.x - self.scene.objectLookup.UpperDoor.x, 1, "inout"),
				Ease(self.scene.camPos, "y", self.scene.player.y - self.scene.objectLookup.UpperDoor.y, 1, "inout"),
			},
			
			PlayAudio("music", "puzzlesolve", 1.0),
			
			Parallel {
				Ease(self.scene.camPos, "x", 0, 1, "inout"),
				Ease(self.scene.camPos, "y", 0, 1, "inout"),
			},
			
			PlayAudio("music", prevMusic, 1.0, true, true),
			
			Do(function()
				self.scene.player.cinematicStack = 0
			end),
		}
	end
end


return RaceSquare
