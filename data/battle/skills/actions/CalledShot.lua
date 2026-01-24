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
local IfElse = require "actions/IfElse"

local Stars = require "data/battle/actions/Stars"
local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"


local LineIntersectsCircle = function(A, B, C, r)
	-- compute the euclidean distance between A and B
	LAB = math.sqrt((B.x - A.x) * (B.x - A.x) + (B.y-A.y) * (B.y-A.y))

	-- compute the direction vector D from A to B
	Dx = (B.x - A.x) / LAB
	Dy = (B.y - A.y) / LAB

	-- the equation of the line AB is x = Dx*t + Ax, y = Dy*t + Ay with 0 <= t <= LAB.

	-- compute the distance between the points A and E, where
	-- E is the point of AB closest the circle center (Cx, Cy)
	t = Dx * (C.x - A.x) + Dy * (C.y - A.y)

	-- compute the coordinates of the point E
	Ex = t * Dx + A.x
	Ey = t * Dy + A.y

	-- compute the euclidean distance between E and C
	LEC = math.sqrt((Ex - C.x) * (Ex - C.x) + (Ey - C.y) * (Ey - C.y))

	return LEC < r
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
	self.slamArrowSpeed = math.pi/200
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
	
	local lockOnSprite = SpriteNode(self.scene, Transform(0, 0, 1, 1), nil, "target", nil, nil, "ui")
	lockOnSprite.transform.ox = lockOnSprite.w/2
	lockOnSprite.transform.oy = lockOnSprite.h/2
	lockOnSprite.color[4] = 0
	
	local targetSprite = target:getSprite()
	lockOnSprite.transform.x = target.calledShotOverrideXForm and target.calledShotOverrideXForm.x or targetSprite.transform.x + math.random(targetSprite.w) - math.random(targetSprite.w)
	lockOnSprite.transform.y = target.calledShotOverrideXForm and target.calledShotOverrideXForm.y or targetSprite.transform.y + math.random(targetSprite.h) - math.random(targetSprite.h)
	
	self.calledShotLanded = false
	self.calledShotDone = false

	return Serial {
		Animate(self.sprite, "slap_idle", true),
		Wait(0.2),

		-- Puck falls from sky, bounces off ground
		Ease(self.puck.transform, "y", self.sprite.transform.y + self.sprite.h/2 + 8, 8, "quad"),
		Ease(self.puck.transform, "y", function() return self.puck.transform.y - 30 end, 10, "quad"),
		Ease(self.puck.transform, "y", function() return self.puck.transform.y + 30 end, 10, "quad"),
		
		-- Target fade in
		Ease(lockOnSprite.color, 4, 255, 5),
		PlayAudio("sfx", "target", 1.0, true),

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
			self.origPuckXForm = Transform.from(self.puck.transform)
		end),

		Animate(self.sprite, "slap", true),
		
		Wait(0.2),
		PlayAudio("sfx", "poptop", 1.0, true),

		-- Puck sails toward arrow direction
		Parallel {
			Ease(self.puck.transform, "x", function()
				return self.puck.transform.x + math.cos(self.slamArrow.transform.angle - math.pi/2) * 800
			end, 3, "linear"),
			Ease(self.puck.transform, "y", function()
				return self.puck.transform.y + math.sin(self.slamArrow.transform.angle - math.pi/2) * 800
			end, 3, "linear"),

			Serial {
				--Wait(0.2),
				Do(function()
					-- If puck intersects lockOnSprite mid-section, then target takes massive damage, otherwise does nothing
					local lineStartXForm = Transform.from(self.origPuckXForm)
					local lineEndXFrom = Transform(
						lineStartXForm.x + math.cos(self.slamArrow.transform.angle - math.pi/2) * 800,
						lineStartXForm.y + math.sin(self.slamArrow.transform.angle - math.pi/2) * 800
					)
					local circleXForm = Transform.from(lockOnSprite.transform)
					local radius = 10
					if LineIntersectsCircle(lineStartXForm, lineEndXFrom, circleXForm, radius) then
						if not self.calledShotLanded then
							Executor(self.scene):act(Serial {
								PlayAudio("sfx", "levelup", 1, true),
								Parallel {
									Ease(lockOnSprite.color, 4, 0, 5),
									Ease(lockOnSprite.transform, "sx", 2, 5),
									Ease(lockOnSprite.transform, "sy", 2, 5),
									target:takeDamage({attack=self.stats.attack*4, speed=100, luck=0}, false, target.calledShotKnockbackFn or target.slamKnockbackFn),
									Stars(self, target)
								},

								Do(function()
									if target.hp > 0 then
										targetSprite:setAnimation("idle")
									end
									self.calledShotDone = true
								end)
							})

							print("landed!")
							self.calledShotLanded = true
						end
					end
				end)
			}
		},

		IfElse(
			function() return self.calledShotLanded end,
			Action(),
			Parallel {
				Ease(lockOnSprite.color, 4, 0, 5),
				target:takeDamage({attack=100, speed=100, luck=100, miss=true}, false),
				Do(function()
					self.calledShotDone = true
				end)
			}
		),

		Do(function()
			lockOnSprite:remove()
			self.calledShotLanded = false
		end),

		Animate(self.sprite, "idle"),
		YieldUntil(self, "calledShotDone")
	}
end
