local Try = class(require "actions/Action")

local Serial = require "actions/Serial"
local Do = require "actions/Do"

function Try:construct(cond, success, fail, timeout)
	self.cond = cond
	self.success = success
	self.fail = fail
	self.timeout = timeout or 0
	self.curtime = self.timeout
	self.chooseSuccess = false
	self.chooseFail = false
	self.type = "Try"
end

function Try:update(dt)
	if self.chooseSuccess then
		self.success:update(dt)
	elseif self.chooseFail then
		self.fail:update(dt)
	else
		self.cond:update(dt)
		self.curtime = self.curtime - dt
		
		if self.cond:isDone() then
			self.success:setScene(self.scene)
			self.chooseSuccess = true
		elseif self.curtime <= 0 then
			self.cond:finish()
			self.fail:setScene(self.scene)
			self.chooseFail = true
		end
	end
end

function Try:setScene(scene)
	self.scene = scene
	self.cond:setScene(scene)
end

function Try:isDone()
	return self.success:isDone() or self.fail:isDone()
end

function Try:reset()
	self.curtime = self.timeout
	
	self.cond:reset()
	self.success:reset()
	self.fail:reset()
	self.chooseSuccess = false
	self.chooseFail = false
end


return Try
