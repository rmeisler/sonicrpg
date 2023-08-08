local Menu = require "actions/Menu"
local Do = require "actions/Do"
local Serial = require "actions/Serial"
local Action = require "actions/Action"
local Animate = require "actions/Animate"
local Ease = require "actions/Ease"

local Player = require "object/Player"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local NPC = require "object/NPC"
local SceneEdge = class(NPC)

function SceneEdge:construct(scene, layer, object)
	NPC.init(self)
	
	self.readyMsg = self.object.properties.readyMsg
	self.ignoreSpawnOffset = self.object.properties.ignore_spawn_offset
	self.needFlag = self.object.properties.needFlag
	
	if object.properties.onLeave then
		self.onLeave = assert(loadstring(object.properties.onLeave))()
	else
		self.onLeave = function(self) return Action() end
	end

	if scene.lastSpawnPoint == self.name then
		scene.player = Player(self.scene, self.layer, table.clone(self.object))
	end
	
	if GameState:isFlagSet(self) and self.sprite then
		self.sprite:setAnimation("open")
	end
end

function SceneEdge:open()
	if self.needFlag then
		return Serial {
			Animate(self.sprite, "opening"),
			Animate(self.sprite, "open"),
			Do(function() GameState:setFlag(self) end)
		}
	end
	return Action()
end

function SceneEdge:update(dt)
	NPC.update(self, dt)
	
	if self.state ~= self.STATE_TOUCHING and self.readyMsgShowing then
		self.readyMsgShowing = false
	end
	
	if  not self.scene.sceneMgr.transitioning and
		self.state == self.STATE_TOUCHING and
		(love.keyboard.isDown(self.object.properties.key) or
			(GameState.leader == "sonic" and self.scene.player.doingSpecialMove and
			 self.scene.player:isFacing(self.object.properties.key))) and
		not self.readyMsgShowing and
		(not self.needFlag or GameState:isFlagSet(self))
	then
		if self.readyMsg then
			self.readyMsgShowing = true
			self.scene.player.cinematic = true
			local menu = Menu {
				layout = Layout {
					{Layout.Text(self.readyMsg), selectable = false},
					{Layout.Text("Yes"),
						choose = function(menu)
							self:goToScene()
							menu:disable()
						end},
					{Layout.Text("No"),
						choose = function(menu)
							menu:close()
							self.scene.player.cinematic = false
						end},
					colWidth = 200
				},
				transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
				selectedRow = 2,
				cancellable = true,
				blocking = true
			}
			self.scene:run {
				menu,
				Do(function()
					if not self.scene.sceneMgr.transitioning then
						self.scene.player.cinematic = false
					end
				end)
			}
		else
			self:goToScene()
		end
	end
end

function SceneEdge:goToScene()
	--[[ Spawn offset based on whether this is a horizontal, vertical, or single-tile (do nothing) exit
	local spawnOffset = Transform()
	if self.object.width > self.object.height then
		spawnOffset.x = math.max(0, self.scene.player.x - self.object.x - self.scene:getTileWidth())
	elseif self.object.height > self.object.width then
		spawnOffset.y = self.scene.player.y - self.object.y
	end]]
	local mapName = "maps/"..self.object.properties.scene
	
	self.scene.player.ignoreSpecialMoveCollision = true
	self.scene.player.cinematicStack = 1
	
	if self.object.properties.key == "up" then
		self.scene.player:run {
			Do(function()
				if next(self.scene.player.ladders) == nil then
					self.scene.player.noIdle = true
					self.scene.player.sprite:setAnimation("walkup")
				end
			end),
			
			Ease(self.scene.player, "y", self.scene.player.y - 100, 3, "linear"),
			
			Do(function()
				if self.scene.player then
					self.scene.player.noIdle = false
				end
			end)
		}
	elseif self.object.properties.key == "down" then
		self.scene.player:run {
			Do(function()
				if next(self.scene.player.ladders) == nil then
					self.scene.player.noIdle = true
					self.scene.player.sprite:setAnimation("walkdown")
				end
			end),
			
			Ease(self.scene.player, "y", self.scene.player.y + 100, 3, "linear"),
			
			Do(function()
				self.scene.player.noIdle = false
			end)
		}
	elseif self.object.properties.key == "left" then
		self.scene.player:run {
			Do(function()
				self.scene.player.noIdle = true
				self.scene.player.sprite:setAnimation("walkleft")
			end),
			
			Ease(self.scene.player, "x", self.scene.player.x - 100, 3, "linear"),
			
			Do(function()
				if self.scene.player then
					self.scene.player.noIdle = false
				end
			end)
		}
	elseif self.object.properties.key == "right" then
		self.scene.player:run {
			Do(function()
				self.scene.player.noIdle = true
				self.scene.player.sprite:setAnimation("walkright")
			end),
			
			Ease(self.scene.player, "x", self.scene.player.x + 100, 3, "linear"),
			
			Do(function()
				if self.scene.player then
					self.scene.player.noIdle = false
				end
			end)
		}
	end

	self:onLeave()

	self.scene.sceneMgr:switchScene {
		class = "BasicScene",
		mapName = mapName,
		map = self.scene.maps[mapName],
		maps = self.scene.maps,
		region = self.scene.region,
		spawn_point = self.object.properties.spawn_point,
		--spawn_point_offset = self.ignoreSpawnOffset and Transform() or spawnOffset,
		fadeInSpeed = self.object.properties.fade_in_speed,
		fadeOutSpeed = self.object.properties.fade_out_speed,
		fadeOutMusic = self.object.properties.fade_out_music,
		enterDelay = self.object.properties.enterDelay,
		hint = self.object.properties.hint,
		images = self.scene.images,
		animations = self.scene.animations,
		audio = self.scene.audio,
		doingSpecialMove = not self.object.properties.no_run and self.scene.player.doingSpecialMove,
		cache = true
	}
end


return SceneEdge
