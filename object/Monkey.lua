local Ease = require "actions/Ease"
local Move = require "actions/Move"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Spawn = require "actions/Spawn"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"

local Player = require "object/Player"
local BasicNPC = require "object/BasicNPC"
local NPC = require "object/NPC"

local Monkey = class(NPC)

function Monkey:construct(scene, layer, object)
	self.ghost = true
	self.throw = false

	NPC.init(self)

	self:addSceneHandler("update", Monkey.update)
end

function Monkey:knockDown(tree)
	self:run {
		-- Scared anim
		Animate(self.sprite, "knockdown"),
		
		Wait(0.1),

		-- Scream
		PlayAudio("sfx", "monkey", 1.0, true),

		-- Bounce off
		Parallel {
			Ease(self, "x", function() return self.x + 50 end, 4, "linear"),
			Ease(self, "y", function() return self.y - 60 end, 6, "linear")
		},
		-- Switch layer
		Do(function()
			if self.layer.name ~= self.scene.currentLayer then
				self.sprite:swapLayer(self.scene.currentLayer)
			end
		end),
		-- Fall to ground
		Ease(self, "y", function() return tree.object.y - self.sprite.h end, 3),

		Wait(0.2),

		-- Fade out and disappear
		Ease(self.sprite.color, 4, 0, 2),
		Do(function()
			GameState:setFlag(self:getFlag())
			self:remove()
		end)
	}
end

function Monkey:update(dt)
	if self:isRemoved() then
		self:removeSceneHandler("update")
		return
	end
	
	if GameState.leader ~= "tails" then
		return
	end

	if not self.viewRange then
		self.viewRange = self.scene.objectLookup[self.object.properties.viewRange]
	end

	-- If you are colliding with view range, and you are flying, monkey will throw coconut at you
	local player = self.scene.player
	if self.viewRange.state == NPC.STATE_TOUCHING and player.doingSpecialMove and not self.throw then
		self.throw = true

		-- Throw a coconut!
		self.coconut = BasicNPC(
			self.scene,
			{name = "all"},
			{
				name = "Coconut",
				x = self.x + 22 * 2,
				y = self.y + 17 * 2,
				width = 8,
				height = 8,
				properties = {ghost = true, sprite = "art/sprites/snowball.png", ignoreMapCollision = true}
			}
		)
		self.coconut.sprite.transform.ox = 4
		self.coconut.sprite.transform.oy = 4
		self.coconut.sprite.color = {60, 60, 0, 255}
		self.coconut.movespeed = 20
		self.scene:addObject(self.coconut)

		self:run {
			-- Hold coconut
			Animate(self.sprite, "hold"),
			Wait(0.2),
			-- Throw animation
			Parallel {
				Animate(self.sprite, "throw"),
				Move(self.coconut, player, "idle")
			},
			Do(function()
				player.forceDrop = true
				player.stopElevating = true
			end),
			-- Player flicker
			Spawn(
				Repeat(
					Serial {
						Ease(player.sprite.color, 4, 0, 20, "linear"),
						Ease(player.sprite.color, 4, 255, 20, "linear")
					},
					12
				)
			),
			PlayAudio("sfx", "poptop", 1.0, true),
			-- Bounce off
			Parallel {
				Ease(self.coconut, "x", function() return self.coconut.x + 100 end, 4, "linear"),
				Ease(self.coconut, "y", function() return self.coconut.y - 60 end, 6, "linear")
			},
			-- Coconut fall to ground, disappear
			Spawn(
				Serial {
					Parallel {
						Ease(self.coconut, "x", function() return self.coconut.x + 20 end, 5, "linear"),
						Ease(self.coconut, "y", function() return player.dropShadow.y end, 3)
					},
					Do(function()
						self.coconut:remove()
						self.throw = false
						self.sprite:setAnimation("idle") -- Monkey return to idle animation
					end)
				}
			)
		}
	end
end


return Monkey
