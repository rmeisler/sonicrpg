local Menu = require "actions/Menu"
local BouncyText = require "actions/BouncyText"
local Transform = require "util/Transform"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Shake = require "actions/Shake"
local Ease = require "actions/Ease"
local Executor = require "actions/Executor"
local Action = require "actions/Action"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local PlayAudio = require "actions/PlayAudio"
local Repeat = require "actions/Repeat"

local EventHandler = require "util/EventHandler"

local BattleActor = class(EventHandler)

BattleActor.STATE_IDLE   = "idle"
BattleActor.STATE_DEAD   = "dead"
BattleActor.STATE_IMMOBILIZED = "immobile"
BattleActor.STATE_HOLOGRAM = "hologram"

function BattleActor:construct(scene, data)
	self.scene = scene
	self.transform = transform
	self.playerSlot = data.playerSlot
	self.sprite = data.sprite
	self.hp = data.hp or 0
	self.sp = data.sp or 0
	self.color = scene.color or {255,255,255,255}
	self.extraLives = 0
	
	self.raw = data
	
	local stats = data.stats or {}
	self.maxhp = stats.maxhp or 0
	self.maxsp = stats.maxsp or 0
	self.id = data.id or data.name
	self.name = data.altName or ""
	self.state = (self.hp == 0) and BattleActor.STATE_DEAD or BattleActor.STATE_IDLE
	self.stats = data.stats or {
		startxp = 0,
		maxhp   = 1000,
		attack  = 15,
		defense = 15,
		speed   = 15
	}
	self.hurtSfx = "smack"
	self.items = data.items or {}
	self.actions = data.battle or {}
	self.options = {}
	for k,v in pairs(self.actions) do
		table.insert(self.options, 1, k)
	end
end

function BattleActor:beginTurn()
	
end

function BattleActor:isTurnOver()
	return true
end

function BattleActor:attack(target)
	return Action()
end

function BattleActor:defend(target)
	return Wait(1)
end

function BattleActor:shockKnockback(impact, direction)
	local sprite = self:getSprite()
	return Serial {
		PlayAudio("sfx", "shocked", nil, true),
		Parallel {
			Repeat(Serial {
				Do(function()
					sprite:setInvertedColor()
				end),
				Wait(0.1),
				Do(function()
					sprite:removeInvertedColor()
				end),
				Wait(0.1),
			}, 3),
			Serial {
				Ease(sprite.transform, "x", sprite.transform.x - (impact/3 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x + (impact/3 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x - (impact/6 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x + (impact/6 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x, 20, "linear"),
			}
		}
	}
end

function BattleActor:poisonKnockback(impact, direction)
	local sprite = self:getSprite()
	return Serial {
		PlayAudio("sfx", "poison", 1.0, true),
		Ease(sprite.transform, "x", sprite.transform.x, 20, "linear")
	}
end

function BattleActor:getSprite()
	return self.sprite
end

function BattleActor:takeDamage(stats, isPassive, knockbackActionFun, attacker)
	isPassive = isPassive or false
	
	local sprite = self:getSprite()
	
	-- Reset animation if backward
	self.prevAnim = sprite.selected
	if self.prevAnim == "backward" then
		self.prevAnim = "idle"
	end

	-- Calculate damage based on stats of the attacker combined with our own
	local direction = (sprite.transform.x > love.graphics.getWidth()/2) and 1 or -1
	local impact = 50

	local knockBackAction
	local damageText
	local damageTextColor = {255, 0, 20, 255}

	local damage = self:calculateDamage(stats)
	
	-- Random chance of miss
	if stats.miss or damage == 0 then
		if stats.miss then
			damageText = "miss"
			damage = 0
			damageTextColor = {255,255,255,255}
		end
		
		impact = 0
		
		-- Flash transparency
		knockBackAction = Serial {
			PlayAudio("sfx", "pressx", 1.0, true),
			Ease(sprite.color, 4, 0, 10, "quad"),
			Ease(sprite.color, 4, 255, 2, "linear")
		}
	else
		-- Random chance of crit
		if self:critChance(stats) then
			damage = damage * 2
			impact = impact * 1.5
		end
		
		if knockbackActionFun then
			knockBackAction = knockbackActionFun(self, impact, direction)
		else
			knockBackAction = Serial {
				PlayAudio("sfx", self.hurtSfx, nil, true),
				Ease(sprite.transform, "x", sprite.transform.x + (impact/3 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x - (impact/6 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x - (impact/3 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x + (impact/6 * direction), 20, "quad"),
				Ease(sprite.transform, "x", sprite.transform.x, 20, "linear"),
			}
		end
	end
	
	if stats.nonlethal then
		damage = math.min(damage, self.hp - 1)
	end
	
	if not damageText then
		damageText = tostring(damage)
	end
	
	local bouncyTextOffsetX = (direction > 0) and 10 or -50
	local endHp = math.max(0, self.hp - damage)
	local action = Serial {
		isPassive = isPassive,
		
		Serial {
			Do(function()
				self:invoke("hit", damage, attacker)
				if (damage > 0 and sprite.animations["hurt"] and not self.noHurtAnim) then
					sprite:setAnimation("hurt")
				end
			end),
			Serial {
				Parallel {
					Ease(sprite.color, 1, 500, 10, "quad"),
					Ease(sprite.transform, "x", sprite.transform.x + (impact * direction), 10, "quad")
				},
				Parallel {
					knockBackAction,
					Ease(sprite.color, 1, self.color[1], 2, "linear"),
				}
			},
			
			Parallel {
				BouncyText(
					Transform(
						self.sprite.transform.x + bouncyTextOffsetX + (self.textOffset.x),
						self.sprite.transform.y + (self.textOffset.y)),
					damageTextColor,
					FontCache.ConsolasLarge,
					damageText,
					6,
					false,
					true -- outline
				),
				
				-- Animate the drop of hp
				Ease(self, "hp", endHp, 5),
				Do(function() self.hp = math.floor(self.hp) end)
			}
		},
		Do(function()
			sprite:setAnimation(self.prevAnim)
			self.hp = endHp
		end)
	}
	if endHp <= 0 then
		action:add(self.scene, self:die())
	end
	return action
end

function BattleActor:critChance(stats)
	return math.random() > (0.95 - (stats.luck/100))
end

function BattleActor:calculateDamage(stats)
	-- Calculate damage based on stats of the attacker combined with our own
	local selfStats = self:getStats()
	local defense = math.random(selfStats.defense * 2, selfStats.defense * 3)
	local damage = math.max(0, math.floor((stats.attack * 10 + math.random(stats.attack)) - defense))

	-- Random chance of miss
	if stats.miss or
	   damage == 0 or
	   ((selfStats.speed > stats.speed) and math.random(100) <= (selfStats.speed - stats.speed))
	then
		if damage ~= 0 or stats.miss then
			damage = 0
			stats.miss = true
		end
	end
	
	return damage
end

-- Takes a table of stat name => mult bonus
function BattleActor:bonusStats(stats)
	local copy = table.clone(self.stats)
	for k,v in pairs(stats) do
		copy[k] = copy[k] * (1.0 + v)
	end
	return copy
end

function BattleActor:pushStats(stats)
	if not self.statStack then
		self.statStack = {}
	end
	table.insert(self.statStack, 1, stats)
end

function BattleActor:popStats(stats)
	if not self.statStack then
		return
	end
	table.remove(self.statStack, 1)
end

function BattleActor:getStats()
	return self.statStack and self.statStack[1] or self.stats
end

function BattleActor:die()
	local revAction = Action()
	if self.reverseAnimation then
		revAction = self.reverseAnimation
	end

	return Serial {
		revAction,
		Do(function()
			self.hp = 0
			self.state = BattleActor.STATE_DEAD
			self.turnsImmobilized = false
			self.poisoned = nil
			
			if self.origOptions then
				self.options = table.clone(self.origOptions)
			end
			
			self:getSprite():setAnimation("dead")
			self:invoke("dead")
		end)
	}
end


return BattleActor
