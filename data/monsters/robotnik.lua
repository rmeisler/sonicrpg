local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Action = require "actions/Action"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local YieldUntil = require "actions/YieldUntil"
local Try = require "actions/Try"
local IfElse = require "actions/IfElse"
local BouncyText = require "actions/BouncyText"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local MessageBox = require "actions/MessageBox"
local TypeText = require "actions/TypeText"
local While = require "actions/While"

local SpriteNode = require "object/SpriteNode"
local BattleActor = require "object/BattleActor"
local Parallax = require "object/Parallax"

local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

local PressX = require "data/battle/actions/PressX"
local PressZ = require "data/battle/actions/PressZ"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

return {
	name = "Robotnik",
	altName = "Robotnik",
	sprite = "sprites/phantomstandin",
	
	mockSprite = "sprites/robotnikbattle",
	mockSpriteOffset = Transform(-50, -50),

	stats = {
		xp = 200,
		maxhp = 8000,
		attack = 30,
		defense = 30,
		speed = 10,
		focus = 10,
		luck = 5,
	},

	boss = true,
	is_bot = false,

	run_chance = 0.2,

	coin = 0,

	drops = {},

	scan = "{h Laser Shields} might be a good idea...",

	onInit = function(self)
		-- Setup beam sprite
		self.beamSprite = SpriteNode(self.scene, Transform(), nil, "botbeam", nil, nil, "ui")
		self.beamSprite.transform.sx = 0
		self.beamSprite.transform.sy = 1
		self.beamSprite.transform.ox = 0
		self.beamSprite.color = {255,255,255,255}
		self.beamSprite:setAnimation("green")
		
		self.targetSprite = SpriteNode(self.scene, Transform(0, 0, 2, 2), nil, "target", nil, nil, "ui")
		self.targetSprite.transform.ox = self.targetSprite.w/2
		self.targetSprite.transform.oy = self.targetSprite.h/2
		self.targetSprite.color[4] = 0
		
		self.shieldSprite = SpriteNode(self.scene, Transform.relative(self:getSprite().transform, Transform(184, 34)), nil, "robotnikshield", nil, nil, "ui")
		self.shieldSprite.color[4] = 0

		self.dropShadow2 = SpriteNode(self.scene, Transform(), nil, "dropshadow", nil, nil, "behind")
		self.dropShadow2.transform.ox = self.dropShadow.w/2
		self.dropShadow2.transform.oy = self.dropShadow.h/2
		self.dropShadow2.transform.sx = 3
		self.dropShadow2.transform.sy = 2
		self.dropShadow2.color[4] = 0
		
		self.parallax = Parallax.ForBattle(self.scene, "rain", 10, 10)
		self.parallax.color = {0,255,0,0}

		self.translate = GameState:isEquipped("babyt", ItemType.Accessory, "Translator Collar")
		self.aerial = true
		self.hasShield = true
		self.states = {"laser"}
		self.numStates = table.count(self.states)
		self.pressXXForm = Transform.relative(self:getSprite().transform, Transform(200, 0))
		self.shieldAction = function(self, target)
			local selfSprite = self:getSprite()
			return Serial {
				Animate(selfSprite, "shield"),
				Parallel {
					Serial {
						PlayAudio("sfx", "shield", 0.4, true),
						Ease(self.shieldSprite.color, 4, 255, 5),
						Wait(0.5),
						Ease(self.shieldSprite.color, 4, 0, 2)
					},
					PressX(
						target,
						self,
						Serial {
							Animate(selfSprite, "shieldbreak"),
							Do(function() self.shieldSprite:setAnimation("broken") end),
							PlayAudio("sfx", "factoryspit", 1, true),
							Wait(1),
							MessageBox {
								message="Robotnik's shield is broken!",
								rect=MessageBox.HEADLINER_RECT,
								closeAction=Wait(1)
							},
							Do(function()
								self.hasShield = false
							end)
						},
						Do(function() end)
					)
				}
			}
		end

		local selfSprite = self:getSprite()
		selfSprite.transform.x = selfSprite.transform.x - 50
		selfSprite.transform.y = selfSprite.transform.y - 100
		selfSprite.continuousAnimation = true

		self.calledShotKnockbackFn = function(self, impact, direction)
			local selfSprite = self:getSprite()
			return Serial {
				Do(function()
					self.aerial = false
				end),
				PlayAudio("sfx", "robotnikhurt", 1, true),
				Animate(selfSprite, "veryhurt"),
				Parallel {
					Ease(selfSprite.transform, "x", function() return selfSprite.transform.x - 20 end, 3),
					Ease(selfSprite.transform, "y", function() return selfSprite.transform.y - 20 end, 3),
					Ease(self.dropShadow2.transform, "x", function() return self.dropShadow2.transform.x - 20 end, 3),
				},
				Ease(selfSprite.transform, "y", self.groundPosition.y, 6),
				Do(function()
					self.dropShadow2.color[4] = 0
				end),
				Animate(selfSprite, "knockdown"),
				Ease(selfSprite.transform, "y", function() return selfSprite.transform.y - 5 end, 8),
				Ease(selfSprite.transform, "y", function() return selfSprite.transform.y + 5 end, 8),
				Do(function()
					selfSprite:pushOverride("idle", "knockdown")
					selfSprite:pushOverride("hurt", "knockdown")

					self.sprite.w = self.sprite.w - 80
					self.sprite.h = self.sprite.h - 80
				end)
			}
		end
		
		self:addHandler("hit", function(damage, attacker)
			-- Declare dead
			if self.hp < 1000 then
				self.state = BattleActor.STATE_DEAD
				self.hp = 0
				self.scene.noBattleMusic = true
				self:getSprite():setAnimation("hurt")
				self:getSprite():pushOverride("idle", "hurt")
			end
		end)

		self.scene.audio:stopMusic()
	end,

	behavior = function (self, target)
		if target == nil then
			return Telegraph(self, "No targets available", {500,500,500,50})
		end
	
		if self.hp <= 0 then
			return Action()
		end
		
		if self.hp <= 7000 and self.numStates == 1 then
			table.insert(self.states, "special")
			table.insert(self.states, "laser")
			self.numStates = 3
		elseif self.hp <= 5000 and self.numStates == 3 then
			table.insert(self.states, "grab")
			table.insert(self.states, "grab")
			self.numStates = 5
		elseif self.hp <= 2500 and self.numStates == 5 then
			table.insert(self.states, "acidrain")
			self.numStates = 6
		end
		
		local selfSprite = self:getSprite()
		self.calledShotOverrideXForm = Transform(
			selfSprite.transform.x + selfSprite.w*1.5 - math.random(1, selfSprite.w/2),
			selfSprite.transform.y + selfSprite.h*1.5 - math.random(1, selfSprite.h/2)
		)
		
		if not self.introDone then
			self.introDone = true

			local selfSprite = self:getSprite()
			self.groundPosition = Transform.from(selfSprite.transform)
			return Serial {
				Parallel {
					PlayAudio("sfx", "yourstoryendshere", 1),
					MessageBox {
						message="Robotnik: Your story...{p60} ends here!",
						rect=MessageBox.HEADLINER_RECT,
						textSpeed=3,
						closeAction=Wait(2)
					}
				},
				Do(function()
					selfSprite:setAnimation("flyup")

					self.dropShadow2.color[4] = 255
					self.dropShadow2.transform.x = selfSprite.transform.x + selfSprite.w - self.dropShadow2.w/2
					self.dropShadow2.transform.y = selfSprite.transform.y + selfSprite.h*2
				end),
				PlayAudio("music", "robotnikbattle", 0.3, true, true),
				Parallel {
					Ease(selfSprite.transform, "y", function() return selfSprite.transform.y - 100 end, 1),
					Ease(self.dropShadow2.transform, "sx", 2.5, 1)
				},
				Do(function()
					selfSprite:setAnimation("idle")

					self.sprite.w = self.sprite.w + 80
					self.sprite.h = self.sprite.h + 80
				end),
				Spawn(While(
					function() return self.aerial end,
					Repeat(
						Serial {
							Parallel {
								Ease(selfSprite.transform, "y", function() return self:getSprite().transform.y + 50 end, 0.5),
								Ease(self.dropShadow2.transform, "sx", 3, 0.5),
							},
							Parallel {
								Ease(selfSprite.transform, "y", function() return self:getSprite().transform.y - 50 end, 0.5),
								Ease(self.dropShadow2.transform, "sx", 2.5, 0.5)
							},
						}
					)
				)),
			}
		else
			local state = self.states[math.random(1,self.numStates)]
			if not self.aerial then
				state = "fly"
			end
			
			if state == "laser" then
				local dodgeAction = target.defenseEvent and
					target.defenseEvent(self, target) or
					Action()

				return Serial {
					Telegraph(self, "Arm Cannon", {500,500,500,50}),
					Animate(selfSprite, "laser"),
					
					Do(function()
						self.targetSprite.transform.x = target.sprite.transform.x
						self.targetSprite.transform.y = target.sprite.transform.y + 10
					end),
					Parallel {
						Ease(self.targetSprite.color, 4, 255, 5),
						Serial {
							PlayAudio("sfx", "lockon", 1.0, true),
							Parallel {
								Ease(self.targetSprite.transform, "sx", 4, 12, "inout"),
								Ease(self.targetSprite.transform, "sy", 4, 12, "inout")
							},
							Parallel {
								Ease(self.targetSprite.transform, "sx", 1.5, 12, "inout"),
								Ease(self.targetSprite.transform, "sy", 1.5, 12, "inout")
							},
							Parallel {
								Ease(self.targetSprite.transform, "sx", 3, 12, "inout"),
								Ease(self.targetSprite.transform, "sy", 3, 12, "inout")
							},
							Parallel {
								Ease(self.targetSprite.transform, "sx", 2, 12, "inout"),
								Ease(self.targetSprite.transform, "sy", 2, 12, "inout")
							},
							
							Ease(self.targetSprite.color, 4, 0, 5),
						}
					},

					Parallel {
						Serial {
							Wait(0.2),
							dodgeAction
						},
						Serial {
							Animate(function()
								local xform = Transform.from(selfSprite.transform)
								xform.x = xform.x + 190
								xform.y = xform.y + 80
								return SpriteNode(self.scene, xform, nil, "beamfire", nil, nil, "ui"), true
							end, "idle"),
							PlayAudio("sfx", "swatbotlaser", 1.0, true),
								
							Do(function()
								self.beamSprite.transform.x = selfSprite.transform.x + 190 + self.beamSprite.w
								self.beamSprite.transform.y = selfSprite.transform.y + 80 + self.beamSprite.h*2
								self.beamSprite.transform.ox = 0
								
								local x1, y1 = self.beamSprite.transform.x, self.beamSprite.transform.y
								local x2, y2 = target.sprite.transform.x, target.sprite.transform.y

								local dx = (x2 - x1)
								local dy = (y2 - y1)

								local dot = dx * dx
								local m1 = math.sqrt(dx*dx + dy*dy)
								local m2 = dx
								local angle = math.acos(dot / (m1 * m2))
								
								if self.beamSprite.transform.y > target.sprite.transform.y then
									self.beamSprite.transform.angle = -angle
								else
									self.beamSprite.transform.angle = angle
								end
								
								self.xDist = dx
								self.yDist = dy
								self.len = m1/self.beamSprite.w	
							end),
							
							-- Beam stretch to target and recede
							Ease(self.beamSprite.transform, "sx", function() return self.len end, 8),
							
							Do(function()
								self.beamSprite.transform.ox = self.beamSprite.w
								
								self.beamSprite.transform.x = self.beamSprite.transform.x + self.xDist
								self.beamSprite.transform.y = self.beamSprite.transform.y + self.yDist
							end),

							Ease(self.beamSprite.transform, "sx", 0, 8),

							Try(
								YieldUntil(
									function()
										return target.dodged
									end
								),
								Do(function()
									target.dodged = false
								end),
								target:takeDamage(self.stats, true, BattleActor.shockKnockback)
							)
						}
					},

					Do(function()
						selfSprite:setAnimation("idle")
					end)
				}
			elseif state == "grab" then
				local origTransform = Transform.from(selfSprite.transform)
				local targetOrigTransform = Transform.from(target.sprite.transform)
				local origDropShadowTransform = Transform.from(self.dropShadow2.transform)
				
				local counterAction = Action()
				if target.id == "babyt" then
					counterAction = Serial {
						Animate(target.sprite, "slap"),
						Animate(target.sprite, "idle")
					}
				elseif target.id == "tails" then
					counterAction = Serial {
						Animate(target.sprite, "slap"),
						Animate(target.sprite, "idle")
					}
				elseif target.id == "b" then
					counterAction = Serial {
						Animate(target.sprite, "crouchleft"),
						Wait(0.1),
						Animate(target.sprite, "jumpleft"),
						Ease(target.sprite.transform, "y", function() return target.sprite.transform.y - 50 end, 3),
						Ease(target.sprite.transform, "y", function() return target.sprite.transform.y + 50 end, 3),
						Animate(target.sprite, "crouchleft"),
						Wait(0.1),
						Animate(target.sprite, "idle")
					}
				end

				self.countered = false
				return Serial {
					Telegraph(self, "Grab", {500,500,500,50}),
					Animate(selfSprite, "lunge"),
					Wait(0.5),
					Parallel {
						While(
							function() return not self.countered end,
							Parallel {
								Ease(selfSprite.transform, "x", target.sprite.transform.x - selfSprite.w*1.5, 2),
								Ease(selfSprite.transform, "y", target.sprite.transform.y - selfSprite.h, 2),
								Ease(self.dropShadow2.transform, "x", target.sprite.transform.x - selfSprite.w, 2),
								Ease(self.dropShadow2.transform, "y", target.sprite.transform.y + target.sprite.h + 20, 2)
							}
						),

						Serial {
							Wait(0.1),
							PressX(
								self,
								target,
								Serial {
									Do(function()
										self.countered = true
									end),
									Parallel {
										counterAction,
										Serial {
											Wait(0.2),
											Parallel {
												self:takeDamage(target.stats),
												Ease(selfSprite.transform, "x", origTransform.x, 4),
												Ease(selfSprite.transform, "y", origTransform.y, 4),
												Ease(self.dropShadow2.transform, "x", origDropShadowTransform.x, 4),
												Ease(self.dropShadow2.transform, "y", origDropShadowTransform.y, 4)
											},
											Animate(selfSprite, "idle")
										}
									}
								},
								Do(function() end)
							)
						}
					},

					IfElse(
						function() return not self.countered end,
						Serial {
							Do(function()
								target.origTransform = target.sprite.transform
								target.originalSortOrderY = target.sprite.sortOrderY
								target.sprite.sortOrderY = 10000

								if target.id == "babyt" then
									target.sprite.transform = Transform.relative(selfSprite.transform, Transform(174, 48))
								else
									target.sprite.transform = Transform.relative(selfSprite.transform, Transform(174, 28))
								end
							end),
							Animate(selfSprite, "grab"),
							Animate(target.sprite, "hurt"),
							PlayAudio("sfx", "bang", 1, true),
							Wait(1),
							Parallel {
								Ease(selfSprite.transform, "x", origTransform.x, 4),
								Ease(selfSprite.transform, "y", origTransform.y, 4),
								Ease(self.dropShadow2.transform, "x", origDropShadowTransform.x, 4),
								Ease(self.dropShadow2.transform, "y", origDropShadowTransform.y, 4)
							},
							Wait(2),
							Animate(selfSprite, "throw"),
							Do(function()
								target.origTransform.x = target.sprite.transform.x
								target.origTransform.y = target.sprite.transform.y
								target.sprite.transform = target.origTransform
							end),
							Parallel {
								Ease(target.sprite.transform, "x", 750, 4, "quad"),
								Do(function()
									target.sprite.sortOrderY = target.originalSortOrderY
									target.originalSortOrderY = nil
								end),
								Ease(target.sprite.transform, "y", function() return target.sprite.transform.y - 50 end, 4)
							},
							Parallel {
								self.scene:screenShake(20, 30, 1),
								target:takeDamage({attack=self.stats.attack*2, speed=100, luck=0}, true, Action()),
								Serial {
									PlayAudio("sfx", "openchasm", 1, true),
									Ease(target.sprite.transform, "x", 700, 4),
									Parallel {
										Ease(target.sprite.transform, "x", targetOrigTransform.x, 6, "quad"),
										Ease(target.sprite.transform, "y", targetOrigTransform.y, 6, "quad"),
										Serial {
											Wait(0.2),
											Animate(target.sprite, "dead")
										}
									},
									PlayAudio("sfx", "bang", 1, true),
									Ease(target.sprite.transform, "y", function() return target.sprite.transform.y - 10 end, 6, "quad"),
									Ease(target.sprite.transform, "y", function() return target.sprite.transform.y + 10 end, 6, "quad"),
									Wait(1),
									Animate(selfSprite, "idle"),
									Wait(1),
									Do(function()
										if target.hp <= 0 then
											target.sprite:setAnimation("dead")
										else
											target.sprite:setAnimation("idle")
										end
									end)
								}
							}
						},
						Action()
					)
				}
			elseif state == "acidrain" then
				local damageAllActions = {}
				for _,party in pairs(self.scene.party) do
					table.insert(damageAllActions, party:takeDamage({attack=self.stats.attack, speed=100, luck=0}))
				end

				return Serial {
					Telegraph(self, "Acid Rain", {500,500,500,50}),
					Animate(selfSprite, "throw"),
					Parallel {
						MessageBox {
							message="Robotnik: Yeeeesss...",
							rect=MessageBox.HEADLINER_RECT,
							textSpeed=3,
							closeAction=Wait(1.5)
						},
						PlayAudio("sfx", "yeeeesss", 1)
					},
					Parallel {
						PlayAudio("sfx", "thunder2", 1, true),
						Repeat(Parallel {
							Serial {
								Parallel {
									Ease(self.scene.bgColor, 1, 512, 8, "quad"),
									Ease(self.scene.bgColor, 2, 512, 8, "quad"),
									Ease(self.scene.bgColor, 3, 512, 8, "quad")
								},
								Parallel {
									Ease(self.scene.bgColor, 1, 255, 8, "quad"),
									Ease(self.scene.bgColor, 2, 255, 8, "quad"),
									Ease(self.scene.bgColor, 3, 255, 8, "quad")
								}
							},
							Do(function() 
								ScreenShader:sendColor("multColor", self.scene.bgColor)
							end)
						}, 2),
						Ease(self.parallax.color, 4, 255, 1)
					},
					Do(function() self.scene.audio:stopSfx() end),
					PlayAudio("sfx", "wind", 1, true),
					Wait(1),
					Parallel(damageAllActions),
					Wait(1),
					Do(function() self.scene.audio:stopSfx("wind") end),
					Ease(self.parallax.color, 4, 0),
					Animate(selfSprite, "idle")
				}
			elseif state == "special" then
				-- Don't keep picking B if already compelled
				if target.id == "b" and target.confused then
					if self.scene.partyByName.babyt.hp <= 0 and self.scene.partyByName.tails.hp <= 0 then
						-- Pick a new action
						table.insert(self.scene.opponentTurns, self)
						return Action()
					end

					if math.random(1,2) == 1 then
						target = self.scene.partyByName.babyt
					else
						target = self.scene.partyByName.tails
					end
				end

				if target.id == "babyt" then
					return Serial {
						Telegraph(self, "Intimidate", {500,500,500,50}),
						Animate(selfSprite, "angry"),
						Animate(target.sprite, "shock"),
						Parallel {
							PlayAudio("sfx", "youdarechallengeme", 1),
							MessageBox {
								message="Robotnik: You dare to challenge me?!",
								rect=MessageBox.HEADLINER_RECT,
								textSpeed=3,
								closeAction=Wait(2.5)
							},
							target:hop()
						},
						Do(function()
							local newStats = table.clone(target.stats)
							newStats.defense = newStats.defense * 0.25
							target:pushStats(newStats)
						end),
						MessageBox {
							message="Baby T defense reduced!",
							rect=MessageBox.HEADLINER_RECT,
							closeAction=Wait(1)
						},
						Animate(selfSprite, "idle"),
						Animate(target.sprite, "idle")
					}
				elseif target.id == "tails" then
					return Serial {
						Telegraph(self, "Terrify", {500,500,500,50}),
						Animate(selfSprite, "scary"),
						PlayAudio("sfx", "robotnikgrit", 1, true),
						PlayAudio("sfx", "stare", 1, true),
						Animate(target.sprite, "shock"),
						Parallel {
							Repeat(Parallel {
								Serial {
									Parallel {
										Ease(self.scene.bgColor, 1, 512, 8, "quad"),
										Ease(self.scene.bgColor, 2, 512, 8, "quad"),
										Ease(self.scene.bgColor, 3, 512, 8, "quad")
									},
									Parallel {
										Ease(self.scene.bgColor, 1, 255, 8, "quad"),
										Ease(self.scene.bgColor, 2, 255, 8, "quad"),
										Ease(self.scene.bgColor, 3, 255, 8, "quad")
									}
								},
								Do(function() 
									ScreenShader:sendColor("multColor", self.scene.bgColor)
								end)
							}, 2),
							target:hop()
						},
						MessageBox {
							message="Tails is immobilized from fear!",
							rect=MessageBox.HEADLINER_RECT,
							closeAction=Wait(1)
						},
						Do(function()
							target.state = BattleActor.STATE_IMMOBILIZED
							target.turnsImmobilized = 2
						end),
						Animate(selfSprite, "idle")
					}
				elseif target.id == "b" then
					target.origXForm = target.origXForm or table.clone(target.sprite.transform)
					self.scene.partyByName.babyt.targetOverride = nil
					self.scene.partyByName.tails.targetOverride = nil
					target.targetOverride = nil

					target.confused = true
					target.turnsConfused = 3

					return Serial {
						Telegraph(self, "Compel", {500,500,500,50}),
						Parallel {
							PlayAudio("sfx", "comehere", 1),
							MessageBox {
								message="Robotnik: Come here...",
								rect=MessageBox.HEADLINER_RECT,
								textSpeed=3,
								closeAction=Wait(2.5)
							},
							Serial {
								Animate(selfSprite, "comehere2"),
								Wait(0.5),
								Animate(selfSprite, "comehere1"),
								Do(function() target.sprite:setAnimation("turncoat") end),
								Wait(1),
								Animate(target.sprite, "redleft")
							}
						},
						MessageBox {
							message="B has fallen under Robotnik's control!",
							rect=MessageBox.HEADLINER_RECT,
							closeAction=Wait(1)
						},
						Animate(target.sprite, "redleapleft"),
						Parallel {
							Ease(target.sprite.transform, "x", selfSprite.transform.x + selfSprite.w*3, 4, "linear"),
							Ease(target.sprite.transform, "y", self.groundPosition.y - self.sprite.h/2, 6, "linear"),
						},
						Do(function()
							target.sprite.sortOrderY = selfSprite.transform.y + selfSprite.h/2
						end),

						Parallel {
							Ease(target.sprite.transform, "x", selfSprite.transform.x + selfSprite.w*2, 4, "linear"),
							Serial {
								Wait(0.09),
								Ease(target.sprite.transform, "y", self.groundPosition.y + selfSprite.h - target.sprite.h, 6, "linear")
							}
						},

						-- Land on ground
						Animate(target.sprite, "redcrouchleft"),
						Wait(0.5),
						Animate(target.sprite, "redidle"),
						Do(function()
							target.confusedAction = (require "data/battle/actions/BFriendlyHitAction")
							target.escapeAction = Serial {
								Do(function()
									target.sprite:setAnimation("turncoat")
									target.targetOverride = nil
								end),
								Wait(1),
								Animate(target.sprite, "idle"),
								MessageBox {
									message="B resisted Robotnik's control!",
									rect=MessageBox.HEADLINER_RECT,
									closeAction=Wait(1)
								},
								Animate(target.sprite, "crouch"),
								Wait(0.1),
								Animate(target.sprite, "leap"),
								Parallel {
									Ease(target.sprite.transform, "x", target.origXForm.x, 3),
									Serial {
										Ease(target.sprite.transform, "y", target.origXForm.y - math.abs(target.sprite.transform.y - target.origXForm.y) - target.sprite.h, 4),
										Do(function()
											target.sprite.sortOrderY = target.sprite.transform.y + target.sprite.h
										end),
										Ease(target.sprite.transform, "y", target.origXForm.y, 6)
									}
								},
								
								Animate(target.sprite, "crouch"),
								Wait(0.1),
								Animate(target.sprite, "idle")
							}
						end),

						Animate(selfSprite, "idle")
					}
				end
			elseif state == "fly" then
				self.aerial = true

				-- Bonus turn
				table.insert(self.scene.opponentTurns, self)

				return Serial {
					Animate(selfSprite, "ground"),
					Ease(selfSprite.transform, "x", self.groundPosition.x, 1),
					Wait(1),
					Do(function()
						selfSprite:setAnimation("flyup")

						self.dropShadow2.color[4] = 255
						self.dropShadow2.transform.x = selfSprite.transform.x + selfSprite.w - self.dropShadow2.w/2
						self.dropShadow2.transform.y = selfSprite.transform.y + selfSprite.h*2
					end),
					Parallel {
						Ease(selfSprite.transform, "y", function() return selfSprite.transform.y - 100 end, 1),
						Ease(self.dropShadow2.transform, "sx", 2.5, 1)
					},
					Do(function()
						selfSprite:popOverride("idle")
						selfSprite:popOverride("hurt")
						selfSprite:setAnimation("idle")

						self.sprite.w = self.sprite.w + 80
						self.sprite.h = self.sprite.h + 80
					end),
					Spawn(While(
						function() return self.aerial end,
						Repeat(
							Serial {
								Parallel {
									Ease(selfSprite.transform, "y", function() return self:getSprite().transform.y + 50 end, 0.5),
									Ease(self.dropShadow2.transform, "sx", 3, 0.5),
								},
								Parallel {
									Ease(selfSprite.transform, "y", function() return self:getSprite().transform.y - 50 end, 0.5),
									Ease(self.dropShadow2.transform, "sx", 2.5, 0.5)
								},
							}
						)
					)),
				}
			else
				return Action()
			end
		end
	end
}