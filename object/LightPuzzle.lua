local BlockPlayer = require "actions/BlockPlayer"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Wait = require "actions/Wait"

local NPC = require "object/NPC"

local LightPuzzle = class(NPC)

function LightPuzzle:construct(scene, layer, object)
    self.ghost = true
	self.active = object.properties.active or false
	self.light = object.properties.light
	self.next = object.properties.next
	self.quicksand = object.properties.quicksand

	NPC.init(self)

	self:addHandler("collision", LightPuzzle.touch, self)
end

function LightPuzzle:touch(prevState)
	if self.touched or not self.active then
		return
	end

	self.touched = true

	if self.next then
		local nextObj = self.scene.objectLookup[self.next]

		-- Find map layer
		local lightLayer = self.scene:findLayer(self.light)
		local nextLightLayer = self.scene:findLayer(nextObj.light)

		local dx = lightLayer.offsetx - nextLightLayer.offsetx
		local dy = lightLayer.offsety - nextLightLayer.offsety
		
		lightLayer.properties.active = false
		nextLightLayer.properties.active = false

		self:run(BlockPlayer {
			PlayAudio("sfx", "gotit", 1, true),
			Ease(lightLayer, "opacity", 0, 1, "quad"),
			Parallel {
				Ease(self.scene.camPos, "x", dx, 1.5, "linear"),
				Ease(self.scene.camPos, "y", dy, 1.5, "linear")
			},
			Ease(nextLightLayer, "opacity", 0.5, 1, "quad"),
			Wait(0.5),
			Parallel {
				Ease(self.scene.camPos, "x", 0, 1.5, "linear"),
				Ease(self.scene.camPos, "y", 0, 1.5, "linear")
			},
			Do(function()
				nextLightLayer.properties.active = true
				nextObj.active = true
				self:permanentRemove()
			end)
		})
	else
		local quicksandObj = self.scene.objectLookup[self.quicksand]
		local quicksandImageObj = self.scene.objectLookup[quicksandObj.image]
		
		print("completed puzzle "..tostring(quicksandObj.object.name))

		-- Find map layer
		local lightLayer = self.scene:findLayer(self.light)

		local dx = self.scene.player.x - quicksandObj.x - quicksandImageObj.sprite.w
		local dy = self.scene.player.y - quicksandObj.y + quicksandImageObj.sprite.h

		lightLayer.properties.active = false

		self:run(BlockPlayer {
			PlayAudio("sfx", "gotit", 1, true),
			Ease(lightLayer, "opacity", 0, 1, "quad"),
			Parallel {
				Ease(self.scene.camPos, "x", dx, 1.5, "linear"),
				Ease(self.scene.camPos, "y", dy, 1.5, "linear")
			},
			Ease(quicksandImageObj.sprite.color, 4, 255, 1, "quad"),
			Do(function()
				quicksandObj.active = true
			end),
			Wait(0.5),
			Parallel {
				Ease(self.scene.camPos, "x", 0, 1.5, "linear"),
				Ease(self.scene.camPos, "y", 0, 1.5, "linear")
			},
			Do(function()
				self:permanentRemove()
			end)
		})
	end
end

return LightPuzzle
