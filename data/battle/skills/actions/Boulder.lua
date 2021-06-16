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

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

return function(self, target)
	local boulderSp = SpriteNode(self.scene, Transform(), nil, "boulder", nil, nil, "ui")
	boulderSp.transform.ox = boulderSp.w/2
	boulderSp.transform.oy = boulderSp.h
	boulderSp.transform.x = self.sprite.transform.x + 20
	boulderSp.transform.y = -200
	boulderSp.transform.sx = 2
	boulderSp.transform.sy = 2
	
	-- Potentially hit all enemies
	

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
					Ease(boulderSp.transform, "x", self.sprite.transform.x - self.sprite.w, 5, "quad"),
					Ease(boulderSp.transform, "y", self.sprite.transform.y - self.sprite.h*3, 5, "quad")
				},
				Parallel {
					Ease(boulderSp.transform, "x", self.sprite.transform.x - 200, 5, "quad"),
					Ease(boulderSp.transform, "y", self.sprite.transform.y - self.sprite.h*2, 5, "quad")
				}
			}
		}
	}
end
