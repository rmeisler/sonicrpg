local Do = require "actions/Do"
local BlockPlayer = require "actions/BlockPlayer"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Action = require "actions/Action"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"

local Transform = require "util/Transform"

local BasicNPC = require "object/BasicNPC"
local NPC = require "object/NPC"

local LaserTrap = class(NPC)

function LaserTrap:construct(scene, layer, object)
	self.ghost = true
	self.alwaysOn = object.properties.alwaysOn
	self.deactivated = object.properties.deactivated

	NPC.init(self)

	self:addHandler("collision", LaserTrap.touch, self)
end

function LaserTrap:postInit()
	self.spawnPointLeft = self.scene.objectLookup[self.object.properties.spawnPointLeft]
	self.spawnPointRight = self.scene.objectLookup[self.object.properties.spawnPointRight]
	
	self.spawnPointLeft.parentTrap = self
	self.spawnPointRight.parentTrap = self
	
	self.laserScale = ((self.spawnPointRight.x - self.spawnPointLeft.x) / 2) / self.scene:getTileWidth()
	
	self.laser1 = BasicNPC(
		self.scene,
		{name = "objects"},
		{
			name = "beamsprite",
			x = self.spawnPointLeft.x + self.spawnPointLeft.object.width/2,
			y = self.spawnPointLeft.y + self.spawnPointLeft.object.height/2,
			width = 32,
			height = 9,
			properties = {nocollision = true, sprite = "art/sprites/botbeam.png"}
		}
	)
	self.laser1.sprite.transform.ox = 0
	self.laser1.sprite.transform.oy = self.laser1.sprite.h/2
	self.laser1.sprite.transform.sx = 0.0
	self.laser1.sprite.transform.sy = 1.0
	self.laser1.sprite.sortOrderY = 99999
	self.scene:addObject(self.laser1)

	self.laser2 = BasicNPC(
		self.scene,
		{name = "objects"},
		{
			name = "beamsprite",
			x = self.spawnPointRight.x + self.spawnPointLeft.object.width/2,
			y = self.spawnPointRight.y + self.spawnPointLeft.object.height/2,
			width = 32,
			height = 9,
			properties = {nocollision = true, sprite = "art/sprites/botbeam.png"}
		}
	)
	self.laser2.sprite.transform.ox = self.laser1.sprite.w
	self.laser2.sprite.transform.oy = self.laser1.sprite.h/2
	self.laser2.sprite.transform.sx = 0.0
	self.laser2.sprite.transform.sy = 1.0
	self.laser2.sprite.sortOrderY = 99999
	self.scene:addObject(self.laser2)
	
	if self.alwaysOn then
		self:lasersOn()
	end
end

function LaserTrap:lasersOn()
	self.laser1:run {
		Ease(self.laser1.sprite.transform, "sx", self.laserScale, 5)
	}
	self.laser2:run {
		Ease(self.laser2.sprite.transform, "sx", self.laserScale, 5)
	}
end

function LaserTrap:update(dt)
	NPC.update(self, dt)
	
	if self.alwaysOn then
		self:shockBots()
	end
end

function LaserTrap:touch(prevState)
	if self.deactivated then
		return
	elseif self.alwaysOn then
		self:shockPlayer()
	elseif prevState == NPC.STATE_IDLE then
	    local player = self.scene.player
        local laser1 = self.laser1
		local laser2 = self.laser2
		
		laser1.x = self.spawnPointLeft.x + self.spawnPointLeft.object.width/2
		laser1.y = self.spawnPointLeft.y + self.spawnPointLeft.object.height/2
		laser1.sprite.transform.ox = 0
		laser1.sprite.transform.oy = laser1.sprite.h/2
		laser1.sprite.transform.sx = 0.0
		laser1.sprite.transform.sy = 1.0

		laser2.x = self.spawnPointRight.x + self.spawnPointLeft.object.width/2
		laser2.y = self.spawnPointRight.y + self.spawnPointLeft.object.height/2
		laser2.sprite.transform.ox = laser1.sprite.w
		laser2.sprite.transform.oy = laser1.sprite.h/2
		laser2.sprite.transform.sx = 0.0
		laser2.sprite.transform.sy = 1.0
		
		laser1:run {
            Ease(laser1.sprite.transform, "sx", self.laserScale, 5),
            Do(function()
                laser1.sprite.transform.ox = laser1.sprite.w
                laser1.x = laser1.x + self.laserScale * self.scene:getTileWidth()
				
				self:shockBots()
                
                if self.state == self.STATE_TOUCHING then
                    self:shockPlayer()
                end
            end),
            Ease(laser1.sprite.transform, "sx", 0, 5)
        }
		
		laser2:run {
            Ease(laser2.sprite.transform, "sx", self.laserScale, 5),
            Do(function()
                laser2.sprite.transform.ox = 0
                laser2.x = laser2.x - self.laserScale * self.scene:getTileWidth()
			end),
			Ease(laser2.sprite.transform, "sx", 0, 5)
		}
	end
end

function LaserTrap:shockBots()
	for _, obj in pairs(self.scene.map.objects) do
		if obj.isBot and
		   not obj:isRemoved() and
		   obj:isTouching(self.x, self.y, self.object.width, self.object.height)
		then
			obj:run(Parallel {
				Serial {
					Do(function()
						obj.sprite:setAnimation("hurtdown")
					end),
					PlayAudio("sfx", "shocked", 1.0, true),
					Repeat(Serial {
						Do(function()
							obj.sprite:setInvertedColor()
						end),
						Wait(0.1),
						Do(function()
							obj.sprite:removeInvertedColor()
						end),
						Wait(0.1),
					}, 3),
				},
				Serial {
					Ease(obj, "y", obj.y - 100, 8, "linear"),
					PlayAudio("sfx", "oppdeath", 1.0, true),
					Parallel {
						Ease(obj.sprite.color, 1, 512, 8, "linear"),
						Ease(obj.sprite.color, 4, 0, 8, "linear"),
					},
					Do(function()
						obj:remove()
					end)
				}
			})
		end
	end
end

function LaserTrap:shockPlayer()
	local player = self.scene.player
	player:run(Parallel {
		BlockPlayer {
			Do(function()
				player.state = "shock"
			end),
			PlayAudio("sfx", "shocked", 1.0, true),
			Repeat(Serial {
				Do(function()
					player.sprite:setInvertedColor()
				end),
				Wait(0.1),
				Do(function()
					player.sprite:removeInvertedColor()
				end),
				Wait(0.1),
			}, 3),
		},
		Serial {
			Ease(player, "y", player.y - 100, 8, "linear"),
			Do(function()
				player.state = "idledown"
			end)
		}
	})
end


return LaserTrap
