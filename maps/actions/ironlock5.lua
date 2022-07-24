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
		
		MessageBox{message="Sonic: What a surprise! {p60}Needle nose is afraid of something!"},

		Animate(scene.objectLookup.Snively.sprite, "angryright"),
		MessageBox{message="Snively: SHUT YOUR MOUTH HEDGEHOG--"},
		
		Animate(scene.objectLookup.Snively.sprite, "idleright_smile"),
		MessageBox{message="Snively: --What am I so angry about? {p60}You won't be a pain my side much longer anyway..."},
		MessageBox{message="Sonic: What's that supposed to mean?!"},
		MessageBox{message="Snively: I doubt your tiny rodent brain could understand--"},
		MessageBox{message="Snively: --this place appears to lie on an interdimensional fault line and Project Firebird's presence\nhas caused it to become unstable..."},
		MessageBox{message="Sally: Unstable?"},
		Do(function() scene.objectLookup.Snively.sprite:setAnimation("idleright_laugh") end),
		MessageBox{message="Snively: That's right, Princess. {p60}This rustic trash heap is about to implode, taking you wretched Freedom Fighters with it!"},
		
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		MessageBox{message="Sonic & Sally: Implode!?"},
		
		Do(function() scene.objectLookup.Snively.sprite:setAnimation("walkleft") end),
		Parallel {
			MessageBox{message="Snively: So long!"},
			Ease(scene.objectLookup.Snively, "x", scene.objectLookup.Snively.x - 400, 0.5, "linear")
		},
		
		MessageBox{message="Sonic: No, no, no!! {p60}Come on! There has to be a way out of here!"},
		
		Animate(scene.objectLookup.Sally.sprite, "thinking2"),
		MessageBox{message="Sally: It's not over Sonic. {p60}I'm sure Fleet, Ivan, and Logan are on their way here."},
		
		Parallel {
			AudioFade("music", 1.0, 0.0, 0.5),
			Ease(scene.camPos, "x", -416, 0.3)
		},
		MessageBox{message="Fleet: I wouldn't count on that rescue, Princess..."},
		
		MessageBox{message="Sally: Oh dear..."},
		Wait(1),
		
		PlayAudio("music", "introspection", 1.0, true),
		Animate(scene.objectLookup.Sally.sprite, "pose"),
		MessageBox{message="Sally: Wait{p60}, Antoine!{p60} Antoine is still out there!", closeAction=Wait(1)},
		
		Do(function() scene.objectLookup.Sonic.sprite:setAnimation("foottap") end),
		MessageBox{message="Sonic: Well that's just great. {p60}We're hedgehog and squirrel stew!", closeAction=Wait(2)},
		Animate(scene.objectLookup.Sally.sprite, "idleleft"),
		MessageBox{message="Sally: Sonic!", closeAction=Wait(1)},
		MessageBox{message="Sonic: Not to be rude, Sal-- but let's face it. {p60}When was the last time, Ant saved any of our butts?", closeAction=Wait(2)},
		
		MessageBox{message="Ivan: Yes. {p60}The cowardly coyote breaking us out of here seems highly improbable.", closeAction=Wait(2)},
		MessageBox{message="Sonic: See! {p60}Even the dingo gets it!", closeAction=Wait(1)},
		Animate(scene.objectLookup.Sally.sprite, "thinking"),
		MessageBox{message="Sally: Alright guys{p60}, Antoine may not be the most heroic person, but he is still a Freedom Fighter!", closeAction=Wait(2)},
		MessageBox{message="Sally: *whisper* Plus...{p60} who would you rather be saved by--{p60} Antoine{p60} or Fleet?", closeAction=Wait(2)},
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Wait(1),
		Animate(scene.objectLookup.Sonic.sprite, "pose"),
		MessageBox{message="Sonic: Go Ant!! {p60}You can do this!!", closeAction=Wait(2)},
		MessageBox{message="Fleet: Hey, I heard that!!", closeAction=Wait(1)},
		
		-- Saw 
	}
end
