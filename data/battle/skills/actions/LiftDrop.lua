local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"
local Action = require "actions/Action"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"
local Telegraph = require "data/monsters/actions/Telegraph"

local SpriteNode = require "object/SpriteNode"

local Layout = require "util/Layout"
local Transform = require "util/Transform"
local TargetType = require "util/TargetType"

local dropAction = function(self, target, carriedTarget, dropShadow)
	local lastXForm = Transform.from(self.sprite.transform)
	local FLY_HEIGHT = 150
	local targetSprite = target:getSprite()
	local carriedTargetSprite = carriedTarget:getSprite()

	return Serial {
		-- Fly toward target
		Parallel {
			Ease(self.sprite.transform, "x", targetSprite.transform.x, 3),
			Ease(self.sprite.transform, "y", targetSprite.transform.y - targetSprite.h - FLY_HEIGHT/2, 3),

			Ease(carriedTargetSprite.transform, "x", targetSprite.transform.x, 3),
			Ease(carriedTargetSprite.transform, "y", targetSprite.transform.y - targetSprite.h - FLY_HEIGHT/2, 3),

			Ease(dropShadow.transform, "x", targetSprite.transform.x, 3),
			Ease(dropShadow.transform, "y", targetSprite.transform.y, 3)
		},

		-- Drop carried target
		Ease(carriedTargetSprite.transform, "y", targetSprite.transform.y, 6),
		Ease(carriedTargetSprite.transform, "y", function() return carriedTargetSprite.transform.y - 3 end, 8, "quad"),
		Ease(carriedTargetSprite.transform, "y", function() return carriedTargetSprite.transform.y + 3 end, 8, "quad"),

		-- Effect of drop or damage based on stats
		carriedTarget:onDrop(self, target),

		-- Fly back
		Parallel {
			Ease(self.sprite.transform, "x", lastXForm.x, 3),
			Ease(self.sprite.transform, "y", lastXForm.y, 3),

			Ease(dropShadow.transform, "x", lastXForm.x - self.sprite.w/2, 3),
			Ease(dropShadow.transform, "y", lastXForm.y + FLY_HEIGHT + self.sprite.h, 3)
		},

		-- Land
		Ease(self.sprite.transform, "y", function() return self.sprite.transform.y + FLY_HEIGHT end, 1),
		Do(function()
			self.flying = false
			self.sprite:popOverride("idle")
			self.options = self.origOptions
			self.untargetable = false
			carriedTarget.untargetable = false
			carriedTarget.sprite:setAnimation(carriedTarget.prevAnim)
			carriedTarget.state = carriedTarget.STATE_IDLE
			carriedTarget.noEscape = false
			dropShadow:remove()
		end)
	}
end

return function(self, target)
	local lastXForm = Transform.from(self.sprite.transform)
	local FLY_HEIGHT = 150
	local targetSprite = target:getSprite()
	
	local dropShadow = SpriteNode(
		self.scene,
		Transform(lastXForm.x - self.sprite.w/2, lastXForm.y + self.sprite.h, 1.3, 2),
		{255,255,255,0},
		"dropshadow",
		nil,
		nil,
		"behind"
	)

	return Serial {
		Do(function()
			self.sprite:setAnimation("flyleft")
			dropShadow.color[4] = 255
		end),

		Parallel {
			Do(function()
				local audio = self.scene.audio
				audio:playSfx("fly", 0.2)
			end),
			Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - 50 end, 1)
		},
		
		Do(function()
			-- Flying benefits
			self.flying = true
			self.sprite:pushOverride("idle", "flyleft")
		end),

		-- Fly toward target
		Parallel {
			Ease(self.sprite.transform, "x", targetSprite.transform.x, 3),
			Ease(self.sprite.transform, "y", targetSprite.transform.y - targetSprite.h, 3),
			
			Ease(dropShadow.transform, "x", targetSprite.transform.x, 3),
			Ease(dropShadow.transform, "y", targetSprite.transform.y + targetSprite.h, 3)
		},

		-- Pickup
		PlayAudio("sfx", "smack", 1.0, true),
		Animate(targetSprite, "hurt"),
		Ease(targetSprite.transform, "x", function() return targetSprite.transform.x - 5 end, 6),
		Ease(targetSprite.transform, "x", function() return targetSprite.transform.x + 5 end, 6),

		target:onLift(self),

		-- If heavy, don't lift
		target.heavy
			and Serial {
				Telegraph(self, "Too heavy to lift!", {255,255,255,50}),

				-- Fly back to your original position (but above it)
				Parallel {
					Ease(self.sprite.transform, "x", lastXForm.x, 3),
					Ease(self.sprite.transform, "y", lastXForm.y - FLY_HEIGHT, 3),

					Ease(dropShadow.transform, "x", lastXForm.x - self.sprite.w/2, 3),
					Ease(dropShadow.transform, "y", lastXForm.y + self.sprite.h, 3)
				},

				-- Land
				Ease(self.sprite.transform, "y", function() return self.sprite.transform.y + FLY_HEIGHT end, 1),
				Do(function()
					self.flying = false
					self.sprite:popOverride("idle")
					dropShadow:remove()
				end)
			}
			or Serial {
				Do(function()
					target.sprite:swapLayer("infront")
				end),

				-- Lift
				Parallel {
					Do(function()
						local audio = self.scene.audio
						audio:playSfx("fly", 0.2)
					end),
					Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - FLY_HEIGHT end, 1),
					Ease(targetSprite.transform, "y", function() return targetSprite.transform.y - FLY_HEIGHT end, 1)
				},

				-- Fly back to your original position (but above it)
				Parallel {
					Ease(self.sprite.transform, "x", lastXForm.x, 3),
					Ease(self.sprite.transform, "y", lastXForm.y - targetSprite.h - FLY_HEIGHT/2, 3),

					Ease(targetSprite.transform, "x", lastXForm.x, 3),
					Ease(targetSprite.transform, "y", lastXForm.y - FLY_HEIGHT/2, 3),

					Ease(dropShadow.transform, "x", lastXForm.x - self.sprite.w/2, 3),
					Ease(dropShadow.transform, "y", lastXForm.y + self.sprite.h, 3)
				},

				Do(function()
					target.immobilizedBy = "tails"
					self.untargetable = true
					target.untargetable = true
					target.prevAnim = targetSprite.selected
					target.state = target.STATE_IMMOBILIZED
					target.noEscape = true
					
					-- Give yourself another turn whydoncha
					table.insert(self.scene.partyTurns, 1, self)

					-- Update battle menu
					self.origOptions = self.options
					self.options = {
						{Layout.Text("Hold"),
							choose = function(menu)
								menu:close()

								self.scene:run {
									menu,
									Do(function()
										self:endTurn()
									end)
								}
							end},
						{Layout.Text("Drop"),
							choose = function(menu)
								self:chooseTarget(
									menu,
									TargetType.Opponent,
									function(dropTarget) return dropTarget == self or dropTarget == target end,
									function(dropSelf, dropTarget)
										menu:close()
										return Serial {
											Parallel {
												menu,
												dropAction(dropSelf, dropTarget, target, dropShadow)
											},
											-- Hack fix sfx issues
											Do(function()
												dropSelf.scene.audio:stopSfx("choose")
												dropSelf.scene.audio:stopSfx("levelup")
											end)
										}
									end
								)
							end}
					}
				end)
			}
	}
end
