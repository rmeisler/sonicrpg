local Serial = require "actions/Serial"
local Repeat = require "actions/Repeat"
local Do = require "actions/Do"
local Wait = require "actions/Wait"

local RunableNPC = require "object/RunableNPC"
local NPC = require "object/NPC"

local Spawner = class(NPC)

function Spawner:construct(scene, layer, object)
    self.ghost = true
	
	NPC.init(self, false)
	
	self.spawnerChildren = {}
	for i=0,(object.properties.max or 10) do
		local inst = RunableNPC(scene, layer, object)
		scene:addObject(inst)
		inst.sprite.visible = false
		table.insert(self.spawnerChildren, inst)
	end

	self.sprite.visible = false
	self.time = 0
end

function Spawner:update(dt)
	self.time = self.time + dt
	
	if self.time > self.object.properties.every then
		local inst = table.remove(self.spawnerChildren, 1)
		table.insert(self.spawnerChildren, inst)
		inst.x = self.x
		inst.y = self.y
		inst.sprite.visible = true
		inst:postInit()

		self.time = 0
	end
end

function Spawner:postInit()
	-- noop
end


return Spawner
