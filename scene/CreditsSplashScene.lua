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

local CreditsSplashScene = class(Scene)

function CreditsSplashScene:onEnter()
	self:pushLayer("ui")
	
	self.images = {}
	self.animations = {}
	
	self.bg = love.graphics.newImage("art/splash/title3.png")
	self.soniclogo = love.graphics.newImage("art/sprites/rpglogo.png")
	
	self.bgY = -466
	
	-- Setup music
	self.audio:registerAs("music", "sonicrpglogo", love.audio.newSource("audio/music/credits.ogg", "static"))
	self.audio:registerAs("music", "credits", love.audio.newSource("audio/music/credits.ogg", "static"))
	self.audio:registerAs("music", "snowday", love.audio.newSource("audio/music/snowday.ogg", "static"))
	
	self.bgColor = {0,0,0,255}
	self.logoColor = {255,255,255,0}
	self.logoXForm = Transform(400, 180, 2, 2)
	
	ScreenShader:sendColor("multColor", {255,255,255,255})
	
	self.exiting = false
	return Serial {
		Parallel {
			Ease(self.bgColor, 1, 255, 0.3, "linear"),
			Ease(self.bgColor, 2, 255, 0.3, "linear"),
			Ease(self.bgColor, 3, 255, 0.3, "linear"),
			AudioFade("music", 0.7, 1.0, 0.3),
			Serial {
				Spawn(Serial {
					PlayAudio("music", "credits", 1.0),
					Wait(1),
					PlayAudio("music", "snowday", 1.0, true),
				}),
				Wait(3),
				Parallel {
					Ease(self.logoColor, 4, 255, 0.3, "inout"),
					Ease(self.logoXForm, "sx", 0.4, 0.3, "inout"),
					Ease(self.logoXForm, "sy", 0.4, 0.3, "inout")
				},
				Wait(8)
			},
			Ease(self, "bgY", 100, 0.2, "inout")
		},
		
		Parallel {
			Ease(self.bgColor, 1, 0, 0.6, "linear"),
			Ease(self.bgColor, 2, 0, 0.6, "linear"),
			Ease(self.bgColor, 3, 0, 0.6, "linear")
		},
		
		Wait(1),
		
		Parallel {
			Ease(self.logoXForm, "y", -550, 0.1, "linear"),
			
			self:getScrollingCredits()
		},
		Spawn(AudioFade("music", 1.0, 0.0, 1)),
		Do(function()
			self.sceneMgr:backToTitle()
		end)
	}
end

function CreditsSplashScene:onExit(args)
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

function CreditsSplashScene:getScrollingCredits()
	local creditsText = [[
[Story]
Jacob Berkley/Good Ol' Groovy Jake
Reggie Meisler/RedG

[Dialog]
Jacob Berkley/Good Ol' Groovy Jake
Reggie Meisler/RedG

[Music]
Billy Adams
Reggie Meisler/RedG
Jesse Rose/GreenCauldron08
F0XShadow
Michael Tavera

[Sound]
Anya Stocks/Frostdrop1
Reggie Meisler/RedG
SEGA
Anonymous

[Sprites]
AmeixaRoxa
Deebs
Racoon Ninja
Joey "The Plokman" Tripp Nimmo
Ibeh Dubem/Flame the Teen
Reggie Meisler/RedG
Unstoppable Thombo
Damien
Anya Stocks/Frostdrop1
E-122-Psi

[Tiles]
Lucas Melo (Death Egg)
Square Enix
daemoth
Reggie Meisler/RedG
Joey "The Plokman" Tripp Nimmo
Nz17

[Background Art]
Reggie Meisler/RedG
Nz17

[Concept Art]
AmeixaRoxa
JayFoxFire
Anya Stocks/Frostdrop1
Jacob Berkley/Good Ol' Groovy Jake
Reggie Meisler/RedG
RobertCo11
Joey "The Plokman" Tripp Nimmo

[Testing]
ScaleyFoxy
Fieryfurnace
GreenCauldron08
CaptainJotaro
Jacob Berkley/Good Ol' Groovy Jake
supermariobro58
King Sonic
Ibeh Dubem/Flame the Teen
Ricardo "Zero Neoz" Fukunaga
Pavel "Limepaul" Haluška

[3D Concept Art]
Nitrosaturn
Pavel "Limepaul" Haluška

[Splash Screen]
Riggo

[2019 Box Art]
Riggo

[2020 Box Art]
SEGAMew (@segamew)

[2021 Box Art]
sqrly jack

[2022 Box Art]
Jonathon Dobbs/InkPants

[2023 Box Art]
Leon Nalić/RingMasterLeon

[Framework]
Reggie Meisler/RedG

[Engine]
Love2D

[Programming]
Reggie Meisler/RedG
tailsluver29

[Tools]
Tiled
Aseprite
Anvil Studio
Audacity

[Special Thanks]
Fans United for SatAM
Sea3on
Jacob Berkley/Good Ol' Groovy Jake
Ibeh Dubem/Flame the Teen
AmeixaRoxa






    This episode is dedicated to a local
      artist and activist, Rick Bell.
	          Rest in power.

	
	
	

           Thanks for playing!
    Join our discord for project updates!
	
	
	
	
	
	
	        www.satamrpg.com	
]]
	local text = TextNode(
		self,
		Transform(100, 800),
		{255,255,255,255},
		creditsText,
		FontCache.Consolas,
		"ui",
		false
	)
	return Serial {
		Ease(text.transform, "y", -3850, 0.0075, "linear"),
		Do(function()
			print("done")
		end)
	}
end

function CreditsSplashScene:draw()
	love.graphics.setColor(self.bgColor)
	love.graphics.draw(
		self.bg,
		0,
		-600,
		0,
		1,
		1
	)
	love.graphics.draw(
		self.bg,
		0,
		self.bgY,
		0,
		1,
		1
	)
	
	love.graphics.setColor(self.logoColor)
	love.graphics.draw(
		self.soniclogo,
		self.logoXForm.x,
		self.logoXForm.y,
		0,
		self.logoXForm.sx,
		self.logoXForm.sy,
		self.soniclogo:getWidth()/2,
		self.soniclogo:getHeight()/2
	)
	
	Scene.draw(self)
end


return CreditsSplashScene