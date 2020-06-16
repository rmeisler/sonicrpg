local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local NPC = require "object/NPC"

local RunPath = class(NPC)

function RunPath:construct(scene, layer, object)
	self.ghost = true
	self.sprite = SpriteNode(
		self.scene,
		Transform(self.object.x, self.object.y, 2, 2),
		{255,255,255,255},
		"arrow",
		nil,
		nil,
		self.layer.name
	)
	
	NPC.init(self)
	
	self.sprite.transform.ox = self.sprite.w/2
	self.sprite.transform.oy = self.sprite.h/2
end

function RunPath:update(dt)
	NPC.update(self, dt)
	
	if not self.scene.player then
		return
	end

	if self.state == NPC.STATE_TOUCHING then
		self:removeSceneHandler("update")
		self.sprite:setAnimation("point")

		self:run(Parallel {
			Ease(self.sprite.color, 1, 512, 5, "inout"),
			Ease(self.sprite.color, 2, 512, 5, "inout"),
			Ease(self.sprite.color, 3, 512, 5, "inout"),
			
			PlayAudio("sfx", "path", 0.2, true, false, true),
			
			Serial {
				Parallel {
					Ease(self.sprite.transform, "sx", 5, 12, "inout"),
					Ease(self.sprite.transform, "sy", 5, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 1.5, 12, "inout"),
					Ease(self.sprite.transform, "sy", 1.5, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 3.5, 12, "inout"),
					Ease(self.sprite.transform, "sy", 3.5, 12, "inout")
				},
				Parallel {
					Ease(self.sprite.transform, "sx", 2, 12, "inout"),
					Ease(self.sprite.transform, "sy", 2, 12, "inout"),
					Ease(self.sprite.color, 4, 0, 9, "inout")
				},
				
				Do(function()
					self:remove()
				end)
			}
		})
	end
end

return RunPath
