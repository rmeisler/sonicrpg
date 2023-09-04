local Wait = require "actions/Wait"
local Transform = require "util/Transform"
local Action = require "actions/Action"
local Move = class(Action)

function Move:construct(obj, target, anim, ttl, earlyExitFun, overlap)
	self.obj = obj
	self.target = target
	self.anim = anim or "walk"
	self.timeout = ttl and Wait(ttl) or nil
	self.earlyExitFun = earlyExitFun or (function() return false end)
	self.done = false
	self.animCooldown = 0
	self.switchAnim = "down"
	self.overlap = overlap
end

function Move:setScene(scene)
	Action.setScene(self, scene)
	self.collisionMap = scene.collisionLayer[self.obj.layer.name]
end

function Move:update(dt)
	if self.obj:isRemoved() or self.target:isRemoved() then
		return 
	end

	if self.timeout then
		self.timeout:update(dt) 
	end
	
	if not self.obj.pauseMove then
		self:stepToward(self.target, self.obj.movespeed * (dt/0.016))
	end

	if self.animCooldown == 0 then
		self.obj.sprite:trySetAnimation(self.anim..self.switchAnim)
		self.obj.manualFacing = self.switchAnim
		self.animCooldown = 0.1
	else
		self.animCooldown = math.max(0, self.animCooldown - dt)
	end 
end

function Move:stepToward(target, speed)
	local objHS = self.obj.hotspots
	local targetHS = target.hotspots
	
	if objHS.left_bot.x - targetHS.left_bot.x > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(objHS.left_top.x, objHS.left_top.y, -speed, 0, self.obj.ignoreCollision, self.collisionMap) and
			 self.obj.scene:canMoveWhitelist(objHS.left_bot.x, objHS.left_bot.y, -speed, 0, self.obj.ignoreCollision, self.collisionMap))
		then
			self.obj.x = self.obj.x - speed
		end
	elseif targetHS.right_bot.x - objHS.right_bot.x > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(objHS.right_top.x, objHS.right_top.y, speed, 0, self.obj.ignoreCollision, self.collisionMap) and
		 	 self.obj.scene:canMoveWhitelist(objHS.right_bot.x, objHS.right_bot.y, speed, 0, self.obj.ignoreCollision, self.collisionMap))
		then
			self.obj.x = self.obj.x + speed
		end 
	end

	if objHS.left_top.y - targetHS.left_top.y > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(objHS.left_top.x, objHS.left_top.y, 0, -speed, self.obj.ignoreCollision, self.collisionMap) and
			 self.obj.scene:canMoveWhitelist(objHS.right_top.x, objHS.right_top.y, 0, -speed, self.obj.ignoreCollision, self.collisionMap))
		then
			self.obj.y = self.obj.y - speed
		end
	elseif targetHS.left_bot.y - objHS.left_bot.y > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(objHS.left_bot.x, objHS.left_bot.y, 0, speed, self.obj.ignoreCollision, self.collisionMap) and
			 self.obj.scene:canMoveWhitelist(objHS.right_bot.x, objHS.right_bot.y, 0, speed, self.obj.ignoreCollision, self.collisionMap))
		then
			self.obj.y = self.obj.y + speed
		end
	end 
	
	if math.abs(targetHS.left_bot.y - objHS.left_bot.y) >
	   math.abs(targetHS.right_bot.x - objHS.right_bot.x) then
		if targetHS.left_bot.y > objHS.left_bot.y then
			self.switchAnim = "down"
		else
			self.switchAnim = "up"
		end
	else
		if targetHS.right_bot.x > objHS.right_bot.x then
			self.switchAnim = "right"
		else
			self.switchAnim = "left"
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