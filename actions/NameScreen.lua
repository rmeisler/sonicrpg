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


local NameScreen = class(Action)

function NameScreen:construct(args)
	self.selectedNumber = 1
	self.color = {255,255,255,255}
	self.currentSequence = ""
	self.closing = false
	self.done = false
	self.prompt = DescBox(args.prompt)
	self.success = args.success or Action()
	self.failure = args.failure or Action()
	self.expected = args.expected
	self.expectedLen = string.len(self.expected)
	
	self.letters = {
		'a','b','c','d',
		'e','f','g','h',
		'i','j','k','l',
		'm','n','o','p',
		'q','r','s','t',
		'u','v','w','x',
		    'y','z'
	}
end

function NameScreen:underscores(num)
	local chars = {}
	for i = 1, num do
		table.insert(chars, "_")
	end
	return table.concat(chars)
end

function NameScreen:spacedout(str)
	local newstr = {}
	for i = 1, #str do
		local c = str:sub(i,i)
		table.insert(newstr, c .. "    ")
	end
	return table.concat(newstr)
end

function NameScreen:setScene(scene)
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
	
	self.scene:addHandler("keytriggered", NameScreen.keytriggered, self)
	self.scene:focus("keytriggered", self)

	self.scene:addNode(self, "ui")
end

function NameScreen:reset()
	if self.closing then
		self.scene:addHandler("keytriggered", NameScreen.keytriggered, self)
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

function NameScreen:isDone()
	if self.done then
		return true
	end
	if self.action:isDone() and self.prompt:isDone() then
		self.scene:removeNode(self)
		self.done = true
		return true
	end
	return false
end

function NameScreen:update(dt)
	self.prompt:update(dt)
	self.action:update(dt)
end

function NameScreen:keytriggered(key)
	if key == "up" then
		if self.selectedNumber == 1 then
			self.selectedNumber = 25
		elseif self.selectedNumber == 2 then
			self.selectedNumber = 26
		elseif self.selectedNumber == 3 then
			self.selectedNumber = 23
		elseif self.selectedNumber == 4 then
			self.selectedNumber = 24
		else
			self.selectedNumber = self.selectedNumber - 4
		end
	elseif key == "down" then
		if self.selectedNumber == 25 then
			self.selectedNumber = 1
		elseif self.selectedNumber == 26 then
			self.selectedNumber = 2
		elseif self.selectedNumber == 23 then
			self.selectedNumber = 3
		elseif self.selectedNumber == 24 then
			self.selectedNumber = 4
		else
			self.selectedNumber = self.selectedNumber + 4
		end
	elseif key == "left" then
		if self.selectedNumber == 1 or
		   self.selectedNumber == 5 or
		   self.selectedNumber == 9 or
		   self.selectedNumber == 13 or
		   self.selectedNumber == 17 or
		   self.selectedNumber == 21
		then
			self.selectedNumber = self.selectedNumber + 3
		elseif self.selectedNumber == 25 then
			self.selectedNumber = 26
		else
			self.selectedNumber = self.selectedNumber - 1
		end
	elseif key == "right" then
		if self.selectedNumber == 4 or
		   self.selectedNumber == 8 or
		   self.selectedNumber == 12 or
		   self.selectedNumber == 16 or
		   self.selectedNumber == 20 or
		   self.selectedNumber == 24
		then
			self.selectedNumber = self.selectedNumber - 3
		elseif self.selectedNumber == 26 then
			self.selectedNumber = 25
		else
			self.selectedNumber = self.selectedNumber + 1
		end
	end
	
	if key == "x" then
		self.scene.audio:playSfx("choose", nil, true)
		self.currentSequence = self.currentSequence .. self.letters[self.selectedNumber]
	end

	local fullyEntered = string.len(self.currentSequence) == self.expectedLen
	if key == "z" or fullyEntered then
		if self.currentSequence == self.expected then
			self.action:add(self.scene, self.success)
			self.action:inject(
				self.scene,
				PlayAudio("sfx", "levelup", 1.0, true)
			)
		elseif fullyEntered then
			self.action:add(self.scene, self.failure)
			self.action:inject(
				self.scene,
				PlayAudio("sfx", "error", 1.0, true)
			)
		end
		self.prompt:close()
		self.prompt:interrupt()
		self.scene:removeHandler("keytriggered", NameScreen.keytriggered, self)
		self.scene:unfocus("keytriggered")
		self.closing = true
	end
end

function NameScreen:interrupt()
	while not self:isDone() do
		self.action:next()
		self:update(0)
	end
end

function NameScreen:draw()
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
	
	-- Selected letters
	love.graphics.setFont(FontCache.ConsolasLarge)
	local numUnderscores = string.len(self.expected) - string.len(self.currentSequence)
	love.graphics.print(
		self:spacedout(self.currentSequence .. self:underscores(numUnderscores)),
		300 - 52 * math.max(0, self.expectedLen - 3),
		100
	)
	
	-- Selectable letter pad
	love.graphics.setFont(FontCache.Consolas)
	local number = 1
	for y=160,440,40 do
		for x=250,550,100 do
			if self.letters[number] then
				love.graphics.print(self.letters[number], x, y)
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
			end
			number = number + 1
		end
	end
end


return NameScreen