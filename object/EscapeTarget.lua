local Do = require "actions/Do"
local BlockPlayer = require "actions/BlockPlayer"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local MessageBox = require "actions/MessageBox"
local Action = require "actions/Action"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"

local Transform = require "util/Transform"

local EscapeLaser = require "object/EscapeLaser"

local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

local EscapeTarget = class(NPC)

function EscapeTarget:construct(scene, layer, object)
	self.action = Serial{}
	self.fast = object.properties.fast
	
	NPC.init(self)
	
	self.sprite.transform.ox = self.sprite.w/2
	self.sprite.transform.oy = self.sprite.h/2
	self.sprite.color[4] = 0
	self.sprite.sortOrderY = 9999
	
	self:animate()
end

function EscapeTarget:update(dt)
	if not self.scene:playerMovable() then
		return
	end

	local fx = self.scene.player.fx
	if self.scene.player.noGas then
		fx = 25
	end

	local bx = self.scene.player.bx
	if bx > 0 then
		bx = bx + 1
	end
	self.x = self.x + (fx + bx) * (dt/0.016)
	
	if not self.action:isDone() then
		self.action:update(dt)

		if self.action:isDone() then
			self.action:cleanup(self)
			self.action = Serial{}
		end
	end
end

function EscapeTarget:animate()
	if self.fast then
		self:run(Parallel {
			Ease(self.sprite.color, 4, 255, 5),
			Serial {
				PlayAudio("sfx", "lockon", 1.0, true),
				Parallel {
					Ease(self.sprite.transform, "sx", 4, 12, "inout"),
					Ease(self.sprite.transform, "sy", 4, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 1.5, 12, "inout"),
					Ease(self.sprite.transform, "sy", 1.5, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 3, 12, "inout"),
					Ease(self.sprite.transform, "sy", 3, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 2, 12, "inout"),
					Ease(self.sprite.transform, "sy", 2, 12, "inout")
				},
				
				Ease(self.sprite.color, 4, 0, 5),
			},
			Serial {
				Wait(0.2),
				Do(function()
					EscapeLaser.fire(
						self.scene,
						self.layer,
						Transform(self.origin.x + self.offset.x, self.origin.y + self.offset.y),
						self
					)
				end),
				
				Wait(2),
				
				Do(function()
					self:remove()
				end)
			}
		})
	else
		self:run(Parallel {
			Ease(self.sprite.color, 4, 255, 5),
			Serial {
				Parallel {
					PlayAudio("sfx", "target", 1.0, true),
					Serial {
						Ease(self, "y", function() return self.y + 60 end, 8, "inout"),
						Ease(self, "y", function() return self.y - 60 end, 8, "inout"),
						Ease(self, "y", function() return self.y + 40 end, 8, "inout"),
						Ease(self, "y", function() return self.y - 40 end, 8, "inout"),
						Ease(self, "y", function() return self.y + 20 end, 8, "inout"),
						Ease(self, "y", function() return self.y - 20 end, 8, "inout"),
						Ease(self, "y", function() return self.y      end, 8, "inout"),
					}
				},
				
				PlayAudio("sfx", "lockon", 1.0, true),
				Parallel {
					Ease(self.sprite.transform, "sx", 4, 12, "inout"),
					Ease(self.sprite.transform, "sy", 4, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 1.5, 12, "inout"),
					Ease(self.sprite.transform, "sy", 1.5, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 3, 12, "inout"),
					Ease(self.sprite.transform, "sy", 3, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 2, 12, "inout"),
					Ease(self.sprite.transform, "sy", 2, 12, "inout")
				},
				
				Ease(self.sprite.color, 4, 0, 5),
				
				Do(function()
					EscapeLaser.fire(
						self.scene,
						self.layer,
						Transform(self.origin.x + self.offset.x, self.origin.y + self.offset.y),
						self
					)
				end),
				
				Wait(2),
				
				Do(function()
					self:remove()
				end)
			}
		})
	end
end

function EscapeTarget:run(actions)
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

function EscapeTarget.place(scene, layer, origin, offset, target, fast)
	local etarget = EscapeTarget(
		scene,
		layer,
		{
			name = "targetObj",
			x = target.x,
			y = target.y,
			width = 33,
			height = 33,
			properties = {nocollision = true, sprite = "art/sprites/target.png", fast = fast}
		}
	)
	scene:addObject(etarget)
	
	etarget.origin = origin
	etarget.offset = offset
	return etarget
end

return EscapeTarget
