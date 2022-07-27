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
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	
	scene.player.sprite.color[1] = 150
	scene.player.sprite.color[2] = 150
	scene.player.sprite.color[3] = 150
	
	if GameState:isFlagSet("ep3_snively") then
		return Do(function() end)
	end
	
	GameState:setFlag("ep3_snively")
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		
		PlayAudio("music", "darkintro", 1.0, true, true),
		MessageBox{message="Snively: Hmmm...{p60}I was afraid of this."},
		
		Animate(scene.objectLookup.Sonic.sprite, "irritated"),
		MessageBox{message="Sonic: What a surprise! {p60}Needle nose is afraid of something!"},

		Animate(scene.objectLookup.Snively.sprite, "angryright"),
		Ease(scene.objectLookup.Snively, "y", function() return scene.objectLookup.Snively.y - 50 end, 8, "linear"),
		Ease(scene.objectLookup.Snively, "y", function() return scene.objectLookup.Snively.y + 50 end, 8, "linear"),
		MessageBox{message="Snively: SHUT YOUR MOUTH HEDGEHOG!!"},
		
		Animate(scene.objectLookup.Snively.sprite, "idleright_lookleft"),
		MessageBox{message="Snively: Ahem. {p60}What am I so angry about?"},
		
		Animate(scene.objectLookup.Snively.sprite, "idleright_smile"),
		MessageBox{message="Snively: You won't be a pain my side much longer anyway..."},
		MessageBox{message="Sonic: What's that supposed to mean?!"},
		MessageBox{message="Snively: I doubt your tiny rodent brain could understand--"},
		MessageBox{message="Snively: --this place appears to lie on an interdimensional fault line and Project Firebird's presence\nhas caused it to become unstable..."},
		Animate(scene.objectLookup.Sally.sprite, "thinking"),
		MessageBox{message="Sally: Unstable?"},
		Do(function() scene.objectLookup.Snively.sprite:setAnimation("idleright_laugh") end),
		MessageBox{message="Snively: That's right, Princess. {p60}This rustic trash heap is about to implode, taking you wretched Freedom Fighters with it!"},
		
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		MessageBox{message="Sonic & Sally: Implode!?"},
		
		Wait(1.5),
		Do(function() scene.objectLookup.Snively.sprite:setAnimation("walkleft") end),
		Parallel {
			MessageBox{message="Snively: So long!"},
			Ease(scene.objectLookup.Snively, "x", scene.objectLookup.Snively.x - 400, 0.5, "linear")
		},
		Do(function()
			scene.objectLookup.Snively:remove()
		end),
		
		MessageBox{message="Sonic: No, no, no!! {p60}Come on! There has to be a way out of here!"},
		
		Animate(scene.objectLookup.Sally.sprite, "thinking2"),
		MessageBox{message="Sally: It's not over Sonic. {p60}I'm sure Fleet, Ivan, and Logan are on their way here."},
		
		Parallel {
			AudioFade("music", 1.0, 0.0, 0.3),
			Ease(scene.camPos, "x", -425, 0.3)
		},
		Animate(scene.objectLookup.Sonic.sprite, "idleright"),
		Animate(scene.objectLookup.Sally.sprite, "idleright"),
		Animate(scene.objectLookup.Fleet.sprite, "lookright"),
		MessageBox{message="Fleet: I wouldn't count on that rescue, Princess..."},
		
		MessageBox{message="Sally: Oh dear..."},
		Wait(2),
		
		PlayAudio("music", "introspection", 1.0, true),
		Animate(scene.objectLookup.Sally.sprite, "pose"),
		MessageBox{message="Sally: Wait{p60}, Antoine!{p60} Antoine is still out there!", closeAction=Wait(1)},
		
		Do(function() scene.objectLookup.Sonic.sprite:setAnimation("foottap") end),
		MessageBox{message="Sonic: Well that's just great. {p60}We're hedgehog and squirrel stew!", closeAction=Wait(2)},
		Animate(scene.objectLookup.Sally.sprite, "idleleft"),
		MessageBox{message="Sally: Sonic!", closeAction=Wait(1)},
		MessageBox{message="Sonic: Not to be rude, Sal-- but let's face it-- {p60}when was the last time, Ant saved any of our butts?", closeAction=Wait(2)},
		
		MessageBox{message="Ivan: Yes. {p60}The cowardly coyote breaking us out of here seems highly improbable.", closeAction=Wait(2)},
		MessageBox{message="Sonic: See! {p60}Even the dingo gets it!", closeAction=Wait(1)},
		Animate(scene.objectLookup.Sally.sprite, "thinking"),
		MessageBox{message="Sally: Guys{p60}, Antoine may not be the most heroic person, but he is still a Freedom Fighter!", closeAction=Wait(2)},
		MessageBox{message="Sally: *whisper* Plus...{p40} who would you rather be saved by--{p20} Antoine{p20} or Fleet?", closeAction=Wait(2)},
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Wait(1),
		Animate(scene.objectLookup.Sonic.sprite, "pose"),
		MessageBox{message="Sonic: Go Ant!! {p60}You can do this!!", closeAction=Wait(2)},
		Animate(scene.objectLookup.Fleet.sprite, "idleleft"),
		MessageBox{message="Fleet: Hey, I heard that!!", closeAction=Wait(1)},
		
		Wait(1),
		PlayAudio("sfx", "explosion", 1.0, true),
		scene:screenShake(30, 20),
		
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		--Animate(scene.objectLookup.Ivan.sprite, "shock"),
		--Animate(scene.objectLookup.Logan.sprite, "shock"),
		--Animate(scene.objectLookup.Fleet.sprite, "shock"),
		
		MessageBox{message="Sonic: Uh oh!"},
		
		PlayAudio("sfx", "explosion2", 1.0, true),
		scene:screenShake(30, 20),
		
		PlayAudio("sfx", "explosion2", 1.0, true),
		scene:screenShake(30, 10),
		PlayAudio("sfx", "explosion2", 1.0, true),
		scene:screenShake(30, 20),
		
		Wait(2),
		
		MessageBox{message="Ello!"},
		
		Animate(scene.objectLookup.Sonic.sprite, "idleleft"),
		Animate(scene.objectLookup.Sally.sprite, "idleleft"),
		
		PlayAudio("music", "antoinerescue", 1.0, true),
		Wait(0.5),
		Ease(scene.camPos, "x", 400, 0.2),
		
		MessageBox{message="Sonic & Sally: Antoine!", closeAction=Wait(1.2)},
		MessageBox{message="Antoine: But of course!", closeAction=Wait(1.2)},
		
		Wait(0.5),
		
		Animate(scene.objectLookup.Sonic.sprite, "idledown"),
		Animate(scene.objectLookup.Sally.sprite, "idledown"),
		Animate(scene.objectLookup.Ivan.sprite, "idledown"),
		Animate(scene.objectLookup.Logan.sprite, "idledown"),
		Animate(scene.objectLookup.Fleet.sprite, "idledown"),
		
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("walkright")
		end),
		Parallel {
			Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Antoine.x + 800, 0.3, "linear"),
			Ease(scene.camPos, "x", -425, 0.3, "linear")
		},
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("idleup")
		end),
		
		MessageBox{message="Antoine: A-A-Are you alright, my princess?", closeAction=Wait(1)},
		MessageBox{message="Sally: We're ok Antoine, but we have to get out of here! {p60}This place is about to implode!", closeAction=Wait(1)},
		MessageBox{message="Antoine: Yes ok, zis is not good I am thinking.", closeAction=Wait(1.2)},
		
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("walkup")
		end),
		Parallel {
			Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Switch.x - 32, 1, "linear"),
			Ease(scene.objectLookup.Antoine, "y", scene.objectLookup.Switch.y - 16, 1, "linear")
		},
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("idleup")
			scene.objectLookup.Switch.sprite:setAnimation("on")
		end),
		
		-- Lift prison bars
		Parallel {
			Animate(scene.objectLookup.Bars1.sprite, "opening"),
			Animate(scene.objectLookup.Bars2.sprite, "opening"),
			Animate(scene.objectLookup.Bars3.sprite, "opening"),
			Animate(scene.objectLookup.Bars4.sprite, "opening")
		},
		Animate(scene.objectLookup.Bars1.sprite, "open"),
		Animate(scene.objectLookup.Bars2.sprite, "open"),
		Animate(scene.objectLookup.Bars3.sprite, "open"),
		Animate(scene.objectLookup.Bars4.sprite, "open"),
		
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("idledown")
		end),
		
		Animate(scene.objectLookup.Sonic.sprite, "pose"),
		MessageBox{message="Sonic: Way past cool, Ant!", closeAction=Wait(1)},
		Do(function()
			scene.objectLookup.Sonic.sprite:setAnimation("walkdown")
		end),
		Ease(scene.objectLookup.Sonic, "y", scene.objectLookup.Sonic.y + 100, 1, "linear"),
		Do(function()
			scene.objectLookup.Sonic.sprite:setAnimation("idleright")
		end),
		
		Animate(scene.objectLookup.Sally.sprite, "pose"),
		MessageBox{message="Sally: Nice work, Antoine!", closeAction=Wait(1)},
		
		Do(function()
			scene.objectLookup.Sally.sprite:setAnimation("walkdown")
		end),
		Ease(scene.objectLookup.Sally, "y", scene.objectLookup.Sally.y + 100, 1, "linear"),
		Do(function()
			scene.objectLookup.Sally.sprite:setAnimation("idleright")
		end),

		Animate(scene.objectLookup.Logan.sprite, "attitude"),
		MessageBox{message="Logan: Thanks... {p40} I mean, I would've eventually found a way to hack the computer system and get us out--", closeAction=Wait(1)},

		Animate(scene.objectLookup.Ivan.sprite, "attitude"),
		MessageBox{message="Ivan: Thank you.", closeAction=Wait(1)},
		Do(function()
			scene.objectLookup.Ivan.sprite:setAnimation("walkdown")
		end),
		Ease(scene.objectLookup.Ivan, "y", scene.objectLookup.Ivan.y + 100, 1, "linear"),
		Do(function()
			scene.objectLookup.Ivan.sprite:setAnimation("idleleft")
		end),
		
		Animate(scene.objectLookup.Logan.sprite, "irritated"),
		MessageBox{message="Logan: --what he said.", closeAction=Wait(1)},
		Do(function()
			scene.objectLookup.Logan.sprite:setAnimation("walkdown")
		end),
		Ease(scene.objectLookup.Logan, "y", scene.objectLookup.Logan.y + 100, 1, "linear"),
		Do(function()
			scene.objectLookup.Logan.sprite:setAnimation("idleleft")
			scene.objectLookup.Fleet.sprite:setAnimation("smirk")
		end),
		MessageBox{message="Fleet: Not bad for a Freedom Fighter...", closeAction=Wait(1)},
		Do(function()
			scene.objectLookup.Fleet.sprite:setAnimation("walkdown")
		end),
		Ease(scene.objectLookup.Fleet, "y", scene.objectLookup.Fleet.y + 100, 1, "linear"),
		Do(function()
			scene.objectLookup.Fleet.sprite:setAnimation("idleleft")
		end),
		Wait(4),

		PlayAudio("sfx", "explosion2", 1.0, true),
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		--Animate(scene.objectLookup.Ivan.sprite, "idledown"),
		--Animate(scene.objectLookup.Logan.sprite, "idledown"),
		--Animate(scene.objectLookup.Fleet.sprite, "idledown"),
		scene:screenShake(30, 20, 15),
		Animate(scene.objectLookup.Sally.sprite, "idleright"),
		Animate(scene.objectLookup.Sonic.sprite, "idleright"),
		PlayAudio("music", "robotropolis", 1.0, true),
		MessageBox{message="Sally: Time to go!"},
		MessageBox{message="Sally: Fleet, you take Logan and Ivan{p30}, Antoine and I will go with Sonic."},
		MessageBox{message="Fleet: Sounds good to me!"},
		-- Rebellion merge together, Fleet flies upwards
		
		Ease(scene.camPos, "x", -200, 1),
		MessageBox{message="Sonic: Alright guys, grab on!"},
		
		-- FFs merge together, Sonic starts run cycle
		MessageBox{message="Sonic: Juice and jam time!", closeAction=Wait(1)},
		
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.TrapDoor.sprite, "opening"),
		Animate(scene.objectLookup.TrapDoor.sprite, "open"),
		Do(function()
			for _,layer in pairs(scene.map.layers) do
				if layer.name == "hidden" then
					layer.opacity = 1.0
					break
				end
			end
		end),
		
		Wait(0.5),
		Ease(scene.objectLookup.Sonic, "y", 1000, 4)
		-- Fall, scene change to boss fight room
	}
end
