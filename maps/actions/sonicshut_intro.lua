return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local Animate = require "actions/Animate"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local AudioFade = require "actions/AudioFade"
	local BlockPlayer = require "actions/BlockPlayer"
	local SpriteNode = require "object/SpriteNode"

	if not scene.updateHookAdded then
		scene.updateHookAdded = true
		scene:addHandler(
			"update",
			function(dt)
				if not scene.player then
					return
				end
			
				-- This update function defines and enforces eliptical collision 
				-- for the interior walls of knothole huts. This is implemented
				-- as just two separate point-to-circle collision checks,
				-- one for the top half of the room, one for the bottom half.
				local px = scene.player.x
				local py = scene.player.y + scene.player.height
				local cx = 400
				local cy = scene.map.properties.lowerCollisionCircleY or 370
				local cr = 200

				-- Player is above center of screen, use lower circle rather than higher circle
				if py < love.graphics.getWidth()/2 then
					cy = 435
				end

				local dx = px - cx
				local dy = py - cy
		
				-- If player is outside the circle
				if (dx*dx) + (dy*dy) > cr*cr then
					-- Determine the angle between their position and the center of the circle
					local radians = math.atan(dy / dx)
					local inv = px > cx and 1 or -1

					-- Use that angle to reposition them at the outer edge of the collision circle
					scene.player.x = cx + inv * (math.cos(radians) * cr)
					scene.player.y = cy - scene.player.height + inv * (math.sin(radians) * cr)
				end
			end
		)
	end
	
	local doNightTime = function()
		if scene.nighttime then
			local prefix = "nighthide"
			for _,layer in pairs(scene.map.layers) do
				if string.sub(layer.name, 1, #prefix) == prefix then
					layer.opacity = 1.0
				end
			end
		end
	end
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.regionName,
		100
	)

	--scene.audio:playMusic("knotholehut", 0.8)

	if hint == "scrapheap" then
		local scrapheapLayers = {
			scene:findLayer("scrapheap"),
			scene:findLayer("scrapheap2"),
			scene:findLayer("disappear")
		}
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.camPos.x = 0
				scene.camPos.y = 0
			end),
			
			Wait(0.6),
			Animate(scene.objectLookup.Sonic.sprite, "shock_wake"),
			Wait(2),
			MessageBox{message="Sonic?", closeAction=Wait(1.5)},
			Wait(1),
			PlayAudio("sfx", "bang", 1, true),
			Animate(scene.objectLookup.Sonic.sprite, "shock_wake_hugged"),
			Parallel {
				MessageBox{message="Sally: Sonic!"},
				Ease(scrapheapLayers[1], "opacity", 1, 0.3),
				Ease(scrapheapLayers[2], "opacity", 1, 0.3),
				Ease(scrapheapLayers[3], "opacity", 0, 0.3),
			},
			Wait(1),
			Animate(scene.objectLookup.Sonic.sprite, "shock_wake_hugged_smile"),
			Wait(0.5),
			PlayAudio("music", "sallyromance", 0.8, true),
			MessageBox{message="Sonic: H-Hey Sal..."},
			Wait(2),
			MessageBox{message="Sally: Sorry! {p60}I'm just so happy to see you awake!"},
			MessageBox{message="Sonic: Missed your hedgehog hunk that much, huh?"},
			MessageBox{message="Sally: *sigh*{p60} I think I like you better unconscious."},
			MessageBox{message="Sonic: *laughs*{p60} Yeah, right! {p60}I--"},
			MessageBox{message="Sonic: Oof. {p60}My head...", textSpeed=3},
			Wait(1),
			MessageBox{message="Sonic: Oh man...{p60} how long was I out?", textSpeed=3},
			AudioFade("music", 0.8, 0, 0.5),
			MessageBox{message="Sally: Yeah{p60}, about that..."},
			MessageBox{message="Sonic: What? {p60}A day?"},
			Wait(1),
			MessageBox{message="Sally: You've been unconscious for a week, Sonic."},
			MessageBox{message="Sonic: What?! {p60}B-But the mission--{p60} the others--{p60}\noh man, we gotta juice!!"},
			MessageBox{message="Sonic: ARG!"},
			MessageBox{message="Sally: Sonic, be careful!"},
			Wait(1),
			PlayAudio("music", "sonicsad", 1, true, true),
			MessageBox{message="Sonic: You're tellin' me I've been in bed for a whole week...{p80} but my leg is still this messed up?...", textSpeed=3},
			Wait(1),
			MessageBox{message="Sally: You were really hurt, Sonic. {p60}Worse than we initially thought... {p80}we just have to be patient."},
			MessageBox{message="Sonic: Patient?! {p60}Sal! {p60}What are ya talkin' about?!\n{p80}We were just about to finally take down Robotnik, once and for all, and then--"},
			MessageBox{message="Sally: Here. {p60}Take this."},
			Wait(1),
			MessageBox{message="Sonic: ?"},
			Wait(1),
			MessageBox{message="Sally: While you've been recovering{p60}, I've been building a communication device."},
			MessageBox{message="Sally: Since the others are probably looking\nfor us{p60}, I'm hoping one of them will pick up my\ndistress signals."},
			MessageBox{message="Sally: The only problem is{p60}, I can't seem to form a\ntwo-way link with anything up there{p60}, so I'm not\nsure if anyone is receiving my messages."},
			Wait(1),
			MessageBox{message="Sonic: ..."},
			Wait(1),
			MessageBox{message="Sally: I know this is a lot, Sonic. {p80}But the only way we'll make it out of here is if we stay calm and act rationally."},
			
			Wait(1),
			MessageBox{message="Sonic: Ok{p60}, I just got one question. {p100}What the heck did you hand me a second ago?"},
			MessageBox{message="Sally: Oh, it's a cane{p60}, to help you walk."},
			MessageBox{message="Sonic: Cool{p60}, cause it looks like a robot leg..."},
			MessageBox{message="Sally: Yeah{p60}, it is... {p80}It's how things are down here. {p80}You make use of what's available."},
			Wait(1),
			MessageBox{message="Sonic: ...{p60} *So {h Sonic the Hedgehog} needs a cane now...*", textSpeed=3},
			AudioFade("music", 1, 0, 1),
			Wait(1),
			PlayAudio("music", "scrapheap", 1, true, true),
			MessageBox{message="Breezie: Ah, I see that prince charming has finally awaken from his long slumber!"},
			MessageBox{message="Sonic: Uh, Breezie{p60}, right?"},
			MessageBox{message="Breezie: Thats me!{p60} I see you haven't suffered any amnesia{p60}, that's great news!"},
			MessageBox{message="Breezie: You're certainly in better shape than that friend of yours{p60}, B is it?{p60} I'm not sure what happened to him, but he's not all there..."},
			MessageBox{message="Sally: *long sigh*{p60} Well, I better get back to work."},
			MessageBox{message="Breezie: Sounds great! {p60}I'll join you!"},
			Wait(1),
			MessageBox{message="Sally: *exasperated breath*{p60} Uh... {p60}ok, sure."},
			MessageBox{message="Sonic: I'm comin' too!"},
			MessageBox{message="Sally: Take it easy, Sonic. {p60}You only just woke up! {p60}Maybe try to rest a bit more?"},
			MessageBox{message="Sonic: Oh come on, Sal, I--{p60} ack!"},
			Wait(1),
			MessageBox{message="Sonic: *sigh*"},
			Wait(1),
			MessageBox{message="Sally: It's ok. {p60}I'll come visit later."},
			Wait(1),
			MessageBox{message="Sonic: Ok."},
			Wait(3),
			MessageBox{message="Sonic: I've been asleep for a whole week and Sal thinks I'm just gonna lay around all day?!{p60} Fat chance!"}
		}
	elseif hint == "snowday" then
		scene.objectLookup.Door.object.properties.scene = "knotholesnowday.lua"
		scene.objectLookup.Sonic:remove()
		local prefix = "nighthide"
		for _,layer in pairs(scene.map.layers) do
			if string.sub(layer.name, 1, #prefix) == prefix then
				layer.opacity = 0.0
			end
		end
	elseif hint == "sleep" then
		doNightTime()
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		-- Undo ignore night
		local shine = require "lib/shine"

		scene.map.properties.ignorenight = false
		scene.originalMapDraw = scene.map.drawTileLayer
		scene.map.drawTileLayer = function(map, layer)
			if not scene.night then
				scene.night = shine.nightcolor()
			end
			scene.night:draw(function()
				scene.night.shader:send("opacity", layer.opacity or 1)
				scene.night.shader:send("lightness", 1 - (layer.properties.darkness or 0))
				scene.originalMapDraw(map, layer)
			end)
		end

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
				scene.camPos.x = 0
				scene.camPos.y = 0
			end),
			Wait(1),
			-- Flash twice
			scene:lightningFlash(),
			Wait(0.1),
			scene:lightningFlash(),
			Spawn(scene:screenShake(35, 20, 10)),
			PlayAudio("sfx", "thunder2",0.8, true),
			Wait(2),
			Do(function()
				scene:changeScene{map="tailshut", fadeOutSpeed=0.5, fadeInSpeed=0.5, hint="sleep", nighttime=true}
				--scene:changeScene{map="rotorsworkshop", fadeOutSpeed=0.2, fadeInSpeed=0.08, enterDelay=3, hint="intro"}
			end)
		}
	else
		if GameState:isFlagSet("ep6intro") then
			scene.objectLookup.Sonic:remove()
			scene.objectLookup.Door.object.properties.scene = "knothole_ep6.lua"
		elseif GameState:isFlagSet("ep5_knothole") then
			scene.objectLookup.Sonic:remove()
			scene.objectLookup.Door.object.properties.scene = "knothole_ep5.lua"
			if not GameState:isFlagSet("ep5_knothole_firefly_trigger") and not GameState:isFlagSet("ep5_knothole_meeting_trigger") then
				scene.audio:playMusic("knotholehut", 0.8)
			end
		elseif GameState:isFlagSet("ep4_introdone") then
			local prefix = "nighthide"
			for _,layer in pairs(scene.map.layers) do
				if string.sub(layer.name, 1, #prefix) == prefix then
					layer.opacity = 0.0
				end
			end
			scene.objectLookup.Door.object.properties.scene = "knothole.lua"
			scene.audio:playMusic("knotholehut", 0.8)
		elseif not scene.nighttime and
		   (GameState:isFlagSet("ep3_ffmeeting") or not GameState:isFlagSet("ep3_knotholerun"))
		then
			scene.audio:playMusic("knotholehut", 0.8)
		elseif not scene.nighttime and not GameState:isFlagSet("ep3_ffmeeting") then
			scene.audio:playMusic("awkward", 1.0)
		else
			doNightTime()
			scene.objectLookup.Door.object.properties.scene = "knotholeatnight.lua"
		end
	end
	
	Executor(scene):act(Serial {
		Wait(0.5),
		text,
		Ease(text.color, 4, 255, 1),
		Wait(2),
		Ease(text.color, 4, 0, 1)
	})
	return Action()
end
