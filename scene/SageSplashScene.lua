local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Do = require "actions/Do"
local PlayAudio = require "actions/PlayAudio"
local YieldUntil = require "actions/YieldUntil"
local Action = require "actions/Action"
local Wait = require "actions/Wait"

local Scene = require "scene/Scene"

local SageSplashScene = class(Scene)

function SageSplashScene:onEnter()
	self.audio:registerAs("music", "sage", love.audio.newSource("audio/music/sage.ogg", "static"))
	self.video = love.graphics.newVideo("art/splash/sage.ogv")
	--self.video:getSource():setVolume(0.5)

	return Serial {
		PlayAudio("music", "sage", 0.2, true),
		Wait(0.5),
		Do(function()
			self.video:play()
		end),
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
	love.graphics.draw(self.video,-80,0,0,0.25,0.25)
	love.graphics.setShader(ScreenShader)
end


return SageSplashScene