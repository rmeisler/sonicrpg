local Serial = require "actions/Serial"
local Repeat = require "actions/Repeat"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"

local NPC = require "object/NPC"

local SnowboardRamp = class(NPC)

function SnowboardRamp:construct(scene, layer, object)
	self.ghost = true
	
	NPC.init(self)
	
	self.touched = false

	self:addHandler("collision", SnowboardRamp.jump, self)
end

function SnowboardRamp:jump()
	if not self.touched then
		self.scene.player.bx = -10
		self.scene.player.invincible = true
		self.scene.player.jump = true
		self.touched = true
	end
end


return SnowboardRamp
