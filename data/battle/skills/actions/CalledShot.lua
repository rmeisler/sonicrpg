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
local YieldUntil = require "actions/YieldUntil"

local Stars = require "data/battle/actions/Stars"
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

local TimedReflect = function(self)
	return PressX(
		self,
		self,
		Serial {
			PlayAudio("sfx", "gotit", 1.0, true),

			-- Note that puck should reflect toward next enemy
			Do(function()
				self.reflectPuck = true
			end)
		},
		Do(function()
			self.reflectPuck = false
		end)
	)
end

return function(self)
	local arrowXform = Transform(self.sprite.transform.x - self.sprite.w, self.sprite.transform.y + self.sprite.h/2 + 8, 4, 4)
	arrowXform.ox = 16
	arrowXform.oy = 32
	arrowXform.angle = -math.pi/2
	self.slamArrow = SpriteNode(
		self.scene,
		arrowXform,
		{255,255,255,0},
		"arrow",
		nil,
		nil,
		"ui"
	)
	self.slamArrow:setAnimation("point")
	self.slamArrowSpeed = math.pi/50
	self.slamArrowEnd = false

	local puckXform = Transform(self.sprite.transform.x - self.sprite.w, self.sprite.transform.y - self.sprite.h*2, 1, 1)
	puckXform.ox = 8
	puckXform.oy = 8
	self.puck = SpriteNode(
		self.scene,
		puckXform,
		nil,
		"puck",
		nil,
		nil,
		"ui"
	)

	return Serial {
		Animate(self.sprite, "slap_idle", true),
		Wait(0.2),

		-- Puck falls from sky, bounces off ground
		Ease(self.puck.transform, "y", self.sprite.transform.y + self.sprite.h/2 + 8, 8, "quad"),
		Ease(self.puck.transform, "y", function() return self.puck.transform.y - 30 end, 10, "quad"),
		Ease(self.puck.transform, "y", function() return self.puck.transform.y + 30 end, 10, "quad"),

		-- Arrow fade in
		Ease(self.slamArrow.color, 4, 255, 1),

		-- Setup temporary keytriggered event
		Do(function()
			self.scene:addHandler("update", ArrowUpdate, self)
			self.scene:addHandler("keytriggered", ArrowKey, self)
			self.scene:focus("keytriggered", self) -- HACK, focus past skills + battle menu
			self.scene:focus("keytriggered", self)
			self.scene:focus("keytriggered", self)
		end),

		YieldUntil(self, "slamArrowEnd"),

		-- Remove temporary keytriggered event
		Do(function()
			self.scene:removeHandler("update", ArrowUpdate, self)
			self.scene:removeHandler("keytriggered", ArrowKey, self)
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.scene:unfocus("keytriggered")
			self.slamArrow:remove()
		end),

		Animate(self.sprite, "slap", true),
		
		Wait(0.2),
		PlayAudio("sfx", "poptop", 1.0, true),

		-- Puck flies toward opponent
		Parallel {
			Ease(self.puck.transform, "x", function()
				return self.puck.transform.x + math.cos(self.slamArrow.transform.angle - math.pi/2) * 800
			end, 3, "linear"),
			Ease(self.puck.transform, "y", function()
				return self.puck.transform.y + math.sin(self.slamArrow.transform.angle - math.pi/2) * 800
			end, 3, "linear"),

			TimedReflect(self),

			Do(function()
				-- If puck intersects other opponents mid-section, those opponents should take damage along the way
				local targetCx = self.puck.transform.x
				local targetCy = self.puck.transform.y
				local radius = 32
				for _,oppo in pairs(self.scene.opponents) do
					if not oppo.hurtBySlam then
						local oppoCx = oppo.sprite.transform.x
						local oppoCy = oppo.sprite.transform.y
						local dx = targetCx - oppoCx
						local dy = targetCy - oppoCy
						local dr = self.puck.w/2 + oppo.sprite.w/2
						if (dx*dx) + (dy*dy) <= (dr*dr) then
							oppo.hurtBySlam = true
							Executor(self.scene):act(Serial {
								Parallel {
									oppo:takeDamage({attack=self.stats.attack*2, speed=100, luck=0}, false, oppo.slamKnockbackFn),
									self.reflectPuck and Stars(self, oppo) or Action()
								},

								Do(function()
									oppo.sprite:setAnimation("idle")
								end)
							})
						end
					end
				end
			end)
		},
		
		--[[
		IfElse(
			function() return self.reflectPuck end,
			Serial {
				Do(function()
					self.reflectPuck = false
				end),

				Parallel {
					Ease(self.puck.transform, "x", function()
						return self.puck.transform.x + math.cos(self.slamArrow.transform.angle - math.pi/2) * 800
					end, 3, "linear"),
					Ease(self.puck.transform, "y", function()
						return self.puck.transform.y + math.sin(self.slamArrow.transform.angle - math.pi/2) * 800
					end, 3, "linear")
				}
			},
			Do(function() end)
		),]]

		-- Unset hurt by slam
		Do(function()
			for _,oppo in pairs(self.scene.opponents) do
				oppo.hurtBySlam = false
			end
		end),
		
		Animate(self.sprite, "idle"),
		Do(function() self:endTurn() end)
	}
end
