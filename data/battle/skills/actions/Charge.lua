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

return function(self)
	local arrowXform = Transform(self.sprite.transform.x - self.sprite.w/2, self.sprite.transform.y, 4, 4)
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

	local lastXForm = Transform.from(self.sprite.transform)
	return Serial {
		-- Setup temporary keytriggered event
		Do(function() self.sprite:setAnimation("runleft") end),
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
				PlayAudio("sfx", "bang", 1.0, true, false, true),
				Wait(0.1)
			}, 100000),
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

		-- Hurt all opponents we collide with while we run off screen
		Parallel {
			Ease(self.sprite.transform, "x", function()
				return self.sprite.transform.x + math.cos(self.slamArrow.transform.angle - math.pi/2) * 1000
			end, 4, "linear"),
			Ease(self.sprite.transform, "y", function()
				return self.sprite.transform.y + math.sin(self.slamArrow.transform.angle - math.pi/2) * 1000
			end, 4, "linear"),

			Do(function()
				-- If skill user intersects other opponents mid-section, those opponents should take damage along the way
				local targetCx = self.sprite.transform.x
				local targetCy = self.sprite.transform.y
				for _,oppo in pairs(self.scene.opponents) do
					if oppo ~= self and not oppo.hurtBySlam then
						local oppoCx = oppo.sprite.transform.x
						local oppoCy = oppo.sprite.transform.y
						local dx = targetCx - oppoCx
						local dy = targetCy - oppoCy
						local dr = self.sprite.h/2 + oppo.sprite.w/2
						if (dx*dx) + (dy*dy) <= (dr*dr) then
							oppo.hurtBySlam = true
							Executor(self.scene):act(Serial {
								oppo:takeDamage({attack=self.stats.attack*2.5, speed=100, luck=0}, false, oppo.slamKnockbackFn),
								Do(function()
									oppo.sprite:setAnimation("idle")
								end)
							})
						end
					end
				end
			end)
		},
		Wait(3),
		Do(function()
			for _,oppo in pairs(self.scene.opponents) do
				oppo.hurtBySlam = false
			end
			
			self.sprite.transform.x = lastXForm.x + 300
			self.sprite.transform.y = lastXForm.y
		end),

		-- Run from other side of screen back to starting position
		Ease(self.sprite.transform, "x", lastXForm.x, 4, "linear"),
		
		Do(function()
			self.sprite:setAnimation("idle")
			self:endTurn()
		end)
	}
end
