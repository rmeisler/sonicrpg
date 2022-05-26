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
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Iron Lock",
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
	
	if hint == "fromworldmap" then
		if GameState:isFlagSet("ep3_darkswampintro") then
			showTitle()
			return PlayAudio("music", "ironlock", 1.0, true, true)
		else
			GameState:setFlag("ep3_darkswampintro")
			
			local fleet = BasicNPC(
				scene,
				{name = "objects"},
				{
					name = "Fleet",
					x = scene.player.x,
					y = scene.player.y - 800,
					width = 80,
					height = 70,
					properties = {nocollision = true, sprite = "art/sprites/leon2.png", defaultAnim = "fleetfloat"}
				}
			)
			scene:addObject(fleet)
			
			local ivan = BasicNPC(
				scene,
				{name = "objects"},
				{
					name = "Ivan",
					x = scene.player.x,
					y = scene.player.y - 800,
					width = 47,
					height = 55,
					properties = {nocollision = true, sprite = "art/sprites/ivan.png", defaultAnim = "idledown"}
				}
			)
			scene:addObject(ivan)
			
			local logan = BasicNPC(
				scene,
				{name = "objects"},
				{
					name = "Logan",
					x = scene.player.x,
					y = scene.player.y - 800,
					width = 47,
					height = 55,
					properties = {nocollision = true, sprite = "art/sprites/logan.png", defaultAnim = "idledown"}
				}
			)
			scene:addObject(logan)

			scene.player.x = -2000
			scene.player.y = 342
			scene.camPos.x = -700
			scene.objectLookup.Eyes1.hidden = true
			scene.objectLookup.Eyes2.hidden = true
			return BlockPlayer {
				Do(function()
					scene.player.x = -2000
					scene.player.y = 342
					scene.camPos.x = -700
				end),
				PlayAudio("music", "darkswamp", 1.0, true, true),
				Wait(1),
				Do(showTitle),
				Wait(3),
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
				Ease(scene.camPos, "x", 0, 0.2, "inout"),
				Do(function()
					scene.objectLookup.Eyes1.hidden = true
				end),
				AudioFade("music", 1, 0, 1),
				PlayAudio("music", "sonicenters", 1.0, true),
				Wait(1),
				Do(function()
					GameState:addToParty("antoine", 6, true)
					GameState:addToParty("sonic", 6, true)
					GameState.leader = "sonic"
					scene.player:updateSprite()
					scene.player.cinematic = true
					scene.player.ignoreSpecialMoveCollision = true
					scene.player.noMoveSpecial = true
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
					local nicole = SpriteNode(
						scene,
						Transform(),
						{255,255,255,0},
						"nicholeprojection",
						nil,
						nil,
						"objects"
					)
					local walkout, walkin, sprites = scene.player:split()
					scene:run(BlockPlayer {
						Do(function()
							for k in pairs(GameState.party) do
								sprites[k].x = scene.player.x - 60
								sprites[k].y = scene.player.y - 60
							end
						end),
						walkout,
						MessageBox{message="Sonic: Alright! {p60}Where to Sal?"},
						PlayAudio("sfx", "nicolebeep", 1.0, true),
						Animate(sprites.sally.sprite, "nichole_project_start"),
						Do(function()
							fleet.x = scene.player.x - 60
							fleet.y = scene.player.y - 800

							sprites.sally.sprite:setAnimation("nichole_project_idle")
							nicole.transform = Transform(
								sprites.sally.sprite.transform.x,
								sprites.sally.sprite.transform.y + 70,
								2,
								2
							)
						end),
						Ease(nicole.color, 4, 220, 5),
						MessageBox{message="Sally: Let's see..."},
						Wait(1),
						PlayAudio("music", "rebellionfanfare", 1.0, true, true),
						Parallel {
							Serial {
								Ease(fleet, "y", function() return scene.player.y - 180 end, 0.5),
								Animate(fleet.sprite, "fleetland"),
								Animate(fleet.sprite, "fleetidle"),
								Do(function()
									logan.x = fleet.x + 10
									logan.y = fleet.y
									logan.sprite:setAnimation("idledown")
									ivan.x = fleet.x + 40
									ivan.y = fleet.y
									ivan.sprite:setAnimation("idledown")
								end),
								Parallel {
									Ease(logan, "x", function() return logan.x - 40 end, 2),
									Ease(ivan, "x", function() return ivan.x + 40 end, 2),
								}
							},
							MessageBox{message="Why are we stopping?"}
						},
						Animate(sprites.sonic.sprite, "idleup"),
						MessageBox{message="Sonic: Sal's gotta pull out the ol' directions--"},
						MessageBox{message="Fleet: Uhh...{p60}while we'd love to aimlessly wander around a swamp with you kids...{p60} we're not gonna do that."},
						Animate(fleet.sprite, "fleetsmile"),
						MessageBox{message="Fleet: We'll be taking the sky path."},
						Animate(ivan.sprite, "attitude"),
						MessageBox{message="Ivan: Indeed."},
						Ease(ivan, "x", function() return ivan.x - 40 end, 2),
						Do(function()
							ivan.hidden = true
						end),
						Animate(logan.sprite, "attitude"),
						MessageBox{message="Logan: Later, nerds!"},
						Ease(logan, "x", function() return logan.x + 40 end, 2),
						Do(function()
							logan.hidden = true
						end),
						Parallel {
							Animate(fleet.sprite, "fleettakeoff"),
							Serial {
								Ease(fleet, "y", function() return fleet.y - 100 end, 1, "quad"),
								Ease(fleet, "y", function() return fleet.y + 50 end, 1.6, "inout")
							}
						},
						PlayAudio("sfx", "sonicrunturn", 1.0, true),
						Ease(fleet, "y", function() return fleet.y - 800 end, 2, "quad"),
						AudioFade("music", 1.0, 0.0, 1),
						Ease(nicole.color, 4, 0, 5),
						Animate(sprites.sally.sprite, "idleup"),
						Animate(sprites.antoine.sprite, "idleup"),
						Animate(sprites.sonic.sprite, "irritated"),
						MessageBox{message="Sonic: Hmph! {p60}Good riddance! {p80}They were crampin' our style anyways!"},
						Animate(sprites.antoine.sprite, "idleleft"),
						Animate(sprites.sally.sprite, "thinking"),
						MessageBox{message="Sally: *sigh* {p80}So much for learning to work together..."},
						
						Do(function()
							scene.player.noMoveSpecial = false
						end),
						walkin,
						Do(function()
							scene.player.state = "idledown"
						end),
						Spawn(Serial {
							Wait(1),
							PlayAudio("music", "darkswamp", 1.0, true, true)
						})
					})
				end)
			}
		end
	end
	
	showTitle()
	return PlayAudio("music", "ironlock", 1.0, true, true)
end
