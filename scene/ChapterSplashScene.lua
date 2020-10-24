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
local Repeat = require "actions/Repeat"

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
	
		local loadingText = TypeText(
		Transform(600, love.graphics.getHeight()-50),
		{255,255,255,255},
		FontCache.Consolas,
		"Loading",
		4
	)
	local loadingDots = TypeText(
		Transform(680, love.graphics.getHeight()-50),
		{255,255,255,255},
		FontCache.Consolas,
		" ... ",
		2
	)
	
	self.bgColor = {0,0,0,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	return Serial {
		Parallel {
			Serial {
				PlayAudio("music", "titlecard", 0.8),
				Serial {
					loadingText,
					Spawn(Repeat(loadingDots))
				}
			},

			-- Loads maps, images, sounds
			Serial {
				Do(function()
					print("Loading tasks...")
				end),
				Parallel(tasks),
				Do(function()
					print("All tasks loaded.")
				end)
			},
			
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