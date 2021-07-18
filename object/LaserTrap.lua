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

	NPC.init(self)

	self:addHandler("collision", LaserTrap.touch, self)
end

function LaserTrap:postInit()
	self.spawnPointLeft = self.scene.objectLookup[self.object.properties.spawnPointLeft]
	self.spawnPointRight = self.scene.objectLookup[self.object.properties.spawnPointRight]
end

function LaserTrap:touch(prevState)
	if prevState == NPC.STATE_IDLE then
	    local player = self.scene.player
		local laser1 = BasicNPC(
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
        laser1.sprite.transform.ox = 0
        laser1.sprite.transform.oy = laser1.sprite.h/2
		laser1.sprite.transform.sy = 1.0
        laser1.sprite.sortOrderY = 99999
        self.scene:addObject(laser1)
		
		local laser2 = BasicNPC(
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
        laser2.sprite.transform.ox = laser1.sprite.w
        laser2.sprite.transform.oy = laser1.sprite.h/2
		laser2.sprite.transform.sy = 1.0
        laser2.sprite.sortOrderY = 99999
        self.scene:addObject(laser2)

        laser1:run {
            Ease(laser1.sprite.transform, "sx", 9, 5),
            Do(function()
                laser1.sprite.transform.ox = laser1.sprite.w
                laser1.x = laser1.x + 9*32
                
                if self.state == self.STATE_TOUCHING then
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
            end),
            Ease(laser1.sprite.transform, "sx", 0, 5)
        }
		
		laser2:run {
            Ease(laser2.sprite.transform, "sx", 9, 5),
            Do(function()
                laser2.sprite.transform.ox = 0
                laser2.x = laser2.x - 9*32
			end),
			Ease(laser2.sprite.transform, "sx", 0, 5)
		}
	end
end


return LaserTrap
