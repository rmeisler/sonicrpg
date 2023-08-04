local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"
local Action = require "actions/Action"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"

local Transform = require "util/Transform"

local SpriteNode = require "object/SpriteNode"
local NPC = require "object/NPC"

local LayerHop = class(NPC)

function LayerHop:construct(scene, layer, object)
	self.ghost = true
	self.fromLayer = object.properties.fromLayer
	self.toLayer = object.properties.toLayer
	self.key = object.properties.key
	NPC.init(self)
end

function LayerHop:notColliding(player)
	if self.keyhint then
		self.keyhint:remove()
		self.keyhint = nil
	end
end

function LayerHop:keytriggered(key, uni)
	if self.key == key and
	   self.state == NPC.STATE_TOUCHING and
	   not self.scene.player.isHopping
	then
		self.scene.player.isHopping = true
		local hopAction
		if self.key == "right" then
			hopAction = Parallel {
				Ease(self.scene.player, "x", self.scene.player.x + 90, 5, "linear"),
				Serial {
					Ease(self.scene.player, "y", self.scene.player.y - 50, 5, "inout"),
					Ease(self.scene.player, "y", self.scene.player.y + 100, 6, "inout")
				},
			}
		elseif self.key == "left" then
			hopAction = Parallel {
				Ease(self.scene.player, "x", self.scene.player.x - 90, 5, "linear"),
				Serial {
					Ease(self.scene.player, "y", self.scene.player.y - 50, 5, "inout"),
					Ease(self.scene.player, "y", self.scene.player.y + 100, 6, "inout")
				},
			}
		elseif self.key == "up" then
			hopAction = Serial {
				Ease(self.scene.player, "y", self.scene.player.y - 150, 5, "inout"),
				Ease(self.scene.player, "y", self.scene.player.y - 120, 6, "inout")
			}
		elseif self.key == "down" then
			hopAction = Serial {
				Ease(self.scene.player, "y", self.scene.player.y - 20, 5, "inout"),
				Ease(self.scene.player, "y", self.scene.player.y + 150, 6, "inout")
			}
		end
		
		self.scene:run {
			Do(function()
				self.scene.player.cinematic = true
				self.scene.player.noIdle = true
				self.scene.player.dropShadow.sprite.visible = false
			end),
			Animate(self.scene.player.sprite, "crouch"..self.key),
			Wait(0.1),
			Animate(self.scene.player.sprite, "jump"..self.key),
			hopAction,
			Animate(self.scene.player.sprite, "crouch"..self.key),
			Do(function()
				self.scene:swapLayer(self.toLayer)
				self.scene.player.movespeed = self.scene.player.baseMoveSpeed
				self.scene.player.cinematic = false
				self.scene.player.isHopping = false
				self.scene.player.noIdle = false
				self.scene.player.dropShadow.sprite.visible = true
			end),
		}
	end
end

function LayerHop:onCollision(prevState)
    NPC.onCollision(self, prevState)

	local curObjectLayer = "objects"..tostring(self.fromLayer)
	if (self.scene.player.onlyInteractWithLayer ~= nil and
	    self.scene.player.onlyInteractWithLayer ~= curObjectLayer) or
	   self.scene.player.isHopping or
	   self.scene.player.doingSpecialMove
	then
		return
	end

	if not self.keyhint then
		local pressDirXForm = Transform.relative(
			self.scene.player.transform,
			Transform(self.scene.player.sprite.w - 10, 0)
		)
		-- HACK: Rotor is too differently shaped for this transform, change it
		if GameState.leader == "rotor" then
			pressDirXForm = Transform.relative(
				self.scene.player.transform,
				Transform(self.scene.player.sprite.w - 15, -10)
			)
		end
		self.keyhint = SpriteNode(
			self.scene,
			pressDirXForm,
			{255,255,255,255},
			"press"..self.key,
			nil,
			nil,
			self.scene:hasUpperLayer() and "upper" or "objects"
		)
		self.keyhint.sortOrderY = 9999999
	end
end


return LayerHop
