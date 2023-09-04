local Transform = require "util/Transform"
local Layout = require "util/Layout"

local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Menu = require "actions/Menu"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Do = require "actions/Do"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local Spawn = require "actions/Spawn"
local While = require "actions/While"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"
local BlockPlayer = require "actions/BlockPlayer"
local YieldUntil = require "actions/YieldUntil"

local Subscreen = require "object/Subscreen"

local shine = require "lib/shine"

local Scene = require "scene/Scene"

local BasicScene = class(Scene)

function BasicScene:onEnter(args)
	self:pushLayer("tiles")
	
	self.lastSpawnPoint = args.spawn_point or "Spawn 1"
	
	self.spawnPoints = {}
	
	self.region = args.region
	self.mapName = args.mapName
	self.map = args.map

	self.map.objects = {}
	self.objectLookup = {}
	
	self.maps = args.maps
	self.images = args.images
	self.animations = args.animations or {}
	self.audio = args.audio
	self.mboxGradient = args.images["mboxgradient"]
	self.camPos = Transform()
	self.tutorial = args.tutorial
	self.nighttime = args.nighttime or self.map.properties.nighttime
	self.noBattleMusic = self.map.properties.noBattleMusic
	self.layered = self.map.properties.layered
	self.currentLayerId = self.map.properties.currentLayer or 1
	self.currentLayer = "objects"..(self.currentLayerId > 1 and tostring(self.currentLayerId) or "")

	self.args = args
	self.cacheSceneData = args.cache

	-- Cache collision layers
	self.collisionLayer = {}
	for _,layer in pairs(self.map.layers) do
		if layer.name == "Collision" then
			self.collisionLayer["objects"] = layer.data
		elseif layer.name == "Collision2" then
			self.collisionLayer["objects2"] = layer.data
		elseif layer.name == "Collision3" then
			self.collisionLayer["objects3"] = layer.data
		elseif layer.name == "Collision4" then
			self.collisionLayer["objects4"] = layer.data
		end
	end
	
	-- NOTE: This is how we draw the lua map data
	-- There is a draw function on the sti map object.
	-- All our SceneNode drawing interface requires is a
	-- draw function, so this works out fine.
	self:addNode(self.map, "tiles")

	if self.nighttime and not self.map.properties.ignorenight then
		self.originalMapDraw = self.map.drawTileLayer
		self.originalImgDraw = self.map.drawImageLayer
		self.map.drawTileLayer = function(map, layer)
			if not self.night then
				self.night = shine.nightcolor()
			end
			self.night:draw(function()
				self.night.shader:send("opacity", layer.opacity or 1)
				self.night.shader:send("lightness", 1 - (layer.properties.darkness or 0))
				self.originalMapDraw(map, layer)
			end)
		end
		self.map.drawImageLayer = function(map, layer)
			if not self.night then
				self.night = shine.nightcolor()
			end
			if layer.properties.nonight then
				self.originalImgDraw(map, layer)
			else
				self.night:draw(function()
					self.night.shader:send("opacity", layer.opacity or 1)
					self.night.shader:send("lightness", 1 - (layer.properties.darkness or 0))
					self.originalImgDraw(map, layer)
				end)
			end
		end
	end
	
	local placeholder
	local classCache = {}
	for _,layer in ipairs(self.map.layers) do
		-- Initialize map objects
		if layer.objects then
			self:pushLayer(layer.name, true)

			local drawFun = layer.draw
			layer.draw = function()
				drawFun()
				self:sortedDraw(layer.name)
			end
			
			for _,object in pairs(layer.objects) do
				if not classCache[object.type] then
					-- Dynamically load classes at most once
					classCache[object.type] = require ("object/"..object.type)
				end
				
				if object.type ~= "Player" or object.name == self.lastSpawnPoint then
					local objRef = (classCache[object.type])(self, layer, object)
					self.objectLookup[object.name] = objRef
					self:addObject(objRef)
				end
				
				-- If object is marked as a player spawn location
				if  object.type == "Player" or
					object.type == "TinyPlayer" or
					object.type == "SnowboardPlayer" or
					object.type == "EscapePlayer" or
					object.type == "EscapePlayerVert" or
					object.type == "SavePoint" or
					object.type == "SceneEdge" or
					object.type == "Door" or
					object.type == "SpawnPoint"
				then
					self.spawnPoints[object.name] = object
				end
				
				-- If object is marked as "fallable"
				if object.properties.fallable then
					if not self.map.fallables then
						self.map.fallables = {}
					end
					table.insert(self.map.fallables, object)
				end
			end
		end
		
		-- Initialize layer-level objects
		local classType = layer.properties.type
		if classType then
			if not classCache[classType] then
				-- Dynamically load classes at most once
				classCache[classType] = require ("object/"..classType)
			end
			local objRef = (classCache[classType])(self, layer)
			self.objectLookup[layer.name] = objRef
			self:addObject(objRef)
		end
	end
	
	self:pushLayer("ui")
	
	-- Play music/sambient sound on start
	if self.map.music then
		self.audio:setMusicVolume(1.0)
		self.audio:playMusic(self.map.music)
	end
	
	if self.map.ambient then
		self.audio:playAmbient(self.map.ambient)
	end
	
	local onLoadAction = Action()
	if self.map.properties.onload then
		onLoadAction = love.filesystem.load("maps/"..self.map.properties.onload)()(self, args.hint)
	end
	
	-- Pan to player
	local toLayer
	if self.player then
		-- Place player at spawn point and orient them appropriately
		if self.lastSpawnPoint then
			local spawn = self.spawnPoints[self.lastSpawnPoint]
			local spawnNpc = self.objectLookup[spawn.name]
			toLayer = spawnNpc.layer.name

			local spawnOffset = args.spawn_point_offset or
				Transform(spawn.width/2, spawn.height/2)
			if not self.player.object.properties.strictLocation then
				-- Place player
				self.player.x = spawn.x + spawnOffset.x
				self.player.y = spawn.y + spawnOffset.y - self.player.height
			end
				
			-- Reset player state
			self.player.doingSpecialMove = false
			self.player.ignoreSpecialMoveCollision = false
			self.player.state = spawn.properties.orientation and "idle"..spawn.properties.orientation or "idledown"
			
			-- Restart special move, if necessary
			if args.doingSpecialMove and GameState.leader == "sonic" then
				self.player.basicUpdate = function(p, dt) end
				self.player.sprite.visible = false
				self.player:run(BlockPlayer {
					Wait(0.5),
					YieldUntil(function()
						return not self.cinematicPause
					end),
					Do(function()
						self.player.skipChargeSpecialMove = true
						self.player.sprite.visible = true
						self.player:onSpecialMove()
					end)
				})
			else
				self.player.basicUpdate = self.player.origUpdate or self.player.basicUpdate
				self.player:updateSprite()
			end
			
			-- Make sure we render the camera in the correct spot now before fade-in
			self:update(0)
		end
	end
	
	self.initialized = true
	
	-- Post init
	for _, obj in pairs(self.map.objects) do
		obj:postInit()
	end
	
	--[[ Create nodes for collision map
	self.pathingNodes = {}
	for y=1,self.map.height do
		for x=1,self.map.width do
			local px,py = self:collisionCoordToWorldCoord(x, y)
			table.insert(self.pathingNodes, {x=px, y=py, canMove=not self.map["collisionMap"][y][x]})
		end
	end]]

	-- Fade in scene
	local fadeInSpeed = args.fadeInSpeed or 1.0
	self.bgColor = {0,0,0,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	
	if GameState.leader == "bunny" then
		print("no special move")
		self.player.noSpecialMove = true
	end
	
	return Serial {
		args.enterDelay and Wait(args.enterDelay) or Action(),
		Do(function()
			-- Swap layer, if applicable
			if self.layered and toLayer then
				local layerId = toLayer:gsub("objects", "")
				self:swapLayer(layerId ~= "" and tonumber(layerId) or 1)
			end
		end),
		Spawn(
			Serial {
				Parallel {
					Ease(self.bgColor, 1, 255, 2 * fadeInSpeed, "linear"),
					Ease(self.bgColor, 2, 255, 2 * fadeInSpeed, "linear"),
					Ease(self.bgColor, 3, 255, 2 * fadeInSpeed, "linear"),
					
					Do(function()
						ScreenShader:sendColor("multColor", self.bgColor)
					end)
				}
			}
		),
			
		onLoadAction,
		
		Do(function()
			self:addHandler("keytriggered", BasicScene.mainInput, self)
			
			if GameState.leader == "bunny" then
				print("yes special move")
				self.player.noSpecialMove = false
			end
		end)
	}
end

function BasicScene:onReEnter(args)
	print("re-enter")

	-- Recreate player
	self.player:remove()
	local prevPlayer = self.player
	local PlayerClass = require("object/"..(prevPlayer.playerType or "Player"))
	self.player = PlayerClass(self, self.player.layer, self.player.object)
	self.player.x = prevPlayer.x
	self.player.y = prevPlayer.y

	-- Place player at spawn point and orient them appropriately
	local toLayer = self.currentLayer
	if args.spawn_point then
		local spawn = self.spawnPoints[args.spawn_point]
		local spawnNpc = self.objectLookup[spawn.name]
		toLayer = spawnNpc.layer.name
		local spawnOffset = args.spawn_point_offset or
			Transform(spawn.width/2, spawn.height/2)
		self.player.x = spawn.x + spawnOffset.x
		self.player.y = spawn.y + spawnOffset.y - self.player.height
		
		-- Reset player state
		self.player.doingSpecialMove = false
		self.player.ignoreSpecialMoveCollision = false
		self.player.state = spawn.properties.orientation and "idle"..spawn.properties.orientation or "idledown"
		
		-- Restart special move, if necessary
		if args.doingSpecialMove and GameState.leader == "sonic" then
			self.player.basicUpdate = function(p, dt) end
			self.player.sprite.visible = false
			self.player:run(BlockPlayer {
				Wait(0.5),
				YieldUntil(function()
					return not self.cinematicPause
				end),
				Do(function()
					self.player.skipChargeSpecialMove = true
					self.player.sprite.visible = true
					self.player:onSpecialMove()
				end)
			})
		else
			self.player.basicUpdate = self.player.origUpdate
			self.player:updateSprite()
		end
	end
	
	self.reenteringFromBattle = self.enteringBattle
	self.enteringBattle = false
	self.player.cinematic = false
	self.reentering = true
	self.nighttime = args.nighttime
	
	self.blur = nil
	
	for _, obj in pairs(self.map.objects) do
		if obj.flagForDeletion then
			obj:remove()
		elseif obj.onEnter then
			obj:onEnter()
		end
	end

	local onLoadAction = Action()
	if self.map.properties.onload then
		onLoadAction = love.filesystem.load("maps/"..self.map.properties.onload)()(self, args.hint)
	end

	local fadeInSpeed = args.fadeInSpeed or 1.0
	self.bgColor = {0,0,0,255}
	ScreenShader:sendColor("multColor", self.bgColor)
	
	if GameState.leader == "bunny" then
		self.player.noSpecialMove = true
	end
	return Serial {
		Do(function()
			self.player.cinematicStack = 1

			-- Swap layer, if applicable
			if self.layered and toLayer then
				local layerId = toLayer:gsub("objects", "")
				self:swapLayer(layerId ~= "" and tonumber(layerId) or 1)
			end
		end),
	
		Parallel {
			-- Fade in
			Ease(self.bgColor, 1, 255, 2 * fadeInSpeed, "linear"),
			Ease(self.bgColor, 2, 255, 2 * fadeInSpeed, "linear"),
			Ease(self.bgColor, 3, 255, 2 * fadeInSpeed, "linear"),
			Do(function()
				ScreenShader:sendColor("multColor", self.bgColor)
			end)
		},
		
		Do(function()
			self.player.cinematicStack = 0
		end),
		
		onLoadAction,
		
		Do(function()
			self.player.cinematicStack = 0
			self.reentering = false
			self.reenteringFromBattle = false
			
			if GameState.leader == "bunny" then
				self.player.noSpecialMove = false
			end
		end)
	}
end

function BasicScene:onExit(args)
	local fadeOutSpeed = args.fadeOutSpeed or 1.0
	ScreenShader:sendColor("multColor", self.bgColor)
	
	local fadeMusicOrNoop = Action()
	if args.fadeOutMusic then
		fadeMusicOrNoop = AudioFade(
			"music",
			self.audio:getMusicVolume(),
			0,
			2 * fadeOutSpeed,
			"linear"
		)
	end
	
	local fadeAction = Action()
	if not args.noFade then
		fadeAction = Parallel {
			fadeMusicOrNoop,
		
			-- Fade to black
			Ease(self.bgColor, 1, 0, 2 * fadeOutSpeed, "linear"),
			Ease(self.bgColor, 2, 0, 2 * fadeOutSpeed, "linear"),
			Ease(self.bgColor, 3, 0, 2 * fadeOutSpeed, "linear"),
			Do(function()
				ScreenShader:sendColor("multColor", self.bgColor)
			end)
		}
	end
	
	return BlockPlayer {
		fadeAction,
		Do(function()
			if not self.enteringBattle and not args.tutorial then
				if args.manifest then
					self.sceneMgr:cleanup()
					print("done with cleanup")
				else
					self:remove()
				end
			end
		end)
	}
end

function BasicScene:hasUpperLayer()
	for _, layer in pairs(self.map.layers) do
		if layer.name == "upper" and layer.type == "objectgroup" then
			return true
		end
	end
	return false
end

function BasicScene:lightningFlash()
	if not BasicScene.flashShader then
		local script = [[
			vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
			{
			    return vec4(1,1,1,0) + Texel(tex, tc);
			}
		]]
		BasicScene.flashShader = love.graphics.newShader(script)
	end
	return Serial {
		Do(function()
			self.lightFlash = true
		end),
		Wait(0.1),
		Do(function()
			self.lightFlash = false
		end)
	}
end

function BasicScene:fadeIn(speed)
	speed = speed or 1
	return Parallel {
		-- Fade from black
		Ease(self.bgColor, 1, 255, 2 * speed, "linear"),
		Ease(self.bgColor, 2, 255, 2 * speed, "linear"),
		Ease(self.bgColor, 3, 255, 2 * speed, "linear"),
		Do(function()
			ScreenShader:sendColor("multColor", self.bgColor)
		end)
	}
end

function BasicScene:fadeOut(speed)
	speed = speed or 1
	return Parallel {
		-- Fade to black
		Ease(self.bgColor, 1, 0, 2 * speed, "linear"),
		Ease(self.bgColor, 2, 0, 2 * speed, "linear"),
		Ease(self.bgColor, 3, 0, 2 * speed, "linear"),
		Do(function()
			ScreenShader:sendColor("multColor", self.bgColor)
		end)
	}
end

function BasicScene:remove(cleanupResources)
	if self.cleaned then -- Already cleaned up
		return
	end
	if cleanupResources then
		print("clean up map")
		self.audio:cleanup()
		self.audio = nil
		self.images = nil
		self.animations = nil
		self.mboxGradient = nil
		self:removeNode(self.map)
		for _, map in pairs(self.maps) do
			if map.layers then
				for _,layer in pairs(map.layers) do
					layer.image = nil
				end
			end
			if map.objects then
				for _, obj in pairs(map.objects) do
					if obj.remove then
						obj:remove()
						obj.sprite:remove()
						obj.sprite:cleanup()
					end
				end
			end
		end
	else
		-- Delete all map objects
		for _, obj in pairs(self.map.objects) do
			obj:remove()
		end
		self.map.drawTileLayer = self.originalMapDraw
		self.map.drawImageLayer = self.originalImgDraw
		self.map.objects = nil
		self.map.fallables = nil
		self:removeNode(self.map)
	end

	self.objectLookup = nil

	self:cleanupLayers()
	self.handlers = {}

	self.player:remove()
	self.player = nil

	self:cleanupLayers()

	if cleanupResources then
		self.map = nil
		self.maps = nil
		self.cleaned = true
	end

	print("destroying cur scene")
end

function BasicScene:restart(args)
	self.isRestarting = true
	args = args or {}
	args.mapName = self.mapName
	args.spawnPoint = args.spawnPoint or self.lastSpawnPoint or "Spawn 1"
	self:changeScene(args)
end

function BasicScene:changeScene(args)
	local mapName = args.mapName or "maps/"..args.map..".lua"
	local fun = args.fun or "switchScene"
	
	if args.manifest then
		for k,_ in pairs(self.maps) do
			if k ~= mapName then
				self.maps[k] = nil
			end
		end

		self.sceneMgr:switchScene {
			class = "Region",
			manifest = string.format("maps/%s.lua", args.manifest),
			images = self.images,
			audio = self.audio,
			animations = self.animations,
			hint = args.hint,
			tutorial = args.tutorial,
			fadeOutSpeed = args.fadeOutSpeed,
			fadeInSpeed = args.fadeInSpeed,
			fadeOutMusic = args.fadeOutMusic,
			spawn_point = args.spawnPoint,
			nighttime = args.nighttime,
			enterDelay = args.enterDelay
		}
	else
		print("change scene...")
		self.sceneMgr[fun](self.sceneMgr, {
			class = "BasicScene",
			map = self.maps[mapName],
			mapName = mapName,
			maps = self.maps,
			images = self.images,
			region = self.region,
			animations = self.animations,
			audio = self.audio,
			spawn_point = args.spawnPoint,
			hint = args.hint,
			tutorial = args.tutorial,
			fadeOutSpeed = args.fadeOutSpeed,
			fadeInSpeed = args.fadeInSpeed,
			fadeOutMusic = args.fadeOutMusic,
			cache = args.cache,
			nighttime = args.nighttime,
			enterDelay = args.enterDelay
		})
	end
end

-- Vertical screen shake
function BasicScene:screenShake(str, sp, rp, noReset)
	local strength = str or 50
	local speed = sp or 15
	local repeatTimes = rp or 1
	
	return Serial {
		Do(function()
			self.isScreenShaking = true
		end),
		
		Repeat(Serial {
			Ease(self.camPos, "y", function() return self.camPos.y - strength end, speed, "quad"),
			Ease(self.camPos, "y", function() return self.camPos.y + strength end, speed, "quad")
		}, repeatTimes),
		
		Ease(self.camPos, "y", function() return self.camPos.y - strength/2 end, speed, "quad"),
		Ease(self.camPos, "y", function() return self.camPos.y + strength/2 end, speed, "quad"),
		
		Do(function()
			self.isScreenShaking = false
			if not noReset then
				self.camPos.y = 0
			end
		end)
	}
end

function BasicScene:addObject(object)
	self.map.objects[tostring(object)] = object
end

function BasicScene:removeObject(object)
	if self.map.objects then
		self.map.objects[tostring(object)] = nil
	end
end

function BasicScene:enterBattle(args)
	if self.enteringBattle or next(args.opponents) == nil then
		return Action()
	end
	local oppostr = ""
	for k,v in pairs(args.opponents) do
		oppostr = oppostr..v..", "
	end
	print("entering battle against... "..oppostr)
	if not self.blur then
		self.blur = shine.boxblur()
		self.blur.radius_v = 0.0
		self.blur.radius_h = 0.0
	end
	return Serial {
		Do(function()
			self.player.cinematic = true
			self.enteringBattle = true
			self:invoke("onEnterBattle")

			self.bgColor = {255,255,255,255}
			ScreenShader:sendColor("multColor", self.bgColor)
		end),
	
		-- Fade out current music
		self.noBattleMusic and
			Action() or
			AudioFade("music", self.audio:getMusicVolume(), 0, 1),

		-- Play enter battle sfx
		PlayAudio("sfx", "battlestart", 1.0, true),

		-- Motion blur + fade to black + fade music
		Ease(self.blur, "radius_h", 150, 2),
		
		args.beforeBattle or Action(),
		
		Do(function()
			self.audio.allowDucking = false
			self.sceneMgr:pushScene {
				class = "BattleScene",
				audio = self.audio,
				images = self.images,
				animations = self.animations,
				background = self.map.properties.battlebg,
				nextMusic = self.noBattleMusic and self.audio:getCurrentMusic() or args.music,
				prevMusic = args.prevMusic or self.audio:getCurrentMusic(),
				noBattleMusic = self.noBattleMusic,
				blur = self.blur,
				opponents = args.opponents,
				bossBattle = args.bossBattle,
				initiative = args.initiative,
				color = args.color,
				practice = args.practice,
				onEnter = args.onEnter,
				arrowColor = args.arrowColor
			}
		end),
		
		Do(function()
			
		end)
	}
end

function BasicScene:mainInput(key, uni)
	-- Open subscreen
	if key == "z" and
		not self.player.cinematic and
		self.player.cinematicStack == 0 and
		(not self.subscreen or
			(self.subscreen.isRemoved and self.subscreen:isRemoved()))
	then
		self.subscreen = Subscreen(self, Transform(100, 15), {255,255,255,255}, self.mboxGradient)
	end
end

function BasicScene:keytriggered(key, uni)
	if key == "escape" then
		if self.tutorial then
			if self.showingEscapeMenu then
				return
			end
			self.showingEscapeMenu = true
			
			self:run(BlockPlayer{ Menu {
				layout = Layout {
					{Layout.Text("Exit tutorial?"), selectable = false},
					{Layout.Text("Yes"), choose = function(menu)
						menu:close()
						self:run {
							menu,
							Do(function() self.sceneMgr:popScene{} end),
							Do(function() end)
						}
					end},
					{Layout.Text("No"),
						choose = function(menu)
							menu:close()
							self:run {
								menu,
								Do(function() self.showingEscapeMenu = false end)
							}
						end},
					colWidth = 200
				},
				transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
				selectedRow = 2,
				cancellable = true
			}})
		else
			if self.showingEscapeMenu then
				love.event.quit()
			end
			self.showingEscapeMenu = true
			
			self:run(BlockPlayer{ Menu {
				layout = Layout {
					{Layout.Text("Exit game?"), selectable = false},
					{Layout.Text("Yes"), choose = love.event.quit},
					{Layout.Text("No"),
						choose = function(menu)
							menu:close()
							self:run {
								menu,
								Do(function() self.showingEscapeMenu = false end)
							}
						end},
					colWidth = 200
				},
				transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
				selectedRow = 2,
				cancellable = true
			}})
		end
    end
end

function BasicScene:playerMovable()
	return  (self.initialized) and
			(not self.mbox or self.mbox:isDone()) and
			(not self.subscreen or (self.subscreen.isRemoved and self.subscreen:isRemoved())) and
			not self.enteringBattle and
			not self.pausePlayer
end

function BasicScene:pauseEnemies(active)
	for _, object in pairs(self.map.objects) do
		if object.isBot then
			object.pauseMove = active
		end
	end
end

function BasicScene:pan(worldOffsetX, worldOffsetY)
	if worldOffsetX > 0 then
		worldOffsetX = self.camPos.x
	elseif worldOffsetX < -(self:getMapWidth() - love.graphics.getWidth()) then
		worldOffsetX = -(self:getMapWidth() - love.graphics.getWidth()) + self.camPos.x
	end

	if worldOffsetY > 0 then
		worldOffsetY = self.camPos.y
	elseif worldOffsetY < -(self:getMapHeight() - love.graphics.getHeight()) then
		worldOffsetY = -(self:getMapHeight() - love.graphics.getHeight())-- + self.camPos.y
	end

	for _,obj in pairs(self.map.objects) do
		if obj.sprite and not obj.hidden and obj.sprite.transform and obj.x then
			if obj.layer and obj.layer.properties and obj.layer.properties.movespeed then
				obj.sprite.transform.x = math.floor((obj.x + worldOffsetX)*obj.layer.properties.movespeed)
				obj.sprite.transform.y = math.floor((obj.y + worldOffsetY)*obj.layer.properties.movespeed)
			else
				obj.sprite.transform.x = math.floor(obj.x + worldOffsetX)
				obj.sprite.transform.y = math.floor(obj.y + worldOffsetY)
			end
		end
	end
	
	for _,layer in ipairs(self.map.layers) do
		if not layer.image then
			layer.x = layer.offsetx + worldOffsetX
			layer.y = layer.offsety + worldOffsetY
		elseif layer.properties.type ~= "Parallax" then
			layer.x = math.floor((layer.offsetx + worldOffsetX)*(layer.properties.movespeed or 1.05))
			layer.y = math.floor((layer.offsety + worldOffsetY)*(layer.properties.movespeed or 1.05))
			
			-- If image layer is configured to shimmer, setup a shimmer cycle and remove config
			if layer.properties.shimmer then
				local originalOpacity = layer.opacity
				Executor(self):act(
					Repeat(
						Serial {
							Ease(layer, "opacity", originalOpacity/1.5, 3, "quad"),
							Ease(layer, "opacity", originalOpacity, 3, "quad")
						}
					)
				)
				layer.properties.shimmer = nil
			end
		end
	end
end

function BasicScene:updatePlayerPos()
	local xCap = love.graphics.getWidth()/2
	local yCap = love.graphics.getHeight()/2
	if self.player.doingSpecialMove then
		--xCap = self.player.sprite.w*4
	end

	if  self.player.x < xCap then
		self.player.sprite.transform.x = math.floor(self.player.x - self.player.width + self.camPos.x)
	elseif self.player.x > self:getMapWidth() - xCap then
		self.player.sprite.transform.x = math.floor(self.player.x - (self:getMapWidth() - love.graphics.getWidth()) - self.player.width + self.camPos.x)
	else
		self.player.sprite.transform.x = math.floor(xCap - self.player.width + self.camPos.x)
	end
	
	if  self.player.y < yCap then
		self.player.sprite.transform.y = math.floor(self.player.y - self.player.height + self.camPos.y)
	elseif self.player.y > self:getMapHeight() - yCap then
		self.player.sprite.transform.y = math.floor(self.player.y - (self:getMapHeight() - love.graphics.getHeight()) - self.player.height + self.camPos.y)
	else
		self.player.sprite.transform.y = math.floor(yCap - self.player.height + self.camPos.y)
	end
end

function BasicScene:update(dt)
	Scene.update(self, dt)

	-- Cannot move while subscreen is up
	if (not self.player or not self:playerMovable()) and
		not self.pausePlayer
	then
		return
	end
	
	if not self.timer then
		self.timer = 0
	end
	self.timer = self.timer + dt
	if self.timer > 1 then
		--print("num objects in scene = "..tostring(table.count(self.map.objects)))
		self.timer = 0
	end

	local panX = self.panX or self.player.x
	local panY = self.panY or self.player.y
	
	-- Shift tiles based on player position
	local worldOffsetX = math.floor((-panX + love.graphics.getWidth()/2))
	local worldOffsetY = math.floor((-panY + love.graphics.getHeight()/2))
	self:pan(
		math.floor((worldOffsetX + self.camPos.x)),
		math.floor((worldOffsetY + self.camPos.y))
	)

	if not self.panX and not self.panY then
		self:updatePlayerPos()
	end
end

function BasicScene:getMapWidth()
	if not self.mapWidth then
		self.mapWidth = self.map.width * self:getTileWidth()
	end
	return self.mapWidth
end

function BasicScene:getMapHeight()
	if not self.mapHeight then
		self.mapHeight = self.map.height * self:getTileHeight()
	end
	return self.mapHeight
end

function BasicScene:worldCoordToCollisionCoord(x, y)
	return math.floor(x/self.map.tilewidth)+1, math.floor(y/self.map.tileheight)+1
end

function BasicScene:screenCoordToWorldCoord(x, y)
	local xcoord
	local ycoord

	if self.player.x >= (self:getMapWidth() - love.graphics.getWidth()/2) then
		xcoord = x + self.player.x - love.graphics.getWidth()/2 - (self.player.x - (self:getMapWidth() - love.graphics.getWidth()/2))
	elseif self.player.x <= love.graphics.getWidth()/2 then
		xcoord = x
	else
		xcoord = x + self.player.x - love.graphics.getWidth()/2
	end
	
	if self.player.y >= (self:getMapHeight() - love.graphics.getHeight()/2) then
		ycoord = y + self.player.y - love.graphics.getHeight()/2 - (self.player.y - (self:getMapHeight() - love.graphics.getHeight()/2))
	elseif self.player.y <= love.graphics.getHeight()/2 then
		ycoord = y
	else
		ycoord = y + self.player.y - love.graphics.getHeight()/2
	end

	return xcoord, ycoord
end

function BasicScene:collisionCoordToWorldCoord(x, y)
	return (x-1) * self.map.tilewidth, (y-1) * self.map.tileheight
end

function BasicScene:getTileWidth()
	return self.map.tilewidth
end

function BasicScene:getTileHeight()
	return self.map.tileheight
end

function BasicScene:canMove(x, y, dx, dy, mapName)
	mapName = mapName or "collisionMap"
	-- Special case for map boundaries
	if  (x + dx) <= 0 or
		(x + dx) >= self:getMapWidth() or
		(y + dy) <= 0 or
		(y + dy) >= self:getMapHeight()
	then
		return false
	end
	local mapx, mapy = self:worldCoordToCollisionCoord(x + dx, y + dy)
	return not self.map[mapName][mapy][mapx]
end

function BasicScene:canMoveWhitelist(x, y, dx, dy, whiteList, collisionLayer)
	collisionLayer = collisionLayer or self.map.collisionMap
	-- Special case for map boundaries
	if  (x + dx) <= 0 or
		(x + dx) >= self:getMapWidth() or
		(y + dy) <= 0 or
		(y + dy) >= self:getMapHeight()
	then
		return false
	end
	local mapx, mapy = self:worldCoordToCollisionCoord(x + dx, y + dy)
	return not collisionLayer[mapy][mapx] or (whiteList and whiteList[mapy] and whiteList[mapy][mapx])
end

function BasicScene:swapLayer(toLayerNum)
	-- Swap object layer (assumes naming convention of "objects" or "objectsN"
	local layerStr = tostring(toLayerNum)
	local objLayer = toLayerNum == 1 and "objects" or ("objects"..layerStr)
	self.player.sprite:swapLayer(objLayer)
	if not self.player.dropShadow:isRemoved() then
		self.player.dropShadow.sprite:swapLayer(objLayer)
	end
	self.player.onlyInteractWithLayer = objLayer
	self.player.layer = {name = objLayer}
	self.currentLayer = objLayer
	self.currentLayerId = toLayerNum

	-- Swap collision layer (assumes naming convention of "Collision" or "CollisionN"
	self.map.collisionMap = self.collisionLayer[objLayer]

	-- Update collision map with objects on same layer
	for _, obj in pairs(self.map.objects) do
		if obj.layer.name == objLayer then
			obj:updateCollision()
		end
	end
end

function BasicScene:draw()
	if self.blur then
		self.blur:draw(function()
			love.graphics.setDefaultFilter("nearest", "nearest")
			Scene.draw(self)
		end)
	elseif self.lightFlash then
		local prevShader = love.graphics.getShader()
		love.graphics.setDefaultFilter("nearest", "nearest")
		love.graphics.setShader(BasicScene.flashShader)
		Scene.draw(self)
		love.graphics.setShader(prevShader)
	else
		love.graphics.setDefaultFilter("nearest", "nearest")
		Scene.draw(self)
	end
end


return BasicScene