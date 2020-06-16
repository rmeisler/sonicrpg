local Wait = require "actions/Wait"
local Transform = require "util/Transform"
local Move = class(require "actions/Action")

function Move:construct(obj, target, anim, ttl, earlyExitFun)
	self.obj = obj
	self.target = target
	self.anim = anim or "walk"
	self.timeout = ttl and Wait(ttl) or nil
	self.earlyExitFun = earlyExitFun or (function() return false end)
	self.done = false
	self.animCooldown = 0
	self.switchAnim = nil
end

function Move:update(dt)
	if self.obj:isRemoved() or self.target:isRemoved() then
		return
	end
	
	if self.timeout then
		self.timeout:update(dt)
	end

	self:stepToward(self.target, self.obj.movespeed * (dt/0.016))
	
	if self.animCooldown == 0 then
		self.obj.sprite:trySetAnimation(self.switchAnim)
		self.animCooldown = 0.1
	else
		self.animCooldown = math.max(0, self.animCooldown - dt)
	end
end

function Move:stepToward(target, speed)
	if self.obj.hotspots.left_bot.x - target.hotspots.right_bot.x > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(self.obj.hotspots.left_top.x, self.obj.hotspots.left_top.y, -speed, 0, self.obj.ignoreCollision) and
			 self.obj.scene:canMoveWhitelist(self.obj.hotspots.left_bot.x, self.obj.hotspots.left_bot.y, -speed, 0, self.obj.ignoreCollision))
		then
			self.obj.x = self.obj.x - speed
			self.switchAnim = self.anim.."left"
		end
	elseif target.hotspots.left_bot.x - self.obj.hotspots.left_bot.x > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(self.obj.hotspots.right_top.x, self.obj.hotspots.right_top.y, speed, 0, self.obj.ignoreCollision) and
		 	 self.obj.scene:canMoveWhitelist(self.obj.hotspots.right_bot.x, self.obj.hotspots.right_bot.y, speed, 0, self.obj.ignoreCollision))
		then
			self.obj.x = self.obj.x + speed
			self.switchAnim = self.anim.."right"
		end
	end
	
	if self.obj.hotspots.left_top.y - target.hotspots.left_top.y > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(self.obj.hotspots.left_top.x, self.obj.hotspots.left_top.y, 0, -speed, self.obj.ignoreCollision) and
			 self.obj.scene:canMoveWhitelist(self.obj.hotspots.right_top.x, self.obj.hotspots.right_top.y, 0, -speed, self.obj.ignoreCollision))
		then
			self.obj.y = self.obj.y - speed
			self.switchAnim = self.anim.."up"
		end
	elseif target.hotspots.left_bot.y - self.obj.hotspots.left_bot.y > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(self.obj.hotspots.left_bot.x, self.obj.hotspots.left_bot.y, 0, speed, self.obj.ignoreCollision) and
			 self.obj.scene:canMoveWhitelist(self.obj.hotspots.right_bot.x, self.obj.hotspots.right_bot.y, 0, speed, self.obj.ignoreCollision))
		then
			self.obj.y = self.obj.y + speed
			self.switchAnim = self.anim.."down"
		end
	end
end

function Move:reset()
	-- noop
end

function Move:stop()
	self.done = true
end

function Move:isDone()
	if self.done or self.obj:isRemoved() or self.target:isRemoved() or (self.timeout and self.timeout:isDone()) then
		return true
	end
	if self.obj:isTouchingObj(self.target) then
		return true
	end
	if self.earlyExitFun() then
		return true
	end
	return false
end


return Move
