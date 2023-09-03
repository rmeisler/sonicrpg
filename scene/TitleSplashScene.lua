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

local Scene = require "scene/Scene"

local TitleSplashScene = class(Scene)

function TitleSplashScene:onEnter()
	self:pushLayer("ui")
	
	self.images = {}
	self.animations = {}
	self.images["pressx"] = love.graphics.newImage("art/sprites/pressx.png")
	self.images["pressz"] = love.graphics.newImage("art/sprites/pressz.png")
	self.images["pressx"]:setFilter("nearest", "nearest")
	self.images["pressz"]:setFilter("nearest", "nearest")
	
	self.pressX = SpriteNode(
		self,
		Transform(680, 550, 2, 2),
		{255,255,255,0},
		self.images["pressx"],
		12,
		12,
		"ui"
	)
	self.pressXText = TextNode(
		self,
		Transform(710, 550),
		{0,0,0,0},
		"select",
		FontCache.Consolas,
		"ui",
		false
	)
	self.pressZ = SpriteNode(
		self,
		Transform(560, 550, 2, 2),
		{255,255,255,0},
		self.images["pressz"],
		12,
		12,
		"ui"
	)
	self.pressZText = TextNode(
		self,
		Transform(590, 550),
		{0,0,0,0},
		"cancel",
		FontCache.Consolas,
		"ui",
		false
	)
	
	self.bg = love.graphics.newImage("art/splash/title3.png")
	self.bgY = -600
	
	-- Setup menu sfx
	self.audio:registerAs("sfx", "choose", love.audio.newSource("audio/sfx/choose.wav", "static"))
	self.audio:registerAs("sfx", "cursor", love.audio.newSource("audio/sfx/cursor.wav", "static"))
	self.audio:registerAs("sfx", "error", love.audio.newSource("audio/sfx/error.wav", "static"))
	self.audio:registerAs("sfx", "wind", love.audio.newSource("audio/sfx/wind.ogg", "static"))
	self.audio:registerAs("music", "pretitle", love.audio.newSource("audio/music/title.ogg", "static"))

	self.bgColor = {255,255,255,255}
	self.logoColor = {255,255,255,0}
	self.menuTextColor = {0,0,0,255}
	self.logoScale = 0

	self.menu = Menu {
		layout = Layout{
			{
				Layout.Text {text="New Game", outline=true},
				choose = function(menu)
					menu:disable()
					self:newGame()
				end
			},
			{
				Layout.Text {text="Continue", outline=true},
				choose = function(menu)
					self:continue()
				end
			},
			{
				Layout.Text {text="Quit", outline=true},
				choose = love.event.quit
			},
		},
		transform = Transform(415, 280),
		color = {0,0,0,0}
	}
	
	ScreenShader:sendColor("multColor", {255,255,255,255})
	love.graphics.setBackgroundColor(0,0,0,255)

	self.exiting = false
	return Executor(self):act(While(
		function()
			return not self.exiting
		end,
		Serial {
			Parallel {
				Ease(self.bgColor, 1, 255, 0.2, "linear"),
				Ease(self.bgColor, 2, 255, 0.2, "linear"),
				Ease(self.bgColor, 3, 255, 0.2, "linear"),
				AudioFade("music", 0.5, 1.0, 0.1),
				Serial {
					PlayAudio("sfx", "wind", 0.5, true, true),
					Wait(4),
					PlayAudio("music", "pretitle", 0.5, true),
					Ease(self, "bgY", 0, 0.053, "inout"),
				}
			},

			Parallel {
				self.menu,
				
				Ease(self.pressX.color, 4, 255, 1),
				Ease(self.pressZ.color, 4, 255, 1),
				Ease(self.pressXText.color, 4, 255, 1),
				Ease(self.pressZText.color, 4, 255, 1)
			}
		}
	))
end

function TitleSplashScene:keytriggered(key)
	if self.menuOpen then
		return
	end
	self.menuOpen = true
	
	Executor(self):act(Parallel {
		self.menu,
		
		Ease(self.pressX.color, 4, 255, 1),
		Ease(self.pressZ.color, 4, 255, 1),
		Ease(self.pressXText.color, 4, 255, 1),
		Ease(self.pressZText.color, 4, 255, 1),
	})
end

function TitleSplashScene:onExit(args)
	return Serial {
		Parallel {
			AudioFade("music", self.audio:getVolume("music"), 0, 0.5),
			Ease(self.bgColor, 1, 0, 0.5, "linear"),
			Ease(self.bgColor, 2, 0, 0.5, "linear"),
			Ease(self.bgColor, 3, 0, 0.5, "linear"),
			Do(function()
				ScreenShader:sendColor("multColor", self.bgColor)
			end)
		}
	}
end

function TitleSplashScene:newGame()
	GameState:addToParty("logan", 8, true)
	GameState.leader = "logan"
	GameState:setFlag("ep3_intro")
	
	self.audio:stopSfx("wind")
	
	self.exiting = true
	self.sceneMgr:switchScene {class = "ChapterSplashScene", manifest = "maps/sonicdemo_manifest.lua"}
end

function TitleSplashScene:continue()
	-- Make sure we have images ready for this screen
	local party = {"sonic", "sally", "bunny", "rotor", "antoine", "logan"}
	for _, member in pairs(party) do
		self.images["sprites/"..member] = love.graphics.newImage("art/sprites/"..member..".png")
		self.animations["sprites/"..member] = love.filesystem.load("art/sprites/"..member..".lua")()
	end
	
	self.audio:stopSfx("wind")
	
	self:run(Savescreen {
		scene = self,
		forLoading = true,
		onLoad = function()
			self.exiting = true
		end
	})
end

function TitleSplashScene:draw()
	love.graphics.setColor(self.bgColor)
	
	love.graphics.draw(
		self.bg,
		0,
		self.bgY,
		0,
		1,
		1
	)
	
	love.graphics.setColor(self.logoColor)
	--[[love.graphics.draw(
		self.logo,
		260 + 144,
		150 + 58,
		0,
		self.logoScale,
		self.logoScale,
		self.logo:getWidth()/2,
		self.logo:getHeight()/2
	)]]
	
	Scene.draw(self)
end


return TitleSplashScene