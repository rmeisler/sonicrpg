local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local Action = require "actions/Action"
local Do = require "actions/Do"

local Player = require "object/Player"
local ThreeDee = require "object/ThreeDee"

local ThreeDeeMushroom = class(ThreeDee)

function ThreeDeeMushroom:construct(scene, layer, object)
	self.visualObject = self.object.properties.visualObject
	self.flyHeight = self.object.properties.flyHeight
	self.exitScene = self.object.properties.exitScene
end

function ThreeDeeMushroom:land()
	local changeSceneAction = Do(function()
		local mapName = "maps/"..self.exitScene
		self.scene:changeScene{
			mapName = mapName,
			fadeOutSpeed = 0.2,
			fadeInSpeed = 0.2,
			fadeOutMusic = true,
			spawnPoint = self.object.properties.spawnPoint,
			hint = "from_mushroom",
		}
	end)
	
	if self.exitScene then
		self.scene.player.noFlyPan = true
	end

	-- Bounce up on landing
	self:run {
		Parallel {
			PlayAudio("sfx", "bounce", 0.5),
			Ease(self.scene.player, "y", self.scene.player.y - self.nextFlyOffsetY - self.flyHeight, 2),
			self.exitScene and Action() or Ease(self.scene.camPos, "y", self.scene.camPos.y - self.nextFlyOffsetY - self.flyHeight, 2),
			Ease(self.scene.player, "flyOffsetY", self.scene.player.flyOffsetY + self.nextFlyOffsetY + self.flyHeight, 2),

			Serial {
				Animate(self.scene.objectLookup[self.visualObject].sprite, "bounce"),
				Animate(self.scene.objectLookup[self.visualObject].sprite, "idle"),
				self.exitScene and changeSceneAction or Action(),
			}
		},
		Do(function()
			self.scene.player.noLand = false
			self.scene.player.stickyLShift = false
		end)
	}
	return true
end


return ThreeDeeMushroom
