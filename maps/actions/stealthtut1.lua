local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Move = require "actions/Move"
local BlockPlayer = require "actions/BlockPlayer"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local AudioFade = require "actions/AudioFade"
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
local Repeat = require "actions/Repeat"

local Player = require "object/Player"
local BasicNPC = require "object/BasicNPC"

return function(scene)
	scene.audio:playMusic("openingmission2", 1.0)
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	scene.player.dustColor = Player.ROBOTROPOLIS_DUST_COLOR
	
	return BlockPlayer {
		MessageBox {message="Computer: Welcome to the stealth tutorial!"},
		MessageBox {message="Computer: Here you will learn how evade enemies and avoid battles!"},
		Parallel {
			Serial {
				MessageBox {message="Computer: To your left is a Swatbot..."},
				MessageBox {message="Computer: ...as well as several pillars you can hide behind..."},
				Ease(scene.camPos, "x", 0, 0.5),
				Do(function()
					local pillar = scene.objectLookup.Pillar6
					local cursor = BasicNPC(
						scene,
						{name = "objects"},
						{
							name = "Cursor",
							x = pillar.x + pillar.sprite.w*2,
							y = pillar.y + pillar.sprite.h*2 - scene.player.height * 2,
							width = 32,
							height = 32,
							properties = {nocollision = true, sprite = "art/sprites/cursor.png"}
						}
					)
					cursor.sprite.transform.ox = 16
					cursor.sprite.transform.oy = 16
					cursor.sprite.transform.angle = math.pi/2
					cursor.sprite.sortOrderY = 99999
					scene:addObject(cursor)
					scene.objectLookup.Cursor = cursor
				end),
				MessageBox {message="Computer: Try to hide behind this pillar. {p50}Hold left against the pillar to hide and peak left."},
			},
			Ease(scene.camPos, "x", 650, 0.5)
		}
	}
end
