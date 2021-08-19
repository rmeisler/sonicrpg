return function(scene)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local YieldUntil = require "actions/YieldUntil"
	local BlockPlayer = require "actions/BlockPlayer"
	local Move = require "actions/Move"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"
	
	local NPC = require "object/NPC"
	local BasicNPC = require "object/BasicNPC"

	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	if GameState:isFlagSet("deathegg:sneak2_done") then
		return Action()
	end
	
	local hop = function(self, waitTime)
		local waitAction = Action()
		if waitTime then
			waitAction = Wait(waitTime)
		end
		return Serial {
			Ease(self, "y", self.y - 50, 8, "linear"),
			Ease(self, "y", self.y, 8, "linear"),
			waitAction
		}
	end
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	scene.cinematicPause = true
	scene.player.noSpecialMove = true
	
	scene.player.handlers.caught = nil

	local caughtHandler
	caughtHandler = function(bot)
		scene.player.doingSpecialMove = false
		scene.player.basicUpdate = function(p, dt) end
		scene.player.sprite:setAnimation("shock")
		for k,v in pairs(scene.player.keyhints) do
			scene.player.hidekeyhints[k] = v
		end
		scene.player:removeHandler("caught", caughtHandler)
		scene:run(
			BlockPlayer {
				Wait(1),
				Do(function()
					scene:restart{hint="caught", fadeOutMusic=false}
				end),
				Do(function() end)
			}
		)
	end
	scene.player:addHandler("caught", caughtHandler)

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			scene.cinematicPause = true
			
			scene.player.doingSpecialMove = false
			scene.player.basicUpdate = scene.player.origUpdate or scene.player.basicUpdate

			if hint == "caught" then
				scene.player.x = scene.player.x + 20
				scene.player.y = scene.player.y + 50
			end
		end),
		
		Do(function()
			local fbot = BasicNPC(
				scene,
				{name="objects"},
				{
					name = "FactoryBot",
					x = scene.objectLookup.FStart.x,
					y = scene.objectLookup.FStart.y,
					width = 64,
					height = 32,
					properties = {
						align = "bottom_left",
						defaultAnim = "idleright",
						ghost = true,
						sprite = "art/sprites/factorybot.png",
						ignoreMapCollision = true
					}
				}
			)
			fbot.movespeed = 3
			scene:addObject(fbot)
			scene.objectLookup.FBot = fbot
			
			fbot:run {
				Parallel {
					Do(function()
						if scene.player and scene.player.x > fbot.x then
							scene.player:invoke("caught", fbot)
						end
					end),
					Serial {
						Move(fbot, scene.objectLookup.FWaypoint1, "walk"),
						YieldUntil(function()
							return scene.objectLookup.PSwitch1.state == NPC.STATE_TOUCHING
						end),
						hop(fbot),
						Wait(1.5),
						Animate(fbot.sprite, "idleleft"),
						Parallel {
							Serial {
								Move(fbot, scene.objectLookup.FWaypoint2, "walk"),
								Wait(2)
							},
							Do(function()
								if not scene.player:isHiding("right") then
									scene.player:invoke("caught", fbot)
								end
							end)
						},
						Move(fbot, scene.objectLookup.FWaypoint3, "walk"),
						YieldUntil(function()
							return scene.objectLookup.PSwitch2.state == NPC.STATE_TOUCHING
						end),
						hop(fbot),
						hop(fbot),
						Wait(1.5),
						Animate(fbot.sprite, "idleleft"),
						Parallel {
							Do(function()
								if not scene.player:isHiding("right") and
								   scene.objectLookup.FBotVisibility.state == NPC.STATE_TOUCHING
								then
									scene.player:invoke("caught", fbot)
								end
							end),
							Wait(2)
						},
						Move(fbot, scene.objectLookup.FWaypoint4, "walk"),
						Do(function() fbot:remove() end)
					}
				}
			}
		end),
		
		Wait(2),
		
		Do(function()
			scene.player.sprite.visible = true
			scene.player.dropShadow.hidden = false
			scene.cinematicPause = false
			scene.player.noSpecialMove = false
		end)
	}
end
