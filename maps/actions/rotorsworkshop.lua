return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"
	local Player = require "object/Player"

	local Action = require "actions/Action"
	local AudioFade = require "actions/AudioFade"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local Move = require "actions/Move"
	local MessageBox = require "actions/MessageBox"
	local BlockPlayer = require "actions/BlockPlayer"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Animate = require "actions/Animate"
	local Parallel = require "actions/Parallel"
	local Spawn = require "actions/Spawn"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local SpriteNode = require "object/SpriteNode"
	
	hint = "ep4_aftermeeting"

	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Rotor's",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Workshop",
		100
	)

	if not scene.updateHookAdded then
		scene.updateHookAdded = true
		scene:addHandler(
			"update",
			function(dt)
				local px = scene.player.x
				local py = scene.player.y + scene.player.height
				
				-- Bottom left
				local a = {x=95, y=575}
				local b = {x=308, y=680}
				
				-- Check bounding rect for each line before doing collision check
				if py > a.y and py < b.y and px > a.x and px < b.x then
					-- Find closest point on line between line and player x, y
					local a_to_p = {x = px - a.x, y = py - a.y}
					local a_to_b = {x = b.x - a.x, y = b.y - a.y}
					local atb_sq = a_to_b.x * a_to_b.x + a_to_b.y * a_to_b.y
					local atp_dot_atb = a_to_p.x * a_to_b.x + a_to_p.y * a_to_b.y
					local t = atp_dot_atb / atb_sq
				
					-- If player x has stepped past the line, place them on it
					local mostx = math.max(a.x + a_to_b.x * t, a.x)
					if px < mostx then
						scene.player.x = mostx
					end
					local leasty = math.min(a.y + a_to_b.y * t, b.y)
					if py > leasty then
						scene.player.y = leasty - scene.player.height
					end
					return
				end
				
				-- Bottom right
				a = {x=671, y=575}
				b = {x=455, y=680}
				
				if py > a.y and py < b.y and px < a.x and px > b.x then
					local a_to_p = {x = px - a.x, y = py - a.y}
					local a_to_b = {x = b.x - a.x, y = b.y - a.y}
					local atb_sq = a_to_b.x * a_to_b.x + a_to_b.y * a_to_b.y
					local atp_dot_atb = a_to_p.x * a_to_b.x + a_to_p.y * a_to_b.y
					local t = atp_dot_atb / atb_sq
				
					local leastx = math.max(a.x + a_to_b.x * t, a.x)
					if px > leastx then
						scene.player.x = leastx
					end
					local leasty = math.min(a.y + a_to_b.y * t, b.y)
					if py > leasty then
						scene.player.y = leasty - scene.player.height
					end
					return
				end
				
				-- Top left
				a = {x=80, y=336}
				b = {x=351, y=167}
				
				if py < a.y and py > b.y and px > a.x and px < b.x then
					local a_to_p = {x = px - a.x, y = py - a.y}
					local a_to_b = {x = b.x - a.x, y = b.y - a.y}
					local atb_sq = a_to_b.x * a_to_b.x + a_to_b.y * a_to_b.y
					local atp_dot_atb = a_to_p.x * a_to_b.x + a_to_p.y * a_to_b.y
					local t = atp_dot_atb / atb_sq
				
					local mostx = math.max(a.x + a_to_b.x * t, a.x)
					if px < mostx then
						scene.player.x = mostx
					end
					local mosty = math.max(a.y + a_to_b.y * t, b.y)
					if py < mosty then
						scene.player.y = mosty - scene.player.height
					end
					return
				end
			end
		)
	end

	if hint == "snowday" then
		scene.objectLookup.Door.object.properties.scene = "knotholesnowday.lua"
		scene.objectLookup.Rotor:remove()
		scene.objectLookup.Rotor2:remove()
		scene.objectLookup.Logan:remove()
	elseif hint == "ep4_aftermeeting" then
		scene.objectLookup.Logan.hidden = false
		scene.objectLookup.Logan.ghost = false
		scene.objectLookup.Logan.isInteractable = true
		scene.objectLookup.Logan:updateCollision()
		scene.objectLookup.Logan.sprite:setAnimation("idleup")
		scene.objectLookup.Logan.x = scene.player.x
		scene.objectLookup.Logan.y = scene.player.y

		scene.objectLookup.Rotor2.hidden = false
		scene.objectLookup.Rotor2.ghost = false
		scene.objectLookup.Rotor2.isInteractable = true
		scene.objectLookup.Rotor2:updateCollision()

		scene.objectLookup.Rotor:remove()
		
		scene.camPos.y = 300
		scene.player.sprite.visible = false

		return BlockPlayer {
			Do(function()
				scene.camPos.y = 300
				scene.player.sprite.visible = false
			end),
			Animate(scene.objectLookup.Rotor2.sprite, "awake"),
			Wait(2),
			PlayAudio("music", "sadintrospect", 1.0, true),
			Wait(2),
			Animate(scene.objectLookup.Rotor2.sprite, "sleeping"),
			MessageBox{message="Rotor: *sigh*"},
			Wait(2),
			PlayAudio("sfx", "door", 1.0, true),
			Animate(scene.objectLookup.Door.sprite, "opening"),
			Animate(scene.objectLookup.Door.sprite, "open"),
			Wait(1),
			Move(scene.objectLookup.Logan, scene.objectLookup.Waypoint1, "walk"),
			Animate(scene.objectLookup.Logan.sprite, "idleup"),
			Wait(1),
			MessageBox{message="Logan: Hey..."},
			Animate(scene.objectLookup.Rotor2.sprite, "awake"),
			MessageBox{message="Rotor: Hey."},
			Wait(1),
			MessageBox{message="Logan: ..."},
			Do(function()
				scene.objectLookup.Logan.sprite:setAnimation("walkup")
			end),
			Parallel {
				Ease(scene.objectLookup.Logan, "x", 320, 0.5, "linear"),
				Ease(scene.objectLookup.Logan, "y", 160, 0.5, "linear"),
			},
			Animate(scene.objectLookup.Logan.sprite, "idleright"),
			Wait(1),
			MessageBox{message="Logan: So you're just gonna let that pompous princess tell you what to do, huh?"},
			PlayAudio("music", "sonicsad", 1.0, true, true),
			MessageBox{message="Rotor: *sigh* {p60}Sally's right. {p60}It's too dangerous."},
			Animate(scene.objectLookup.Logan.sprite, "irritated"),
			MessageBox{message="Logan: And I was beginning to think you and I were the same..."},
			Animate(scene.objectLookup.Rotor2.sprite, "laylookleft"),
			MessageBox{message="Rotor: What's that supposed to mean?"},
			Animate(scene.objectLookup.Logan.sprite, "idleright"),
			MessageBox{message="Logan: It 'means' you should stand up for yourself!"},
			MessageBox{message="Logan: How many times has Miss 'No Danger' Princess Sally gone chasing after her father?"},
			MessageBox{message="Logan: She nearly let Iron Lock collapse around her team just to listen to a few incoherent sentences from some interdimensional ghost!"},
			Animate(scene.objectLookup.Rotor2.sprite, "awake"),
			MessageBox{message="Rotor: ..."},
			Wait(1),
			Animate(scene.objectLookup.Logan.sprite, "attitude"),
			MessageBox{message="Logan: I'm just sayin'... {p60}if it were my mom up there in the mountains?..."},
			MessageBox{message="Logan: Well, I wouldn't be taking 'no' for an answer. {p60}I'd high-tail my butt up that mountain."},
			AudioFade("music", 1, 0, 0.5),
			MessageBox{message="Rotor: ...{p60}Yeah...{p60} I mean you're right!"},
			Animate(scene.objectLookup.Logan.sprite, "idleright"),
			scene.objectLookup.Logan:hop(),
			MessageBox{message="Logan: Of course I'm right!"},
			Animate(scene.objectLookup.Rotor2.sprite, "laylookleft"),
			MessageBox{message="Rotor: But how am I supposed to find my way to him without Nicole?"},
			Animate(scene.objectLookup.Logan.sprite, "angrydown"),
			scene.objectLookup.Logan:hop(),
			MessageBox{message="Logan: *snort* Nicole!?"},
			Animate(scene.objectLookup.Logan.sprite, "idleright"),
			MessageBox{message="Logan: You don't need that second-rate soundboard! {p60}I can help guide you there with my own computer!"},
			MessageBox{message="Rotor: Whoah! {p100}You'd do that for me?"},
			PlayAudio("music", "rotorsentimental", 1.0, true),
			Animate(scene.objectLookup.Logan.sprite, "irritated"),
			MessageBox{message="Logan: Uh... {p120}yeah. {p120}I mean it's no big deal..."},
			MessageBox{message="Logan: Besides... {p60}I gotta see the look on the Princess' face when we get back!"},
			MessageBox{message="Rotor: W-Well, alright!"},
			PlayAudio("music", "rotorready", 1.0, true, true),
			Animate(scene.objectLookup.Rotor2.sprite, "idleleft"),
			scene.objectLookup.Rotor2:hop(),
			Do(function()
				scene.objectLookup.Rotor2.y = scene.objectLookup.Rotor2.y + 20
			end),
			Animate(scene.objectLookup.Logan.sprite, "idleright"),
			MessageBox{message="Rotor: I-I guess we gotta get to the {h Freedom Stormer}\nthen."},
			MessageBox{message="Rotor: I stashed it in the {h Great Forest}{p60}, behind some\nboulders for safe keeping..."},
			MessageBox{message="Logan: Let's do it!"},
		}
	elseif hint == "intro" then
		scene.audio:stopSfx()
		scene.objectLookup.Logan.hidden = false
		scene.objectLookup.Logan.ghost = false
		scene.objectLookup.Logan.isInteractable = true
		scene.objectLookup.Logan:updateCollision()
		scene.objectLookup.Logan.sprite:setAnimation("idledown")

		scene.objectLookup.Rotor2.hidden = false
		scene.objectLookup.Rotor2.ghost = false
		scene.objectLookup.Rotor2.isInteractable = true
		scene.objectLookup.Rotor2:updateCollision()

		scene.objectLookup.Rotor:remove()
		scene.objectLookup.Computer.isInteractable = false
		scene.camPos.y = 300

		return BlockPlayer {
			Do(function()
				scene.camPos.y = 300
			end),
			Animate(scene.objectLookup.Logan.sprite, "sleeping"),
			Wait(4),
			PlayAudio("music", "flutter", 0.8, true),
			Serial {
				Wait(0.5),
				subtext,
				text,
				Parallel {
					Ease(text.color, 4, 255, 1),
					Ease(subtext.color, 4, 255, 1),
				},
				Wait(2),
				Parallel {
					Ease(text.color, 4, 0, 1),
					Ease(subtext.color, 4, 0, 1)
				}
			},
			Wait(2),
			Animate(scene.objectLookup.Logan.sprite, "waking"),
			Animate(scene.objectLookup.Logan.sprite, "laying"),
			MessageBox{message="Logan: ...*yawn*", closeAction=Wait(2)},
			MessageBox{message="Logan: Seems like the storm has passed..."},
			PlayAudio("music", "rotorsworkshop", 1.0, true),
			Animate(scene.objectLookup.Logan.sprite, "cold"),
			Parallel {
				MessageBox{message="Logan: !!", closeAction=Wait(0.5)},
				Serial {
					scene.objectLookup.Logan:hop(),
					Do(function()
						scene.objectLookup.Logan.sprite:setAnimation("shiver")
					end)
				},
			},
			MessageBox{message="Logan: Brr!!"},
			Animate(scene.objectLookup.Rotor2.sprite, "waking"),
			Wait(0.5),
			Animate(scene.objectLookup.Rotor2.sprite, "laylookleft"),
			MessageBox{message="Rotor: ...Huh?"},
			MessageBox{message="Logan: Why is it freezing cold in here!?"},
			MessageBox{message="Rotor: Feels fine to me."},
			Animate(scene.objectLookup.Logan.sprite, "cold"),
			scene.objectLookup.Logan:hop(),
			Wait(0.5),
			Animate(scene.objectLookup.Logan.sprite, "idleright"),
			Wait(0.5),
			MessageBox{message="Logan: Of course it feels fine to you{p60}, you're a walrus!"},
			Animate(scene.objectLookup.Rotor2.sprite, "awake"),
			Wait(0.5),
			MessageBox{message="Rotor: Oh yeah! {p60}Good point."},
			--PlayAudio("music", "doittoit", 1.0, true, true),
			Animate(scene.objectLookup.Logan.sprite, "idledown"),
			Do(function()
				scene.objectLookup.Logan:removeCollision()
				scene.objectLookup.Logan:remove()

				scene.camPos.y = 0
				scene.player.x = scene.objectLookup.Logan.x + 40
				scene.player.y = scene.objectLookup.Logan.y + 58
				scene.player.state = Player.STATE_IDLEDOWN

				scene.player.sprite.visible = true
				scene.player.dropShadow.hidden = false

				scene.objectLookup.Door.object.properties.scene = "knotholesnowday.lua"
				scene.objectLookup.Door.object.properties.hint = "intro"
			end)
		}
	elseif scene.nighttime then
		scene.objectLookup.Logan.hidden = false
		scene.objectLookup.Logan.ghost = false
		scene.objectLookup.Logan.isInteractable = true
		scene.objectLookup.Logan:updateCollision()

		scene.objectLookup.Rotor:remove()
		scene.objectLookup.Computer.isInteractable = false

		scene.objectLookup.Door.object.properties.scene = "knotholeatnight.lua"
		local prefix = "nighthide"
		for _,layer in pairs(scene.map.layers) do
			if string.sub(layer.name, 1, #prefix) == prefix then
				layer.opacity = 1.0
			end
		end
	else
		scene.objectLookup.Door.object.properties.scene = "knothole.lua"
		local prefix = "nighthide"
		for _,layer in pairs(scene.map.layers) do
			if string.sub(layer.name, 1, #prefix) == prefix then
				layer.opacity = 0.0
			end
		end

		scene.audio:playMusic("doittoit", 0.5)
	end

	Executor(scene):act(Serial {
		Wait(0.5),
		subtext,
		text,
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
	
	return Action()
end
