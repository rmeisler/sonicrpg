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
local While = require "actions/While"
local Action = require "actions/Action"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local LeapBackward = function(self, target)
	local targetSp = target.sprite
	return Serial {
		-- Bounce off target
		Parallel {
			Ease(self.sprite.transform, "y", targetSp.transform.y - self.sprite.h*2.5, 4, "linear"),
			Ease(self.sprite.transform, "x", targetSp.transform.x + self.sprite.w*2, 4, "linear"),
		},
		Parallel {
			Ease(self.sprite.transform, "y", targetSp.transform.y + targetSp.h - self.sprite.h, 4, "linear"),
			Ease(self.sprite.transform, "x", targetSp.transform.x + self.sprite.w*3, 4, "linear")
		},
		
		-- Land on ground
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "idle"),
		Wait(0.2),
		
		-- Leap backward
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 3),
			Serial {
				Ease(self.sprite.transform, "y", self.sprite.transform.y - math.abs(targetSp.transform.y - self.sprite.transform.y) - self.sprite.h, 4),
				Ease(self.sprite.transform, "y", self.sprite.transform.y, 6)
			}
		},
		
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "idle"),
	}
end

local ArrowKey = function(self, key)
	if key == "x" then
		self.slamArrowEnd = true
	end
end

local ArrowUpdate = function(self, dt)
	if love.keyboard.isDown("up") and self.slamArrow.transform.angle < -(math.pi/4) then
		self.slamArrow.transform.angle = self.slamArrow.transform.angle + self.slamArrowSpeed * (dt/0.016)
	elseif love.keyboard.isDown("down") and self.slamArrow.transform.angle > -(3 * (math.pi/4)) then
		self.slamArrow.transform.angle = self.slamArrow.transform.angle - self.slamArrowSpeed * (dt/0.016)
	end
end

return function(self, target)
	local arrowXform = Transform(target.sprite.transform.x - target.sprite.w/2, target.sprite.transform.y, 4, 4)
	arrowXform.ox = 16
	arrowXform.oy = 32
	arrowXform.angle = -math.pi/2
	self.slamArrow = SpriteNode(
		self.scene,
		arrowXform,
		nil,
		"arrow",
		nil,
		nil,
		"ui"
	)
	self.slamArrow:setAnimation("point")
	self.slamArrowSpeed = math.pi/50
	self.slamArrowEnd = false

	local targetSp = target:getSprite()
	return Serial {
		-- Setup temporary keytriggered event
		Animate(self.sprite, "crouch", true),
		Wait(0.2),
		
		Do(function()
			self.scene:addHandler("update", ArrowUpdate, self)
			self.scene:addHandler("keytriggered", ArrowKey, self)
			self.scene:focus("keytriggered", self) -- HACK, focus past skills + battle menu
			self.scene:focus("keytriggered", self)
			self.scene:focus("keytriggered", self)
		end),
		
		While(
			function()
				return not self.slamArrowEnd
			end,
			Repeat(Serial {
				Do(function()
					self.scene.audio:stopSfx()
					self.scene.audio:playSfx("spincharge")
					self.sprite:setAnimation("spincharge")
				end),
				Spawn(Animate(function()
					local xform = Transform.from(self.sprite.transform)
					xform.y = xform.y + self.sprite.h
					local sprite = SpriteNode(self.scene, xform, nil, "spindust", nil, nil, "ui")
					sprite.transform.y = sprite.transform.y - sprite.h*2
					return sprite, true
				end, "idle")),
				Wait(0.2)
			}, 10),
			Do(function()
				
			end)
		),
		
		-- Remove temporary keytriggered event
		Do(function()
			self.scene:removeHandler("update", ArrowUpdate, self)
			self.scene:removeHandler("keytriggered", ArrowKey, self)
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.slamArrow:remove()
		end),

		Animate(self.sprite, "spin", true),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w, 4, "linear"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y, 6, "linear"),
		},

		Parallel {
			target:takeDamage(
				{attack=self.stats.attack, speed=100, luck=0},
				false,
				function(_self, _impact, _direction)
					return Action()
				end
			),
			
			-- Knock opponent into other opponent(s)
			Serial {
				Parallel {
					Ease(target.sprite.transform, "x", function()
						return target.sprite.transform.x + math.cos(self.slamArrow.transform.angle - math.pi/2) * 500
					end, 3, "linear"),
					Ease(target.sprite.transform, "y", function()
						return target.sprite.transform.y + math.sin(self.slamArrow.transform.angle - math.pi/2) * 500
					end, 3, "linear"),
					
					Do(function()
						-- If target intersects other opponents mid-section, those opponents should take damage along the way
						local targetCx = target.sprite.transform.x
						local targetCy = target.sprite.transform.y
						local radius = 32
						for _,oppo in pairs(self.scene.opponents) do
							if oppo ~= target and not oppo.hurtBySlam then
								local oppoCx = oppo.sprite.transform.x
								local oppoCy = oppo.sprite.transform.y
								local dx = targetCx - oppoCx
								local dy = targetCy - oppoCy
								local dr = target.sprite.w/2 + oppo.sprite.w/2
								if (dx*dx) + (dy*dy) <= (dr*dr) then
									oppo.hurtBySlam = true
									Executor(self.scene):act(Serial {
										oppo:takeDamage({attack=self.stats.attack*1.5, speed=100, luck=0}),
										Do(function()
											oppo.sprite:setAnimation("idle")
										end)
									})
								end
							end
						end
					end)
				},
				Wait(2),
				Do(function()
					for _,oppo in pairs(self.scene.opponents) do
						oppo.hurtBySlam = false
					end
					target.sprite.transform.y = target.slot.y + target.sprite.h
				end),
				Ease(target.sprite.transform, "x", target.slot.x + target.sprite.w, 1, "linear")
			},

			LeapBackward(self, target)
		}
	}
end
