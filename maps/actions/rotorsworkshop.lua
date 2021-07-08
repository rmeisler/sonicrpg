return function(scene)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local AudioFade = require "actions/AudioFade"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local SpriteNode = require "object/SpriteNode"

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
	
	if GameState:isFlagSet("rotorreveal_done") then
		scene.audio:playMusic("doittoit", 0.5)
		return Action()
	else
		--scene.audio:playMusic("doittoit", 0.5)
		GameState:setFlag("rotorreveal_done")
		return Serial {
			AudioFade("music", 1, 0, 1),
			Do(function() scene.audio:stopMusic() end),
			
			MessageBox {message="Rotor: Hey guys, {p40}check this out!"},
			
			scene:enterBattle {
				opponents = {
					"swatbot"
				},
				music = "doittoit",
				onEnter = function(battleScene)
					local rotor = SpriteNode(battleScene, table.remove(battleScene.opponentSlots, 1), nil, "rotor", nil, nil, "sprites")
					rotor:setAnimation("idleright")
					
					battleScene.partyByName.sonic.id = "notsonic"
					battleScene.opponents[1].stats.miss = true
					
					local Swatbot = require "data/monsters/swatbot"
					return Serial {
						Wait(2),
						MessageBox {message="Sonic: What's the deal with the Swatbutt, Rote?"},
						Do(function()
							rotor:setAnimation("explaining_right1")
						end),
						MessageBox {message="Rotor: I found this guy wandering around Sector 2."},
						MessageBox {message="Rotor: But he's not exactly a regular Swatbot. {p70}Watch this."},
						Do(function()
							rotor:setAnimation("idleright")
						end),
						MessageBox {message="Rotor: Swatbot. {p40}Target Sonic the Hedgehog."},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("shock")
							battleScene.partyByName.sally.sprite:setAnimation("shock")
						end),
						Parallel {
							MessageBox {message="Sonic: What!? {p40}Not cool, Rote!!"},
							Swatbot.behavior(battleScene.opponents[1], battleScene.partyByName.sonic)
						},
						
						-- Swatbot fires at Sonic, misses
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("idle")
							battleScene.partyByName.sally.sprite:setAnimation("idle")
						end),
						MessageBox {message="Sonic: Huh?..."},
						MessageBox {message="Rotor: Swatbot. {p40}Target Princess Sally."},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("shock")
							battleScene.partyByName.sally.sprite:setAnimation("shock")
						end),
						Parallel {
							MessageBox {message="Sally: Rotor!!"},
							Swatbot.behavior(battleScene.opponents[1], battleScene.partyByName.sally)
						},
						
						-- Swatbot fires at Rotor, misses
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("idle")
							battleScene.partyByName.sally.sprite:setAnimation("idle")
							rotor:setAnimation("explaining_right2")
						end),
						MessageBox {message="Rotor: See? {p40}He can't hit his target!"},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("criticizing")
						end),
						MessageBox {message="Sonic: Ya tryin' to give us a heart attack?!"},
						MessageBox {message="Sonic: Why ya showing us this, Rote?"},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("idle")
							rotor:setAnimation("thinking")
						end),
						AudioFade("music", 1, 0, 1),
						MessageBox {message="Rotor: Well... {p40}based on what I'm seeing...{p40} this malfunction isn't caused by faulty {h hardware}..."},
						Do(function()
							battleScene.partyByName.sally.sprite:setAnimation("thinking")
						end),
						MessageBox {message="Sally: *gasp*! {p50}But that must mean...", textSpeed=3, closeAction=Wait(1)},
						Do(function()
							battleScene.audio:playMusic("areyouready", 0.4)
						end),
						MessageBox {message="Rotor: Yeah... {p40}I'm thinking it's exploitable.", textSpeed=4},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("annoyed")
						end),
						MessageBox {message="Sonic: Guys, {p30}guys, {p30}can someone speak english here?"},
						MessageBox {message="Sally: Well... {p40}basically... {p40}the Swatbot is, uh{p20}.{p20}.{p20}.{p40} {h glitchin'}.", textSpeed=4},
						MessageBox {message="Rotor: Right. {p40}And because this glitch showed up in a production model, {p40}my theory is, {p40}we could potentially mask this glitch as a {h software patch}.", textSpeed=3},
						MessageBox {message="Sally: Meaning, {p40}we could spread this glitch to other bots!", textSpeed=3},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("thinking")
						end),
						MessageBox {message="Sonic: Whoah guys, {p40}are you really telling me what I think you're telling me?", textSpeed=3},
						MessageBox {message="Sally: If we do this right, {p40}we could upload this glitch to Robotnik's entire army! {p50}They wouldn't be able to lay a finger on us!", textSpeed=3},
						MessageBox {message="Sally: ...But how are we going to make the software patch look authentic?"},
						MessageBox {message="Rotor: We'll need to use Buttnik's terminal to create a {h certificate of authenticity}."},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("criticizing")
						end),
						MessageBox {message="Sonic: Sounds like somethin' ol' Buttnik would be heavily guarding..."},
						MessageBox {message="Rotor: You're right. {p50}As far as I know, {p20}the only terminal which can produce a certificate of authenticity is in the {h Death Egg}.", textSpeed=3},
						AudioFade("music", 0.4, 0, 1),
						Wait(2),
						Do(function()
							battleScene.partyByName.sally.sprite:setAnimation("sad")
							battleScene.audio:playMusic("sonicsad", 0.8)
						end),
						MessageBox {message="Sally: *sigh* {p40}Well{p20}.{p20}.{p20}. {p40}so much for that plan...", textSpeed=2},
						Do(function()
							rotor:setAnimation("sad")
						end),
						Wait(1),
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("criticizing_sad")
						end),
						MessageBox {message="Sonic: ...", textSpeed=2},
						AudioFade("music", 0.8, 0, 1),
						Wait(1),
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("thinking")
						end),
						MessageBox {message="Sonic: Wait a sonic second!"},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("victory")
						end),
						MessageBox {message="Sonic: B could get us into Robotnik's headquarters!"},
						Do(function()
							battleScene.audio:playMusic("doittoit2", 1.0)
							battleScene.partyByName.sally.sprite:setAnimation("idleup")
							rotor:setAnimation("idleright")
						end),
						MessageBox {message="Sally: A-Are you sure?"},
						MessageBox {message="Sonic: Hey, do I look like a guy who isn't sure?"},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("idle")
							battleScene.partyByName.sally.sprite:setAnimation("thinking3")
						end),
						MessageBox {message="Sally: Ok, {p40}far be it from me to say this, {p40}but I think we've been playing it safe for long enough."},
						MessageBox {message="Sally: We need to do this."},
						Do(function()
							battleScene.partyByName.sonic.sprite:setAnimation("victory")
						end),
						MessageBox {message="Sonic: Alright!"},
						Do(function()
							rotor:setAnimation("pose")
						end),
						MessageBox {message="Rotor: Yeah!"},
						Do(function()
							battleScene.partyByName.sally.sprite:setAnimation("victory")
							
							battleScene.partyByName.sonic.id = "sonic"
						end),
						MessageBox {message="All: Let's do it to it!", textSpeed=4},
						AudioFade("music", 1, 0),
						battleScene:earlyExit()
					}
				end
				--prevMusic = "patrol"
			}
		}
	end
end
