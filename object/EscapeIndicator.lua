local Do = require "actions/Do"
local Wait = require "actions/Wait"
local Serial = require "actions/Serial"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

local EscapeIndicator = class(NPC)

function EscapeIndicator:construct(scene, layer, object)
	self.action = Serial{}
	
	NPC.init(self)
	
	self.sprite.transform.ox = self.sprite.w/2
	self.sprite.transform.oy = self.sprite.h/2
	self.sprite.sortOrderY = 9999
end

function EscapeIndicator:update(dt)
	self.x = self.scene.player.x + 350
	
	if not self.action:isDone() then
		self.action:update(dt)

		if self.action:isDone() then
			self.action:cleanup(self)
			self.action = Serial{}
		end
	end
end

function EscapeIndicator:run(actions)
	-- Lazily evaluated actions
	if type(actions) == "function" then
		actions = actions()
	end

	-- Table is implicitly a Serial action
	if not getmetatable(actions) then
		actions = Serial(actions)
	end

	self.action:inject(self.scene, actions)
	self.action.done = false
end

function EscapeIndicator.place(scene, layer, yOffset)
	local indicator = EscapeIndicator(
		scene,
		layer,
		{
			name = "indicatorObj",
			x = 0,
			y = yOffset,
			width = 32,
			height = 32,
			properties = {nocollision = true, sprite = "art/sprites/alert.png"}
		}
	)
	scene:addObject(indicator)
	return indicator
end

return EscapeIndicator
