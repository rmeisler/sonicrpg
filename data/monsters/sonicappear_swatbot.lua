local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"
local Animate = require "actions/Animate"
local Try = require "actions/Try"
local Action = require "actions/Action"
local YieldUntil = require "actions/YieldUntil"
local BouncyText = require "actions/BouncyText"
local While = require "actions/While"
local AudioFade = require "actions/AudioFade"
local MessageBox = require "actions/MessageBox"
local Spawn = require "actions/Spawn"

local SpriteNode = require "object/SpriteNode"
local PartyMember = require "object/PartyMember"
local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local BattleActor = require "object/BattleActor"

local Swatbot = require "data/monsters/swatbot"

return {
	name = "Swatbot",
	altName = "Swatbot",
	sprite = "sprites/swatbot",

	stats = {
		xp    = 5,
		maxhp = 200,
		attack = 25,
		defense = 15,
		speed = 5,
		focus = 0,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {},
	
	scan = "Swatbots are succeptible to water damage.",

	behavior = function (self, target)
		if not self.turnsTaken then
			self.turnsTaken = 0
		end
		
		self.turnsTaken = self.turnsTaken + 1

		if self.turnsTaken == 1 then
			target = self.scene.partyByName.antoine
			
			local origY = target.sprite.transform.y
			local action = Swatbot.behavior(self, target)
			local prevMusic = self.scene.audio:getCurrentMusic()
			return Serial {
				MessageBox {message="Sally: We're in trouble!"},
				MessageBox {message="Antoine: Not to be worried, my princess! {p40}I will get us right out of this!!"},
				action,
				
				While(
					function()
						return self.scene.partyByName.antoine.hp > 0
					end,
					Serial {
						MessageBox {message="Antoine: {p30}.{p30}.{p30}."},

						-- Antoine scared
						Parallel {
							Serial {
								Animate(target.sprite, "scaredhop1"),
								Wait(0.1),
								Animate(target.sprite, "scaredhop2"),
								Ease(target.sprite.transform, "y", function() return origY - 50 end, 7, "linear"),
								Animate(target.sprite, "scaredhop3"),
								Ease(target.sprite.transform, "y", function() return origY end, 7, "linear"),
								Animate(target.sprite, "scaredhop4"),
								Wait(0.1),
								Animate(target.sprite, "scaredhop5")
							},
							
							MessageBox {message="Antoine: We are doom-ed!!"},
							Wait(1)
						}
					},
					Action()
				),

				AudioFade("music", 1.0, 0.0, 2),
				
				Wait(0.5),
				
				Do(function()
					-- Add Sonic to partyMembers
					GameState:addToParty("sonic", 1, true)
					local data = table.clone(GameState.party.sonic)
					data.sprite = SpriteNode(
						self.scene,
						self.scene.playerSlots[1],
						{255,255,255,255},
						data.battlesprite
					)
					data.sprite.transform.ox = data.sprite.w/2
					data.sprite.transform.oy = data.sprite.h/2
					data.sprite.transform.x = data.sprite.transform.x + data.sprite.w
					data.sprite.transform.y = data.sprite.transform.y + data.sprite.h
					data.playerSlot = index
					
					local partyMember = PartyMember(self.scene, data)
					partyMember:setShadow()
					local origX = data.sprite.transform.x
					local origY = data.sprite.transform.y
					
					-- Sonic runs in
					partyMember.sprite.transform.x = 700
					partyMember.sprite.transform.y = 700
					partyMember.sprite:setAnimation("juiceupleft")
					
					local antoineAction = Action()
					if self.scene.partyByName.antoine.hp > 0 then
						antoineAction = Animate(target.sprite, "idle")
					end
					
					self.scene:run {
						Spawn(
							While(
								function()
									return partyMember.sprite.selected ~= "idle"
								end,
								Repeat(Do(function()
									if not self.dustTime or self.dustTime > 0.05 then
										self.dustTime = 0
									elseif self.dustTime < 0.05 then
										self.dustTime = self.dustTime + love.timer.getDelta()
										return
									end
									
									local dust = SpriteNode(
										self.scene,
										Transform(partyMember.sprite.transform.x, partyMember.sprite.transform.y),
										nil,
										"dust"
									)
									dust.color[1] = 130
									dust.color[2] = 130
									dust.color[3] = 200
									dust.color[4] = 255
									
									dust.transform.x = dust.transform.x - dust.w
									dust.transform.y = dust.transform.y - dust.h*2
									dust.transform.sx = 4
									dust.transform.sy = 4

									if partyMember.sprite.selected == "juiceupleft" then
										dust.transform.x = dust.transform.x - partyMember.sprite.w
										dust.transform.y = dust.transform.y + partyMember.sprite.h*2
										dust:setAnimation("updown")
									else
										dust.transform.x = dust.transform.x - partyMember.sprite.w*2 - 5
										dust.transform.y = dust.transform.y - 10
										dust:setAnimation("right")
									end
									
									dust.animations[dust.selected].callback = function()
										local ref = dust
										ref:remove()
									end
									
									self.dustTime = self.dustTime + love.timer.getDelta()
								end)),
								Action()
							)
						),
					
						Parallel {
							Spawn(Serial {
								PlayAudio("music", "sonicenters", 1.0),
								Wait(6),
								PlayAudio("music", prevMusic, 1.0, true, true)
							}),
							
							Serial {
								Parallel {
									Ease(partyMember.sprite.transform, "x", 300, 0.8, "inout"),
									Ease(partyMember.sprite.transform, "y", origY, 0.8, "inout"),
									
									Serial {
										Wait(0.7),
										Animate(partyMember.sprite, "juiceup"),
										Wait(0.04),
										Animate(partyMember.sprite, "juiceupright"),
										Wait(0.04),
										Animate(partyMember.sprite, "juiceright"),
									}
								},
								Ease(partyMember.sprite.transform, "x", origX, 2, "inout"),
								Animate(partyMember.sprite, "idle")
							}
						},
						
						Do(function()
							table.insert(self.scene.party, 1, partyMember)
							self.scene.partyByName.sonic = partyMember
							
							-- Make sure our leader is still Sally
							GameState.leader = "sally"
						end),
						
						antoineAction,
						Animate(partyMember.sprite, "idle"),
						MessageBox {message="Sonic: Looks like you guys could use some help!"},
						Animate(self.scene.partyByName.sally.sprite, "annoyed"),
						MessageBox {message="Sally: Where have you been?!"},
						Animate(partyMember.sprite, "victory"),
						MessageBox {message="Sonic: Hey, I'm here aren't I?"},
						MessageBox {message="Sally: *sigh*"},
						
						Animate(self.scene.partyByName.sally.sprite, "idle"),
						Animate(partyMember.sprite, "idle"),
					}
				end),
				
				YieldUntil(function()
					return self.scene.partyByName.sonic
				end)
			}
		else
			return Swatbot.behavior(self, target)
		end
	end
}