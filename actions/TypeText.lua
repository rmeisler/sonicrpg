local TypeText = class(require "actions/Action")

function TypeText:construct(transform, color, font, text, speed, noFastForward, outline, wordwrap)
    self.transform = transform
    self.color = color
    self.font = font
    self.text = text or ""
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
    self.textFont = font or FontCache.ConsolasSmall
    self.hlText = " "
    self.hlcolor = {0,255,255,self.color[4]}
    self.outlineCLR = {0,0,0,self.color[4]}
	
	local text = ""
	if type(self.text) == "string" then
		text = self.text
		self.curtext = text
		self.textlen = string.len(text)
		self.textTable = {}
		self.textTable = self:UpdateText(text or " ")
	end
	
	-- If TypeText is too fast, just have it autocompleted
	if speed >= 100 then
		local updateFn = self.update
		self.update = function(_, _)
		    while not self:isDone() do
				updateFn(self, 1)
			end
		end
	end
end

function TypeText:setScene(scene)
    -- Set Scene
        -- Sets upo the current scene for dynamic textx
    -- Params:
        -- takes in obect of the current scene that the player sees
    if self.scene then
        return
    end
    
    self.scene = scene

    scene:addHandler("update", TypeText.update, self)
    scene:addNode(self, "ui")
	
	if type(self.text) == "function" then
		local text = ""
		text = self.text()
		self.curtext = text
		self.textlen = string.len(text)
		self.textTable = {}
		self.textTable = self:UpdateText(text or " ")
	end

    self:update(0)
end

function TypeText:cleanup(scene)
    --Clean Up 
        -- Removes the text from the currently loaded scene.
        -- For more text or the next scene
    -- Params:
        -- takes in obect of the current scene that the player sees
    if not self.scene then
        return
    end
    
    self.scene:removeHandler("update", TypeText.update, self)
    self.scene:removeNode(self)
    self.scene = nil
end

function TypeText:isDone()
    -- Is Done
        -- The text is finished ouputting to the screen
    return self.charidx >= self.textlen
end

function TypeText:reset()
    -- Reset
        -- resets the window for the next dynamically loaded text
    self.charidx = 1
    self.elapsed = 0
    self.curtext = self.text
    self.textlen = #self.text
    self.textTable=self:UpdateText(self.curtext)
end

function TypeText:update(dt)
    -- Update
        -- Updates the text field with the const speed, speed_mult and time elapsed.
    -- Params
        -- DT: 

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
                self.curtext:sub(self.lastSpaceIdx+1, self.curtext:len())
                self.charCounter = 0

                self.textTable = self:clroffset(self.lastSpaceIdx+1, self.curtext:len())

            end
            self.lastSpaceIdx = self.charidx
        elseif nextChar == '\n' then
            self.charCounter = 0
        else
            self.charCounter = self.charCounter + 1
        end
    end

    for k,v in pairs(self.textTable) do
        if type(v) == "table" then
            v[4] = self.color[4]
        end
    end

    self.outlineCLR[4] = self.color[4]
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

function TypeText:oncode_h(idx)
    self.hltext = self.curtext:sub(self.charidx + 3, idx - 1)

    -- Remove event from string feed
    self.curtext = self.curtext:sub(1, self.charidx - 1)..self.curtext:sub(idx + 1, self.curtext:len())
    self.textlen = #self.curtext

	--adding the {h} inbetween text back
    self.curtext = self.curtext:sub(1, self.charidx - 1)..self.hltext..self.curtext:sub(self.charidx, self.curtext:len())

    -- Move back one char
    self.charidx = math.max(self.charidx - 1, 1)

    self.textTable = self:hlighttext(self.charidx+1,(self.charidx + self.hltext:len()), self.hlcolor)
end

function TypeText:draw()
    love.graphics.setFont(self.textFont)

    if self.outline then
        -- Draw black outline
        for x=-2,2,2 do
            for y=-2,2,2 do
                love.graphics.print({self.outlineCLR,self.curtext:sub(1, self.charidx)}, self.transform.x + x, self.transform.y + y, 0, self.transform.sx, self.transform.sy)
            end
        end
    end

    love.graphics.print(self:UpdateText(self.curtext:sub(1, self.charidx)), self.transform.x, self.transform.y, 0, self.transform.sx, self.transform.sy)
end

function TypeText:UpdateText(string)
    local tab = {}
	local i
    for i = 1, #string do
        if self.textTable[(i*2)-1] == nil then
            self.textTable[(i*2)-1] = self.color
        end

        if self.textTable[(i*2)] == nil then
           self.textTable[(i*2)] = "nil"
        end

        tab[(i*2)-1] = self.textTable[(i*2)-1]
        tab[(i*2)] = string:sub(i, i)
	end
	
	return tab
end

function TypeText:hlighttext(strt,fin,clr)
    local tab = {}

    for k, v in ipairs(self.textTable) do
       tab[k] = v
    end

    for i = strt, fin do
        tab[(i*2)-1] = clr
    end
    
    return tab
end


function TypeText:clroffset(strt,fin)
    local tab = {}

    for k, v in ipairs(self.textTable) do
        table[k] = v
    end

    for i = strt,  fin do
        tab[((i*2)+1)] = self.textTable[(((i*2)+1)-2)]
    end

    return tab
end


return TypeText