return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local Animate = require "actions/Animate"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local BlockPlayer = require "actions/BlockPlayer"
	local Do = require "actions/Do"
	local Move = require "actions/Move"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	local knotholeIntro = function()
		local subtext = TypeText(
			Transform(50, 470),
			{255, 255, 255, 0},
			FontCache.TechnoSmall,
			"Great Forest",
			100
		)
		
		local text = TypeText(
			Transform(50, 500),
			{255, 255, 255, 0},
			FontCache.Techno,
			"Knothole",
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
		
		scene.audio:playMusic("knothole", 0.8)
	end
	
	scene.player.dustColor = Player.FOREST_DUST_COLOR
	
	if GameState:hasItem("Antoine's Key") then
		if scene.objectLookup.Antoine then
			scene.objectLookup.Antoine:remove()
		end
		if scene.objectLookup.AntoinesKeys then
			scene.objectLookup.AntoinesKeys:remove()
		end
	end
	
	if GameState:isFlagSet("ffmeeting") then
		if scene.objectLookup.Bunnie then
			scene.objectLookup.Bunnie:remove()
		end
		if scene.objectLookup.PestExample then
			scene.objectLookup.PestExample:remove()
		end
	elseif GameState:isFlagSet("bunnie_game_over") then
		if not scene.bunnieReset then
			scene.bunnieReset = true
			
			scene.objectLookup.PestExample:remove()
			
			local bunnie = scene.objectLookup.Bunnie
			bunnie.sprite:setAnimation("idleright")
			bunnie.handlers.interact = nil
			bunnie:addInteract(function()
				bunnie.scene.player.hidekeyhints[tostring(bunnie)] = bunnie
				bunnie:facePlayer()
				bunnie.scene:run {
					MessageBox {message = "Bunnie: My goodness, {p40}I sure am glad those pests are gone.", blocking = true},
					Do(function()
						bunnie:refreshKeyHint()
					end)
				}
			end)
		end
	end

	if hint == "fromworldmap" then
		knotholeIntro()
		return BlockPlayer {
			Parallel {
				Do(function()
					local cart = scene.objectLookup.CartBG
					scene.player.x = cart.x + cart.sprite.w
					scene.player.y = cart.y + cart.sprite.h
				end),
				Move(scene.objectLookup.CartBG, scene.objectLookup.CartWaypoint2),
				Move(scene.objectLookup.Cart, scene.objectLookup.CartWaypoint2)
			}
		}
	elseif GameState:isFlagSet("ep3_intro") and
		not GameState:isFlagSet("ep3_introknothole")
	then
		GameState:setFlag("ep3_introknothole")
		scene.audio:stopMusic()
		return BlockPlayer {
			PlayAudio("music", "natbeauty", 1.0),
			MessageBox {message="Sally: Ahhh...", textspeed=1},
			MessageBox {message="Sally: Nothing like a breath of that fresh, morning Great Forest air to clear your head...", textspeed=1},
			Wait(2),
			MessageBox {message="Sonic: Gettin' scared, feather weight?"},
			PlayAudio("music", "rotorsworkshop", 1.0),
			MessageBox {message="Sally: ?"},
			Wait(1),
			-- Sonic/Fleet blast past Sally
			scene.player:spin(3, 0.01),
			Do(function()
				scene.player.sprite:setAnimation("shock")
			end),
			Wait(1),
			Do(function()
				scene.player.sprite:setAnimation("frustrateddown")
			end),
			MessageBox {message="Sally: Sonic!!"}
		}
	elseif GameState:isFlagSet("rotorreveal_done") and
		not GameState:isFlagSet("ffmeeting")
	then
		GameState:setFlag("ffmeeting")
		
		scene.audio:stopMusic()
		scene.player.x = scene.objectLookup.BunnieMtg.x
		scene.player.y = scene.objectLookup.BunnieMtg.y

		scene.objectLookup.SonicMtg.hidden = false
		scene.objectLookup.RotorMtg.hidden = false
		scene.objectLookup.AntoineMtg.hidden = false
		scene.objectLookup.SallyMtg.hidden = false
		scene.objectLookup.BunnieMtg.hidden = false
		
		local sally = scene.objectLookup.SallyMtg
		local antoine = scene.objectLookup.AntoineMtg
		local sonic = scene.objectLookup.SonicMtg
		local rotor = scene.objectLookup.RotorMtg
		local bunnie = scene.objectLookup.BunnieMtg
		
		local hop = function(obj)
			return Serial {
				Ease(obj, "y", function() return obj.y - 30 end, 8),
				Ease(obj, "y", function() return obj.y + 30 end, 8, "quad"),
				Ease(obj, "y", function() return obj.y - 5 end, 20, "quad"),
				Ease(obj, "y", function() return obj.y + 5 end, 20, "quad"),
				Ease(obj, "y", function() return obj.y - 2 end, 20, "quad"),
				Ease(obj, "y", function() return obj.y + 2 end, 20, "quad")
			}
		end

		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true

		return BlockPlayer {
			PlayAudio("music", "meettherebellion", 1.0, true, true),
			MessageBox {message="Sally: Alright everyone-- {p40}here's the plan."},
			Animate(sally.sprite, "planning_lookdown"),
			MessageBox {message="Sally: We will first enter Robotropolis from the western corridor."},
			Animate(sally.sprite, "planning_lookdown_point"),
			MessageBox {message="Sally: From there, we'll meet up with B, who has already agreed to escort us into the Death Egg..."},
			Animate(sally.sprite, "planning_lookdown"),
			MessageBox {message="Sally: Once inside, we'll need to find a master terminal. {p60}Only master terminals are capable of producing a certificate of authenticity--"},
			hop(antoine),
			MessageBox {message="Antoine: Ahem. {p60}I am having a question."},
			Animate(sally.sprite, "planning"),
			MessageBox {message="Sally: Go ahead, Antoine."},
			MessageBox {message="Antoine: Once you are inside zee Egg of Death, how are you to know where zis terminal even is?"},
			MessageBox {message="Sally: Good question, Antoine."},
			MessageBox {message="Sally: Unfortunately, intel on the internal layout of the Death Egg is sparse. {p60}We won't know exactly where B will take us, nor where the closest master terminal will be."},
			MessageBox {message="Sally: But-- {p40}according to Griff-- {p40}Factory bots need to refresh their security access codes with a master terminal every couple of hours..."},
			MessageBox {message="Rotor: ...so all you need to do is find one of these bots and follow it around until it leads you to a master terminal?"},
			MessageBox {message="Sally: Right!"},
			MessageBox {message="Bunnie: My goodness, Sally-girl! How do you come up with this stuff?"},
			MessageBox {message="Sally: Any other questions?"},
			hop(sonic),
			MessageBox {message="Sonic: Yeah! {p60}Are we having dinner after this? {p40}I'm starving!"},
			Animate(sally.sprite, "planning_irritated"),
			MessageBox {message="Sally: Sonic! {p40}Be serious!"},
			MessageBox {message="Sonic: I never joke about dinner, Sal!"},
			MessageBox {message="Sally: Fine. {p60}We'll have dinner immediately after this meeting."},
			Animate(sally.sprite, "planning"),
			MessageBox {message="Sally: Are there any \"real\" questions?"},
			hop(bunnie),
			MessageBox {message="Bunnie: Who ya got in mind for the mission?"},
			MessageBox {message="Sally: I wanna keep the team small, but versatile. {p40}\nYou, me, and Sonic."},
			MessageBox {message="Bunnie: You got it, sugah!"},
			AudioFade("music", 1.0, 0.0, 0.5),
			Wait(1),
			Animate(sally.sprite, "planning_smile"),
			PlayAudio("music", "exciting", 1.0, true),
			MessageBox {message="Sally: Alright guys. {p60}This is the opportunity we've all been waiting for..."},
			MessageBox {message="Sally: Let's do it to it!"},
			Do(function()
				scene.player.cinematic = true
				sally:run(BlockPlayer {
					Parallel {
						Serial {
							scene:fadeOut(0.2),
							Wait(1)
						},
						AudioFade("music", 1.0, 0.0, 0.2)
					},
					Do(function()
						scene.player.sprite.visible = true
						scene.player.dropShadow.hidden = false
						
						sally.hidden = true
						rotor.hidden = true
						bunnie.hidden = true
						sonic.hidden = true
						antoine.hidden = true
						
						GameState:addToParty("bunny", 3, true)
						GameState.leader = "sonic"
						scene.player:updateSprite()
						
						local cart = scene.objectLookup.Cart
						scene.player.hidekeyhints[tostring(cart)] = cart
						
						scene.player.x = scene.objectLookup.CartWaypoint2.x + 64 - 50
						scene.player.y = scene.objectLookup.CartWaypoint2.y + 50 - 50
						
						local walkout, walkin, sprites = scene.player:split {
							GameState.party.sonic,
							GameState.party.bunny,
							GameState.party.sally
						}
						
						scene.player.x = scene.objectLookup.CartWaypoint2.x + 94
						scene.player.y = scene.objectLookup.CartWaypoint2.y + 50
						
						scene.player.cinematicStack = scene.player.cinematicStack + 1
						scene.player.cinematic = false
						
						scene.objectLookup.Bunnie:remove()
						scene.objectLookup.PestExample:remove()

						sonic:run(BlockPlayer {
							scene:fadeIn(0.5),
							Wait(0.5),
							walkout,
							Do(function()
								scene.audio:playMusic("knothole", 0.8)
							end),
							MessageBox{message="Sally: When you're both ready to go, we can just ride this pulley cart out of Knothole."},
							walkin
						})
					end)
				})
			end)
		}
	else
		knotholeIntro()
		return Action()
	end
end
