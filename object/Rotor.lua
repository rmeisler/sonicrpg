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
local Animate = require "actions/Animate"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"

local BlockPlayer = require "actions/BlockPlayer"

local Transform = require "util/Transform"
local Layout = require "util/Layout"

local SpriteNode = require "object/SpriteNode"
local Pickup = require "object/Pickup"
local NPC = require "object/NPC"

local Rotor = class(NPC)

function Rotor:construct(scene, layer, object)
	self.craftItems = {
		{id = "WaterBalloon", item = require("data/items/WaterBalloon")},
		{id = "Mine", item = require("data/items/Mine")},
		{id = "FlashGrenade", item = require("data/items/FlashGrenade")},
		{id = "LaserShield", item = require("data/items/LaserShield")},
		{id = "EMPGrenade", item = require("data/items/EMPGrenade")},
		{id = "SuperMagnet", item = require("data/items/SuperMagnet")}
	}
	self.itemSlots = {
		Transform(576, 352 - 32),
		Transform(576, 448 - 48),
		Transform(576, 512 - 32)
	}

	NPC.init(self)

	self:addInteract(Rotor.onInteract)
	self:addSceneHandler("update")
	
	self.maxSparkleCount = 5
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
                {Layout.Text("Yes"), choose = function(menu)
                    menu:close()
					
					if #self.itemSlots == 0 then
						self.scene:run {
                            menu,
                            MessageBox {
                                message = "Rotor: Maybe you can make some room on my table first?",
                                blocking = true
                            }
                        }
						return
					end
					
                    local junkItems = GameState:getItemsOfSubtype("junk")
                    local junkCount = 0
                    for _, rec in pairs(junkItems) do
                        junkCount = junkCount + rec.count
                    end
                    local menuParams = {}
                    for _, rec in pairs(self.craftItems) do
						local id = rec.id
						local item = rec.item
                        if item.cost <= junkCount then
                            table.insert(
								menuParams,
								{
									Layout.Image{name=item.icon},
									Layout.Text(item.name),
									Layout.Text{text={{255,255,0,255},tostring(item.cost)}},
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
												name = id,
												x = slot.x,
												y = slot.y,
												width = 64,
												height = 32,
												properties = {item = id, sprite = "art/sprites/"..item.img..".png", rotorItem = true}
											}
										)
										self.scene:addObject(pickup)
										pickup.sprite.color[1] = 512
										pickup.sprite.color[2] = 512
										pickup.sprite.color[3] = 512
										pickup.sprite.color[4] = 0
										pickup:addHandler("remove", function()
											table.insert(self.itemSlots, slot)
										end)
										
										self.scene:run {
											menu,
											AudioFade("music", 0.8, 0, 2),
											MessageBox { message = "Rotor: I'm on it!", blocking = true},
											self:fadeOut(),
											PlayAudio("sfx", "craft", 1.0),
											self:fadeIn(),
											Parallel {
												Serial {
													PlayAudio("music", "sallyrally", 1.0),
													PlayAudio("music", "doittoit", 1.0, true, true)
												},
												Ease(pickup.sprite.color, 4, 255, 0.5),
												Serial {
													Do(function() self.sparkleCount = self.maxSparkleCount end),
													Repeat(Serial {
														Do(function()
															local sparkle = SpriteNode(
																pickup.scene,
																Transform(pickup.x, pickup.y - pickup.sprite.h*3),
																{512,512,512,0},
																"sparkle",
																5,
																5,
																"ui"
															)
															Executor(pickup.scene):act(Parallel {
																Repeat(Animate(sparkle, "idle"), nil, false),
																Ease(sparkle.transform, "y", pickup.y - pickup.sprite.h*4, 1.5),
																Ease(sparkle.color, 4, 255, 9),
																Repeat(Serial {
																	Parallel {
																		Ease(sparkle.transform, "x", sparkle.transform.x, 6),
																		Ease(sparkle.transform, "sx", 2, 12),
																		Ease(sparkle.transform, "sy", 2, 12),
																	},
																	Parallel {
																		Ease(sparkle.transform, "x", sparkle.transform.x + pickup.sprite.w*2, 6),
																		Ease(sparkle.transform, "sx", 1, 12),
																		Ease(sparkle.transform, "sy", 1, 12),
																	}
																}, 2, true),
																Serial {
																	Wait(1),
																	Ease(sparkle.color, 4, 0, 3)
																},
															})
															self.sparkleCount = self.sparkleCount + 1
														end),
														Wait(0.1)
													}, 4),
													Parallel {
														Ease(pickup.sprite.color, 1, 255, 1),
														Ease(pickup.sprite.color, 2, 255, 1),
														Ease(pickup.sprite.color, 3, 255, 1),
													}
												}
											}
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

function Rotor:fadeOut()
	return Parallel {	
		-- Fade to black
		Ease(self.scene.bgColor, 1, 0, 2, "linear"),
		Ease(self.scene.bgColor, 2, 0, 2, "linear"),
		Ease(self.scene.bgColor, 3, 0, 2, "linear"),
		Do(function()
			ScreenShader:sendColor("multColor", self.scene.bgColor)
		end)
	}
end

function Rotor:fadeIn()
	return Parallel {	
		-- Fade in
		Ease(self.scene.bgColor, 1, 255, 2, "linear"),
		Ease(self.scene.bgColor, 2, 255, 2, "linear"),
		Ease(self.scene.bgColor, 3, 255, 2, "linear"),
		Do(function()
			ScreenShader:sendColor("multColor", self.scene.bgColor)
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
	local dx = self.x + self.sprite.w/2 - player.x
    local dy = self.y + self.sprite.h/2 - player.y
    if dx * dx + dy * dy < 100*100 then
        return
    end

	self:facePlayer()
end


return Rotor
