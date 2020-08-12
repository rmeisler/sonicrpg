local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"
local TextNode = require "object/TextNode"
local Savescreen = require "object/Savescreen"

local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Menu = require "actions/Menu"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local TypeText = require "actions/TypeText"
local Spawn = require "actions/Spawn"
local Executor = require "actions/Executor"
local While = require "actions/While"

local Layout = require "util/Layout"

local Region = require "scene/Region"
local ChapterSplashScene = class(Region)

function ChapterSplashScene:loadingAnimation(tasks)
	local titlecard = SpriteNode(
		self,
		Transform(0, 0, 1, 1),
		nil,
		love.graphics.newImage("art/splash/sonictitlecard_entropy.png"),
		nil,
		nil,
		"ui"
	)
	self.audio:registerAs("music", "titlecard", love.audio.newSource("audio/music/titlecard.ogg", "static"))
	
	self.bgColor = {0,0,0,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	return Serial {
		Parallel {
			PlayAudio("music", "titlecard", 0.8, true),

			-- Loads maps, images, sounds
			Parallel(tasks),
			
			-- Fade in screen
			Ease(self.bgColor, 1, 255, 1),
			Ease(self.bgColor, 2, 255, 1),
			Ease(self.bgColor, 3, 255, 1),
			Do(function() ScreenShader:sendColor("multColor", self.bgColor) end)
		},
		
		Parallel {
			-- Fade in screen
			Ease(self.bgColor, 1, 0, 2),
			Ease(self.bgColor, 2, 0, 2),
			Ease(self.bgColor, 3, 0, 2),
			Do(function() ScreenShader:sendColor("multColor", self.bgColor) end)
		},

		-- Initialize scene with loaded resources
		Do(function() self:finalize() end)
	}
end


return ChapterSplashScene