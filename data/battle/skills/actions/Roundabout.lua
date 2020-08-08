local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"
local Spawn = require "actions/Spawn"
local Action = require "actions/Action"
local While = require "actions/While"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

return function(self, target)
	self.sprite:setAnimation("juiceleft")

	local RunCircle = function(speed, animLag)
		return Serial {
			Do(function()
				self.scene.audio:playSfx("sonicrunturn", nil, true)
				self.sprite.prevSortOrderY = self.sprite.sortOrderY
				self.sprite.sortOrderY = target.sprite.transform.y + target.sprite.h*2 - self.sprite.h*2 - 20
				target.sprite:setAnimation("idle")
			end),
			Parallel {
				Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h*2, 20, "inout"),
				Serial {
					Do(function() self.sprite:setAnimation("juiceupleft") end),
					Wait(animLag),
					Do(function() self.sprite:setAnimation("juiceupright") end),
					Wait(animLag),
					Do(function() self.sprite:setAnimation("juiceright") end)
				},
				Serial {
					Ease(self.sprite.transform, "x", target.sprite.transform.x - 110, 20, "inout"),
					Ease(self.sprite.transform, "x", target.sprite.transform.x + 100, speed, "inout"),
				}
			},
			
			Do(function()
				self.scene.audio:playSfx("sonicrunturn", nil, true)
				target.sprite:setAnimation("backward")
			end),
			
			Parallel {
				Serial {
					Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 20, "inout"),
					Do(function()
						self.sprite.sortOrderY = self.sprite.prevSortOrderY
					end)
				},
				Serial {
					Do(function() self.sprite:setAnimation("juicedownright") end),
					Wait(animLag),
					Do(function() self.sprite:setAnimation("juicedownleft") end),
					Wait(animLag),
					Do(function() self.sprite:setAnimation("juiceleft") end)
				},
				Serial {
					Ease(self.sprite.transform, "x", target.sprite.transform.x + 110, 20, "inout"),
					Ease(self.sprite.transform, "x", target.sprite.transform.x - 100, speed, "inout"),
				}
			}
		}
	end

	return Serial {
		Spawn(
			While(
				function()
					return self.sprite.selected ~= "idle"
				end,
				Repeat(Do(function()
					if not self.dustTime or self.dustTime > 0.005 then
						self.dustTime = 0
					elseif self.dustTime < 0.005 then
						self.dustTime = self.dustTime + love.timer.getDelta()
						return
					end
					
					local dust = SpriteNode(
						self.scene,
						Transform(self.sprite.transform.x, self.sprite.transform.y),
						nil,
						"dust",
						nil,
						nil,
						"sprites"
					)
					dust.color[1] = 130
					dust.color[2] = 130
					dust.color[3] = 200
					dust.color[4] = 255
					dust.sortOrderY = self.sprite.sortOrderY --self.sprite.transform.y + self.sprite.h*2 - 20
					
					if self.sprite.selected == "juiceleft" or self.sprite.selected == "juicedownleft" then
						dust.transform.x = dust.transform.x + self.sprite.w
						dust:setAnimation("left")
					elseif self.sprite.selected == "juiceright" or self.sprite.selected == "juiceupright" then
						dust.transform.x = dust.transform.x - self.sprite.w*2 - 5
						dust:setAnimation("right")
					end
					
					dust.transform.y = dust.transform.y - 10
					dust.transform.sx = 2
					dust.transform.sy = 2
					
					dust.animations[dust.selected].callback = function()
						local ref = dust
						ref:remove()
					end
					
					self.dustTime = self.dustTime + love.timer.getDelta()
				end)),
				Action()
			)
		),
	
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x - 100, 3, "inout"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 3, "inout"),
		},
		
		-- Round 1
		RunCircle(3, 0.03),
		
		-- Round 2-3
		Repeat(RunCircle(5, 0.03), 2),
		
		-- Round 4-8
		Repeat(RunCircle(8, 0.03), 5),

		Do(function()
			self.sprite:setAnimation("juiceright")
		end),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 5, "inout"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y, 5, "inout")
		},
		Do(function()
			self.sprite:setAnimation("idle")
			
			target.confused = true
		end),
		
		-- Bot is confused
		MessageBox {message=target.name.." is confused!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
	}
end
