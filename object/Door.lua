local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"
local Serial = require "actions/Serial"
local Animate = require "actions/Animate"
local SceneManager = require "scene/SceneManager"

local Player = require "object/Player"

local NPC = require "object/NPC"
local Door = class(NPC)

function Door:construct(scene, layer, object)
	self.opensfx = object.properties.opensfx or "door"
	self.open = false

	NPC.init(self)
	
	self:addSceneHandler("enter")
	self:addInteract(Door.interact)
	
	if scene.lastSpawnPoint == self.name then
		scene.player = Player(self.scene, self.layer, table.clone(self.object))
	end
end

function Door:enter()
	self.sprite:setAnimation("closed")
	self.open = false
	self:addInteract(Door.interact)
end

function Door:onCollision(prevState)
	if  self.open and
		self.scene.player:isFacing(self.object.properties.key) and
		not self.scene.sceneMgr.transitioning
	then
		self.scene.sceneMgr:pushScene {
			class = "BasicScene",
			map = self.scene.maps["maps/"..tostring(self.object.properties.scene)],
			maps = self.scene.maps,
			images = self.scene.images,
			animations = self.scene.animations,
			audio = self.scene.audio,
			spawn_point = self.object.properties.spawn_point,
			cache = true
		}
	end
end

function Door:interact()
	self:removeInteract(Door.interact)

    self:run {
		Parallel {
			PlayAudio("sfx", self.opensfx, 1.0),
			Serial {
				Animate(self.sprite, "opening"),
				Animate(self.sprite, "open")
			}
		},
		Do(function()
			self.open = true
		end)
	}
end


return Door
