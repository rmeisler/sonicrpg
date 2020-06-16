local Serial = require "actions/Serial"
local NPC = require "object/NPC"

local RunableNPC = class(NPC)

function RunableNPC:construct(scene, layer, object)
	self.action = Serial{}
	
	NPC.init(self, true)
	
	self:addSceneHandler("update", RunableNPC.updateAction)
end

function RunableNPC:updateAction(dt)
	if not self.action:isDone() then
		self.action:update(dt)

		if self.action:isDone() then
			self.action:cleanup(self)
			self.action = Serial{}
		end
	end
end

function RunableNPC:run(actions)
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

return RunableNPC
