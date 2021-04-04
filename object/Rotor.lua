local MessageBox = require "actions/MessageBox"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Repeat = require "actions/Repeat"
local Executor = require "actions/Executor"
local Menu = require "actions/Menu"
local Action = require "actions/Action"

local BlockPlayer = require "actions/BlockPlayer"

local Transform = require "util/Transform"
local Layout = require "util/Layout"

local Pickup = require "object/Pickup"
local NPC = require "object/NPC"

local Rotor = class(NPC)

function Rotor:construct(scene, layer, object)
	self.craftItems = {
		WaterBalloon = require("data/items/WaterBalloon"),
		Mine = require("data/items/Mine"),
		FlashGrenade = require("data/items/FlashGrenade"),
		EMPGrenade = require("data/items/EMPGrenade"),
		LaserShield = require("data/items/LaserShield"),
		SuperMagnet = require("data/items/SuperMagnet")
	}
	self.itemSlots = {
		Transform(576, 352),
		Transform(576, 448),
		Transform(576, 512)
	}

	NPC.init(self)

	self:addInteract(Rotor.onInteract)
	self:addSceneHandler("update")
end

function Rotor:onInteract()
	self.scene.player.hidekeyhints[tostring(self)] = self

    local facingMap = {idleup = "idledown", idledown = "idleup", idleleft = "idleright", idleright = "idleleft"}
    local playername = GameState.party[GameState.leader].altName
    self.sprite:setAnimation(facingMap[self.scene.player.state] or "idledown")
    self.scene:run {
        MessageBox {
            message = "Rotor: Hey "..playername.."! {p30}Got any spare parts for me?",
            blocking = true
        },
        BlockPlayer{ Menu {
            layout = Layout {
                {Layout.Text("Show items to Rotor?"), selectable = false},
                {Layout.Text("Yes"), noChooseSfx = true, choose = function(menu)
                    menu:close()
                    local junkItems = GameState:getItemsOfSubtype("junk")
                    local junkCount = 0
                    for _, rec in pairs(junkItems) do
                        junkCount = junkCount + rec.count
                    end
                    local menuParams = {}
                    for file, item in pairs(self.craftItems) do
                        if item.cost <= junkCount then
                            table.insert(
								menuParams,
								{
									Layout.Text(item.name),
									choose = function(menu)
										menu:close()
										
										local curCost = item.cost
										for _, rec in pairs(junkItems) do
											if curCost == 0 then
												break
											end
											while curCost > 0 and rec.count > 0 do
												GameState:useItem(rec)
												curCost = curCost - 1
											end
										end
										
										local slot = table.remove(self.itemSlots)
										local pickup = Pickup(
											self.scene,
											{name = "objects"},
											{
												name = file,
												x = slot.x,
												y = slot.y,
												width = 64,
												height = 32,
												properties = {item = file, sprite = "art/sprites/"..item.img..".png"}
											}
										)
										self.scene:addObject(pickup)
										pickup.sprite.color[4] = 0
										pickup:addHandler("remove", function()
											table.insert(self.itemSlots, slot)
										end)
										
										self.scene:run {
											menu,
											MessageBox { message = "Rotor: I'm on it!", blocking = true},
											Ease(pickup.sprite.color, 4, 255, 2)
										}
									end,
									desc = item.desc
								}
							)
                        end
                    end
                    if #menuParams > 1 then
                        self.scene:run {
                            menu,
                            MessageBox {
                                message = "Rotor: Hmmm{p30}.{p30}.{p30}. {p30}alright, here's what I can make for you.",
                                blocking = true
                            },
                            BlockPlayer{Menu {
                                layout = Layout(menuParams),
                                cancellable = true,
                                transform = Transform(love.graphics.getWidth()/2 + 150, love.graphics.getHeight()/2 + 30)
                            }},
							self:exitMsg()
                        }
                    else
                        self.scene:run {
                            menu,
                            MessageBox {
                                message = "Rotor: Hmmm{p30}.{p30}.{p30}.",
                                blocking = true
                            },
                            MessageBox {
                                message = "Rotor: Sorry guys, I need at least 3 junk parts in order to make something for you.",
                                blocking = true
                            }
                        }
                    end
                end},
                {Layout.Text("No"), choose = function(menu)
                    menu:close()
                    self.scene:run {
                        menu,
                        self:exitMsg()
                    }
                end},
            },
            cancellable = true,
            transform = Transform(love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 30),
            selectedRow = 2
        }},
        Do(function()
            self.scene.player.hidekeyhints[tostring(self)] = nil
        end)
    }
end

function Rotor:exitMsg()
	return MessageBox {
		message = "Rotor: If you find any junk parts, bring 'em to me!",
		blocking = true
	}
end

function Rotor:update(dt)
	NPC.update(self, dt)

	local player = self.scene.player
	local dx = self.x + self.sprite.w - player.x + player.sprite.w
    local dy = self.y + self.sprite.h - player.y + player.sprite.h
    if dx * dx + dy * dy < 100*100 then
        return
    end

    if math.abs(dx) < math.abs(dy) then
        if dy < 0 then
            self.sprite:setAnimation("idledown")
        else
            self.sprite:setAnimation("idleup")
        end
    else
        if dx < 0 then
            self.sprite:setAnimation("idleright")
        else
            self.sprite:setAnimation("idleleft")
        end
    end
end


return Rotor
