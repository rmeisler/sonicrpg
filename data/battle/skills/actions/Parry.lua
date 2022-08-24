local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local Ease = require "actions/Ease"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local BouncyText = require "actions/BouncyText"

local PressZ = require "data/battle/actions/PressZ"
local Stars = require "data/battle/actions/Stars"

local Transform = require "util/Transform"
local SpriteNode = require "object/SpriteNode"

return function(self, target)
	return Serial {
		Wait(0.5),
		
		Do(function()
			self.sprite:setAnimation("parry")
		end),
		PlayAudio("sfx", "stare", 1.0, true),
		MessageBox {
			rect=MessageBox.HEADLINER_RECT,
			message="Antoine: Coming at me if you dare, eh?!",
			textSpeed=8,
			closeAction=Wait(1)
		},
		Do(function()
			self.sprite:pushOverride("idle", "parry_idle")
			self.sprite:setAnimation("idle")
			self.origTakeDmg = self.takeDamage
			self.takeDamage = function(stats, isPassive, knockbackActionFun)
				return Serial {
					PressZ(
						self,
						self,
						Serial {
							Parallel {
								Serial {
									Animate(self.sprite, "scaredhop2"),
									Ease(self.sprite.transform, "y", self.sprite.transform.y - 50, 7, "linear"),
									Animate(self.sprite, "scaredhop3"),
									Ease(self.sprite.transform, "y", self.sprite.transform.y, 7, "linear"),
									Animate(self.sprite, "scaredhop4"),
									Wait(0.1),
									Animate(self.sprite, "scaredhop5"),
									
									Wait(1)
								},
								Serial {
									PlayAudio("sfx", "pressx", 1.0, true),
									Ease(self.sprite.color, 4, 0, 10, "quad"),
									Ease(self.sprite.color, 4, 255, 2, "linear")
								},
								BouncyText(
									Transform(
										self.sprite.transform.x + 10 + (self.textOffset.x),
										self.sprite.transform.y + (self.textOffset.y)),
									{255,255,255,255},
									FontCache.ConsolasLarge,
									"miss",
									6,
									false,
									true -- outline
								)
							},
							Do(function()
								self.sprite:setAnimation("idle")
							end)
						},
						self.origTakeDmg(stats, isPassive, knockbackActionFun) 
					),
					Do(function()
						self.sprite:popOverride("idle")
						self.takeDamage = self.origTakeDmg
					end)
				}
			end
			
			self:endTurn()
		end)
	}
end