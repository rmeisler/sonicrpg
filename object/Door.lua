local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local PlayAudio = require "actions/PlayAudio"
local Serial = require "actions/Serial"
local Animate = require "actions/Animate"
local MessageBox = require "actions/MessageBox"
local SceneManager = require "scene/SceneManager"

local Player = require "object/Player"

local NPC = require "object/NPC"
local Door = class(NPC)

function Door:construct(scene, layer, object)
	self.opensfx = object.properties.opensfx or "door"
	self.locked = object.properties.locked
	self.open = false

	NPC.init(self)
	
	self:addSceneHandler("enter")
	self:addInteract(Door.interact)
	
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
	if self.locked then
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
			Do(function()
				self.open = true
			end)
		}
	end
end


return Door
