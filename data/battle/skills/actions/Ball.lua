local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Repeat = require "actions/Repeat"
local Ease = require "actions/Ease"

local Layout = require "util/Layout"
local Telegraph = require "data/monsters/actions/Telegraph"

return function(self)
	return Serial {
		Animate(self.sprite, "ball"),
		Telegraph(self, self.name.." defense increased by 50%!", {255,255,255,50}),
		Do(function()
			-- Change animations
			self.sprite:pushOverride("idle", "ball_idle")
			self.sprite:pushOverride("hurt", "ball_idle")
			self.sprite:pushOverride("shock", "ball_idle")

			-- Change options
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
				{Layout.Text("Unball"),
					choose = function(menu)
						menu:close()

						self.scene:run {
							menu,
							Animate(self.sprite, "unball"),
							Telegraph(self, self.name.." defense returned to base stats", {255,255,255,50}),
							Do(function()
								self.sprite:setAnimation("idle")
								self.sprite:popOverride("idle")
								self.sprite:popOverride("hurt")
								self.sprite:popOverride("shock")
								self:popStats()
								self.options = self.origOptions
								self:endTurn()
							end)
						}
					end}
			}

			-- Increase defense
			local buffStats = table.clone(self.stats)
			buffStats.defense = self.stats.defense * 1.5
			self:pushStats(buffStats)

			self.noCounter = true

			self:endTurn()
		end)
	}
end