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
local SpriteNode = require "object/SpriteNode"

return function(self)
	local descBox = DescBox("Laser Configuration Interface")
	return Parallel {
		descBox,
		Menu {
			layout = Layout {
				{Layout.Text("Shift Left"),
					choose = function(menu)
						menu:close()
						local lasers = {}
						if  self.scene.objectLookup.Laser2_1 and
							not self.scene.objectLookup.Laser1_1
						then
							lasers = {
								self.scene.objectLookup.Laser2_1,
								self.scene.objectLookup.Laser2_2
							}
						elseif  self.scene.objectLookup.Laser2_3  and
							not self.scene.objectLookup.Laser1_3
						then
							lasers = {
								self.scene.objectLookup.Laser2_3,
								self.scene.objectLookup.Laser2_4
							}
						elseif  self.scene.objectLookup.Laser2_5 and
							not self.scene.objectLookup.Laser1_5
						then
							lasers = {
								self.scene.objectLookup.Laser2_5,
								self.scene.objectLookup.Laser2_6
							}
						else
							self.scene.audio:playSfx("error", nil, true)
							return
						end
						
						local sallyDummy = SpriteNode(
							self.scene,
							Transform.from(self.scene.player.transform),
							{255,255,255,255},
							"sprites/sally",
							nil,
							nil,
							"objects"
						)
						sallyDummy:setAnimation("nicholeup")
						self.scene.player.sprite.visible = false
						self.scene.player:removeKeyHint()
						self.scene.player.cinematic = true
						self.scene.player.dontfuckingmove = true
						self.scene.player.blockingKeyHint = true
						
						self.scene:run {
							menu,
							descBox,
							-- Pan up to show lasers
							Parallel {
								Ease(self.scene.player, "y", self.scene.player.y - 400, 1),
								Ease(sallyDummy.transform, "y", sallyDummy.transform.y + 400, 1),
							},
							Wait(1),
						
							Parallel {
								Ease(lasers[1].sprite.color, 4, 0, 5),
								Ease(lasers[2].sprite.color, 4, 0, 5)
							},
							Do(function()
								lasers[1].x = lasers[1].x - 320
								lasers[2].x = lasers[2].x - 320
								lasers[1]:updateCollision()
								lasers[2]:updateCollision()
								
								local newName1 = string.gsub(lasers[1].laserName, "Laser2", "Laser1")
								local newName2 = string.gsub(lasers[2].laserName, "Laser2", "Laser1")
								self.scene.objectLookup[newName1] = lasers[1]
								self.scene.objectLookup[newName2] = lasers[2]
								self.scene.objectLookup[lasers[1].laserName] = nil
								self.scene.objectLookup[lasers[2].laserName] = nil
								lasers[1].laserName = newName1
								lasers[2].laserName = newName2
								
								-- Solved the puzzle!
								if  not self.scene.objectLookup.Laser2_1 and
									not self.scene.objectLookup.Laser2_2 and
									not self.scene.objectLookup.Laser2_3 and
									not self.scene.objectLookup.Laser2_4 and
									not self.scene.objectLookup.Laser2_5 and
									not self.scene.objectLookup.Laser2_6
								then
									self:run(MessageBox {
										message="Sally: That's it!",
										blocking=true
									})
								end
							end),
							
							Wait(1),
							Parallel {
								Ease(lasers[1].sprite.color, 4, 255, 5),
								Ease(lasers[2].sprite.color, 4, 255, 5)
							},
							Wait(1),
							
							-- Pan back down
							Parallel {
								Ease(self.scene.player, "y", self.scene.player.y, 1),
								Ease(sallyDummy.transform, "y", sallyDummy.transform.y, 1),
							},
							Do(function()
								sallyDummy:remove()
								self.scene.player.sprite.visible = true
								self.scene.player.cinematic = false
								self.scene.player.dontfuckingmove = false
								self.scene.player.blockingKeyHint = false
								self.scene.player:showKeyHint(
									self.isInteractable,
									self.specialHintPlayer
								)
								self.scene.player.keyHintObj = tostring(self)
							end),
						}
					end},
				{Layout.Text("Shift Right"),
					choose = function(menu)
						menu:close()
						local lasers = {}
						if  self.scene.objectLookup.Laser2_1 and
							not self.scene.objectLookup.Laser3_1
						then
							lasers = {
								self.scene.objectLookup.Laser2_1,
								self.scene.objectLookup.Laser2_2
							}
						elseif  self.scene.objectLookup.Laser2_3 and
							not self.scene.objectLookup.Laser3_3
						then
							lasers = {
								self.scene.objectLookup.Laser2_3,
								self.scene.objectLookup.Laser2_4
							}
						elseif  self.scene.objectLookup.Laser2_5 and
							not self.scene.objectLookup.Laser3_5
						then
							lasers = {
								self.scene.objectLookup.Laser2_5,
								self.scene.objectLookup.Laser2_6
							}
						else
							self.scene.audio:playSfx("error", nil, true)
							return
						end
						
						-- HACK
						-- Dummy sprite shouldn't be necessary. Separate camera from player
						local sallyDummy = SpriteNode(
							self.scene,
							Transform.from(self.scene.player.transform),
							{255,255,255,255},
							"sprites/sally",
							nil,
							nil,
							"objects"
						)
						sallyDummy:setAnimation("nicholeup")
						self.scene.player.sprite.visible = false
						self.scene.player:removeKeyHint()
						self.scene.player.cinematic = true
						self.scene.player.dontfuckingmove = true
						self.scene.player.blockingKeyHint = true
						
						self.scene:run {
							menu,
							descBox,
							-- Pan up to show lasers
							Parallel {
								Ease(self.scene.player, "y", self.scene.player.y - 400, 1),
								Ease(sallyDummy.transform, "y", sallyDummy.transform.y + 400, 1),
							},
							Wait(1),
						
							Parallel {
								Ease(lasers[1].sprite.color, 4, 0, 5),
								Ease(lasers[2].sprite.color, 4, 0, 5)
							},
							Do(function()
								lasers[1].x = lasers[1].x + 320
								lasers[2].x = lasers[2].x + 320
								lasers[1]:updateCollision()
								lasers[2]:updateCollision()
								
								local newName1 = string.gsub(lasers[1].laserName, "Laser2", "Laser3")
								local newName2 = string.gsub(lasers[2].laserName, "Laser2", "Laser3")
								self.scene.objectLookup[newName1] = lasers[1]
								self.scene.objectLookup[newName2] = lasers[2]
								self.scene.objectLookup[lasers[1].laserName] = nil
								self.scene.objectLookup[lasers[2].laserName] = nil
								lasers[1].laserName = newName1
								lasers[2].laserName = newName2
								
								-- Solved the puzzle!
								if  not self.scene.objectLookup.Laser2_1 and
									not self.scene.objectLookup.Laser2_2 and
									not self.scene.objectLookup.Laser2_3 and
									not self.scene.objectLookup.Laser2_4 and
									not self.scene.objectLookup.Laser2_5 and
									not self.scene.objectLookup.Laser2_6
								then
									self:run(MessageBox {
										message="Sally: That's it!",
										blocking=true
									})
								end
							end),
							
							Wait(1),
							Parallel {
								Ease(lasers[1].sprite.color, 4, 255, 5),
								Ease(lasers[2].sprite.color, 4, 255, 5)
							},
							Wait(1),
							
							-- Pan back down
							Parallel {
								Ease(self.scene.player, "y", self.scene.player.y, 1),
								Ease(sallyDummy.transform, "y", sallyDummy.transform.y, 1),
							},
							Do(function()
								sallyDummy:remove()
								self.scene.player.sprite.visible = true
								self.scene.player.cinematic = false
								self.scene.player.dontfuckingmove = false
								self.scene.player.blockingKeyHint = false
								self.scene.player:showKeyHint(
									self.isInteractable,
									self.specialHintPlayer
								)
								self.scene.player.keyHintObj = tostring(self)
							end),
						}
					end},
				{Layout.Text("Reset"),
					choose = function(menu)
						menu:close()
						
						-- HACK
						-- Dummy sprite shouldn't be necessary. Separate camera from player
						local sallyDummy = SpriteNode(
							self.scene,
							Transform.from(self.scene.player.transform),
							{255,255,255,255},
							"sprites/sally",
							nil,
							nil,
							"objects"
						)
						sallyDummy:setAnimation("nicholeup")
						self.scene.player.sprite.visible = false
						self.scene.player:removeKeyHint()
						self.scene.player.cinematic = true
						self.scene.player.dontfuckingmove = true
						self.scene.player.blockingKeyHint = true
						
						-- Find all the lasers
						local lasers = {
							Laser1_1 = self.scene.objectLookup.Laser1_1,
							Laser1_2 = self.scene.objectLookup.Laser1_2,
							Laser1_3 = self.scene.objectLookup.Laser1_3,
							Laser1_4 = self.scene.objectLookup.Laser1_4,
							Laser1_5 = self.scene.objectLookup.Laser1_5,
							Laser1_6 = self.scene.objectLookup.Laser1_6,
							
							Laser2_1 = self.scene.objectLookup.Laser2_1,
							Laser2_2 = self.scene.objectLookup.Laser2_2,
							Laser2_3 = self.scene.objectLookup.Laser2_3,
							Laser2_4 = self.scene.objectLookup.Laser2_4,
							Laser2_5 = self.scene.objectLookup.Laser2_5,
							Laser2_6 = self.scene.objectLookup.Laser2_6,
							
							Laser3_1 = self.scene.objectLookup.Laser3_1,
							Laser3_2 = self.scene.objectLookup.Laser3_2,
							Laser3_3 = self.scene.objectLookup.Laser3_3,
							Laser3_4 = self.scene.objectLookup.Laser3_4,
							Laser3_5 = self.scene.objectLookup.Laser3_5,
							Laser3_6 = self.scene.objectLookup.Laser3_6,
						}
						
						local hideActions = {}
						local showActions = {}
						for curName, laser in pairs(lasers) do
							if laser then
								table.insert(hideActions, Ease(laser.sprite.color, 4, 0, 5))
								table.insert(
									showActions,
									Serial {
										Do(function()
											laser.x = self.scene.laserPositions[laser.name].x
											laser.y = self.scene.laserPositions[laser.name].y
											laser:updateCollision()
											self.scene.objectLookup[curName] = nil
											self.scene.objectLookup[laser.name] = laser
											laser.laserName = laser.name
										end),
										Ease(laser.sprite.color, 4, 255, 5)
									}
								)
							end
						end
						
						self.scene:run {
							menu,
							descBox,
							-- Pan up to show lasers
							Parallel {
								Ease(self.scene.player, "y", self.scene.player.y - 400, 1),
								Ease(sallyDummy.transform, "y", sallyDummy.transform.y + 400, 1),
							},
							Wait(1),
							Parallel(hideActions),
							Wait(1),
							Parallel(showActions),
							Wait(1),
							
							-- Pan back down
							Parallel {
								Ease(self.scene.player, "y", self.scene.player.y, 1),
								Ease(sallyDummy.transform, "y", sallyDummy.transform.y, 1),
							},
							Do(function()
								sallyDummy:remove()
								self.scene.player.sprite.visible = true
								self.scene.player.cinematic = false
								self.scene.player.dontfuckingmove = false
								self.scene.player.blockingKeyHint = false
								self.scene.player:showKeyHint(
									self.isInteractable,
									self.specialHintPlayer
								)
								self.scene.player.keyHintObj = tostring(self)
							end),
						}
					end},
				{Layout.Text("Cancel"),
					choose = function(menu)
						menu:close()
					end},
				colWidth = 200
			},
			transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
			cancellable = true,
			withClose = Do(function() descBox:close() end),
			blocking = true
		}
	}
end
