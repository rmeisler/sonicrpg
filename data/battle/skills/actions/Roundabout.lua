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
	
	local targetSp = target:getSprite()
	if target.mockSprite then
		targetSp.transform.ox = targetSp.w/2
		targetSp.transform.oy = targetSp.h/2
		targetSp.transform.x = targetSp.transform.x + targetSp.w
		targetSp.transform.y = targetSp.transform.y + targetSp.h
	end

	local RunCircle = function(speed, animLag)
		return Serial {
			PlayAudio("sfx", "sonicrunturn", 1.0, true),
			Do(function()
				self.sprite.prevSortOrderY = self.sprite.sortOrderY
				if target:getSprite().sortOrderY then
					self.sprite.sortOrderY = target:getSprite().sortOrderY - 100
				else
					self.sprite.sortOrderY = targetSp.transform.y + targetSp.h*2 - self.sprite.h*2 - 100
				end
				targetSp:setAnimation(target:getIdleAnim())
			end),
			Parallel {
				Ease(self.sprite.transform, "y", targetSp.transform.y + targetSp.h - self.sprite.h*2, 20, "inout"),
				Serial {
					Do(function() self.sprite:setAnimation("juiceupleft") end),
					Wait(animLag),
					Do(function() self.sprite:setAnimation("juiceupright") end),
					Wait(animLag),
					Do(function() self.sprite:setAnimation("juiceright") end)
				},
				Serial {
					Ease(self.sprite.transform, "x", targetSp.transform.x - 110, 20, "inout"),
					Ease(self.sprite.transform, "x", targetSp.transform.x + 100, speed, "inout"),
				}
			},
			
			PlayAudio("sfx", "sonicrunturn", 1.0, true),
			
			Do(function()
				targetSp:setAnimation(target:getBackwardAnim())
			end),
			
			Parallel {
				Serial {
					Ease(self.sprite.transform, "y", targetSp.transform.y + targetSp.h - self.sprite.h, 20, "inout"),
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
					Ease(self.sprite.transform, "x", targetSp.transform.x + 110, 20, "inout"),
					Ease(self.sprite.transform, "x", targetSp.transform.x - 100, speed, "inout"),
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
					dust.sortOrderY = self.sprite.sortOrderY - 100 --self.sprite.transform.y + self.sprite.h*2 - 20
					
					dust.transform.sx = 2
					dust.transform.sy = 2
					
					if self.sprite.selected == "juiceleft" then
						dust.transform.x = dust.transform.x + self.sprite.w
						dust:setAnimation("left")
					elseif self.sprite.selected == "juiceright" then
						dust.transform.x = dust.transform.x - self.sprite.w*2 - 5
						dust:setAnimation("right")
					elseif self.sprite.selected == "juicedownleft" or self.sprite.selected == "juicedownright" then
						dust.transform.x = dust.transform.x + self.sprite.w - dust.w
						dust.transform.y = dust.transform.y - dust.h*2
						dust.transform.sx = 4
						dust.transform.sy = 4
						dust:setAnimation("left")
					elseif self.sprite.selected == "juiceupleft" or self.sprite.selected == "juiceupright" then
						dust.transform.x = dust.transform.x - self.sprite.w*2 - 5 - dust.w
						dust.transform.y = dust.transform.y - dust.h*2
						dust.transform.sx = 4
						dust.transform.sy = 4
						dust:setAnimation("right")
					end
					
					dust.transform.y = dust.transform.y - 10
					
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
			Ease(self.sprite.transform, "x", targetSp.transform.x - 100, 3, "inout"),
			Ease(self.sprite.transform, "y", targetSp.transform.y + targetSp.h - self.sprite.h, 3, "inout"),
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
			
			if target.mockSprite then
				targetSp.transform.ox = 0
				targetSp.transform.oy = 0
				targetSp.transform.x = targetSp.transform.x - targetSp.w
				targetSp.transform.y = targetSp.transform.y - targetSp.h
			end
		end),
		
		target.onConfused and
			target:onConfused() or
			MessageBox {message=target.name.." is confused!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)}
	}
end
