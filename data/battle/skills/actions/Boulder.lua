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
local Action = require "actions/Action"
local Repeat = require "actions/Repeat"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

return function(self, targets)
	local boulderSp = SpriteNode(self.scene, Transform(), nil, "boulder", nil, nil, "ui")
	boulderSp.transform.ox = boulderSp.w/2
	boulderSp.transform.oy = boulderSp.h/2
	boulderSp.transform.x = self.sprite.transform.x + 20
	boulderSp.transform.y = -200
	boulderSp.transform.sx = 2
	boulderSp.transform.sy = 2
	
	-- Find lowest y
	local lowesty = 0
	for _,v in pairs(targets) do
		lowesty = math.max(lowesty, v.sprite.transform.y + v.sprite.h - 45)
	end
	
	table.sort(
		targets,
		function(a,b)
			return a.sprite.transform.x > b.sprite.transform.x
		end
	)
	local targetHits = {}
	for _,t in pairs(targets) do
		table.insert(
			targetHits,
			Spawn(
				t:takeDamage(
					{attack = self.stats.attack*0.6, speed = self.stats.speed, luck = self.stats.luck}
				)
			)
		)
	end
	
	-- Potentially hit all enemies
	local firstTarget = targets[1]
	return Serial {
		Ease(boulderSp.transform, "y", self.sprite.transform.y - 45, 2, "quad"),
		Animate(self.sprite, "hold"),
		Spawn(self.scene:screenShake(20, 40)),
		Repeat(Serial {
			Ease(self.sprite.transform, "y", function() return self.sprite.transform.y + 1 end, 20),
			Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - 1 end, 20)
		}, 4),
		Wait(0.5),
		Parallel {
			Animate(self.sprite, "throw"),
			Serial {
				Parallel {
					Ease(boulderSp.transform, "x", firstTarget.sprite.transform.x + firstTarget.sprite.w*3, 5),
					Ease(boulderSp.transform, "y", self.sprite.transform.y - self.sprite.h*2.5, 10)
				},
				Parallel {
					Ease(boulderSp.transform, "angle", -math.pi*2, 0.65),
					Ease(boulderSp.transform, "x", self.sprite.transform.x - 550, 0.65, "log"),
					Serial {
						table.remove(targetHits, 1) or Action(),
						Ease(boulderSp.transform, "y", lowesty, 3, "quad"),
						
						Spawn(self.scene:screenShake(25, 40)),
						Wait(0.03),
						Ease(boulderSp.transform, "y", lowesty - 150, 6, "log"),
						Wait(0.03),
						table.remove(targetHits, 1) or Action(),
						Ease(boulderSp.transform, "y", lowesty, 6, "quad"),
						
						Spawn(self.scene:screenShake(20, 40)),
						Wait(0.02),
						Ease(boulderSp.transform, "y", lowesty - 130, 6, "log"),
						table.remove(targetHits, 1) or Action(),
						Wait(0.02),
						Ease(boulderSp.transform, "y", lowesty, 6, "quad"),
						
						Spawn(self.scene:screenShake(10, 40)),
						table.remove(targetHits, 1) or Action(),
						Wait(0.01),
						Ease(boulderSp.transform, "y", lowesty - 80, 6, "log"),
						Wait(0.01),
						Ease(boulderSp.transform, "y", lowesty, 6, "quad"),
						
						Spawn(self.scene:screenShake(5, 40)),
						Repeat(Serial {
							Ease(boulderSp.transform, "y", function() return boulderSp.transform.y + 1 end, 20),
							Ease(boulderSp.transform, "y", function() return boulderSp.transform.y - 1 end, 20)
						}, 2)
					}
				},
				Ease(boulderSp.color, 4, 0, 2),
				Do(function()
					self.sprite:setAnimation("idle")
					boulderSp:remove()
				end)
			}
		}
	}
end
