local Wait = require "actions/Wait"
local Transform = require "util/Transform"
local Action = require "actions/Action"
local MoveStep = class(Action)

-- This is different from Move in that we aren't automatically moving toward an
-- object, we are moving toward a grid space which was selected for us by a
-- pathing algorithm. Note that this assumes a movespeed that is less than 1
-- tile's width/height (< 32 px)
function MoveStep:construct(obj, destx, desty, anim, movespeed, earlyExitFun)
	self.obj = obj
	self.destx = destx -- Note destination is in collision coords, not world coords
	self.desty = desty
	self.anim = anim or "walk"
	self.movespeed = movespeed
	self.earlyExitFun = earlyExitFun or (function() return false end)
	self.animCooldown = 0
	self.done = false
end

function MoveStep:setScene(scene)
	Action.setScene(self, scene)
	self.collisionMap = scene.collisionLayer[self.obj.layer.name]
end

function MoveStep:update(dt)
	if self.obj:isRemoved() or self.done or self.earlyExitFun() then
		self.done = true
		return
	end

	local cx, cy = self.obj.scene:worldCoordToCollisionCoord(self.obj.x, self.obj.y)
	if cx == self.destx and cy == self.desty then
		self.done = true
		return
	end

	local movespeed = self.movespeed * (dt/0.016)
	local dx, dy = 0, 0

	if cx < self.destx then
		dx = movespeed
	elseif cx > self.destx then
		dx = -movespeed
	end

	if cy < self.desty then
		dy = movespeed
	elseif cy > self.desty then
		dy = -movespeed
	end

	self.obj.x = self.obj.x + dx
	self.obj.y = self.obj.y + dy

	if math.abs(dy) > math.abs(dx) then
		if dy > 0 then
			self.switchAnim = "down"
		else
			self.switchAnim = "up"
		end
	else
		if dx > 0 then
			self.switchAnim = "right"
		else
			self.switchAnim = "left"
		end
	end

	if self.animCooldown == 0 then
		self.obj.sprite:trySetAnimation(self.anim..self.switchAnim)
		self.obj.manualFacing = self.switchAnim
		self.animCooldown = 0.1
	else
		self.animCooldown = math.max(0, self.animCooldown - dt)
	end
end

function MoveStep:reset()
	-- noop
end
 
function MoveStep:stop()
	self.done = true
end
 
function MoveStep:isDone()
	return self.done or self.obj:isRemoved() or self.earlyExitFun()
end

 
return MoveStep