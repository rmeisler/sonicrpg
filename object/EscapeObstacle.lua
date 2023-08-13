local Serial = require "actions/Serial"
local Repeat = require "actions/Repeat"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Wait = require "actions/Wait"
local Menu = require "actions/Menu"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

local NPC = require "object/NPC"

local EscapeObstacle = class(NPC)

function EscapeObstacle:construct(scene, layer, object)
	self.ghost = true
	
	NPC.init(self)
	
	self.touched = false

	self:addHandler("collision", EscapeObstacle.killPlayer, self)
end

function EscapeObstacle:killPlayer()
	if not self.touched then
		self.scene.player.bx = -10

		if self.scene.invincible then
			self.touched = true
			return
		end

		if not self.scene.player.obstacleTouches then
			self.scene.player.obstacleTouches = 3
		end

		self.scene.invincible = true
		self.scene.player.obstacleTouches = self.scene.player.obstacleTouches - 1

		if self.scene.player.obstacleTouches > 0 then
			self:run {
				Repeat(
					Serial {
						Ease(self.scene.player.sprite.color, 4, 0, 20, "quad"),
						Ease(self.scene.player.sprite.color, 4, 255, 20, "quad")
					},
					10
				),
				Do(function()
					self.scene.invincible = false
				end)
			 }
		else
			self:run {
				Parallel {
					Repeat(
						Serial {
							Ease(self.scene.player.sprite.color, 4, 0, 20, "quad"),
							Ease(self.scene.player.sprite.color, 4, 255, 20, "quad")
						},
						10
					)
				},
				Do(function()
					self.scene.invincible = false
					if not self.scene.player.dropShadow:isRemoved() then
						self.scene.player.sprite.visible = false
						self.scene.player.dropShadow.sprite.visible = false
					end
					self.scene.player.fx = 0
					self.scene.player.bx = 0
					self.scene.player.extraBx = 0
					self.scene.player.fy = 0
					self.scene.player.by = 0
					self.scene.player.noGas = true
					self.scene.player.cinematic = true
					self.scene.playerDead = true
				end),
				Wait(3),
				Menu {
					layout = Layout {
						{Layout.Text("Try again?"), selectable = false},
						{Layout.Text("Yes"),
							choose = function(menu)
								menu:close()
								self.scene:restart()
							end},
						{Layout.Text("No"),
							choose = function(menu)
								menu:close()
								self.scene:changeScene{map="knotholesnowday", hint="snowboard_fail", spawnPoint="SnowboardSpawn"}
							end},
						colWidth = 200
					},
					transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
					selectedRow = 2
				}
			}
		end
		self.touched = true
	end
end


return EscapeObstacle
