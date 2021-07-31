local SceneNode = class(require "util/EventHandler")

function SceneNode:construct(scene)
	self.scene = scene
	self.internalHandlers = {}
	self.focusedOn = {}
	self:addSceneNode()
end

function SceneNode:focusScene(type)
	self.scene:focus(type, self)
	table.insert(self.focusedOn, type)
end

function SceneNode:unfocusScene(type)
	local index = 1
	for k,v in pairs(self.focusedOn) do
		if v == type then
			index = k
			break
		end
	end
	table.remove(self.focusedOn, index)
	self.scene:unfocus(type)
end

function SceneNode:addSceneHandler(type, func, ...)
	func = func or self[type]
    self.scene:addHandler(type, func, self, ...)

    if not self.internalHandlers[type] then
        self.internalHandlers[type] = {}
    end
    self.internalHandlers[type][tostring(func)] = func
end

function SceneNode:removeSceneHandler(type, func)
	func = func or self[type]
    self.scene:removeHandler(type, func, self)
	
	if not self.internalHandlers[type] then
        self.internalHandlers[type] = {}
    end
    self.internalHandlers[type][tostring(func)] = nil
end

function SceneNode:removeAllSceneHandlers()
    for type, handlers in pairs(self.internalHandlers) do
        for _,func in pairs(handlers) do
            self:removeSceneHandler(type, func)
        end
    end
end

function SceneNode:addSceneNode(layerName)
	self.scene:addNode(self, layerName)
end

function SceneNode:removeSceneNode()
	self.scene:removeNode(self)
end

function SceneNode:swapLayer(newLayer)
	self.scene:removeNode(self)
	self.scene:addNode(self, newLayer)
end

function SceneNode:getSceneLayer()
	return self.sceneLayer
end

function SceneNode:pushColor(color)
	local layer = self:getSceneLayer()
	table.insert(layer.colorStack, color)
end

function SceneNode:postInit()
	-- noop
end

function SceneNode:remove()
	self:invoke("remove")

	-- Remove all children
	for k,v in pairs(self.children) do
	    v:remove()
	end
	self:removeSceneNode()
	self:removeAllSceneHandlers()
	for _,type in pairs(self.focusedOn) do
		self.scene:unfocus(type)
	end
	self.focusedOn = {}
end

function SceneNode:isRemoved()
	return self.scene.nodes[tostring(self)] == nil
end


return SceneNode