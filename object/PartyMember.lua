local Menu = require "actions/Menu"
local BouncyText = require "actions/BouncyText"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Shake = require "actions/Shake"
local Ease = require "actions/Ease"
local Executor = require "actions/Executor"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"
local Do = require "actions/Do"
local MessageBox = require "actions/MessageBox"
local Animate = require "actions/Animate"

local Layout = require "util/Layout"
local Transform = require "util/Transform"
local TargetType = require "util/TargetType"

local SpriteNode = require "object/SpriteNode"
local Arrow = require "object/Arrow"
local BattleActor = require "object/BattleActor"

local RunAway = require "data/battle/actions/RunAway"

local Scene = require "scene/Scene"

local PartyMember = class(BattleActor)

-- TODO: Fix ctor override bug (See OpposingPartyMember)
function PartyMember:construct(scene, data)
	self.scene = scene
	self.transform = transform
	self.playerSlot = data.playerSlot
	self.sprite = data.sprite
	self.hp = data.hp or 0
	self.sp = data.sp or 0
	self.charge = 100
	self.extraLives = 0
	
	self.sprite.color = table.clone(scene.color or {255,255,255,255})
	
	self.raw = data
	
	local stats = data.stats or {}
	self.maxhp = stats.maxhp or 0
	self.maxsp = stats.maxsp or 0
	self.id = data.id or data.name
	self.name = data.altName or ""
	self.state = (self.hp == 0) and BattleActor.STATE_DEAD or BattleActor.STATE_IDLE
	self.stats = data.stats
	self.actions = data.battle or {}
	self.options = {}
	for _,v in pairs(self.actions) do
		self:addBattleOption(v)
	end
	
	self.origOptions = table.clone(self.options)
	
	self.textOffset = data.textOffset or Transform()

	self.canTargetFlying = false
	
	self.hurtSfx = "smack2"

	-- Check all equipped items for special bonuses
	self.attackEvent = false
	self.defenseEvent = false

	if data.equip.weapon and data.equip.weapon.event then
		self.defenseEvent = data.equip.weapon.event.action()
	end
	if data.equip.armor and data.equip.armor.event then
		self.defenseEvent = data.equip.armor.event.action()
	end
	if data.equip.accessory and data.equip.accessory.event then
		self.defenseEvent = data.equip.accessory.event.action()
	end
	
	if self.state == BattleActor.STATE_DEAD then
		self.sprite:setAnimation("dead")
	end
	
	self:addHandler("hit", function(damage)
		if damage > 0 and self.state == BattleActor.STATE_IMMOBILIZED then
			self.state = BattleActor.STATE_IDLE
			self.prevAnim = "idle"
		end
	end)
	
	self.side = TargetType.Party
end

function PartyMember:addBattleOption(battleSkill)
	local option = battleSkill.name
	local target = battleSkill.target
	local action = battleSkill.action
	local fun
	if target == TargetType.None then
		fun = function(menu)
			self.scene:run(action(self, menu))
		end
	else
		fun = function(menu)
			self:chooseTarget(menu, target, battleSkill.unusable or function(_target) return false end, action)
		end
	end
	table.insert(self.options, {Layout.Text(option), choose = fun})
end

function PartyMember:setShadow()
	-- HIDDEN, UNHIDE WHEN WORKING
	self.dropShadow = SpriteNode(
		self.scene,
		Transform(self.sprite.transform.x - 22, self.sprite.transform.y + self.sprite.h - 13, 1.3, 2),
		{255,255,255,0},
		"dropshadow"
	)
	self.dropShadow.sortOrderY = -1
end

function PartyMember:beginTurn()
	if self.state == BattleActor.STATE_IMMOBILIZED then
		self.turnover = false
		
		if not self.turnsImmobilized then
			self.turnsImmobilized = 1
		else
			self.turnsImmobilized = self.turnsImmobilized - 1
		end
		
		local shake = Repeat(Serial {
			Do(function()
				self.scene.audio:playSfx("bang")
			end),

			Ease(
				self.sprite.transform,
				"x",
				function() return self.sprite.transform.x + 7 end,
				10
			),
			Ease(
				self.sprite.transform,
				"x",
				function() return self.sprite.transform.x - 7 end,
				10
			),
			Ease(
				self.sprite.transform,
				"x",
				function() return self.sprite.transform.x + 3 end,
				10
			),
			Ease(
				self.sprite.transform,
				"x",
				function() return self.sprite.transform.x - 3 end,
				10
			),
			Ease(
				self.sprite.transform,
				"x",
				function() return self.sprite.transform.x end,
				10
			),
			
			Wait(0.5)
		}, 2)
		
		-- Escape
		if math.random(1, self.turnsImmobilized + 1) then
			BattleActor.beginTurn(self)
			
			self.turnsImmobilized = nil

			self.mainMenu = Menu {
				transform = Transform(250, love.graphics.getHeight() - 97),
				layout = Layout(self.options),	
			}
			self.mainMenu:addHandler("cancel", PartyMember.skipTurn, self, self.mainMenu)
			self.state = BattleActor.STATE_IDLE
			
			self.scene:run {
				shake,
				self.escapeAction or Action(),
				Do(function()
					self.sprite:setAnimation("idle")
					self:invoke("escape")
					self.escapeAction = nil
				end),
				MessageBox {message=self.name.." broke free!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
				self.mainMenu
			}
		else
			self.scene:run {
				shake,
				MessageBox {message=self.name.." is immobilized!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(1)},
				Do(function()
					self:endTurn()
				end)
			}
		end
	else
		-- If poisoned, take some damage
		local preAction = Action()
		if self.poisoned then
			preAction = Serial {
				MessageBox {message=self.name.." is poisoned!", rect=MessageBox.HEADLINER_RECT, closeAction=Wait(0.6)},
				self:takeDamage(self.poisoned, true, BattleActor.poisonKnockback)
			}
		end
		
		if self.onNextTurn then
			print("next turn here")
			preAction = Serial {
				self.onNextTurn,
				preAction
			}
			self.onNextTurn = nil
		end
	
		BattleActor.beginTurn(self)
		
		self.turnover = false

		self.mainMenu = Menu {
			transform = Transform(250, love.graphics.getHeight() - 97),
			layout = Layout(self.options),	
		}
		self.mainMenu:addHandler("cancel", PartyMember.skipTurn, self, self.mainMenu)
		self.scene:run {
			preAction,
			self.mainMenu
		}
	end
end

function PartyMember:skipTurn(actionMenu)
	self.scene:run(Menu {
		layout = Layout {
			{Layout.Text("Skip turn?"), selectable = false},
			{Layout.Text("Yes"), choose = function(menu)
				menu:close()
				self.mainMenu:close()
				self.scene:run {
					Parallel {
						menu,
						self.mainMenu,
					},
					Do(function() self:endTurn() end)
				}
			end},
			{Layout.Text("No"), choose = function(menu)
				menu:close()
				self.scene:run(menu)
			end},
			colWidth = 200
		},
		transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
		selectedRow = 2,
		cancellable = true
	})
end

function PartyMember:chooseTarget(menu, targetType, unusable, callback, ...)
	-- Already choosing target
	if self.arrow then
		self:cleanupChooseTarget()
	end
	
	-- Don't allow chooseTarget if menu is in the process of closing
	if menu.closing then
		return
	end

	self.scene:addHandler("keytriggered", PartyMember.chooseTargetKey, self, unusable)
	self.scene:focus("keytriggered", self)
	
	-- Hide menu arrow
	menu.showCursor = false

	self.targetType = targetType
	self.callback = callback
	self.callbackArgs = {...}
	self.selectedMenu = menu

	-- Setup arrow
	if self.targetType == TargetType.AllOpponents then
		self.arrow = {}
		for _, target in pairs(self.scene.opponents) do
			local arrow = SpriteNode(
				self.scene,
				Transform(
					target.sprite.transform.x + target.sprite.w / 2,
					target.sprite.transform.y - target.sprite.h * 1.5,
					2,
					2,
					math.pi/2
				),
				{255,255,255,255},
				CursorSprite,
				nil,
				nil,
				"ui"
			)
			-- Can't target for some reason
			if (unusable and unusable(target)) or target.untargetable then
				arrow.color = {150,150,150, 255}
			else
				arrow.color = {255, 255, 255, 255}
			end
			table.insert(self.arrow, arrow)
		end
	elseif self.targetType == TargetType.AllParty then
		self.arrow = {}
		for _, target in pairs(self.scene.party) do
			local arrow = SpriteNode(
				self.scene,
				Transform(
					target.sprite.transform.x + target.sprite.w / 2,
					target.sprite.transform.y - target.sprite.h * 1.5,
					2,
					2,
					math.pi/2
				),
				{255,255,255,255},
				CursorSprite,
				nil,
				nil,
				"ui"
			)
			-- Can't target for some reason
			if (unusable and unusable(target)) or target.untargetable then
				arrow.color = {150,150,150, 255}
			else
				arrow.color = {255, 255, 255, 255}
			end
			table.insert(self.arrow, arrow)
		end
	else
		local target = self.scene[self.targetType][self.scene.selectedTarget]
		if not target then
			self.scene.selectedTarget = 1
			target = self.scene[self.targetType][self.scene.selectedTarget]
		end
		self.arrow = SpriteNode(
			self.scene,
			Transform(
				target.sprite.transform.x + target.sprite.w / 2,
				target.sprite.transform.y - target.sprite.h * 1.5,
				2,
				2,
				math.pi/2
			),
			{255,255,255,255},
			CursorSprite,
			nil,
			nil,
			"ui"
		)
		
		-- Can't target for some reason
		if (unusable and unusable(target)) or target.untargetable then
			self.arrow.color = {150,150,150, 255}
		else
			self.arrow.color = {255, 255, 255, 255}
		end
	end
end

function PartyMember:chooseTargetKey(key, _, unusable)
	if  self.targetType == TargetType.AllOpponents or
		self.targetType == TargetType.AllParty
	then
		if key == "x" then
			local targets
			local onBeforeAttackActions = {}
			local onAttackActions = {}
			if self.targetType == TargetType.AllParty then
				targets = table.clone(self.scene.party)
				for index, target in pairs(targets) do
					if (unusable and unusable(target)) or target.untargetable then
						targets[index] = nil
					end
				end
			else
				targets = table.clone(self.scene.opponents)
				for index, target in pairs(targets) do
					if (not unusable or not unusable(target)) and not target.untargetable then
						table.insert(onAttackActions, (target.onAttack and target.state ~= BattleActor.STATE_IMMOBILIZED) and target:onAttack(self) or Action())
						table.insert(onBeforeAttackActions, target.onBeforeAttack and target:onBeforeAttack(self) or Action())
					else
						targets[index] = nil
					end
				end
			end
			
			-- Perform callback
			if next(targets) ~= nil then
				self.scene.audio:playSfx("choose", nil, true)
				
				-- Choosing target
				for _, arrow in pairs(self.arrow) do
					arrow:remove()
				end
				self.arrow = nil
				self.scene:removeHandler("keytriggered", PartyMember.chooseTargetKey, self)
				self.scene:unfocus("keytriggered")
				
				self.selectedMenu:close()
				self.scene:run {
					Parallel {
						self.selectedMenu,
						Serial {
							Serial(onBeforeAttackActions),
							self.callback(self, targets, unpack(self.callbackArgs)),
							Serial(onAttackActions),
							Do(function() self:endTurn() end)
						}
					}
				}
			else
				self.scene.audio:playSfx("error", nil, true)
			end
		elseif key == "z" then
			-- Back out of attack option
			self:cleanupChooseTarget()
		end
	else
		local target = self.scene[self.targetType][self.scene.selectedTarget]
		local invalidateArrowPos = false

		if key == "up" then
			self.scene.audio:playSfx("cursor", nil, true)
			self.scene.selectedTarget = (self.scene.selectedTarget == 1) and #self.scene[self.targetType] or (self.scene.selectedTarget - 1)
			target = self.scene[self.targetType][self.scene.selectedTarget]
			invalidateArrowPos = true

		elseif key == "down" then
			self.scene.audio:playSfx("cursor", nil, true)
			self.scene.selectedTarget = (self.scene.selectedTarget == #self.scene[self.targetType]) and 1 or (self.scene.selectedTarget + 1)
			target = self.scene[self.targetType][self.scene.selectedTarget]
			invalidateArrowPos = true
			
		elseif key == "left" or key == "right" then
			-- Change target type
			self.targetType = self.targetType == TargetType.Opponent and TargetType.Party or TargetType.Opponent
			self.scene.selectedTarget = 1
			target = self.scene[self.targetType][self.scene.selectedTarget]
			invalidateArrowPos = true
		
		elseif key == "x" then
			-- Can't attack flying if we can't target flying
			if (unusable and unusable(target)) or target.untargetable then
				self.scene.audio:playSfx("error", nil, true)
			else
				self.scene.audio:playSfx("choose", nil, true)

				-- Choosing target
				self.arrow:remove()
				self.arrow = nil
				self.scene:removeHandler("keytriggered", PartyMember.chooseTargetKey, self)
				self.scene:unfocus("keytriggered")
				
				-- Set sort order based on target
				self.sprite.sortOrderY = target.sprite.transform.y + target.sprite.h*2 - self.sprite.h*2
				
				local startingX = self.dropShadow.transform.x
				local startingY = self.dropShadow.transform.y
				
				-- Perform callback
				self.selectedMenu:close()
				self.scene:run {
					Parallel {
						self.selectedMenu,
						-- Have shadow follow
						Do(function()
							-- HACK
							local m = 1 - (self.dropShadow.transform.x - target.sprite.transform.x + target.sprite.w*3)/(startingX - target.sprite.transform.x + target.sprite.w*3)
							self.dropShadow.transform.x = self.sprite.transform.x - 22
							self.dropShadow.transform.y = startingY + (startingY - target.sprite.transform.y + target.sprite.h) * m
						end),
						Serial {
							target.onBeforeAttack and target:onBeforeAttack(self) or Action(),
							self.callback(self, target, unpack(self.callbackArgs)),
							(target.onAttack and target.state ~= BattleActor.STATE_IMMOBILIZED) and target:onAttack(self) or Action(),
							Do(function() self:endTurn() end)
						}
					},
					-- Update drop shadow
					Do(function()
						self.dropShadow.transform.x = startingX
						self.dropShadow.transform.y = startingY
					end)
				}
			end
		elseif key == "z" then
			-- Back out of attack option
			self:cleanupChooseTarget()
		end
		
		if invalidateArrowPos and self.arrow then
			self.arrow.transform.x = target.sprite.transform.x + target.sprite.w / 2
			self.arrow.transform.y = target.sprite.transform.y - target.sprite.h * 1.5
			
			-- Can't target
			if (unusable and unusable(target)) or target.untargetable then
				self.arrow.color = {150,150,150, 255}
			else
				self.arrow.color = {255, 255, 255, 255}
			end
		end
	end
end

function PartyMember:endTurn()
	self.scene:invoke("turnover")
	self.scene.handlers["turnover"] = {} -- Reset handlers
	self.turnover = true
	self.sprite.sortOrderY = nil
end

function PartyMember:isTurnOver()
	return self.turnover
end

function PartyMember:cleanupChooseTarget(menu)
	if  self.targetType == TargetType.AllOpponents or
		self.targetType == TargetType.AllParty
	then
		for _, arrow in pairs(self.arrow) do
			arrow:remove()
		end
		self.arrow = nil
	else
		self.arrow:remove()	
	end
	
	self.arrow = nil
	self.scene:removeHandler("keytriggered", PartyMember.chooseTargetKey, self)
	self.scene:unfocus("keytriggered")
	
	-- Go back to top menu
	self.selectedMenu.showCursor = true
end


return PartyMember
