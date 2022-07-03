local Wait = require "actions/Wait"
local Transform = require "util/Transform"
local Move = class(require "actions/Action")

function Move:construct(obj, target, anim, ttl, earlyExitFun, overlap)
	self.obj = obj
	self.target = target
	self.anim = anim or "walk"
	self.timeout = ttl and Wait(ttl) or nil
	self.earlyExitFun = earlyExitFun or (function() return false end)
	self.done = false
	self.animCooldown = 0
	self.switchAnim = nil
	self.overlap = overlap
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
	--print("self x = "..tostring(self.obj.hotspots.left_bot.x).." self y = "..tostring(self.obj.hotspots.left_bot.y)..
	--      " target x = "..tostring(target.hotspots.left_bot.x).." target y = "..tostring(target.hotspots.left_bot.y))

	local objHS = self.obj.hotspots
	local targetHS = target.hotspots
	
	--[[if self.obj.hotspotOffsets then
		for orientation, coords in pairs(self.obj.hotspots) do
			objHS[orientation] = {}
			for coord, value in pairs(coords) do
				objHS[orientation][coord] = value + self.obj.hotspotOffsets[orientation][coord]
			end
		end
		for orientation, coords in pairs(target.hotspots) do
			targetHS[orientation] = {}
			for coord, value in pairs(coords) do
				targetHS[orientation][coord] = value + target.hotspotOffsets[orientation][coord]
			end
		end
	end]]
	
	if objHS.left_bot.x - targetHS.left_bot.x > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(objHS.left_top.x, objHS.left_top.y, -speed, 0, self.obj.ignoreCollision) and
			 self.obj.scene:canMoveWhitelist(objHS.left_bot.x, objHS.left_bot.y, -speed, 0, self.obj.ignoreCollision))
		then
			self.obj.x = self.obj.x - speed
			--self.switchAnim = self.anim.."left"
		end
	elseif targetHS.right_bot.x - objHS.right_bot.x > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(objHS.right_top.x, objHS.right_top.y, speed, 0, self.obj.ignoreCollision) and
		 	 self.obj.scene:canMoveWhitelist(objHS.right_bot.x, objHS.right_bot.y, speed, 0, self.obj.ignoreCollision))
		then
			self.obj.x = self.obj.x + speed
			--self.switchAnim = self.anim.."right"
		end 
	end

	if objHS.left_top.y - targetHS.left_top.y > speed then --or (self.overlap and objHS.left_top.y - self.target.y > speed) then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(objHS.left_top.x, objHS.left_top.y, 0, -speed, self.obj.ignoreCollision) and
			 self.obj.scene:canMoveWhitelist(objHS.right_top.x, objHS.right_top.y, 0, -speed, self.obj.ignoreCollision))
		then
			self.obj.y = self.obj.y - speed
			--self.switchAnim = self.anim.."up"
		end
	elseif targetHS.left_bot.y - objHS.left_bot.y > speed then
		if  self.obj.object.properties.ignoreMapCollision or
			(self.obj.scene:canMoveWhitelist(objHS.left_bot.x, objHS.left_bot.y, 0, speed, self.obj.ignoreCollision) and
			 self.obj.scene:canMoveWhitelist(objHS.right_bot.x, objHS.right_bot.y, 0, speed, self.obj.ignoreCollision))
		then
			self.obj.y = self.obj.y + speed
			--self.switchAnim = self.anim.."down"
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