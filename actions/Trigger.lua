local Trigger = class(require "actions/Action")

function Trigger:construct(key, focus)
	self.key = key
	self.triggered = false
	self.shouldFocus = focus or false
	self.type = "Trigger"
end

function Trigger:setScene(scene)
	self.scene = scene
	self:reset()
end

function Trigger:keytriggered(key)
	self.triggered = (key == self.key) or self.key == nil
end

function Trigger:finish()
	self.triggered = true
	self:isDone()
end

function Trigger:reset()
	self.triggered = false
	self.done = false
	self.scene:addHandler("keytriggered", Trigger.keytriggered, self)
	if self.shouldFocus then
		self.scene:focus("keytriggered", self)
	end
end

function Trigger:isDone()
	if self.done then
		return true
	end
    if self.triggered then --or love.keyboard.isDown("f") then -- fast forward
		self.scene:removeHandler("keytriggered", Trigger.keytriggered, self)
		if self.shouldFocus then
			self.scene:unfocus("keytriggered")
		end
		self.done = true
	end
	return self.done
end


return Trigger
