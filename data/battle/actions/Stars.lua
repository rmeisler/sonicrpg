local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Ease = require "actions/Ease"
local Wait = require "actions/Wait"
local Do = require "actions/Do"
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"

return function(self, target)
	local starCount = 0
	return Repeat(Serial {
		Wait(0.05),
		Do(function()
			local targetXform = target.sprite.transform
			local star = SpriteNode(
				target.scene,
				Transform(targetXform.x + (starCount % 2 == 0 and -16 or 16),
				          targetXform.y, 0.5, 0.5),
				{0,0,0,0},
				"star",
				nil,
				nil,
				"ui"
			)
			star.transform.ox = star.w/2
			star.transform.oy = star.h/2
			local randomsize = 1.2 - 0.2 * starCount
			local starColors = {
				{0,255,255,0},
				{255,0,0,0},
				{0,255,0,0},
				{255,255,0,0},
				{0,0,255,0},
			}
			Executor(target.scene):act(Parallel {
				Ease(star.color, 4, 255, 9),
				Ease(star.color, 1, starColors[starCount + 1][1], 3),
				Ease(star.color, 2, starColors[starCount + 1][2], 3),
				Ease(star.color, 3, starColors[starCount + 1][3], 3),
				Ease(star.transform, "sx", randomsize, 2, "inout"),
				Ease(star.transform, "sy", randomsize, 2, "inout"),
				Ease(star.transform, "angle", (starCount % 2 == 0 and -math.pi/3 or math.pi/3), 2),
				Ease(star.transform, "x", targetXform.x + (starCount % 2 == 0 and -90 or 90), 2, "inout"),
				Serial {
					Ease(star.transform, "y", targetXform.y - target.sprite.h*0.8, 3, "inout"),
					Parallel {
						Ease(star.transform, "y", targetXform.y + target.sprite.h/2, 2, "quad"),
						Ease(star.color, 4, 0, 2)
					},
					Do(function()
						star:remove()
					end)
				},
			})
			
			starCount = starCount + 1
		end)
	}, 5)
end