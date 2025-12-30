local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local WaitForFrame = require "actions/WaitForFrame"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"
local EscapeObstacle = require "object/EscapeObstacle"
local EscapeHoverbot = require "object/EscapeHoverbot"
local EscapeIndicator = require "object/EscapeIndicator"

local SpriteNode = require "object/SpriteNode"
local BasicNPC = require "object/BasicNPC"
local EscapePlayer = require "object/EscapePlayer"

local TARGET_OFFSET_X = 400

return function(scene)
	scene.bgColor = {255,255,255,255}
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	scene.objectLookup.Robotnik.stopMoving = true

	GameState.leader = "tails"
	
	local ROBOTNIK_SPEED = 20
	local tails = scene.objectLookup.Tails
	local robotnik = scene.objectLookup.Robotnik
	local chargeShot = BasicNPC(
		scene,
		{name = "objects"},
		{
			name = "chargeshot",
			x = robotnik.x + 240,
			y = robotnik.y + 70,
			width = 19,
			height = 19,
			properties = {nocollision = true, sprite = "art/sprites/plasmabeam.png"}
		}
	)
	chargeShot.sprite.transform.ox = chargeShot.sprite.w/2
	chargeShot.sprite.transform.oy = chargeShot.sprite.h/2
	chargeShot.sprite.transform.sx = 0.3
	chargeShot.sprite.transform.sy = 0.3
	chargeShot.sprite:setAnimation("charge")
	chargeShot.hidden = true
	scene:addObject(chargeShot)

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Do(function()
			scene.objectLookup.Robotnik:addSceneHandler("update", function(self, dt)
				local vx = ROBOTNIK_SPEED * (dt/0.016)
				self.x = self.x + vx
				chargeShot.x = chargeShot.x + vx

				if self.x > 48000 then
					tails.x = tails.x + vx + 1 * (dt/0.016)
				elseif self.x > 13000 and self.x < 22000 then
					tails.x = tails.x + vx + 1 * (dt/0.016)
				elseif self.x > 11000 and self.x < 14000 then
					tails.x = tails.x + vx
				elseif self.x > 2000 then
					tails.x = tails.x + vx
				end

				if self.x > 9000 and self.x < 11000 then
					self.sprite:setAnimation("lookback")
					--self.scene.audio:playSfx("robotnikgrit")
					scene.camPos.x = scene.camPos.x - vx
				elseif self.x > 11000 and self.x < 13000 then
					-- pan back
					scene.camPos.x = scene.camPos.x - vx/2
				elseif self.x > 13000 and self.x < 20000 then
					-- look at tails
					scene.camPos.x = scene.camPos.x - vx
				elseif self.x > 20000 and self.x < 22000 then
					-- pan forward again
					scene.camPos.x = scene.camPos.x - vx*1.5
				--[[elseif self.x > 48000 and self.x < 50000 then
					-- pan back
					scene.camPos.x = scene.camPos.x - vx/2
				elseif self.x > 50000 and self.x < 57000 then
					-- look at tails
					scene.camPos.x = scene.camPos.x - vx
				elseif self.x > 57000 and self.x < 59000 then
					-- pan forward again
					scene.camPos.x = scene.camPos.x - vx*1.5]]
				else
					scene.camPos.x = scene.camPos.x - vx
				end
			end)
		end),
		Wait(2),
		PlayAudio("music", "tailsrace", 1, true),
		Wait(17),
		MessageBox{message="Robotnik: That putrescent little mongrel is persistent, isn't he?", textSpeed=3, closeAction=Wait(4)},
		Wait(2),
		Do(function() robotnik.sprite:setAnimation("lookforward") end),
		MessageBox{message="Robotnik: Let's see how he handles this! {p40}He he he!", textSpeed=3, closeAction=Wait(3)},
		Wait(2),
		Do(function() robotnik.sprite:setAnimation("dropmines") end),
		Repeat(Serial {
			Wait(0.2),
			Do(function()
				local mine = BasicNPC(
					scene,
					{name = "objects"},
					{
						name = "robomine",
						x = robotnik.x + 204,
						y = robotnik.y + 106,
						width = 19,
						height = 19,
						properties = {nocollision = true, sprite = "art/sprites/robotnikmine.png"}
					}
				)
				mine.sprite.transform.ox = 9.5
				mine.sprite.transform.oy = 9.5
				scene:addObject(mine)
				
				mine:run(Ease(mine, "y", function() return mine.y + 60 end, 6))

				if not scene.mines then
					scene.mines = {}
				end
				table.insert(scene.mines, mine)
			end)
		}, 5),
		Do(function() robotnik.sprite:setAnimation("lookforward") end),
		
		Wait(1),
		Repeat(Serial {
			PlayAudio("sfx", "explosion", 1, true, false, true),
			Wait(0.2)
		}, 5),
		
		MessageBox{message="Robotnik: Adieu{p40}, little fox boy...", textSpeed=3, closeAction=Wait(3)},
		
		Wait(6),
		Do(function() robotnik.sprite:setAnimation("scared") end),
		Wait(1),
		MessageBox{message="Robotnik: This isn't possible!!", textSpeed=3, closeAction=Wait(3)},
		Do(function() robotnik.sprite:setAnimation("angry") end),
		MessageBox{message="Robotnik: No!! {p40}I will not be beaten by a child!!", textSpeed=3, closeAction=Wait(3)},
		Wait(2),
		Do(function()
			robotnik.sprite:setAnimation("aim")
			chargeShot.hidden = false
		end),
		Parallel {
			Ease(chargeShot.sprite.transform, "sx", 1, 0.5),
			Ease(chargeShot.sprite.transform, "sy", 1, 0.5),
			
			PlayAudio("sfx", "robotnikgrit", 1, true),
			MessageBox{message="Robotnik: DIE!!", textSpeed=3, closeAction=Wait(2)},
		},

		MessageBox{message="Watch where you're pointing that thing! {p60}You could shoot your eye out!"},
		
		Wait(1000)
	}
end
