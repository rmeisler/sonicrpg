local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Move = require "actions/Move"
local Action = require "actions/Action"
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
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"

return function(scene, hint)
	scene.audio:stopMusic()
	scene.audio:stopSfx()

	local sallySprite = scene.objectLookup.Sally.sprite
	local sonicSprite = scene.objectLookup.Sonic.sprite
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			
			sallySprite:setAnimation("shock")
			sallySprite.transform.oy = sallySprite.h/2
			sallySprite.transform.ox = sallySprite.w/2
			sallySprite:pushOverride("walkup", "shock")
			sallySprite:pushOverride("walkdown", "shock")
			sallySprite:pushOverride("walkleft", "shock")
			sallySprite:pushOverride("walkright", "shock")

			sonicSprite:setAnimation("shock")
			sonicSprite.transform.ox = sonicSprite.w/2
			sonicSprite.transform.oy = sonicSprite.h/2
			sonicSprite:pushOverride("walkup", "shock")
			sonicSprite:pushOverride("walkdown", "shock")
			sonicSprite:pushOverride("walkleft", "shock")
			sonicSprite:pushOverride("walkright", "shock")
		end),
		Parallel {
			Ease(sallySprite.transform, "angle", -20*math.pi, 0.1, "linear"),
			Ease(sonicSprite.transform, "angle", -20*math.pi, 0.1, "linear"),
			Serial {
				Wait(0.5),
				Parallel {
					Ease(scene.objectLookup.Sonic, "x", 100, 0.7, "linear"),
					Ease(scene.objectLookup.Sonic, "y", 100, 0.7, "linear")
				},
				Ease(scene.objectLookup.Sonic, "y", 170, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sonic, "x", 700, 0.7, "linear"),
					Ease(scene.objectLookup.Sonic, "y", 200, 0.7, "linear")
				},
				Ease(scene.objectLookup.Sonic, "y", 270, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sonic, "x", 100, 0.7, "linear"),
					Ease(scene.objectLookup.Sonic, "y", 300, 0.7, "linear"),
				},
				Ease(scene.objectLookup.Sonic, "y", 370, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sonic, "x", 700, 0.7, "linear"),
					Ease(scene.objectLookup.Sonic, "y", 400, 0.7, "linear"),
				},
				Ease(scene.objectLookup.Sonic, "y", 470, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sonic, "x", 100, 0.7, "linear"),
					Ease(scene.objectLookup.Sonic, "y", 500, 0.7, "linear"),
				},
				Ease(scene.objectLookup.Sonic, "y", 570, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sonic, "x", 900, 0.7, "linear"),
					Ease(scene.objectLookup.Sonic, "y", 600, 0.7, "linear"),
				}
			},
			Serial {
				Parallel {
					Ease(scene.objectLookup.Sally, "x", 100, 0.7, "linear"),
					Ease(scene.objectLookup.Sally, "y", 100, 0.7, "linear")
				},
				Ease(scene.objectLookup.Sally, "y", 170, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sally, "x", 700, 0.7, "linear"),
					Ease(scene.objectLookup.Sally, "y", 200, 0.7, "linear")
				},
				Ease(scene.objectLookup.Sally, "y", 270, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sally, "x", 100, 0.7, "linear"),
					Ease(scene.objectLookup.Sally, "y", 300, 0.7, "linear")
				},
				Ease(scene.objectLookup.Sally, "y", 370, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sally, "x", 700, 0.7, "linear"),
					Ease(scene.objectLookup.Sally, "y", 400, 0.7, "linear")
				},
				Ease(scene.objectLookup.Sally, "y", 470, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sally, "x", 100, 0.7, "linear"),
					Ease(scene.objectLookup.Sally, "y", 500, 0.7, "linear")
				},
				Ease(scene.objectLookup.Sally, "y", 570, 4, "linear"),
				Parallel {
					Ease(scene.objectLookup.Sally, "x", 900, 0.7, "linear"),
					Ease(scene.objectLookup.Sally, "y", 600, 0.7, "linear")
				}
			}
		}
	}
end
