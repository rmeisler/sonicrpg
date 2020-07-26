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
		end),
		Wait(1),
		Do(function()
			-- When we get back from this battle, have a cinematic
			local afterBattle
			afterBattle = function()
				self.scene.player:removeKeyHint()
				self.scene.player.sprite:setAnimation("idledown")
				self.scene.player.cinematicStack = self.scene.player.cinematicStack + 1
				self.scene.player.noIdle = false
				local walkout, walkin, sprites = self.scene.player:split()
				Executor(self.scene):act(
					Serial {
						PlayAudio("music", "patrol", 1.0, true, true),
						walkout,
						
						MessageBox {message="Sally: That was a close one.", blocking = true},
						MessageBox {message="Sonic: Mighta bit off more than we can chew on this one, Sal. {p30}Should we abort?", blocking = true},
						
						MessageBox {message="Antoine: I will be voting yes on that!", blocking = true},
						
						Animate(sprites.sally.sprite, "thinking"),
						MessageBox {message="Sally: Hmmm{p20}.{p20}.{p20}. {p50}I think we should keep going.", blocking = true},
						
						Animate(sprites.antoine.sprite, "scaredhop1"),
						
						MessageBox {message="Sally: We're almost there, and this could really hurt Robotnik!", blocking = true},
						
						Animate(sprites.sonic.sprite, "idledown"),
						MessageBox {message="Sonic: Your call.", blocking = true},
						
						Animate(sprites.sonic.sprite, "thinking"),
						
						MessageBox {message="Sonic: Since when am I the cautious one?", blocking = true},
						
						Animate(sprites.antoine.sprite, "idledown"),
						MessageBox {message="Antoine: Sacre bleu...", textSpeed = 4, blocking = true},
						
						walkin,
						Do(function()
							self.scene.player.x = self.scene.player.x + 80
							self.scene.player.y = self.scene.player.y + 70
							
							self.scene:removeHandler("enter", afterBattle)
							
							self.scene.player.cinematicStack = self.scene.player.cinematicStack - 2
							self.scene.player.disableScan = false
						end)
					}
				)
			end
			self.scene:addHandler("enter", afterBattle)
			
			self.scene.player.sprite:setAnimation("shock")
			self.scene.player.noIdle = true
		end),
		MessageBox {
			message = "Sally: Uh oh!",
			blocking = true,
			closeAction = Wait(2)
		}
	}
end
