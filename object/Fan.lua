local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"
local Menu = require "actions/Menu"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"

local NPC = require "object/NPC"
local Fan = class(NPC)

Fan.WIDTH_OFFSET = 30
Fan.PULL_RANGE = 300
Fan.PULL_SPEED = 3.5

function Fan:construct(scene, layer, object)
	self.sprite = SpriteNode(
		self.scene,
		Transform(),
		nil,
		"fancenter",
		nil,
		nil,
		"objects"
	)
	
	NPC.init(self)
	
	self.sprite.transform = Transform(self.x, self.y, 2, 2)
	
	-- Blades
	self.bladeSprites = {}
	for _, anim in pairs({"first", "second", "third", "fourth"}) do
		local sprite = SpriteNode(
			self.scene,
			self.sprite.transform,
			nil,
			"fanblade",
			nil,
			nil,
			"objects"
		)
		sprite:setAnimation(anim)
		self.bladeSprites[anim] = sprite
	end

	self:addInteract(Fan.use)
	self:addSceneHandler("exit")
	self:addSceneHandler("enter")
	
	self.respawn = object.properties.respawn
	self.nosound = object.properties.nosound
	
	if object.properties.on then
		self:use()
	end
end

function Fan:exit()
	if GameState:isFlagSet(self) and not self.nosound then
		self.scene.audio:stopSfx("fan")
	end
end

function Fan:enter()
	if GameState:isFlagSet(self) and not self.nosound then
		self.scene.audio:playSfx("fan", 0.5)
		self.scene.audio:setLooping("sfx", true)
	end
end

function Fan:update(dt)
	for name, sprite in pairs(self.bladeSprites) do
		sprite.sortOrderY = self.sprite.transform.y - 5
		
		if GameState:isFlagSet(self) then
			sprite:setAnimation(name)
		else
			sprite:setAnimation(name.."_idle")
		end
	end
	
	if GameState:isFlagSet(self) then
		local targets = {self.scene.player}
		for _, obj in pairs(self.scene.map.objects) do
			if obj.isBot then
				table.insert(targets, obj)
			end
		end
		
		-- Iterate over player and all bots to see if they are within your rect
		-- If so, start pulling them
		for _, target in pairs(targets) do
			if  target.y > self.y - self.object.height and
				target.y < self.y + Fan.PULL_RANGE and
				target.x > self.x + Fan.WIDTH_OFFSET and
				target.x < self.x + self.object.width - Fan.WIDTH_OFFSET
			then
				if self.scene.player ~= target then
					target.y = target.y - math.pow(
						math.max(3, math.min(Fan.PULL_SPEED, ((Fan.PULL_RANGE - (target.y - self.y)) / Fan.PULL_RANGE) * Fan.PULL_SPEED)) * (dt/0.016),
						2
					)				
					target.disabled = true
					-- Knock out of fan three times, doing damage, until dead
					if target.y < self.y then
						self.scene.audio:playSfx("smack", 1.0)
						self.scene.audio:playSfx("oppdeath", 1.0)
						target.isBot = false
						self:run {
							Parallel {
								Ease(target.sprite.color, 4, 0, 1),
								Ease(target.sprite.color, 1, 800, 1)
							},
							Do(function()
								target:remove()
							end)
						}
					end
					target.sprite:setAnimation("hurtdown")
				elseif not target.cinematic then
					if target.y > self.y + self.sprite.h*1.5 then
						target.y = math.max(
							target.y - math.pow(
								math.max(3, math.min(Fan.PULL_SPEED, ((Fan.PULL_RANGE - (target.y - self.y)) / Fan.PULL_RANGE) * Fan.PULL_SPEED)) * (dt/0.016),
								2
							),
							self.y + self.sprite.h*1.5
						)
					else
						-- Teleport player next to fan
						self.scene.audio:playSfx("smack2", 1.0)
						self.scene.player.cinematic = true
						self.scene.player.state = "shock"
						self.scene.player:run {
							Parallel {
								Ease(target.sprite.color, 4, 0, 1),
								Ease(target.sprite.color, 1, 800, 1)
							},
							Do(function()
								self.scene.player.cinematic = false
								
								if self.respawn then
									self.scene.player.x = self.scene.objectLookup[self.respawn].x
									self.scene.player.y = self.scene.objectLookup[self.respawn].y
									self.scene.player.state = "idleup"
								else
									self.scene.player.x = self.x + self.sprite.w*2 + 100
									self.scene.player.y = self.y + 100
									self.scene.player.state = "idledown"
								end
							end),
							-- Blink transparency
							Repeat(
								Serial {
									Ease(self.scene.player.sprite.color, 4, 0, 20, "quad"),
									Ease(self.scene.player.sprite.color, 4, 255, 20, "quad")
								},
								10
							)
						}
					end
				end
			end
		end
		
		if not self.nosound then
			local minAudibleDist = 800
			local maxAudibleDist = 200
			local num = self:distanceFromPlayerSq() - maxAudibleDist*maxAudibleDist
			local denom = (minAudibleDist - maxAudibleDist)*(minAudibleDist - maxAudibleDist)
			local volume = 1.0 - math.min(1.0, math.max(0.0, num) / denom)

			self.scene.audio:setVolumeFor("sfx", "fan", volume)
		end
	end
end

function Fan:use()
	if GameState:isFlagSet(self) then
		return
	end

	GameState:setFlag(self)
	
	if not self.nosound then
		self.scene.audio:playSfx("fan", 0.5)
		self.scene.audio:setLooping("sfx", true)
	end
end

function Fan:distanceFromPlayerSq()
	local dx = (self.scene.player.x - (self.x + self.sprite.w))
	local dy = (self.scene.player.y - (self.y + self.sprite.h))
	return (dx*dx + dy*dy)
end

function Fan:onScan()
	return Action()
end


return Fan
