local Serial = require "actions/Serial"
local Repeat = require "actions/Repeat"
local Do = require "actions/Do"
local Wait = require "actions/Wait"

local RunableNPC = require "object/RunableNPC"
local NPC = require "object/NPC"

local Spawner = class(NPC)

function Spawner:construct(scene, layer, object)
    self.ghost = true
	
	NPC.init(self)
	
	self.sprite.visible = false
	
	self:run(
		Repeat(
			Serial {
				Do(function()
					local inst = RunableNPC(scene, layer, object)
					scene:addObject(inst)
					inst:postInit()
				end),
				Wait(object.properties.every or 1)
			}
		)
	)
end

function Spawner:postInit()
	-- noop
end


return Spawner
