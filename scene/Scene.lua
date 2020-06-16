local ColorStack = require "util/ColorStack"
local Audio = require "util/Audio"
local Transform = require "util/Transform"

local Serial = require "actions/Serial"
local Executor = require "actions/Executor"

local SceneLayer = class()

function SceneLayer:construct(scene, layerName, sorted, nodes, colorStack)
	self.layerName = layerName
	self.sorted = sorted
	self.nodes = nodes or {}
	self.colorStack = ColorStack.new{}
	self.actions = {}
	scene.colorStack:addChild(self.colorStack)
end

local Scene = class(require "util/EventHandler")

function Scene:construct(sceneMgr)
    self.sceneMgr = sceneMgr
    self.paused = false
    self.sceneLayers = {}
    self.sceneCount = 0
    self.sceneLookup = {}
	self.nodes = {}
	self.objects = {}
	self.colorStack = ColorStack.new{}
	self.audio = Audio({}, {}, {})
	self.action = Serial{}
end

function Scene:update(dt)
	if self.action:isDone() then
		return
	end

	self.action:update(dt)

	if self.action:isDone() then
		self.action:cleanup(self)
		self.action = Serial{}
	end
end

function Scene:registerAudio(sfx, music, ambient)
	self.audio = Audio(sfx, music, ambient)
end

function Scene:pushLayer(layerName, sorted)
    self.sceneCount = self.sceneCount + 1
    table.insert(self.sceneLayers, SceneLayer(self, layerName, sorted))
    self.sceneLookup[layerName] = self.sceneLayers[self.sceneCount]
end

function Scene:popLayer()
    local layerName = self.sceneLayers[self.sceneCount].layerName
    self.sceneCount = self.sceneCount - 1
    table.remove(self.sceneLayers)
    self.sceneLookup[layerName] = nil
end

function Scene:addNode(node, layerName)
	local flag = tostring(node)
	if self.nodes[flag] and node.sceneLayer then
		return
	end
	local sceneLayer = self.sceneLookup[layerName]
	if sceneLayer then
		table.insert(sceneLayer.nodes, node)
		node.sceneLayer = sceneLayer
	end
	
	self.nodes[flag] = node
end

function Scene:removeNode(node)
	local flag = tostring(node)
	if node.sceneLayer then
		-- Find node
		for i,slnode in pairs(node.sceneLayer.nodes) do
			if tostring(slnode) == flag then
				table.remove(node.sceneLayer.nodes, i)
				break
			end
		end
	end
    
	node.sceneLayer = nil
	self.nodes[flag] = nil
end

function Scene:run(actions)
	-- Lazily evaluated actions
	if type(actions) == "function" then
		actions = actions()
	end

	-- Table is implicitly a Serial action
	if not getmetatable(actions) then
		actions = Serial(actions)
	end

	self.action:inject(self, actions)
	self.action.done = false
end

function Scene:onEnter()
	
end

function Scene:onReEnter()
	
end

function Scene:onExit()
	
end

function Scene:sortedDraw(layerName)
	local sceneLayer = self.sceneLookup[layerName]
	local sortedY = {}
	local nodeByY = {}
	for _, node in pairs(sceneLayer.nodes) do
		if not node.transform then
			node.transform = Transform(0,0,1,1)
		end
		if not node.h then
			node.h = 0
		end
		local posy = node.sortOrderY or node.transform.y
		if node.transform.oy == 0 then
			posy = posy + node.h*2
		end
		if not nodeByY[tostring(posy)] then
			nodeByY[tostring(posy)] = {}
		end
		table.insert(nodeByY[tostring(posy)], node)
		table.insert(sortedY, posy)
	end
	table.sort(sortedY)

	for _, y in ipairs(sortedY) do
		for _, node in pairs(nodeByY[tostring(y)]) do
			node:draw()
			love.graphics.setColor(255,255,255,255)
		end
	end
end

function Scene:draw(layerName)
	local layersToDraw = self.sceneLayers
	if layerName then
		layersToDraw = {self.sceneLookup[layerName]}
	end
    for _, sceneLayer in ipairs(layersToDraw) do
		if not sceneLayer.sorted then
			for _, node in pairs(sceneLayer.nodes) do
				if node.draw then
					node:draw()
					love.graphics.setColor(255,255,255,255)
				end
			end
		end
    end
end


return Scene