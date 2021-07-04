local Player = require "object/Player"
local NPC = require "object/NPC"

local WorldMapPoint = class(NPC)

function WorldMapPoint:construct(scene, layer, object)
    self.ghost = true
	self.neighbors = {
		up    = scene.objectLookup[object.properties.neighborUp],
		down  = scene.objectLookup[object.properties.neighborDown],
		left  = scene.objectLookup[object.properties.neighborLeft],
		right = scene.objectLookup[object.properties.neighborRight]
	}
	NPC.init(self, true)
	
	self:addSceneHandler("keytriggered")
end

function WorldMapPoint:keytriggered(key)
	local toNeighbor = self.neighbors[key]
	if toNeighbor then
		self:moveTo(toNeighbor)
	end
end

function WorldMapPoint:onTouch()
	
end

function WorldMapPoint:onLeave()
	
end

function WorldMapPoint:moveTo(neighbor)
	
end


return WorldMapPoint
