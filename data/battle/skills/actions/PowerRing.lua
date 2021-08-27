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
local Telegraph = require "data/monsters/actions/Telegraph"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local RunCircle = function(self, speed, animLag)
	return Serial {
		PlayAudio("sfx", "sonicrunturn", 1.0, true),
		Do(function()
			self.sprite.sortOrderY = 0
		end),
		Parallel {
			Serial {
				Ease(self.sprite.transform, "y", 200, speed, "inout"),
				Ease(self.sprite.transform, "y", 220, speed*2, "inout")
			},
			Serial {
				Do(function() self.sprite:setAnimation("juiceupleft") end),
				Wait(animLag),
				Do(function() self.sprite:setAnimation("juiceupright") end),
				Wait(animLag),
				Do(function() self.sprite:setAnimation("ring_runright") end)
			},
			Serial {
				Ease(self.sprite.transform, "x", 35, speed*2, "inout"),
				Ease(self.sprite.transform, "x", 375, speed, "inout"),
			}
		},
		
		PlayAudio("sfx", "sonicrunturn", 1.0, true),
		
		Parallel {
			Serial {
				Ease(self.sprite.transform, "y", 390, speed, "inout"),
				Do(function()
					self.sprite.sortOrderY = 900
				end),
				Ease(self.sprite.transform, "y", 370, speed*2, "inout"),
			},
			Serial {
				Do(function() self.sprite:setAnimation("juicedownright") end),
				Wait(animLag),
				Do(function() self.sprite:setAnimation("juicedownleft") end),
				Wait(animLag),
				Do(function() self.sprite:setAnimation("ring_runleft") end)
			},
			Serial {
				Ease(self.sprite.transform, "x", 385, speed*2, "inout"),
				Ease(self.sprite.transform, "x", 45, speed, "inout"),
			}
		}
	}
end

local Spin = function(target, speed, iterations)
	return Repeat(Serial {
		Parallel {
			Serial {
				Ease(target.sprite.transform, "x", 160, speed, "linear"),
				Ease(target.sprite.transform, "x", 300, speed-1, "linear"),
				Ease(target.sprite.transform, "x", 385, speed, "linear"),
			},
			Serial {
				Ease(target.sprite.transform, "y", 160, speed, "linear"),
				Ease(target.sprite.transform, "y", 100, speed-1, "linear"),
				Ease(target.sprite.transform, "y", 160, speed, "linear")
			}
		},
		Parallel {
			Serial {
				Ease(target.sprite.transform, "x", 300, speed, "linear"),
				Ease(target.sprite.transform, "x", 160, speed-1, "linear"),
				Ease(target.sprite.transform, "x", 35,  speed, "linear"),
			},
			Serial {
				Ease(target.sprite.transform, "y", 300, speed, "linear"),
				Ease(target.sprite.transform, "y", 390, speed-1, "linear"),
				Ease(target.sprite.transform, "y", 300, speed, "linear")
			}
		}
	}, iterations)
end

local PickedUp = function(target, iterations)
	target.origTransform = Transform.from(target.sprite.transform)
	return Serial {
		Wait(0.2),
		Do(function()
			target.sprite:setAnimation("hurt")
			target.sprite.sortOrderY = 99999
		end),
		Repeat(Serial {
			Ease(target.sprite.transform, "y", function() return target.sprite.transform.y - 2 end, 20),
			Ease(target.sprite.transform, "y", function() return target.sprite.transform.y + 2 end, 20)
		}, iterations),
		Do(function()
			target.sprite:trySetAnimation("hurtdown")
		end),
		Spin(target, 12, 3),
		Spin(target, 24, 14),
		Parallel {
			Ease(target.sprite.transform, "angle", math.pi, 2),
			Ease(target.sprite.transform, "sx", 50, 2),
			Ease(target.sprite.transform, "sy", 50, 2),
			Ease(target.sprite.color, 4, 0, 2),
		},
		Do(function()
			target.hp = 0
			target.state = target.STATE_DEAD
		end)
	}
end

return function(self, targets)
	local ringbeamActions = {}
	for index=1,12 do
		local sprite = SpriteNode(self.scene, Transform.from(self.sprite.transform), nil, "ringbeam", nil, nil, "ui")
		sprite.transform.angle = index * math.pi/6
		sprite.transform.x = sprite.transform.x - 28
		sprite.transform.y = sprite.transform.y - 12
		sprite.transform.sy = 0
		sprite.transform.ox = -5
		sprite.transform.oy = 32
		sprite.color[4] = 0
		table.insert(
			ringbeamActions,
			Serial {
				Wait((index % 3) / 3),
				
				Parallel {
					Ease(sprite.transform, "sy", (index % 3 == 0) and 3 or 1, 2),
					
					Repeat(Serial {
						Ease(sprite.color, 4, 125, 20),
						Ease(sprite.color, 4, 100, 20)
					}, 20 - 6 * (index % 3))
				},
				Ease(sprite.color, 4, 255, 3),
				Ease(sprite.color, 4, 0, 3),
				Do(function()
					sprite:remove()
				end)
			}
		)
	end
	
	local action
	if not GameState:hasItem("Power Ring") then
		action = Serial {
			Animate(self.sprite, "noring_idle"),
			Telegraph(self, "No Power Ring in inventory...", {255,255,255,50}),
			Do(function()
				self.sprite:setAnimation("idle")
			end)
		}
	else
		GameState:useItem(GameState:getItem("Power Ring"))
		local startingLocationX = self.sprite.transform.x
		local startingLocationY = self.sprite.transform.y
		
		local powerring = SpriteNode(self.scene, Transform(0,0,2,2), {255,255,255,0}, "powerring", nil, nil, "sprites")
		local tornadoSprites = {
			SpriteNode(self.scene, Transform(35, 200, 2, 3), {255,255,255,0}, "tornado", nil, nil, "behind"),
			SpriteNode(self.scene, Transform(35, 200, 2, 3), {255,255,255,0}, "tornado", nil, nil, "infront"),
			SpriteNode(self.scene, Transform(35, 70, 2, 3),  {255,255,255,0}, "tornado", nil, nil, "behind"),
			SpriteNode(self.scene, Transform(35, 70, 2, 3),  {255,255,255,0}, "tornado", nil, nil, "infront")
		}
		tornadoSprites[1]:setAnimation("top_ground")
		tornadoSprites[2]:setAnimation("bot_ground")
		tornadoSprites[3]:setAnimation("top_air")
		tornadoSprites[4]:setAnimation("bot_air")
		
		local pickupActions = {}
		for index, target in pairs(targets) do
			table.insert(
				pickupActions,
				Spawn(PickedUp(target, 20 + index*3))
			)
		end
		
		action = Serial {
			PlayAudio("music", "sonicring", 1.0, true),
			Animate(self.sprite, "foundring_backpack"),
			Do(function() self.sprite:setGlow({255,255,0,255},2) end),
			PlayAudio("sfx", "usering", 1.0, true),
			Parallel {
				Serial {
					Animate(self.sprite, "liftring_idle", true),
					Wait(0.5),
					Parallel(ringbeamActions)
				},
				Ease(self.sprite, "glowSize", 6, 2),
				Ease(self.sprite.color, 1, 500, 2),
				Ease(self.sprite.color, 2, 500, 2),
			},
			Parallel {
				Ease(self.sprite.glowColor, 4, 0, 5, "quad"),
				Ease(self.sprite, "glowSize", 2, 5, "quad"),
				Ease(self.sprite.color, 1, 255, 5, "quad"),
				Ease(self.sprite.color, 2, 255, 5, "quad"),
			},
			Do(function() self.sprite:removeGlow() end),
			Animate(self.sprite, "liftring"),
			Parallel {
				MessageBox {message="Sonic: Gotta juice and cut it loose!", closeAction=Wait(0.7)},
				Serial {
					Do(function()
						powerring.transform.x = self.sprite.transform.x - powerring.w - 40
						powerring.transform.y = self.sprite.transform.y - powerring.h - 12
						powerring.color[4] = 255
					end),
					Animate(self.sprite, "ring_chargerun1"),
					Do(function()
						self.sprite:setAnimation("ring_chargerun2")
					end),
					Wait(0.4),
					PlayAudio("sfx", "sonicrun", 1.0, true),
					Wait(0.4)
				}
			},
			Do(function()
				powerring:remove()
			end),
			Do(function()
				self.sprite:setAnimation("ring_runleft")
			end),
			Wait(0.05),
			Spawn(Serial {
				Wait(0.7),
				Parallel(pickupActions),
				Parallel {
					Ease(tornadoSprites[1].color, 4, 200, 5),
					Ease(tornadoSprites[2].color, 4, 200, 5)
				},
				Repeat(Serial {
					Parallel {
						Ease(tornadoSprites[1].color, 4, 100, 5),
						Ease(tornadoSprites[2].color, 4, 100, 5)
					},
					Parallel {
						Ease(tornadoSprites[1].color, 4, 200, 5),
						Ease(tornadoSprites[2].color, 4, 200, 5)
					}
				},20),
				Parallel {
					Ease(tornadoSprites[1].color, 4, 0, 1),
					Ease(tornadoSprites[2].color, 4, 0, 1)
				},
				Do(function()
					tornadoSprites[1]:remove()
					tornadoSprites[2]:remove()
				end)
			}),
			
			Spawn(Serial {
				Wait(2),
				Parallel {
					Ease(tornadoSprites[3].color, 4, 200, 5),
					Ease(tornadoSprites[4].color, 4, 200, 5)
				},
				Repeat(Serial {
					Parallel {
						Ease(tornadoSprites[3].color, 4, 100, 5),
						Ease(tornadoSprites[4].color, 4, 100, 5)
					},
					Parallel {
						Ease(tornadoSprites[3].color, 4, 200, 5),
						Ease(tornadoSprites[4].color, 4, 200, 5)
					}
				},20),
				Parallel {
					Ease(tornadoSprites[3].color, 4, 0, 1),
					Ease(tornadoSprites[4].color, 4, 0, 1)
				},
				Do(function()
					tornadoSprites[3]:remove()
					tornadoSprites[4]:remove()
				end)
			}),
			
			Parallel {
				
				Repeat(Do(function()
					if not self.dustTime or self.dustTime > 0.002 then
						self.dustTime = 0
					elseif self.dustTime < 0.002 then
						self.dustTime = self.dustTime + love.timer.getDelta()
						return
					end
					
					local dust = SpriteNode(
						self.scene,
						Transform(self.sprite.transform.x, self.sprite.transform.y),
						nil,
						"flametrail",
						nil,
						nil,
						"behind"
					)
					dust.transform.sx = 2
					dust.transform.sy = 2
					
					if self.sprite.selected == "ring_runleft" then
						dust.transform.x = dust.transform.x + self.sprite.w
						dust:setAnimation("left")
					elseif self.sprite.selected == "ring_runright" then
						dust:setAnimation("right")
						dust.transform.sx = -2
					end
					
					dust.transform.y = dust.transform.y - 10
					
					dust:onAnimationComplete(function()
						local ref = dust
						if ref then
							ref:remove()
						end
					end)
					
					self.dustTime = self.dustTime + love.timer.getDelta()
				end), 15),
				
				Serial {
					Ease(self.sprite.transform, "y", 350, 5, "inout"),
					Do(function()
						self.sprite.sortOrderY = 9999
					end),
					Ease(self.sprite.transform, "y", 330, 10, "inout"),
				},
				Serial {
					Ease(self.sprite.transform, "x", 385, 10, "inout"),
					Ease(self.sprite.transform, "x", 45, 5, "inout")
				}
			},
			
			Repeat(RunCircle(self, 10, 0.01), 3),
			Repeat(RunCircle(self, 20, 0.01), 40),
			
			Do(function()
				self.sprite:setAnimation("ring_runright")
			end),
			Parallel {
				Ease(self.sprite.transform, "x", startingLocationX, 3),
				Ease(self.sprite.transform, "y", startingLocationY, 3),
			},
			Do(function()
				self.sprite:setAnimation("idle")
				self.sprite.sortOrderY = nil
			end),
			Wait(2.5)
		}
	end

	return Serial {
		Animate(self.sprite, "fish_backpack"),
		action
	}
end
