local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

local NPC = require "object/NPC"
local EscapeWarning = class(NPC)

function EscapeWarning:construct(scene, layer, object)
	self.ghost = true
	NPC.init(self)
	
	self.spotMapY = {
		["1"] = 165+32,
		["2"] = 229+32,
		["3"] = 293+32,
		["4"] = 357+32,
		["5"] = 421+32,
		["6"] = 485+32
	}
	self.spots = pack(object.properties.spots:split(','))
end

function EscapeWarning:update(dt)
	if self.colliding then
		return
	end

	NPC.update(self, dt)

	if self.state == NPC.STATE_TOUCHING then
		self.colliding = true
		self:run {
			PlayAudio("sfx", "alert", 1.0, true),
			Do(function()
				self.indicators = {}
				for _, spot in pairs(self.spots) do
					table.insert(self.indicators, SpriteNode(
						self.scene,
						Transform(700, self.spotMapY[spot], 2, 2),
						{255,255,255,255},
						"alert",
						nil,
						nil,
						"ui"
					))
				end
			end),
			Wait(1.5),
			Do(function()
				for _, indicator in pairs(self.indicators) do
					indicator:remove()
				end
			end)
		}
	end
end


return EscapeWarning
