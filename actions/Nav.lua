require "util/astar"
local Wait = require "actions/Wait"
local Nav = class(require "actions/Action")

function Nav:construct(obj, target, anim, ttl, earlyExitFun)
	self.obj = obj
	self.target = target
	self.origTarget = {x=target.x, y=target.y}
	self.anim = anim or "walk"
	self.timeout = ttl and Wait(ttl) or nil
	self.earlyExitFun = earlyExitFun or function() return false end
	self.done = false
	self.animCooldown = 0
	self.pathCooldown = 0
	self.switchAnim = nil
end

function Nav:update(dt)
	if self.obj:isRemoved() or self.target:isRemoved() then
		return
	end
	
	if self.timeout then
		self.timeout:update(dt)
	end
	
	-- Out of nodes
	if not self.path or next(self.path) == nil then
		return
	end
	
	-- Reached node, try to grab another node
	if  self.obj.hotspots.left_bot.x <= self.curPoint.x and
		self.obj.hotspots.right_bot.x >= self.curPoint.x and
		self.obj.hotspots.left_top.y <= self.curPoint.y and
		self.obj.hotspots.left_bot.y >= self.curPoint.y
	then
		self.curPoint = table.remove(self.path, 1)
	end

	-- Move along path
	local speed = self.obj.movespeed * (dt/0.016)
	if self.obj.hotspots.left_bot.x >= self.curPoint.x then
		self.obj.x = self.obj.x - speed
		self.switchAnim = self.anim.."left"
	elseif self.curPoint.x >= self.obj.hotspots.right_bot.x then
		self.obj.x = self.obj.x + speed
		self.switchAnim = self.anim.."right"
	end
	
	if self.obj.hotspots.left_top.y >= self.curPoint.y then
		self.obj.y = self.obj.y - speed
		self.switchAnim = self.anim.."up"
	elseif self.curPoint.y >= self.obj.hotspots.left_bot.y then
		self.obj.y = self.obj.y + speed
		self.switchAnim = self.anim.."down"
	end
	
	-- Update animations
	if self.animCooldown == 0 then
		self.obj.sprite:trySetAnimation(self.switchAnim)
		self.animCooldown = 0.3
	else
		self.animCooldown = math.max(0, self.animCooldown - dt)
	end
	
	-- Update pathing
	if  self.pathCooldown == 0 and
		(self.target.x ~= self.origTarget.x or self.target.y ~= self.origTarget.y)
	then
		self:calcPath()
	else
		self.pathCooldown = math.max(0, self.pathCooldown - dt)
	end
end

function Nav:calcPath()
	local objcx, objcy = self.scene:worldCoordToCollisionCoord(self.obj.x, self.obj.y)
	local targetcx, targetcy = self.scene:worldCoordToCollisionCoord(self.target.x, self.target.y)

	self.path = astar.path(
		self.scene.pathingNodes[(objcy - 1) * self.scene.map.width + (objcx % self.scene.map.width)],
		self.scene.pathingNodes[(targetcy - 1) * self.scene.map.width + (targetcx % self.scene.map.width)],
		self.scene.pathingNodes,
		true,
		function(node, neighbor)
			return not neighbor.collision
		end
	)
	local startNode = self.scene.pathingNodes[(objcy - 1) * self.scene.map.width + (objcx % self.scene.map.width)]
	local endNode = self.scene.pathingNodes[(targetcy - 1) * self.scene.map.width + (targetcx % self.scene.map.width)]
	print("start: ".."x = "..tostring(self.obj.x)..", y = "..tostring(self.obj.y))
	print("start2: ".."x = "..tostring(startNode.x)..", y = "..tostring(startNode.y))
	print("end: ".."x = "..tostring(self.target.x)..", y = "..tostring(self.target.y))
	print("end2: ".."x = "..tostring(endNode.x)..", y = "..tostring(endNode.y))
	for _, p in pairs(self.path) do
		print("x = "..tostring(p.x)..", y = "..tostring(p.y))
	end
	if not self.path then
		self.done = true
	else
		self.curPoint = table.remove(self.path, 1)
	end
	self.pathCooldown = 5
end

function Nav:setScene(scene)
	self.scene = scene
	self:calcPath()
end

function Nav:reset()
	self:calcPath()
end

function Nav:stop()
	self.done = true
end

function Nav:isDone()
	if self.done or self.obj:isRemoved() or self.target:isRemoved() or (self.timeout and self.timeout:isDone()) then
		return true
	end
	--if self.obj:isTouchingObj(self.target) then
	--	return true
	--end
	if not self.path or next(self.path) == nil then
		return
	end
	if self.earlyExitFun() then
		return true
	end
	return false
end


return Nav
