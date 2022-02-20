return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local TextNode = require "object/TextNode"
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	
	scene.player.sprite.color[1] = 150
	scene.player.sprite.color[2] = 150
	scene.player.sprite.color[3] = 150
	
	if hint == "fromworldmap" then
		local text = TypeText(
			Transform(50, 500),
			{255, 255, 255, 0},
			FontCache.Techno,
			"Dark Swamp",
			100
		)
		local showTitle = function()
			Executor(scene):act(Serial {
				Wait(0.5),
				text,
				Ease(text.color, 4, 255, 1),
				Wait(2),
				Ease(text.color, 4, 0, 1)
			})
		end
		if GameState:isFlagSet("ep3_darkswampintro") then
			showTitle()
			return PlayAudio("music", "darkswamp", 1.0, true, true)
		else
			GameState:setFlag("ep3_darkswampintro")
			
			scene.player.x = -2000
			scene.camPos.x = -700
			scene.objectLookup.Eyes1.hidden = true
			scene.objectLookup.Eyes2.hidden = true
			return BlockPlayer {
				Do(function()
					scene.player.x = -2000
					scene.camPos.x = -700
				end),
				Wait(2),
				Do(function()
					scene.objectLookup.Eyes1.hidden = false
				end),
				Animate(scene.objectLookup.Eyes1.sprite, "blink"),
				Animate(scene.objectLookup.Eyes1.sprite, "forward"),
				Wait(1),
				Animate(scene.objectLookup.Eyes1.sprite, "left"),
				Wait(1),
				Animate(scene.objectLookup.Eyes1.sprite, "right"),
				Wait(1),
				PlayAudio("sfx", "wolf", 0.5, true),
				Animate(scene.objectLookup.Eyes1.sprite, "smile"),
				Wait(1),
				Do(function()
					scene.objectLookup.Eyes1.sprite:setAnimation("laugh")
				end),
				Ease(scene.camPos, "x", 0, 0.1, "inout"),
				Do(function()
					scene.objectLookup.Eyes1.hidden = true
				end),
				Wait(1),
				PlayAudio("music", "sonicenters", 1.0, true),
				Wait(1),
				Do(function()
					GameState:addToParty("sonic", 6, true)
					GameState.leader = "sonic"
					scene.player:updateSprite()
					scene.player.cinematic = true
					scene.player.ignoreSpecialMoveCollision = true
					scene.player:onSpecialMove()
				end),
				Wait(2),
				Do(function()
					scene.player.cinematic = false
					scene.player.skipChargeSpecialMove = false
					scene.player.ignoreSpecialMoveCollision = false
				end),
				Wait(2),
				Do(function()
					local walkout, walkin, sprites = scene.player:split()
					scene:run(BlockPlayer {
						walkout,
						MessageBox{message="Logan: Why are we stopping?"},
						MessageBox{message="Sally: It's been quite awhile since we were last here..."},
						MessageBox{message="Sally: I'll need Nicole's help to find our way to Iron Lock."},
						MessageBox{message="Fleet: While we'd love to walk around a swamp with you kids--"},
						MessageBox{message="Fleet: I think we're going to take the sky path!"},
						MessageBox{message="Ivan: Indeed."},
						MessageBox{message="Logan: Later, nerds!"},
						MessageBox{message="Sonic: Good riddance! {p60}You were crampin' our style anyhow!"},
						MessageBox{message="Sally: *sigh* {p80}So much for learning to work together..."},
						
						Do(showTitle),
						PlayAudio("music", "darkswamp", 1.0, true, true),
						walkin
					})
				end)
			}
		end
	end
	
	return Action()
end
