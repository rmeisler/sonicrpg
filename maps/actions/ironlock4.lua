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
	
	if GameState:isFlagSet("ep3_antoine") then
		scene.objectLookup.Antoine:remove()
		return Do(function() end)
	end
	
	GameState:setFlag("ep3_antoine")
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("paceright")
		end),
		Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Antoine.x + 170, 1, "linear"),
		PlayAudio("music", "introspection", 1.0, true),
		Parallel {
			Repeat(Serial {
				Do(function()
					scene.objectLookup.Antoine.sprite:setAnimation("paceleft")
				end),
				Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Antoine.x - 250, 0.6, "linear"),
				Do(function()
					scene.objectLookup.Antoine.sprite:setAnimation("paceright")
				end),
				Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Antoine.x + 170, 0.6, "linear")
			}, 14),
			
			Serial {
				MessageBox{message="Antoine: Alright Antoine, this is fine.", closeAction=Wait(1.5)},
				MessageBox{message="Antoine: Sonic and Sally are captured{p40}, that is that.", closeAction=Wait(1.5)},
				MessageBox{message="Antoine: Leaving them be is no option{p40}, so you must save them. {p40}Save them from over ze dozens of ze Swatbots.", closeAction=Wait(1.5)},
				
				MessageBox{message="Antoine: I shall simply use my mastery of kungfu to defeat them! {p40}Except for ze fact that I do not actually know any kungfu... {p60}zis is just something I say to protect my own skin...", closeAction=Wait(2)},
				
				MessageBox{message="Antoine: So what skills do you have then, Antoine\nDepardieu?", closeAction=Wait(1)},
				MessageBox{message="Antoine: Ah! {p40}I am a very fine chef! {p40}Yes, that is right!", closeAction=Wait(1)},
				MessageBox{message="Antoine: So I will serve them food on ze platter and serve ze Swatbots a knuckle sandwhich!! {p40}No, this does not make sense. {p40}Bots are made of metal. {p40}I will simply hurt my hand...", closeAction=Wait(2)},
				MessageBox{message="Antoine: So {p40}what I'm getting at here is zat I am unskilled{p40}, untrained{p40}, and completely helpless. {p60}I am ze worst Freedom Fighter and I can not help in any capacity, all I do is get captured and let people down, as I am always doing!!", closeAction=Wait(4), textSpeed=3},
			}
		},
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("paceleft")
		end),
		Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Antoine.x - 16, 1, "linear"),
		Animate(scene.objectLookup.Antoine.sprite, "scream"),
		MessageBox{message="Antoine: POURQUOI JE SUIS LE PIRE COMBATTANT DE LA LIBERTE QUI NE PEUT RIEN FAIRE DE BIEN!?"},
		
		Wait(1),
		Animate(scene.objectLookup.Antoine.sprite, "saddown"),
		Wait(3),
		
		MessageBox{message="???: Antoine..."},
		
		Animate(scene.objectLookup.Antoine.sprite, "scaredhop1"),
		MessageBox{message="Antoine: Who said that?"},
			
		Wait(1),
		MessageBox{message="???: Antoine..."},

		Wait(0.1),
		Animate(scene.objectLookup.Antoine.sprite, "tremble"),
		Animate(scene.objectLookup.Antoine.sprite, "scaredhop2"),
		Ease(scene.objectLookup.Antoine, "y", scene.objectLookup.Antoine.y - 50, 7, "linear"),
		Animate(scene.objectLookup.Antoine.sprite, "scaredhop3"),
		Ease(scene.objectLookup.Antoine, "y", scene.objectLookup.Antoine.y, 7, "linear"),
		Animate(scene.objectLookup.Antoine.sprite, "scaredhop4"),
		Wait(0.1),
		Animate(scene.objectLookup.Antoine.sprite, "scaredhop5"),
		
		Wait(1),
		
		Animate(scene.objectLookup.Antoine.sprite, "idleup"),
		MessageBox{message="Antoine: I am warning to you!"},
		
		Do(function()
			scene.objectLookup.Belpois.hidden = false
			scene.objectLookup.Belpois.sprite.color[4] = 0
			scene.objectLookup.Evangeline.hidden = false
			scene.objectLookup.Evangeline.sprite.color[4] = 0
			scene.objectLookup.YoungAnt.hidden = false
			scene.objectLookup.YoungAnt.sprite.color[4] = 0
		end),
		
		PlayAudio("music", "memories", 1.0, true, true),
		Parallel {
			Ease(scene.objectLookup.YoungAnt.sprite.color, 4, 255, 0.3),
			Ease(scene.objectLookup.Evangeline.sprite.color, 4, 255, 0.3),
			MessageBox{message="Evangeline: Antoine... {p60}aren't you forgetting something?"}
		},
		
		Animate(scene.objectLookup.YoungAnt.sprite, "youngant_lookaway"),
		MessageBox{message="Young Antoine: But mama--{p60} it's embarrasing!"},
		MessageBox{message="Antoine: ...M{p60}...mama?..."},
		MessageBox{message="Evangeline: But I just want to eat you up!"},
		Do(function()
			scene.objectLookup.Evangeline.sprite:setAnimation("evangeline_crouchleft_kiss")
		end),
		MessageBox{message="Young Antoine: Mama, stop it!"},
		Animate(scene.objectLookup.Evangeline.sprite, "evangeline_crouchleft_laugh"),
		MessageBox{message="Evangeline: You be careful now, you hear me?"},
		Animate(scene.objectLookup.YoungAnt.sprite, "youngant_idle"),
		MessageBox{message="Young Antoine: Yes. {p60}Can I go see my friends now?"},
		Animate(scene.objectLookup.Evangeline.sprite, "evangeline_crouchleft_smile"),
		MessageBox{message="Evangeline: Of course sweetie, have fun!"},
		
		Ease(scene.objectLookup.YoungAnt, "y", function() return scene.objectLookup.YoungAnt.y - 50 end, 8),
		Ease(scene.objectLookup.YoungAnt, "y", function() return scene.objectLookup.YoungAnt.y + 50 end, 8),
		
		Parallel {
			Ease(scene.objectLookup.YoungAnt.sprite.color, 4, 0, 0.3),
			Ease(scene.objectLookup.Evangeline.sprite.color, 4, 0, 0.3),
			MessageBox{message="Young Antoine: Bye mama!"}
		},
		
		Animate(scene.objectLookup.Antoine.sprite, "saddown"),
		MessageBox{message="Antoine: I remember your kisses, mama... {p60}I wish I could've made you proud..."},
		
		Wait(1),
		MessageBox{message="Belpois: Did the little one run off?"},
		Animate(scene.objectLookup.Antoine.sprite, "idledown"),
		MessageBox{message="Antoine: Papa!"},
		Animate(scene.objectLookup.Antoine.sprite, "idleup"),
		
		Animate(scene.objectLookup.Evangeline.sprite, "evangeline_idle"),
		Parallel {
			Ease(scene.objectLookup.Belpois.sprite.color, 4, 255, 0.3),
			Ease(scene.objectLookup.Evangeline.sprite.color, 4, 255, 0.3)
		},
		MessageBox{message="Evangeline: Yes{p60}, I'm so glad he's made friends."},
		Animate(scene.objectLookup.Evangeline.sprite, "evangeline_worried"),
		MessageBox{message="Evangeline: I just worry about him sometimes...{p60} he always seems so afraid of everything..."},
		Wait(1),
		Animate(scene.objectLookup.Antoine.sprite, "saddown"),
		MessageBox{message="Antoine: Ah--{p60} you were right to worry, mama."},
		
		Wait(1),
		Animate(scene.objectLookup.Belpois.sprite, "belpois_convince"),
		MessageBox{message="Belpois: There is no reason to worry, mon amour."},
		Animate(scene.objectLookup.Antoine.sprite, "idledown"),
		
		Wait(1),
		Animate(scene.objectLookup.Antoine.sprite, "idleup"),
		MessageBox{message="Belpois: It is not as though we were ourselves not scared in our younger days, eh?"},
		Animate(scene.objectLookup.Evangeline.sprite, "evangeline_idle"),
		MessageBox{message="Evangeline: Heh{p60}, ain't it ze truth."},
		MessageBox{message="Belpois: --and we pulled through did we not?"},
		Animate(scene.objectLookup.Evangeline.sprite, "evangeline_laugh"),
		MessageBox{message="Evangeline: *chuckles* Yes we did."},
		Animate(scene.objectLookup.Belpois.sprite, "belpois_idle"),
		MessageBox{message="Belpois: What I have learned in my days is that bravery is not to be lacking ze fear, it is to be moving forward in the face of it!"},
		Animate(scene.objectLookup.Evangeline.sprite, "evangeline_idle"),
		MessageBox{message="Evangeline: Our little Ant is certainly fitting the bill. {p60}Remember how scared he was to talk to Max's daughter?"},
		MessageBox{message="Evangeline: He eventually found his courage, and now zey are good friends!"},
		Animate(scene.objectLookup.Belpois.sprite, "belpois_convince"),
		MessageBox{message="Belpois: Exactly, mon amour! {p60}Our son may get scared a bit too easily at times, but he is no coward! {p80}He is the bravest person I know!"},
		
		Parallel {
			AudioFade("music", 1.0, 0.0, 0.2),
			Ease(scene.objectLookup.Belpois.sprite.color, 4, 0, 0.3),
			Ease(scene.objectLookup.Evangeline.sprite.color, 4, 0, 0.3)
		},
		MessageBox{message="Antoine: ...Yes... {p60}I can do this."},
		Animate(scene.objectLookup.Antoine.sprite, "idledown"),
		Wait(1),
		Parallel {
			Spawn(Serial {
				PlayAudio("music", "antoine", 1.0),
				PlayAudio("music", "missionready", 1.0, true, true)
			}),
			Serial {
				Animate(scene.objectLookup.Antoine.sprite, "pose"),
				MessageBox{message="Antoine: Listen{p40}, whoever is listening!!", closeAction=Wait(2)},
				Wait(0.5),
				Do(function() scene.objectLookup.Antoine.sprite:setAnimation("proud") end),
				MessageBox{message="Antoine: I am Antoine Depardieu!!", closeAction=Wait(2)},
				Wait(0.5),
				Animate(scene.objectLookup.Antoine.sprite, "scaredhop1"),
				MessageBox{message="Antoine: ...and though I am scared beyond belief...", closeAction=Wait(2)},
				Wait(0.5),
				Animate(scene.objectLookup.Antoine.sprite, "determined"),
				MessageBox{message="Antoine: I will not be giving up until I have saved my friends!!", closeAction=Wait(3)},
				Wait(0.5),
				MessageBox{message="Antoine: You hear that Sonic and Sally?! {p60}I am coming for you!!", closeAction=Wait(2)},
				MessageBox{message="Antoine learned Resiliency!", sfx="levelup", rect=MessageBox.HEADLINER_RECT}
			}
		},
		
		Do(function()
			GameState:removeFromParty("sonic")
			GameState:removeFromParty("sally")
			
			-- Give Resiliency skill
			table.insert(GameState.party.antoine.levelup[6].skills, require "data/battle/skills/Resiliency")
			
			scene.objectLookup.Antoine:remove()
			GameState.leader = "antoine"
			scene.player:updateSprite()
			scene.player.y = scene.player.y + 40
			scene.player.sprite.visible = true
			scene.player.dropShadow.hidden = false
		end)
	}
end
