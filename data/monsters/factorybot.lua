local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Wait = require "actions/Wait"
local Action = require "actions/Action"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local BouncyText = require "actions/BouncyText"

local Transform = require "util/Transform"

local PressX = require "data/battle/actions/PressX"
local Heal = require "data/items/actions/Heal"
local Telegraph = require "data/monsters/actions/Telegraph"
local Smack = require "data/monsters/actions/Smack"

local sendHome

sendHome = function(self, target)
	target:removeHandler("dead", sendHome, self)
	return self.scene:run {
		Animate(self.sprite, "idle"),
		Parallel {
			Ease(self.sprite.transform, "x", self.originalLocation.x, 1, "inout"),
			Ease(self.sprite.transform, "y", self.originalLocation.y, 1, "inout")
		}
	}
end

return {
	name = "Factory Bot",
	altName = "Factory Bot",
	sprite = "sprites/factorybot",

	stats = {
		xp    = 5,
		maxhp = 300,
		attack = 15,
		defense = 15,
		speed = 2,
		focus = 1,
		luck = 1,
	},

	run_chance = 0.7,

	coin = 0,

	drops = {
		{item = require "data/items/GreenLeaf", count = 1, chance = 0.2},
	},

	behavior = function (self, target)
		-- If there's less than 3 opponents (cambot + 2 swatbots), spawn another swatbot
		if #self.scene.opponents < 3 then
			return Serial {
				Telegraph(self, "Intruder alert!", {255,255,255,50}),
				Do(function()
					self.scene:addMonster("swatbot")
				end)
			}
		elseif not self.grabbing then
			self.originalLocation = Transform(self.sprite.transform.x, self.sprite.transform.y)
			
			-- Make sure your target isn't already grabbed. If so, choose a new target
			if target.state == target.STATE_IMMOBILIZED then
				local targets = self.scene.party
				if self.confused then
					targets = self.scene.opponents
				end
				
				target = nil
				for _, newTarget in pairs(targets) do
					if newTarget.state == newTarget.STATE_IDLE then
						target = newTarget
					end
				end
				
				if not target then
					return Telegraph(self, self.name.." pauses stoically...", {255,255,255,50})
				end
			end
			
			-- Grab can be dodged by Sonic
			local grabAction = Serial {
				Animate(self.sprite, "grabbing"),
				Animate(self.sprite, "grab"),
				Animate(target.sprite, "hurt"),
				
				PlayAudio("sfx", "bang", 1.0, true),

				Ease(
					target.sprite.transform,
					"x",
					function() return target.sprite.transform.x + 7 end,
					10
				),
				Ease(
					target.sprite.transform,
					"x",
					function() return target.sprite.transform.x - 7 end,
					10
				),
				Ease(
					target.sprite.transform,
					"x",
					function() return target.sprite.transform.x + 3 end,
					10
				),
				Ease(
					target.sprite.transform,
					"x",
					function() return target.sprite.transform.x - 3 end,
					10
				),
				Ease(
					target.sprite.transform,
					"x",
					function() return target.sprite.transform.x end,
					10
				),
				
				Wait(0.5),
				
				MessageBox {message=self.name.." grabbed "..target.name.."!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
				Do(function()
					target.state = target.STATE_IMMOBILIZED
					self.grabbing = target.id
					self.grabTurns = 0
					
					-- Send home if target dies
					target:addHandler("dead", sendHome, self, target)
				end)
			}

			local grabWithDodgeAction
			if target.id == "sonic" then
				grabWithDodgeAction = Serial {
					Wait(0.5),
					PressX(
						self,
						target,
						Serial {
							PlayAudio("sfx", "pressx", 1.0, true),
							Do(function()
								target.sprite.sortOrderY = target.sprite.transform.y
							end),
							Parallel {
								Serial {
									Animate(target.sprite, "leap_dodge"),
									Ease(target.sprite.transform, "y", target.sprite.transform.y - target.sprite.h*2, 8, "linear"),
									Ease(target.sprite.transform, "y", target.sprite.transform.y, 6, "quad"),
									Animate(target.sprite, "crouch"),
									Wait(0.1),
									Animate(target.sprite, "victory"),
									Wait(0.3),
									Animate(target.sprite, "idle"),
								},
								BouncyText(
									Transform(
										target.sprite.transform.x + 10 + (target.textOffset.x),
										target.sprite.transform.y + (target.textOffset.y)),
									{255,255,255,255},
									FontCache.ConsolasLarge,
									"miss",
									6,
									false,
									true -- outline
								),
								
								Serial {
									Wait(0.5),
									Parallel {
										Ease(self.sprite.transform, "x", self.sprite.transform.x, 1, "inout"),
										Ease(self.sprite.transform, "y", self.sprite.transform.y, 1, "inout")
									}
								}
							},
							Do(function()
								target.sprite.sortOrderY = nil
							end),
						},
						grabAction,
						0.3
					)
				}
			else
				grabWithDodgeAction = Serial {
					Wait(0.8),
					grabAction
				}
			end
			
			return Serial {
				Telegraph(self, "Grab", {255, 255, 255, 50}),
				Parallel {
					Ease(self.sprite.transform, "x", target.sprite.transform.x - 50, 1, "inout"),
					Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h*2 - self.sprite.h*2 + 20, 1, "inout"),
					
					grabWithDodgeAction
				}
			}
		else
			-- Chance to escape grip
			local grabbed = self.scene.partyByName[self.grabbing]
			if  math.random() < (0.5 + (self.grabTurns * grabbed.stats.luck/20)) or
				self.grabTurns == 3
			then
				return Serial {
					Telegraph(self, self.name.."'s lost its grip!", {255, 255, 255, 50}),
					Animate(self.sprite, "idle"),
					Parallel {
						Ease(self.sprite.transform, "x", self.originalLocation.x, 1, "inout"),
						Ease(self.sprite.transform, "y", self.originalLocation.y, 1, "inout")
					}
				}
			else
				self.grabTurns = self.grabTurns + 1
				return Telegraph(self, self.name.."'s grip tightens...", {255, 255, 255, 50})
			end
		end
	end,
	
	onDead = function(self)
		return Do(
			function()
				if self.grabbing then
					local grabbed = self.scene.partyByName[self.grabbing]
					grabbed.state = self.STATE_IDLE
					grabbed.sprite:setAnimation("idle")
					grabbed:removeHandler("dead", sendHome, self)
				end
			end
		)
	end
}