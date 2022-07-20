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
	local BasicNPC = require "object/BasicNPC"
	local Move = require "actions/Move"
	
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	
	scene.player.sprite.color[1] = 150
	scene.player.sprite.color[2] = 150
	scene.player.sprite.color[3] = 150
	
	if GameState:isFlagSet("ep3_youngsally") then
		scene.objectLookup.Ghost:remove()
		return Do(function() end)
	end
	
	GameState:setFlag("ep3_youngsally")

	scene.player.y = scene.player.y - 100
	local walkout, walkin, sprites = scene.player:split{GameState.party.antoine, GameState.party.sonic, GameState.party.sally}
	scene.player.y = scene.player.y + 100
	scene.player:removeKeyHint()
	scene.player.hidekeyhints[tostring(scene.objectLookup.Door)] = scene.objectLookup.Door
	return BlockPlayer {
		Do(function()
			scene.player:removeKeyHint()
			scene.player.hidekeyhints[tostring(scene.objectLookup.Door)] = scene.objectLookup.Door
		end),
		Parallel {
			AudioFade("music", 1.0, 0.0, 0.3),
			Ease(scene.objectLookup.Ghost.sprite.color, 4, 255, 0.3)
		},
		PlayAudio("music", "mysterious", 1.0, true, true),
		walkout,
		Animate(sprites.sally.sprite, "idleup"),
		Animate(sprites.sonic.sprite, "idleup"),
		Animate(sprites.antoine.sprite, "idleup"),
		MessageBox{message="Antoine: It is you, my princess!"},
		MessageBox{message="Sally: We'll see about that!"},
		Do(function()
			sprites.sally.sprite:setAnimation("walkup")
		end),
		Ease(sprites.sally, "y", sprites.sally.y - 128, 3, "linear"),
		Do(function()
			sprites.sally.sprite:setAnimation("nicholeup")
		end),
		PlayAudio("sfx", "nichole", 1.0),
		PlayAudio("sfx", "nicholescan", 1.0, true),
		Do(function()
			scene.objectLookup.Ghost.sprite:setParallax(4)
		end),
		
		Wait(0.7),
		
		Do(function()
			scene.objectLookup.Ghost.sprite:removeParallax()
		end),
		Parallel {
			MessageBox{message="Sally: Gotcha!"},
			Ease(scene.objectLookup.Ghost.sprite.color, 4, 0, 0.3),
		},
		Do(function()
			scene.objectLookup.Ghost:remove()
			sprites.sonic.sprite:setAnimation("walkup")
			sprites.antoine.sprite:setAnimation("walkup")
		end),
		Parallel {
			Serial {
				Parallel{
					Ease(sprites.sonic, "y", function() return sprites.sonic.y - 100 end, 3, "linear"),
					Ease(sprites.antoine, "y", function() return sprites.antoine.y - 100 end, 3, "linear"),
				},
				Do(function()
					sprites.sonic.sprite:setAnimation("idleup")
					sprites.antoine.sprite:setAnimation("idleup")
				end)
			},
			MessageBox{message="Sally: Alright Nicole{p60}, let's figure out what is going on here..."}
		},
		MessageBox{message="Nicole: The entity scanned is Princess Sally Acorn."},
		Animate(sprites.sally.sprite, "shock"),
		MessageBox{message="Sally: What!? {p60}How is that possible, Nicole?"},
		MessageBox{message="Nicole: The entity appears to be emitting alpha particles that signal a {h temporal anomaly}."},
		Animate(sprites.sally.sprite, "thinking"),
		MessageBox{message="Sally: Could it be?...{p40} a rift in space time?!"},
		Animate(sprites.sally.sprite, "nicholeup"),
		MessageBox{message="Sally: Nicole{p40}, you've been collecting environmental data since we entered the Dark Swamp, right?"},
		MessageBox{message="Nicole: I always collect environmental data{p40}, Sally."},
		MessageBox{message="Sally: No need for sass, Nicole! {p60}Using your environmental data, let's see a heatmap of alpha particles\nin the Dark Swamp."},
		MessageBox{message="Nicole: Processing{p40}, Sally..."},
		Animate(sprites.sonic.sprite, "thinking"),
		MessageBox{message="Sonic: Alpha whatsa?"},
		Animate(sprites.sonic.sprite, "idleup"),
		MessageBox{message="Nicole: Processing complete."},
		-- Show mini-worldmap with green to yellow to red to black, centered on Iron Loc
		AudioFade("music", 1.0, 0.0, 0.3),
		Wait(1),
		Animate(sprites.sally.sprite, "shock"),
		MessageBox{message="Sally: Oh no!"},
		MessageBox{message="Antoine: What is it?"},
		MessageBox{message="Sally: It...{p60} It's some kind of a... fault line! {p60}And Iron Lock is at the center!"},
		Animate(sprites.sonic.sprite, "irritated"),
		MessageBox{message="Sonic: In english, Sal?"},
		Animate(sprites.sally.sprite, "thinking"),
		PlayAudio("music", "ironlockintro", 1.0, true),
		MessageBox{message="Sally: In short, {p60}these aren't ghosts. {p60}They are real people from different times and places!"},
		Animate(sprites.sonic.sprite, "shock"),
		Animate(sprites.antoine.sprite, "shock"),
		MessageBox{message="Sonic: Say wha?!"},
		Animate(sprites.sally.sprite, "thinking3"),
		MessageBox{message="Sally: I'm guessing this is what the {h curse} of the\nDark Swamp is really about!"},
		MessageBox{message="Sally: It seems like the presence of Project Firebird is making things worse too! {p60}This tearing of space time is growing and centered on Iron Lock!"},
		MessageBox{message="Antoine: I am not liking the sound of this!"},
		Animate(sprites.sonic.sprite, "idleup"),
		Animate(sprites.antoine.sprite, "idleup"),
		MessageBox{message="Sonic: Sounds like bad news! {p60}What do we do?"},
		Animate(sprites.sally.sprite, "idledown"),
		MessageBox{message="Sally: We have to find the Rebellion and get out of here!"},
		MessageBox{message="Sonic: What about trashing Buttnik's new bot?"},
		MessageBox{message="Sally: If my readings are correct{p60}, we have less than an hour before Iron Lock implodes!"},
		Animate(sprites.sonic.sprite, "shock"),
		Animate(sprites.antoine.sprite, "shock"),
		MessageBox{message="Antoine: *screams*"},
		Animate(sprites.sonic.sprite, "smileright"),
		PlayAudio("music", "troublefanfare", 1.0, true),
		MessageBox{message="Sonic: Ok, ok! {p60}Let's get find the three stooges and juice!"},
		walkin,
		Do(function()
			scene.player.x = scene.player.x + 60
			scene.player.y = scene.player.y - 100
		end)
	}
end
