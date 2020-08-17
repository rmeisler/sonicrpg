local TypeText = class(require "actions/Action")

function TypeText:construct(transform, color, font, text, speed, noFastForward, outline, wordwrap)
	self.transform = transform
	self.color = color
	self.font = font
	self.text = text or ""
	self.curtext = self.text
	self.textlen = string.len(self.text)
	self.charidx = 1
	self.spacing = 2
	self.elapsed = 0
	self.speed = speed or 20
	self.speed_mult = 1.0
	self.wordwrap = wordwrap
	self.charCounter = 0
	self.lastSpaceIdx = 1
	self.outline = outline
	self.noFastForward = noFastForward
	self.type = "TypeText"
end

function TypeText:setScene(scene)
	'''This is a test commit'''
	if self.scene then
		return
	end
	
	self.scene = scene

	scene:addHandler("update", TypeText.update, self)
	
	scene:addNode(self, "ui")
	
	self:update(0)
end

function TypeText:cleanup(scene)
	if not self.scene then
		return
	end
	
	self.scene:removeHandler("update", TypeText.update, self)
	
	self.scene:removeNode(self)
	self.scene = nil
end

function TypeText:isDone()
    return self.charidx >= self.textlen
end

function TypeText:reset()
	self.charidx = 1
	self.elapsed = 0
	self.curtext = self.text
	self.textlen = #self.text
end

function TypeText:update(dt)
	local invalidateChar = false
	self.elapsed = self.elapsed + dt * self.speed * self.speed_mult
	if self.elapsed >= 1.0 then
	    self.elapsed = 0
		self.charidx = self.charidx + 1
		invalidateChar = true
	end
	
	-- Applies speed multiplier to typing while the user holds 'x'
	if not self.noFastForward and love.keyboard.isDown("x") then
		self.speed_mult = 5.0
	else
		self.speed_mult = 1.0
	end

	-- Look ahead for special character codes
	if invalidateChar then
		local nextChar = self.curtext:sub(self.charidx, self.charidx)
		if nextChar == '{' then
			local charCode = self.curtext:sub(self.charidx + 1, self.charidx + 1)
			local idx = self.curtext:find("}", self.charidx + 1, true)
			self["oncode_"..charCode](self, idx)
		elseif nextChar == ' ' and self.wordwrap then
			self.charCounter = self.charCounter + 1
			
			if self.charCounter > self.wordwrap then
				self.curtext = self.curtext:sub(1, self.lastSpaceIdx)..
					"\n"..
					self.curtext:sub(self.lastSpaceIdx + 1, self.curtext:len())
				self.charCounter = 0
			end
			self.lastSpaceIdx = self.charidx
		elseif nextChar == '\n' then
			self.charCounter = 0
		else
			self.charCounter = self.charCounter + 1
		end
	end
end

function TypeText:oncode_s(idx)
	-- Remove special characters
	self.curtext = self.curtext:sub(1, self.charidx - 1)..
		self.curtext:sub(self.charidx + 2, idx - 1)..
		self.curtext:sub(idx + 1, self.curtext:len())
	self.charidx = self.charidx + (idx - self.charidx - 3)
end

function TypeText:oncode_p(idx)
	self.elapsed = self.elapsed - tonumber(self.curtext:sub(self.charidx + 2, idx - 1))

	-- Remove event from string feed
	self.curtext = self.curtext:sub(1, self.charidx - 1)..self.curtext:sub(idx + 1, self.curtext:len())
	self.textlen = #self.curtext
	
	-- Move back one char
	self.charidx = math.max(self.charidx - 1, 1)
end

function TypeText:draw()
	love.graphics.setFont(self.font)

	if self.outline then
		-- Draw black outline
		love.graphics.setColor(0,0,0,self.color[4])
		for x=-2,2,2 do
			for y=-2,2,2 do
				love.graphics.print(self.curtext:sub(1, self.charidx), self.transform.x + x, self.transform.y + y, 0, self.transform.sx, self.transform.sy)
			end
		end
	end
	
	-- Draw over outline
	love.graphics.setColor(self.color)
	love.graphics.print(self.curtext:sub(1, self.charidx), self.transform.x, self.transform.y, 0, self.transform.sx, self.transform.sy)
end


return TypeText