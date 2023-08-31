local Task = require "actions/Task"
local Action = require "actions/Action"
local Do = require "actions/Do"
local Serial = require "actions/Serial"
local BlockInput = require "actions/BlockInput"

local Audio = require "util/Audio"

local SceneManager = class(require "util/EventHandler")

function SceneManager:construct()
	self.current = 0
	self.cachedScenes = {}
	self.sceneStack = {}
	
	self.gamepad = false
	self.gamepadLock = {}
	
	-- Kick off threads
	Task.SpawnThreads()
end

function SceneManager:cleanup()
	for id,scene in pairs(self.sceneStack) do
		if scene.remove then
			scene:remove(true)
		end
	end
	self.cachedScenes = {}
	collectgarbage("collect")
end

function SceneManager:getCurrent()
	return self.sceneStack[self.current]
end

function SceneManager:getPrevious()
	return self.sceneStack[self.current > 1 and self.current - 1 or 1]
end

function SceneManager:pushScene(args)
	self.transitioning = true
	local nextScene = function()
		-- Pop last scene, if args request
		if args.popPrev then
			table.remove(self.sceneStack)
			self.current = self.current - 1
		end

		scene = require("scene/"..args.class)(self)
		scene:run {
			scene:onEnter(args) or Action(),
			Do(function()
				scene:addHandler("update", Audio.update, scene.audio, scene)
				scene:invoke("enter")
				self:invoke("enter", scene)
				self.transitioning = false
				if scene.onPostEnter then
					scene:onPostEnter()
				end
			end)
		}
		
		table.insert(self.sceneStack, scene)
		self.current = self.current + 1
	end

	local scene = self.sceneStack[self.current]
	if scene then
		scene:invoke("exit")
		self:invoke("exit", scene)
		scene:run {
			scene:onExit(args) or Action(),
			Do(nextScene)
		}
	else
		nextScene()
	end
end

function SceneManager:backToTitle()
	self.transitioning = true
	local scene = self.sceneStack[self.current]
	scene:invoke("exit")
	self:invoke("exit", scene)
	scene:run {
		scene:onExit{fadeOutMusic = true, toTitle = true} or Action(),
		Do(function()
			for i=self.current, 1, -1 do
				table.remove(self.sceneStack)
			end
			self.current = 1
			
			-- Wipe current GameState
			GameState = (require "object/GameState")()
			
			self:switchScene{class="TitleSplashScene"}
		end)
	}
end

function SceneManager:popScene(args)
	self.transitioning = true
	local scene = self.sceneStack[self.current]
	scene:invoke("exit")
	self:invoke("exit", scene)
	scene:run(BlockInput {
		scene:onExit(args) or Action(),
		Do(function()
			table.remove(self.sceneStack)
			self.current = self.current - 1
			
			local nextScene = self:getCurrent()
			if nextScene then
				nextScene:run {
					nextScene:onReEnter(args) or Action(),
					Do(function()
						self.transitioning = false
						nextScene:invoke("enter")
						self:invoke("enter", nextScene)
					end)
				}
			end
		end)
	})
    
	return self.current ~= 0
end

function SceneManager:switchScene(args)
	args.popPrev = true
	return self:pushScene(args)
end

function SceneManager:update(dt)
	-- Only update scene at the top of the stack
	local scene = self.sceneStack[self.current]
	if scene then
		scene:invoke("update", dt)
		if not scene.paused and scene.update then
			scene:update(dt)
		end
	end
end

function SceneManager:draw()
	-- Only draw the top scene
	local scene = self.sceneStack[self.current]
	if scene then
		scene:draw()
	end
end

function SceneManager:handleInput(type, ...)
	--[[ No input during transitions
	if self.transitioning then
		return
	end]]

	-- Only top scene processes input
	local scene = self.sceneStack[self.current]
	if scene then
		scene:invoke(type, ...)
		if scene[type] then
			scene[type](scene, ...)
		end
	end
end

function SceneManager:joystickadded(joystick)
	self.gamepad = joystick
	self:handleInput("joystickadded", joystick)
end

function SceneManager:gamepadpressed(joystick, button)
	self:handleInput("gamepadpressed", joystick, button)
end

function SceneManager:gamepadreleased(joystick, button)
	self:handleInput("gamepadreleased", joystick, button)
end

function SceneManager:keypressed(key, uni)
	self:handleInput("keytriggered", key, uni)
end

function SceneManager:keyreleased(key, uni)
	self:handleInput("keyreleased", key, uni)
end

function SceneManager:mousepressed(...)
	self:handleInput("mousepressed", ...)
end

function SceneManager:mousereleased(...)
	self:handleInput("mousereleased", ...)
end


return SceneManager