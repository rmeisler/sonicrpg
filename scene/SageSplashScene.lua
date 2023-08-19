local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local Action = require "actions/Action"

local Scene = require "scene/Scene"

local SageSplashScene = class(Scene)

function SageSplashScene:onEnter()
	self.video = love.graphics.newVideo("art/splash/sage.ogv")
	self.video:getSource():setVolume(0.5)
	self.video:play()

	return Serial {
		YieldUntil(function()
			return not self.video:isPlaying()
		end),
		Do(function() self.sceneMgr:switchScene{class="CreatorSplashScene"} end)
	}
end

function SageSplashScene:onExit()
	return Action()
end

function SageSplashScene:draw()
	Scene.draw(self)
	
	love.graphics.setShader()
	love.graphics.draw(self.video, -90,30,0,0.5)
	love.graphics.setShader(ScreenShader)
end


return SageSplashScene