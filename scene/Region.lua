local Transform  = require "util/Transform"

local Action     = require "actions/Action"
local Animate    = require "actions/Animate"
local Ease       = require "actions/Ease"
local Parallel   = require "actions/Parallel"
local Serial     = require "actions/Serial"
local Do         = require "actions/Do"
local Repeat     = require "actions/Repeat"
local TypeText   = require "actions/TypeText"
local Task       = require "actions/Task"

local SpriteNode = require "object/SpriteNode"

local Scene = require "scene/Scene"

local Region = class(Scene)

function Region:onEnter(args)
    self:pushLayer("ui")
	
	self.args = args

	self.maps = {}
	self.images = args.images or {}
	self.audio = args.audio or self.audio
	self.animations = args.animations or {}
	local manifestFile, err = love.filesystem.load(args.manifest)
	if manifestFile == nil then
		print(err)
	end
	local manifest = manifestFile()
	
	-- Construct tasks from manifest
	self.loadSonicSprite = Task {type = "image", file = "art/sprites/sonicloading.png"}
	local tasks = {
		self.loadSonicSprite
	}
	for _,data in pairs(manifest) do
		-- If this is a map, find internal images and load them
	    if data.type == "map" then
			local mapData = love.filesystem.load(data.file)()
			-- Tilesets
			for _,tileset in pairs(mapData.tilesets) do
				local filename = tileset.image
				tasks[filename] = Task {
					type = "image",
					file = filename:match("%.%./(.*)"),
					processor = self:getTilesetProcessor(),
					tileset.transparentcolor or "#000000FF"
				}
			end
			-- Images from image layers or object sprites
			for _,layer in pairs(mapData.layers) do
				if layer.type == "imagelayer" then
					tasks[layer.image] = Task {type = "image", file = layer.image:match("%.%./(.*)")}
				elseif layer.type == "objectgroup" then
					for _,object in ipairs(layer.objects) do
						local image = object.properties.sprite
						if image then
							tasks[image] = Task {type = "image", file = image:match("%.%./(.*)")}
						end
					end
				end
			end
			-- Load battle bgs from map properties, if present
			if mapData.properties.battlebg then
				local image = mapData.properties.battlebg
				tasks[image] = Task {type = "image", file = image:match("%.%./(.*)")}
			end
			-- Load bgm, if present
			local bgmRes
			if mapData.properties.bgm then
				local bgm = mapData.properties.bgm
				local bgmRes = bgm:match("%.%./(.*)")
				tasks[bgm] = Task {type = "sound", file = bgmRes, category = "music"}
			end
			
			if data.primary then
				self.primaryMap = data.file
			end
			mapData.music = bgmRes and bgmRes:match("/(%w+)%.") or data.music
			mapData.ambient = data.ambient
			self.maps[data.file] = mapData
		-- Otherwise, load data by type
		else
			tasks[data.file or data.name] = Task(data)
		end
	end
	
	return self:loadingAnimation(tasks)
end

function Region:loadingAnimation(tasks)
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
	
	local loadingTextAnim = Action()
	local loadingTextFade = Action()
	if not self.args.noloadingtext then
		loadingTextAnim = Serial {
			loadingText,
			Repeat(loadingDots, nil, false),
			isPassive = true
		}
		loadingTextFade = Parallel {
			Ease(loadingText.color, 4, 0, 2),
			Ease(loadingDots.color, 4, 0, 2)
		}
	end
	
	self.bgColor = {0,0,0,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	return Serial {
		-- Load sonic sprite first
		self.loadSonicSprite,
		Do(function()
			return SpriteNode(self, Transform(550, 530, 2, 2), nil, "sonicloading", nil, nil, "ui")
		end),
		
		Parallel {
			-- Loads maps, images, sounds
			Parallel(tasks),
			
			-- Fade in screen
			Ease(self.bgColor, 1, 255, self.args.fadeInSpeed or 1),
			Ease(self.bgColor, 2, 255, self.args.fadeInSpeed or 1),
			Ease(self.bgColor, 3, 255, self.args.fadeInSpeed or 1),
			Do(function() ScreenShader:sendColor("multColor", self.bgColor) end),

			-- Animated "Loading..." text
			loadingTextAnim
		},
		
		-- Fade out loading text
		loadingTextFade,

		-- Initialize scene with loaded resources
		Do(function() self:finalize() end)
	}
end

function Region:getTilesetProcessor()
	return string.dump(function(hex)
		return function(_, _, r, g, b, a)
			if hex:sub(1, 1) == "#" then
				hex = hex:sub(2)
			end
			local mask = {
				r = tonumber(hex:sub(1, 2), 16),
				g = tonumber(hex:sub(3, 4), 16),
				b = tonumber(hex:sub(5, 6), 16)
			}
			if  r == mask.r and
				g == mask.g and
				b == mask.b then
				return r, g, b, 0
			end
			return r, g, b, a
		end
	end)
end

function Region:finalize()
	-- Construct maps
	local sti = require "lib/tiled/sti"
	for filename,map in pairs(self.maps) do
  	    -- Inject tileset image into map
		for _,tileset in pairs(map.tilesets) do
		    local img = self.images[tileset.image:match("/(%w+)%.")]
			img:setFilter("nearest", "nearest")
			tileset.image = img
		end
		
		-- Inject imagelayer image
		for _,layer in pairs(map.layers) do
			if layer.image then
				print("Loading layer image "..tostring(layer.image))
				local img = self.images[layer.image:match("/(%w+)%.")]
				img:setFilter("nearest", "nearest")
				layer.image = img
			end
		end
		
		-- Inject battlebg
		if map.properties.battlebg then
			local name = map.properties.battlebg
			local img = self.images[name:match("/(%w+)%.")]
			img:setFilter("nearest", "nearest")
			map.properties.battlebg = img
		end

		local mapSti = sti(map)
		
		for _,layer in ipairs(mapSti.layers) do
			-- Find collision map
			if layer.name == "Collision" then
				mapSti.collisionMap = layer.data
			elseif layer.name == "BunnyExtCollision" then
				mapSti.bunnyExtCollisionMap = layer.data
			end
			
			-- Update y offset of all objects (why is this necessary???)
			if layer.objects then
				for _,object in ipairs(layer.objects) do
					object.y = object.y - object.height
				end
			end
		end

		self.maps[filename] = mapSti
	end
	
	self.isReady = true
	
	-- Transition to primary scene
	self:goToNext()
end

function Region:goToNext()
	if self.isReady then
		local mapName = self.args.map or self.primaryMap
		local map = self.maps[mapName]
		map.music = self.args.nextMusic
		
		collectgarbage("collect")
		
		-- Transition to primary scene
		self.sceneMgr:switchScene {
			class = "BasicScene",
			mapName = mapName,
			map = map,
			maps = self.maps,
			images = self.images,
			animations = self.animations,
			audio = self.audio,
			fadeInSpeed = self.args.fadeInSpeed or 0.2,
			region = self.args.manifest,
			spawn_point = self.args.spawn_point,
			hint = self.args.hint,
			nighttime = self.args.nighttime,
			tutorial = self.args.tutorial,
			fadeOutSpeed = self.args.fadeOutSpeed,
			fadeOutMusic = self.args.fadeOutMusic,
			cache = true
		}
	end
end


return Region
