local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"
local Spawn = require "actions/Spawn"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local BounceStep = function(startPoint, endPoint, boulder)
	local cr = math.abs(startPoint.x - endPoint.x)/2
	local cx,cy
	if startPoint.x > endPoint.x then
		cx = startPoint.x - (startPoint.x - endPoint.x)/2
	else
		cx = startPoint.x + (endPoint.x - startPoint.x)/2
	end
	if startPoint.y > endPoint.y then
		cy = startPoint.y - (startPoint.y - endPoint.y)/2
	else
		cy = startPoint.y + (endPoint.y - startPoint.y)/2
	end
	
	local dx = boulder.transform.x - cx
	local dy = boulder.transform.y - cy
	local radians = math.atan(dy / dx)
	
	boulder.transform.x = cx + (math.cos(radians) * cr)
	boulder.transform.y = cy + (math.sin(radians) * cr)
end

return function(self, target)
	local boulderSp = SpriteNode(self.scene, Transform(), nil, "boulder", nil, nil, "ui")
	boulderSp.transform.ox = boulderSp.w/2
	boulderSp.transform.oy = boulderSp.h
	boulderSp.transform.x = self.sprite.transform.x + 20
	boulderSp.transform.y = -200
	boulderSp.transform.sx = 2
	boulderSp.transform.sy = 2
	
	-- Potentially hit all enemies
	--[[local landActions = {}
	for index,p in pairs(self.scene.opponents) do
		local pSp = p:getSprite()
		table.insert(
			landActions,
			Serial {
				Parallel {
					Ease(boulderSp.transform, "x", pSp.transform.x, 5, "quad"),
					Ease(boulderSp.transform, "y", pSp.transform.y + pSp.h*2, 5, "quad")
				},
				Spawn(
					p:takeDamage({attack = self.stats.attack*0.7, speed = self.stats.speed, luck = self.stats.luck})
				),
				Ease(boulderSp.transform, "y", pSp.transform.y + pSp.h*2 - 300 + (index*50), 5, "quad")
			}
		)
	end]]

	return Serial {
		Ease(boulderSp.transform, "y", self.sprite.transform.y - 20, 2, "quad"),
		Animate(self.sprite, "hold"),
		Wait(2),
		Parallel {
			Animate(self.sprite, "throw"),
			Serial {
				Parallel {
					Ease(boulderSp.transform, "x", self.sprite.transform.x, 5, "quad"),
					Ease(boulderSp.transform, "y", self.sprite.transform.y - self.sprite.h, 5, "quad")
				},
				Parallel {
					Ease(boulderSp.transform, "x", self.sprite.transform.x - 200, 5, "quad"),
					Ease(boulderSp.transform, "y", self.sprite.transform.y - self.sprite.h*3, 5, "quad")
				},
				Parallel {
					Ease(boulderSp.transform, "x", self.sprite.transform.x - 400, 5, "quad"),
					Ease(boulderSp.transform, "y", self.sprite.transform.y - self.sprite.h*2, 5, "quad")
				},
				--Serial(landActions)
			}
		}
	}
end
