local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"
local Serial = require "actions/Serial"
local Animate = require "actions/Animate"
local MessageBox = require "actions/MessageBox"
local Action = require "actions/Action"
local SceneManager = require "scene/SceneManager"

local Transform = require "util/Transform"
local Player = require "object/Player"

local NPC = require "object/NPC"
local Door = class(NPC)

function Door:construct(scene, layer, object)
	self.opensfx = object.properties.opensfx or "door"
	self.locked = object.properties.locked
	self.keyToDoor = object.properties.keyToDoor
	self.flagForDoor = object.properties.flagForDoor
	self.open = false

	NPC.init(self)
	
	self:addSceneHandler("enter")
	self:addInteract(Door.interact)

	if object.properties.onOpen then
		self.onOpen = assert(loadstring(object.properties.onOpen))()
	else
		self.onOpen = function(self) return Action() end
	end
	
	if scene.lastSpawnPoint == self.name then
		scene.player = Player(self.scene, self.layer, table.clone(self.object))
	end
end

function Door:enter()
	if self.sprite then
		self.sprite:setAnimation("closed")
	end
	self.open = false
	self:addInteract(Door.interact)
end

function Door:onCollision(prevState)
	if  self.open and
		self.scene.player:isFacing(self.object.properties.key) and
		not self.scene.sceneMgr.transitioning
	then
		self.scene.player.cinematic = true
		local mapName = "maps/"..tostring(self.object.properties.scene)
		self.scene.sceneMgr:switchScene {
			class = "BasicScene",
			map = self.scene.maps[mapName],
			mapName = mapName,
			maps = self.scene.maps,
			region = self.scene.region,
			images = self.scene.images,
			animations = self.scene.animations,
			audio = self.scene.audio,
			nighttime = self.scene.nighttime,
			hint = self.object.properties.hint,
			spawn_point = self.object.properties.spawn_point,
			enterDelay = self.object.properties.enterDelay,
			spawn_point_offset =
				(self.object.properties.spawn_point_offset_x or
				 self.object.properties.spawn_point_offset_y)
				and Transform(
				    self.object.properties.spawn_point_offset_x or 0,
				    self.object.properties.spawn_point_offset_y or 0
				) or nil
		}
	end
end

function Door:interact()
	if self.locked and
		(self.keyToDoor and not GameState:hasItem(self.keyToDoor)) or
		(self.flagForDoor and not GameState:isFlagSet(self.flagForDoor))
	then
		self:run {
			PlayAudio("sfx", "locked", 1.0, true),
			MessageBox {message = "Locked.", blocking = true},
			Do(function()
				self.scene.player.hidekeyhints[tostring(self)] = nil
			end)
		}
	else
		self:removeInteract(Door.interact)

		local anim = Serial{}
		if self.sprite then
			anim = Serial {
				Animate(self.sprite, "opening"),
				Animate(self.sprite, "open")
			}
		end
		
		self:run {
			Parallel {
				PlayAudio("sfx", self.opensfx, 1.0),
				anim
			},
			self.onOpen(self),
			Do(function()
				self.open = true
			end)
		}
	end
end


return Door
