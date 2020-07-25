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
			GameState:setFlag("roboterminal_used")
			
			-- Remove collision around door
			self.scene.objectLookup.Door:removeCollision()
			
			self.scene.player.cinematic = true
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
			local swatbot1 = Swatbot(
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
						battleOnCollide = true,
						disappearAfterBattle = true,
						battle = "/data/monsters/swatbot.lua",
						noInvestigate = true
					}
				}
			)
			self.scene:addObject(swatbot1)
			swatbot1.sprite:setAnimation("idledown")
			swatbot1.sprite.color[4] = 0
			swatbot1:run {
				Ease(swatbot1.sprite.color, 4, 255, 2, "linear"),
				Move(swatbot1, self.scene.objectLookup.Waypoint3),
				Do(function()
					swatbot1.noticeDist = 1000
				end)
			}
			local swatbot2 = Swatbot(
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
						battleOnCollide = true,
						disappearAfterBattle = true,
						battle = "/data/monsters/sonicappear_swatbot.lua",
						noInvestigate = true
					}
				}
			)
			self.scene:addObject(swatbot2)
			swatbot2.sprite:setAnimation("idledown")
			swatbot2.sprite.color[4] = 0
			swatbot2:run {
				Ease(swatbot2.sprite.color, 4, 255, 2, "linear"),
				Move(swatbot2, self.scene.objectLookup.Waypoint4),
				Do(function()
					swatbot2.noticeDist = 1000
				end)
			}
			
			self.scene.player.cinematic = true
		end),
		Wait(1),
		Do(function()
			-- When we get back from this battle, have a cinematic
			local afterBattle
			afterBattle = function()
				self.scene.player:removeKeyHint()
				self.scene.player.sprite:setAnimation("idledown")
				local walkout, walkin, sprites = self.scene.player:split()
				Executor(self.scene):act(
					Serial {
						PlayAudio("music", "patrol", 1.0, true, true),
						walkout,
						
						MessageBox {message="Sally: That was a close one."},
						MessageBox {message="Sonic: Mighta bit off more than we can chew on this one, Sal."},
						
						MessageBox {message="Sonic: Should we abort?"},
						MessageBox {message="Antoine: I will be voting yes on that!"},
						
						Animate(sprites.sally.sprite, "thinking"),
						MessageBox {message="Sally: No. {p50}We're so close, {p50}and this could really hurt Robotnik."},
						
						Animate(sprites.antoine.sprite, "scaredhop1"),
						
						Animate(sprites.sonic.sprite, "idledown"),
						MessageBox {message="Sonic: Your call."},
						
						Animate(sprites.sonic.sprite, "thinking"),
						
						MessageBox {message="Sonic: Since when am I the cautious one?"},
						
						Animate(sprites.antoine.sprite, "idledown"),
						MessageBox {message="Antoine: Sacre bleu...", textSpeed = 4},
						
						walkin,
						Do(function()
							self.scene.player.x = self.scene.player.x + 80
							self.scene.player.y = self.scene.player.y + 70
							self.scene:removeHandler("enter", afterBattle)
						end)
					}
				)
			end
			self.scene:addHandler("enter", afterBattle)
			self.scene.player.cinematic = true
		end),
		Animate(self.scene.player.sprite, "shock"),
		MessageBox {
			message = "Sally: Uh oh!",
			blocking = true
		},
		
		Do(function()
			self.scene.player.cinematic = true
		end)
	}
end
