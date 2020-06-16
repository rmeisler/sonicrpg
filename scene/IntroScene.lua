local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local TypeText = require "actions/TypeText"

local Region = require "scene/Region"

local IntroScene = class(Region)

function IntroScene:onEnter(args)
	args.noloadingtext = true
	local actions = Region.onEnter(self, args)
    
	self.bgColor = {255,255,255,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	
	local star1 = love.graphics.newImage("art/sprites/Star1.png")
	local star2 = love.graphics.newImage("art/sprites/Star2.png")
	
	local star1Pos = {
		Transform(50,100),
		Transform(190,130),
		Transform(600,200),
		Transform(300,20),
		Transform(60,300),
		Transform(310,420),
		Transform(100,350),
		Transform(500,500),
		Transform(420,50),
		Transform(100,500),
		Transform(410,300),
		Transform(670,470),
	}
	
	for index,pos in pairs(star1Pos) do
		if index % 2 == 0 then
			local sprite = SpriteNode(self, pos, {255,255,255,255}, star2, 69/3, 23, "ui")
			if index % 3 == 0 then
				sprite:addAnimation("sparkle", {{0,0},{1,0},{2,0},{1,0}}, 0.2)
			end 
		else
			local sprite = SpriteNode(self, pos, {255,255,255,255}, star1, 115/5, 23, "ui")
			if index % 3 == 0 then
				sprite:addAnimation("sparkle", {{0,0},{1,0},{2,0},{3,0},{4,0}}, 0.2)
			end 
		end
	end

	self.bgm = love.audio.newSource("audio/music/intro.ogg", "static")
	self.bgm:setVolume(1.0)
	love.audio.play(self.bgm)
	
	local storyText = {
		TypeText(
			Transform(70,150),
			{255,255,255,255},
			FontCache.ConsolasSmall,
			"After forty years of hegemony,\n\tthe authoritarian rule of The Order is coming to an end...",
			15,
			true
		),
		TypeText(
			Transform(70,250),
			{255,255,255,255},
			FontCache.ConsolasSmall,
			"\tAmbassador Verdelle of V has completed negotiations for a treaty\n\tbetween The Trade Union Federation and The Allied Order.",
			15,
			true
		),
		TypeText(
			Transform(70,350),
			{255,255,255,255},
			FontCache.ConsolasSmall,
			"\tAs Verdelle and her crew begin their long journey home\n\ttheir ship thunders with celebration over the historic moment...",
			15,
			true
		)
	}
	
	return Parallel {
		actions,
		Serial {
			Wait(1.5),
			storyText[1],
			Wait(3.5),
			
			storyText[2],
			Wait(6),
			
			storyText[3],

			Wait(8),
			
			Parallel {
				Ease(storyText[1].color, 4, 0, 0.2),
				Ease(storyText[2].color, 4, 0, 0.2),
				Ease(storyText[3].color, 4, 0, 0.2)
			},
			
			Wait(2),

			Do(function()
				self:goToNext()
			end)
		}
	}
end

function IntroScene:onExit()
	self.bgColor = {255,255,255,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	return Serial {
		Parallel {
			Ease(self.bgColor, 1, 0, 0.5, "linear"),
			Ease(self.bgColor, 2, 0, 0.5, "linear"),
			Ease(self.bgColor, 3, 0, 0.5, "linear"),
			Do(function()
				ScreenShader:sendColor("multColor", self.bgColor)
			end)
		}
	}
end


return IntroScene