local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local TypeText = require "actions/TypeText"
local Trigger = require "actions/Trigger"
local Do = require "actions/Do"
local Serial = require "actions/Serial"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local Animate = require "actions/Animate"

local SpriteNode = require "object/SpriteNode"

local MessageBox = class(Action)

MessageBox.ANIM_SPEED = 2
MessageBox.DEFAULT_TEXT_SPEED = 4
MessageBox.FAST_TEXT_SPEED = 12
MessageBox.HEADLINER_RECT = Rect(Transform(love.graphics.getWidth()/2, 30), love.graphics.getWidth() - 10, 60)
MessageBox.SUBLINER_RECT = Rect(Transform(love.graphics.getWidth()/2, love.graphics.getHeight() - 30), love.graphics.getWidth() - 10, 60)

function MessageBox:construct(args) -- name, message, rect, closeAction, blocking, textSpeed
	if not args.rect then
		local w = (love.graphics.getWidth() - 10)
		local h = 160
		self.rect = Rect(
			Transform(love.graphics.getWidth() / 2, love.graphics.getHeight() - h/2),
			w,
			h
		)
	else
		self.rect = args.rect
	end
	self.rect.transform.sx = 0
	self.rect.transform.sy = 0
	self.color = {255,255,255,0}
	self.blocking = args.blocking or false
	self.sfxAction = args.sfx and PlayAudio("sfx", args.sfx, 1.0, true) or Action()
	
	if args.options then
		local Layout = require "util/Layout"
		local Menu = require "actions/Menu"

		local rows = {}
		for _, opt in pairs(args.options) do
			table.insert(rows, {Layout.Text(opt.text), choose = function(menu) opt.callback(self, menu) end})
		end		
		self.optionAction = Menu {
			layout = Layout(rows),
			transform = Transform(100, love.graphics.getHeight() - 60)
		}
	else
		self.optionAction = Action()
	end
	self.type = "MessageBox"
	self.opened = false

	self.text = TypeText(
		Transform(self.rect.transform.x - self.rect.w/2 + 15, self.rect.transform.y - self.rect.h/2 + 15),
		{255,255,255,255},
		FontCache.Consolas,
		args.message,
		10 * (args.textSpeed or MessageBox.DEFAULT_TEXT_SPEED),
		false,
		false,
		50
	)
	self:addChild(self.text)

	self.drawPressX = not args.closeAction and not args.noPressX
	
	local closeAction = args.closeAction or Trigger("x", self.blocking)
	self:addChild(closeAction)

	self.expand = Serial {
		-- Fade in/grow
		Parallel {
			Ease(self.color, 4, 200, MessageBox.ANIM_SPEED),
			Ease(self.rect.transform, "sx", 1, MessageBox.ANIM_SPEED),
			Ease(self.rect.transform, "sy", 1, MessageBox.ANIM_SPEED)
		},
		Do(function() self.opened = true end),
		self.sfxAction,
		self.text,
		self.optionAction
	}
	
	self.action = Serial {
		-- Fade in/grow + text
		self.expand,
		-- Close
		closeAction,
		-- Mark opened
		Do(function()
			self.opened = false
			self.scene.audio:stopSfx()
		end),
		-- Fade out/shrink
		Parallel {
			Ease(self.color, 4, 0, MessageBox.ANIM_SPEED),
			Ease(self.rect.transform, "sx", 0, MessageBox.ANIM_SPEED),
			Ease(self.rect.transform, "sy", 0, MessageBox.ANIM_SPEED),
			Ease(self.text.color, 4, 0, 15, "linear")
		}
	}
end

function MessageBox:setText(text)
	self.text.text = text
	self.text:reset()
end

function MessageBox:setScene(scene)
	if self.scene or self.done then
		return
	end

	scene:addNode(self, "ui")
	self.action:setScene(scene)
	self.img = scene.mboxGradient
	
	if self.blocking then
		scene:focus("keytriggered", self)
	end
	
	if scene.player and self.blocking then
		scene.player.cinematic = true
	end
	
	self.pressXSprite = SpriteNode(
		scene,
		Transform(
			self.rect.transform.x + self.rect.w/2 - 32,
			self.rect.transform.y + self.rect.h/2 - 32,
			2,
			2
		),
		{255,255,255,255},
		"pressx",
		nil,
		nil,
		false
	)
	self.pressXSprite.drawWithNight = false
	
	self.scene = scene
end

function MessageBox:update(dt)
	self.action:update(dt)
end

function MessageBox:reset()
	self.done = false
	self.opened = false
	self.action:reset()
	
	if self.blocking then
		self.scene:unfocus("keytriggered")
	end
	
	if self.scene.player and self.blocking then
		self.scene.player.cinematic = false
	end
	
	-- Add back nodes for drawing
	self.scene:addNode(self, "ui")
	self.scene:addNode(self.text, "ui")
	
	self.scene = nil
end

function MessageBox:isDone()
	if self.done then
		return true
	end
	if self.action:isDone() then
		self.done = true
		self.scene:removeNode(self)
		self.scene:removeNode(self.text)
		if self.blocking then
			self.scene:unfocus("keytriggered")
		end
		if self.scene.player then
			self.scene.player.cinematic = false
		end
		return true
	end
	return false
end

function MessageBox:cleanup(scene)
	self.action:cleanup(scene)
end

function MessageBox:close()
	self.action:next()
end

function MessageBox:interrupt()
	while not self:isDone() do
		self.action:next()
		self:update(0)
	end
end

function MessageBox:draw()
	local center = Transform(
		self.rect.transform.x - self.rect.transform.sx * self.rect.w/2,
		self.rect.transform.y - self.rect.transform.sy * self.rect.h/2
	)
	
	-- Draw drop shadow
	love.graphics.setColor(0,0,0, 100 * (self.color[4] / 255))
	love.graphics.rectangle(
		"fill",
		center.x - 5,
		center.y + 5,
		self.rect.w * self.rect.transform.sx - 5,
		self.rect.h * self.rect.transform.sy,
		15,
		15
	)
	
	-- Draw overlay
	love.graphics.setColor({20,0,255,self.color[4]})
	love.graphics.rectangle(
		"fill",
		center.x,
		center.y,
		self.rect.w * self.rect.transform.sx,
		self.rect.h * self.rect.transform.sy,
		15,
		15
	)
	
	-- Draw press x
	if self.drawPressX and self.opened then
		self.pressXSprite:draw()
	end
end


return MessageBox