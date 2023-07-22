local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local TypeText = require "actions/TypeText"
local YieldUntil = require "actions/YieldUntil"

local Scene = require "scene/Scene"

local CreatorSplashScene = class(Scene)

function CreatorSplashScene:onEnter()
	self:pushLayer("ui")
	
	love.graphics.setBackgroundColor(255, 255, 255, 255)
	
	self.bgColor = {0,0,0,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	self.typeTextColor = {0,0,0,255}

	return Serial {
		Parallel {
			Ease(self.bgColor, 1, 255, 0.5, "linear"),
			Ease(self.bgColor, 2, 255, 0.5, "linear"),
			Ease(self.bgColor, 3, 255, 0.5, "linear"),
			Do(function()
				ScreenShader:sendColor("multColor", self.bgColor)
			end)
		},
		TypeText(
			Transform(70, 250),
			self.typeTextColor,
			FontCache.Consolas,
			"Sonic The Hedgehog and all related characters and \n"
			.."  intellectual property are owned by SEGA Inc.\n\n"
			.."{p100}              This is a fan game.",
			60,
			true
		),
		Wait(1),
		Do(function() self.sceneMgr:switchScene{class="TitleSplashScene"} end)
	}
end

function CreatorSplashScene:onExit()
	self.bgColor = {255,255,255,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	return Serial {
		Parallel {
			Ease(self.typeTextColor, 1, 255, 1, "linear"),
			Ease(self.typeTextColor, 2, 255, 1, "linear"),
			Ease(self.typeTextColor, 3, 255, 1, "linear"),
			Ease(self.bgColor, 1, 0, 0.5, "linear"),
			Ease(self.bgColor, 2, 0, 0.5, "linear"),
			Ease(self.bgColor, 3, 0, 0.5, "linear"),
			Do(function()
				ScreenShader:sendColor("multColor", self.bgColor)
			end)
		}
	}
end

function CreatorSplashScene:draw()
	Scene.draw(self)
end


return CreatorSplashScene