local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local SpriteNode = require "object/SpriteNode"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local YieldUntil = require "actions/YieldUntil"
local Menu = require "actions/Menu"
local Do = require "actions/Do"
local Actor = require "actions/Executor"
local MessageBox = require "actions/MessageBox"
local Trigger = require "actions/Trigger"
local PlayAudio = require "actions/PlayAudio"
local Action = require "actions/Action"
local BlockPlayer = require "actions/BlockPlayer"
local DescBox = require "actions/DescBox"

local Layout = require "util/Layout"
local EventType = require "util/EventType"
local ItemType = require "util/ItemType"


local NumScreen = class(Action)

function NumScreen:construct(args)
	self.selectedNumber = 1
	self.color = {255,255,255,255}
	self.currentSequence = ""
	self.closing = false
	self.done = false
	self.descBoxes = {}
	self.prompt = DescBox(args.prompt)
	self.expected = args.expected
end

function NumScreen:underscores(num)
	local chars = {}
	for i = 1, num do
		table.insert(chars, "_")
	end
	return table.concat(chars)
end

function NumScreen:spacedout(str)
	local newstr = {}
	for i = 1, #str do
		local c = str:sub(i,i)
		table.insert(newstr, c .. "    ")
	end
	return table.concat(newstr)
end

function NumScreen:setScene(scene)
	if self.scene or self.done then
		return
	end

	self.action = BlockPlayer {
		Ease(self.color, 4, 255 * 0.8, 6),
		YieldUntil(self, "closing"),
		Parallel {
			Ease(self.color, 4, 0, 6),
			self.prompt
		}
	}
	
	self.prompt:setScene(scene)
	self.img = scene.mboxGradient
	self.scene = scene
	
	self.scene:addHandler("keytriggered", NumScreen.keytriggered, self)
	self.scene:focus("keytriggered", self)

	self.scene:addNode(self, "ui")
end

function NumScreen:reset()
	if self.closing then
		self.scene:addHandler("keytriggered", NumScreen.keytriggered, self)
	end
		
	if self:isDone() then
		self.scene:focus("keytriggered", self)
		self.scene:addNode(self, "ui")
	end
	
	self.prompt:reset()
	
	self.scene = nil
	self.done = false
	self.action:reset()
end

function NumScreen:isDone()
	if self.done then
		return true
	end
	if self.action:isDone() then
		self.scene:removeNode(self)
		
		for _,v in pairs(self.descBoxes) do
			v:close()
		end

		self.done = true
		return true
	end
	return false
end

function NumScreen:update(dt)
	self.prompt:update(dt)
	self.action:update(dt)
end

function NumScreen:keytriggered(key)
	if key == "up" then
		if self.selectedNumber < 4 then
			self.selectedNumber = (self.selectedNumber - 4) % 10
		else
			self.selectedNumber = self.selectedNumber - 3
		end
	elseif key == "down" then
		if self.selectedNumber > 6 then
			self.selectedNumber = ((self.selectedNumber + 3) % 10) + 1
		else
			self.selectedNumber = self.selectedNumber + 3
		end
	elseif key == "left" then
		if self.selectedNumber == 1 then
			self.selectedNumber = 9
		else
			self.selectedNumber = self.selectedNumber - 1
		end
	elseif key == "right" then
		if self.selectedNumber == 9 then
			self.selectedNumber = 1
		else
			self.selectedNumber = self.selectedNumber + 1
		end
	end
	
	if key == "x" then
		self.scene.audio:playSfx("choose", nil, true)
		self.currentSequence = self.currentSequence .. tostring(self.selectedNumber)
	end

	local fullyEntered = string.len(self.currentSequence) == 4
	if key == "z" or fullyEntered then
		if self.currentSequence == self.expected then
			self.action:inject(
				self.scene,
				MessageBox {message="Access granted.", sfx="levelup", blocking=true}
			)
		elseif fullyEntered then
			self.action:inject(
				self.scene,
				MessageBox {message="Access denied.", sfx="error", blocking=true}
			)
		end
		self.prompt:close()
		self.scene:removeHandler("keytriggered", NumScreen.keytriggered, self)
		self.scene:unfocus("keytriggered")
		self.closing = true
	end
end

function NumScreen:interrupt()
	while not self:isDone() do
		self.action:next()
		self:update(0)
	end
end

function NumScreen:draw()
	-- Window background
	love.graphics.setColor(255, 255, 255, self.color[4] * 0.8)
	local rect = Rect(
		Transform(0, 0),
		love.graphics.getWidth(),
		love.graphics.getHeight()
	)
    if self.img then
		love.graphics.draw(self.img, rect.transform.x, rect.transform.y, 0, rect.w * rect.transform.sx / self.img:getWidth(), rect.h * rect.transform.sy / self.img:getHeight())
	else
		love.graphics.rectangle("fill", rect.transform.x, rect.transform.y, rect.w * rect.transform.sx, rect.h * rect.transform.sy)
	end

	love.graphics.setColor(255, 255, 255, self.color[4])
	
	-- Selected numbers
	love.graphics.setFont(FontCache.ConsolasLarge)
	local numUnderscores = string.len(self.expected) - string.len(self.currentSequence)
	love.graphics.print(self:spacedout(self.currentSequence .. self:underscores(numUnderscores)), 250, 100)
	
	-- Selectable number pad
	love.graphics.setFont(FontCache.Consolas)
	local number = 1
	for y=200,400,100 do
		for x=300,500,100 do
			love.graphics.print(tostring(number), x, y)

			if self.selectedNumber == number then
				love.graphics.draw(
					CursorSprite,
					x - CursorSprite:getWidth() * 2,
					y - 5,
					0,
					2,
					2
				)
			end
			number = number + 1
		end
	end
end


return NumScreen