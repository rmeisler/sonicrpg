local YieldUntil = class(require "actions/Action")

function YieldUntil:construct(obj, flag)
	self.obj = obj
	self.flag = flag
	self.type = "YieldUntil"
	self.done = false
end

function YieldUntil:isDone()
	if self.done then
		return true
	end

	-- Resolve lazy obj ref
	if type(self.obj) == "function" and self.flag == nil then
		return self.obj()
	else
		local val = self.obj[self.flag]
		return type(val) == "function" and val(self.obj) or val
	end
end

function YieldUntil:finish()
	-- noop
	self.done = true
end


return YieldUntil
