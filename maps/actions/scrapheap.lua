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
	
	local subtext = TypeText(
		Transform(10, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Robot Wasteland",
		100
	)
	local text = TypeText(
		Transform(10, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Scrapheap",
		100
	)
	
	if GameState:isFlagSet("ep6_oneweeklater") then
		return BlockPlayer {
			Spawn(Serial {
				Wait(2),
				subtext,
				text,
				PlayAudio("music", "scrapheap", 1.0, true, true),
				Parallel {
					Ease(text.color, 4, 255, 1),
					Ease(subtext.color, 4, 255, 1),
				},
				Wait(2),
				Parallel {
					Ease(text.color, 4, 0, 1),
					Ease(subtext.color, 4, 0, 1)
				}
			})
		}
	end
	
	if hint == "intro" then
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(2),
			PlayAudio("sfx", "openchasm", 1, true),
			Parallel {
				Ease(scene.objectLookup.Sally, "x", scene.objectLookup.Mattress.x - 64, 8, "linear"),
				Ease(scene.objectLookup.Sally, "y", scene.objectLookup.Mattress.y - 60, 8, "linear"),
				Ease(scene.objectLookup.LogRide, "y", scene.objectLookup.LogRide.y + 5, 8, "linear"),
			},
			Do(function()
				scene.objectLookup.Sally.sprite.sortOrderY = scene.objectLookup.Mattress.y + 5
			end),
			Parallel {
				Ease(scene.objectLookup.LogRide, "y", scene.objectLookup.LogRide.y - 5, 8, "linear"),
				Ease(scene.objectLookup.Sally, "x", scene.objectLookup.Mattress.x + 16, 6, "linear"),
				Ease(scene.objectLookup.Sally, "y", scene.objectLookup.Mattress.y - 40, 6, "linear"),
			},
			PlayAudio("sfx", "smack", 1, true),
			Parallel {
				Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y - 5 end, 8),
				Ease(scene.objectLookup.Mattress, "y", scene.objectLookup.Mattress.y + 3, 8),
			},
			Parallel {
				Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y + 5 end, 8),
				Ease(scene.objectLookup.Mattress, "y", scene.objectLookup.Mattress.y - 3, 8)
			},
			Animate(scene.objectLookup.Sally.sprite, "kneelleft"),
			MessageBox{message="Sally: ...", closeAction=Wait(1)},
			Wait(1),
			Parallel {
				Ease(scene.objectLookup.Sonic, "x", scene.objectLookup.Mattress.x - 64, 8, "linear"),
				Ease(scene.objectLookup.Sonic, "y", scene.objectLookup.Mattress.y - 60, 8, "linear"),
				Ease(scene.objectLookup.LogRide, "y", scene.objectLookup.LogRide.y + 5, 8, "linear"),
			},
			Do(function()
				scene.objectLookup.Sonic.sprite.sortOrderY = scene.objectLookup.Mattress.y + 6
			end),
			PlayAudio("sfx", "openchasm", 1, true),
			Parallel {
				Ease(scene.objectLookup.Sonic, "x", scene.objectLookup.Mattress.x + 16, 6, "linear"),
				Ease(scene.objectLookup.Sonic, "y", scene.objectLookup.Mattress.y - 60, 6, "linear"),
				Ease(scene.objectLookup.LogRide, "y", scene.objectLookup.LogRide.y - 5, 8, "linear"),
			},
			PlayAudio("sfx", "smack", 1, true),
			Animate(scene.objectLookup.Sally.sprite, "dead"),
			Parallel {
				Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y - 5 end, 8),
				Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y - 3 end, 8),
				Ease(scene.objectLookup.Mattress, "y", scene.objectLookup.Mattress.y + 3, 8),
			},
			Parallel {
				Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y + 5 end, 8),
				Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y + 3 end, 8),
				Ease(scene.objectLookup.Mattress, "y", scene.objectLookup.Mattress.y - 3, 8)
			},
			MessageBox{message="Sally: Ugh!"},
			Wait(1),
			MessageBox{message="Ba-HA-ha-HAAA!"},
			Ease(scene.camPos, "x", -650, 0.5, "linear"),
			scene.objectLookup.Scratch:hop(),
			MessageBox{message="???: Managed to get past all of our security, eh?"},
			scene.objectLookup.Coconuts:hop(),
			MessageBox{message="???: Dis guy must be some kinda robo genius or somethin'!"},
			scene.objectLookup.Grounder:hop(),
			MessageBox{message="???: Duh{p60}, he don't look so smart to me!"},
			MessageBox{message="???: Well, uh-- {p60}you should prepare for trouble when you're up against the--"},
			PlayAudio("music", "dumbbots", 1, true, true),
			scene.objectLookup.Scratch:hop(),
			MessageBox{message="???: Hey! {p60}That's my line! {p60}Be-HA!"},
			scene.objectLookup.Grounder:hop(),
			MessageBox{message="???: Ow!"},
			scene.objectLookup.Scratch:hop(),
			MessageBox{message="???: I am the leader after all!"},
			scene.objectLookup.Coconuts:hop(),
			MessageBox{message="???: Hey, who made you leada, peck?"},
			scene.objectLookup.Scratch:hop(),
			MessageBox{message="???: That does it! {p60}Now you're gonna get it!"},
			-- Fight cloud
			Do(function()
				scene.objectLookup.Sonic:remove()
				scene.objectLookup.Sally:remove()
				scene.player.sprite.visible = true
				scene.player.dropShadow.hidden = false
				scene.player.state = "idleright"
			end),
			Ease(scene.camPos, "x", 0, 1),
			Do(function()
				scene.objectLookup.Coconuts.color = {255,255,255,255}
				scene.objectLookup.Scratch.color = {255,255,255,255}
				scene.objectLookup.Grounder.color = {255,255,255,255}
			end)
		}
	end
	
	return BlockPlayer {
		PlayAudio("music", "scrapheap", 1, true, true)
	}
end
