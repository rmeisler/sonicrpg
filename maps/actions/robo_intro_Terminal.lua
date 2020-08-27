local Transform = require "util/Transform"
local Layout = require "util/Layout"

local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local DescBox = require "actions/DescBox"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local Do = require "actions/Do"
local Animate = require "actions/Animate"
local NameScreen = require "actions/NameScreen"
local Move = require "actions/Move"
local BlockInput = require "actions/BlockInput"

local SpriteNode = require "object/SpriteNode"

return function(self)
	return Serial {
		Do(function()
			self.disabled = true -- Disable computer
			
			-- Remove collision around door
			self.scene.objectLookup.Door:removeCollision()
			
			self.scene.player.cinematicStack = self.scene.player.cinematicStack + 1
			self.scene.player.disableScan = true
		end),
		Parallel {
			MessageBox {
				message = "Sally: Got it! {p50}We're in!",
				blocking = true
			},
			Serial {
				Wait(0.5),
				Animate(self.scene.objectLookup.Door.sprite, "opening"),
				Animate(self.scene.objectLookup.Door.sprite, "open")
			}
		},
		Do(function()
			local Swatbot = require "object/Swatbot"
			self.scene.swatbot1 = Swatbot(
				self.scene,
				{name = "objects"},
				{
					name = "SwatbotFromDoor1",
					x = self.scene.objectLookup.Door.x + 80,
					y = self.scene.objectLookup.Door.y + self.scene.objectLookup.Door.sprite.h + 10,
					width = 56,
					height = 79,
					properties = {
						ghost = true,
						sprite = "art/sprites/swatbot.png",
						noInvestigate = true,
						ignoreMapCollision = true,
						visibleDistance = 0
					}
				}
			)
			self.scene.swatbot1:postInit()
			self.scene:addObject(self.scene.swatbot1)
			self.scene.swatbot1.sprite:setAnimation("idledown")
			self.scene.swatbot1.sprite.color[4] = 0
			self.scene.swatbot1:run {
				Ease(self.scene.swatbot1.sprite.color, 4, 255, 2, "linear"),
				Move(self.scene.swatbot1, self.scene.objectLookup.Waypoint3),
				Do(function()
					self.scene.swatbot1.forceSee = true
				end)
			}
			self.scene.swatbot2 = Swatbot(
				self.scene,
				{name = "objects"},
				{
					name = "SwatbotFromDoor2",
					x = self.scene.objectLookup.Door.x + 160,
					y = self.scene.objectLookup.Door.y + self.scene.objectLookup.Door.sprite.h + 10,
					width = 56,
					height = 79,
					properties = {
						ghost = true,
						sprite = "art/sprites/swatbot.png",
						noInvestigate = true,
						ignoreMapCollision = true,
						visibleDistance = 0
					}
				}
			)
			self.scene.swatbot2:postInit()
			self.scene:addObject(self.scene.swatbot2)
			self.scene.swatbot2.sprite:setAnimation("idledown")
			self.scene.swatbot2.sprite.color[4] = 0
			self.scene.swatbot2:run {
				Ease(self.scene.swatbot2.sprite.color, 4, 255, 2, "linear"),
				Move(self.scene.swatbot2, self.scene.objectLookup.Waypoint4),
				Do(function()
					self.scene.swatbot2.forceSee = true
				end)
			}
		end),
		Wait(1),
		Do(function()
			GameState:setFlag("roboterminal_openeddoor")
			
			self.scene.player.sprite:setAnimation("shock")
			self.scene.player.noIdle = true
		end),
		MessageBox {
			message = "Sally: Uh oh!",
			blocking = true,
			closeAction = Wait(1.3)
		},
		self.scene:enterBattle {
			opponents = {
				"swatbot",
				"sonicappear_swatbot"
			},
			beforeBattle = Do(function()
				self.scene.swatbot1:remove()
				self.scene.swatbot2:remove()
				self.scene.swatbot1:removeCollision()
				self.scene.swatbot2:removeCollision()
				print("removed swatbots")
			end),
			initiative = "opponent",
			prevMusic = "patrol"
		}
	}
end
