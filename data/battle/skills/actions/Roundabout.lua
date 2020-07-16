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
	return Serial {
		Spawn(
			While(
				function()
					return self.sprite.selected ~= "idle"
				end,
				Repeat(Do(function()
					if not self.dustTime or self.dustTime > 0.01 then
						self.dustTime = 0
					elseif self.dustTime < 0.01 then
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
					dust.sortOrderY = self.sprite.sortOrderY
					
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
		Do(function()
			self.scene.audio:playSfx("sonicrunturn", nil, true)
			self.sprite.prevSortOrderY = self.sprite.sortOrderY
			self.sprite.sortOrderY = 0
		end),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + 100, 3, "inout"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h*2, 9, "inout"),
			
			Serial {
				Do(function() self.sprite:setAnimation("juiceupleft") end),
				Wait(0.08),
				Do(function() self.sprite:setAnimation("juiceupright") end),
				Wait(0.08),
				Do(function() self.sprite:setAnimation("juiceright") end)
			}
		},
		Do(function()
			self.scene.audio:playSfx("sonicrunturn", nil, true)
			target.sprite:setAnimation("backward")
		end),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x - 100, 3, "inout"),
			Serial {
				Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 9, "inout"),
				Do(function()
					self.sprite.sortOrderY = self.sprite.prevSortOrderY
				end)
			},
			
			Serial {
				Do(function() self.sprite:setAnimation("juicedownright") end),
				Wait(0.08),
				Do(function() self.sprite:setAnimation("juicedownleft") end),
				Wait(0.08),
				Do(function() self.sprite:setAnimation("juiceleft") end)
			}
		},
		
		-- Round 2
		Do(function()
			self.scene.audio:playSfx("sonicrunturn", nil, true)
			target.sprite:setAnimation("idle")
			self.sprite.prevSortOrderY = self.sprite.sortOrderY
			self.sprite.sortOrderY = 0
		end),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + 100, 5, "inout"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h*2, 15, "inout"),
			
			Serial {
				Do(function() self.sprite:setAnimation("juiceupleft") end),
				Wait(0.05),
				Do(function() self.sprite:setAnimation("juiceupright") end),
				Wait(0.05),
				Do(function() self.sprite:setAnimation("juiceright") end)
			}
		},
		Do(function()
			self.scene.audio:playSfx("sonicrunturn", nil, true)
			target.sprite:setAnimation("backward")
		end),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x - 100, 5, "inout"),
			Serial {
				Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 15, "inout"),
				Do(function()
					self.sprite.sortOrderY = self.sprite.prevSortOrderY
				end)
			},
			
			Serial {
				Do(function() self.sprite:setAnimation("juicedownright") end),
				Wait(0.05),
				Do(function() self.sprite:setAnimation("juicedownleft") end),
				Wait(0.05),
				Do(function() self.sprite:setAnimation("juiceleft") end)
			}
		},
		
		-- Round 3
		Do(function()
			self.scene.audio:playSfx("sonicrunturn", nil, true)
			target.sprite:setAnimation("idle")
			self.sprite.prevSortOrderY = self.sprite.sortOrderY
			self.sprite.sortOrderY = 0
		end),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + 100, 5, "inout"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h*2, 15, "inout"),
			
			Serial {
				Do(function() self.sprite:setAnimation("juiceupleft") end),
				Wait(0.05),
				Do(function() self.sprite:setAnimation("juiceupright") end),
				Wait(0.05),
				Do(function() self.sprite:setAnimation("juiceright") end)
			}
		},
		Do(function()
			self.scene.audio:playSfx("sonicrunturn", nil, true)
			target.sprite:setAnimation("backward")
		end),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x - 100, 5, "inout"),
			
			Serial {
				Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 15, "inout"),
				Do(function()
					self.sprite.sortOrderY = self.sprite.prevSortOrderY
				end)
			},
			
			Serial {
				Do(function() self.sprite:setAnimation("juicedownright") end),
				Wait(0.05),
				Do(function() self.sprite:setAnimation("juicedownleft") end),
				Wait(0.05),
				Do(function() self.sprite:setAnimation("juiceleft") end)
			}
		},
		
		-- Round 4-9
		Repeat(
			Serial {
				Do(function()
					self.scene.audio:playSfx("sonicrunturn", nil, true)
					target.sprite:setAnimation("idle")
					self.sprite.prevSortOrderY = self.sprite.sortOrderY
					self.sprite.sortOrderY = 0
				end),
				Parallel {
					Ease(self.sprite.transform, "x", target.sprite.transform.x + 100, 6, "inout"),
					Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h*2, 18, "inout"),
					
					Serial {
						Do(function() self.sprite:setAnimation("juiceupleft") end),
						Wait(0.02),
						Do(function() self.sprite:setAnimation("juiceupright") end),
						Wait(0.02),
						Do(function() self.sprite:setAnimation("juiceright") end)
					}
				},
				Do(function()
					self.scene.audio:playSfx("sonicrunturn", nil, true)
					target.sprite:setAnimation("backward")
				end),
				Parallel {
					Ease(self.sprite.transform, "x", target.sprite.transform.x - 100, 6, "inout"),
					Serial {
						Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 18, "inout"),
						Do(function()
							self.sprite.sortOrderY = self.sprite.prevSortOrderY
						end)
					},
					
					Serial {
						Do(function() self.sprite:setAnimation("juicedownright") end),
						Wait(0.02),
						Do(function() self.sprite:setAnimation("juicedownleft") end),
						Wait(0.02),
						Do(function() self.sprite:setAnimation("juiceleft") end)
					}
				}
			},
			5
		),
		
		Do(function()
			self.sprite:setAnimation("juiceright")
		end),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 5, "inout"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y, 5, "inout")
		},
		Do(function()
			self.sprite:setAnimation("idle")
		end),
		
		-- Bot is confused
		MessageBox {message=target.name.." is confused!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
	}
end
