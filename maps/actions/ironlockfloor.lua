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
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Iron Lock",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.sectorName,
		100
	)
	
	local showTitle = function()
		Executor(scene):act(Serial {
			Wait(0.5),
			subtext,
			text,
			Parallel {
				Ease(subtext.color, 4, 255, 1),
			    Ease(text.color, 4, 255, 1)
			},
			Wait(2),
			Parallel {
				Ease(subtext.color, 4, 0, 1),
			    Ease(text.color, 4, 0, 1)
			}
		})
	end
	
	if hint == "thirdfloor" then
		showTitle()
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(2),
			Parallel {
				Ease(scene.objectLookup.Sonic, "y", scene.player.y - 98, 3, "linear"),
				Ease(scene.objectLookup.Sally, "y", scene.player.y + 60 - 98, 3, "linear"),
				Ease(scene.objectLookup.Antoine, "y", scene.player.y - 98, 3, "linear")
			},
			PlayAudio("sfx", "bang", 1.0, true),
			Animate(scene.objectLookup.Sonic.sprite, "dead"),
			Animate(scene.objectLookup.Sally.sprite, "dead"),
			Animate(scene.objectLookup.Antoine.sprite, "dead"),
			Wait(2.5),
			Animate(scene.objectLookup.Sonic.sprite, "idleright"),
			Animate(scene.objectLookup.Sally.sprite, "idleup"),
			Animate(scene.objectLookup.Antoine.sprite, "idleleft"),
			Wait(1.5),
			Do(function()
				scene.objectLookup.Sonic.sprite:setAnimation("walkup")
				scene.objectLookup.Sally.sprite:setAnimation("walkup")
				scene.objectLookup.Antoine.sprite:setAnimation("walkup")
			end),
			Parallel {
				Ease(scene.player, "y", function() return scene.player.y - 700 end, 0.3),
				Serial {
					Parallel {
						Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y - 700 end, 0.5, "linear"),
						Ease(scene.objectLookup.Antoine, "y", function() return scene.objectLookup.Antoine.y - 600 end, 0.5, "linear"),
						Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y - 700 end, 0.5, "linear")
					},
					Do(function()
						scene.objectLookup.Sonic.sprite:setAnimation("idleup")
						scene.objectLookup.Sally.sprite:setAnimation("idleup")
						scene.objectLookup.Antoine.sprite:setAnimation("idleup")
					end)
				}
			},
			PlayAudio("music", "patrol", 0.8, true, true),
			MessageBox{message="Antoine: Is zat--"},
			MessageBox{message="Sally: Yes. {p60}That looks like where they're keeping {h Project Firebird}..."},
			Animate(scene.objectLookup.Antoine.sprite, "scaredhop1"),
			MessageBox{message="Antoine: S-S-Should we be waiting for ze Rebels?"},
			Animate(scene.objectLookup.Sally.sprite, "thinking"),
			MessageBox{message="Sally: You're right, Antoine. {p60}Ugh! Where could they be?"},
			Animate(scene.objectLookup.Sonic.sprite, "irritated"),
			MessageBox{message="Sonic: Come on, Sal! Lemme at it! {p60}We don't need them! {p60}I can smash this bucket of bolts and blast us outta here before ya even know I'm gone!"},
			MessageBox{message="Sally: ..."},
			Animate(scene.objectLookup.Sally.sprite, "idleup"),
			MessageBox{message="Sally: Ok. {p60}Let's do it to it."},
			Animate(scene.objectLookup.Sonic.sprite, "pose"),
			MessageBox{message="Sonic: Alright, Sal!"},
			Parallel {
				MessageBox{message="Sally: I'll get the door. {p60}You keep watch, Antoine."},
				Serial {
					Do(function()
						scene.objectLookup.Sally.sprite:setAnimation("walkup")
					end),
					Parallel {
						Ease(scene.objectLookup.Sally, "x", function() return scene.objectLookup.Sally.x - 255 end, 1, "linear"),
						Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y - 150 end, 1, "linear")
					},
					Do(function()
						scene.objectLookup.Sally.sprite:setAnimation("idleup")
					end)
				},
				Serial {
					Do(function()
						scene.objectLookup.Sonic.sprite:setAnimation("walkup")
					end),
					Parallel {
						Ease(scene.objectLookup.Sonic, "x", function() return scene.objectLookup.Sonic.x + 50 end, 1, "linear"),
						Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y - 100 end, 1, "linear")
					},
					Do(function()
						scene.objectLookup.Sonic.sprite:setAnimation("idleup")
					end)
				}
			},
			Animate(scene.objectLookup.Antoine.sprite, "hideleft"),
			Wait(1),
			Animate(scene.objectLookup.Antoine.sprite, "peekleft"),
			Wait(1),
			Animate(scene.objectLookup.Antoine.sprite, "hideright"),
			Wait(0.5),
			
			Do(function()
				scene.objectLookup.Swatbot8.hidden = false
				scene.objectLookup.Swatbot8.sprite:setAnimation("walkup")
			end),
			
			Parallel {
				Serial {
					Ease(scene.objectLookup.Swatbot8, "y", scene.objectLookup.Swatbot8.y - 400, 0.5, "linear"),
					Do(function()
						scene.objectLookup.Swatbot8.hidden = false
						scene.objectLookup.Swatbot8.sprite:setAnimation("idleup")
					end)
				},
				Serial {
					Wait(1),
					Animate(scene.objectLookup.Antoine.sprite, "shock"),
					MessageBox{message="Antoine: !"}
				}
			},
			
			PlayAudio("music", "trouble", 1.0, true, true),
			MessageBox{message="Sonic: How's it looking back there, Ant?"},
			MessageBox{message="Antoine: Not so good, I am thinking!"},
			Animate(scene.objectLookup.Sonic.sprite, "idledown"),
			Wait(1),
			Animate(scene.objectLookup.Sonic.sprite, "pose"),
			MessageBox{message="Sonic: One swatbutt? {p60}You think that's enough to stop me!?"},
			Wait(0.5),
			Animate(scene.objectLookup.Sally.sprite, "idledown"),
			MessageBox{message="Snively: How about a dozen?"},
			
			Animate(scene.objectLookup.Sonic.sprite, "shock"),
			Animate(scene.objectLookup.Sally.sprite, "shock"),
			
			Parallel {
				Serial {
					Do(function()
						scene.objectLookup.Swatbot5.hidden = false
						scene.objectLookup.Swatbot6.hidden = false
						scene.objectLookup.Swatbot7.hidden = false
					end),
					Parallel {
						Serial {
							Wait(1),
							PlayAudio("music", "troublefanfare", 1.0, true),
							Do(function()
								scene.objectLookup.Swatbot4.sprite:setAnimation("walkleft")
								scene.objectLookup.Swatbot11.sprite:setAnimation("walkleft")
								scene.objectLookup.Swatbot9.sprite:setAnimation("walkleft")
								scene.objectLookup.Swatbot10.sprite:setAnimation("walkleft")
							end),
							Parallel {
								Ease(scene.objectLookup.Swatbot4, "x", scene.objectLookup.Swatbot4.x - 200, 1, "linear"),
								Ease(scene.objectLookup.Swatbot11, "x", scene.objectLookup.Swatbot11.x - 200, 1, "linear"),
								Ease(scene.objectLookup.Swatbot9, "x", scene.objectLookup.Swatbot9.x - 200, 1, "linear"),
								Ease(scene.objectLookup.Swatbot10, "x", scene.objectLookup.Swatbot10.x - 200, 1, "linear"),
							},
							Do(function()
								scene.objectLookup.Swatbot4.sprite:setAnimation("idleleft")
								scene.objectLookup.Swatbot11.sprite:setAnimation("idleleft")
								scene.objectLookup.Swatbot9.sprite:setAnimation("idleleft")
								scene.objectLookup.Swatbot10.sprite:setAnimation("idleleft")
							end),
						},
						Serial {
							Wait(1),
							Do(function()
								scene.objectLookup.Swatbot5.sprite:setAnimation("walkup")
								scene.objectLookup.Swatbot6.sprite:setAnimation("walkup")
								scene.objectLookup.Swatbot7.sprite:setAnimation("walkup")
							end),
							Parallel {
								Ease(scene.objectLookup.Swatbot5, "y", scene.objectLookup.Swatbot5.y - 400, 0.3, "linear"),
								Ease(scene.objectLookup.Swatbot6, "y", scene.objectLookup.Swatbot6.y - 400, 0.3, "linear"),
								Ease(scene.objectLookup.Swatbot7, "y", scene.objectLookup.Swatbot7.y - 400, 0.3, "linear")
							},
							Do(function()
								scene.objectLookup.Swatbot5.sprite:setAnimation("idleup")
								scene.objectLookup.Swatbot6.sprite:setAnimation("idleup")
								scene.objectLookup.Swatbot7.sprite:setAnimation("idleup")
							end)
						},
						Serial {
							Do(function()
								scene.objectLookup.Swatbot1.sprite:setAnimation("walkright")
								scene.objectLookup.Swatbot2.sprite:setAnimation("walkright")
								scene.objectLookup.Swatbot3.sprite:setAnimation("walkright")
								scene.objectLookup.Snively.sprite:setAnimation("walkright")
							end),
							Parallel {
								Ease(scene.objectLookup.Swatbot1, "x", scene.objectLookup.Swatbot1.x + 250, 1, "linear"),
								Ease(scene.objectLookup.Swatbot2, "x", scene.objectLookup.Swatbot2.x + 250, 1, "linear"),
								Ease(scene.objectLookup.Swatbot3, "x", scene.objectLookup.Swatbot3.x + 250, 1, "linear"),
								Ease(scene.objectLookup.Snively, "x", scene.objectLookup.Snively.x + 250, 1, "linear")
							},
							Do(function()
								scene.objectLookup.Swatbot1.sprite:setAnimation("idleright")
								scene.objectLookup.Swatbot2.sprite:setAnimation("idleright")
								scene.objectLookup.Swatbot3.sprite:setAnimation("idleright")
								scene.objectLookup.Snively.sprite:setAnimation("idleright_smile")
							end),
							Wait(4),
							Do(function()
								scene.objectLookup.Snively.sprite:setAnimation("idleright_laugh")
							end),
							Wait(1),
							MessageBox{message="Snively: Let him go. He's no threat without the Princess or Hedgehog."}
						}
					}
				},
			
				Serial {
					Wait(2),
					-- Scared hop
					Animate(scene.objectLookup.Antoine.sprite, "scaredhop1"),
					Wait(0.1),
					Animate(scene.objectLookup.Antoine.sprite, "tremble"),
					Animate(scene.objectLookup.Antoine.sprite, "scaredhop2"),
					Ease(scene.objectLookup.Antoine, "y", function() return scene.objectLookup.Antoine.y - 50 end, 7, "linear"),
					Animate(scene.objectLookup.Antoine.sprite, "scaredhop3"),
					Ease(scene.objectLookup.Antoine, "y", function() return scene.objectLookup.Antoine.y + 50 end, 7, "linear"),
					Animate(scene.objectLookup.Antoine.sprite, "scaredhop4"),
					Wait(0.1),
					Animate(scene.objectLookup.Antoine.sprite, "scaredhop5"),
					
					Wait(1),
					-- Run away
					Do(function() scene.objectLookup.Antoine.sprite:setAnimation("runscared") end),
					Wait(0.5),
					Ease(scene.objectLookup.Antoine, "x", function() return scene.objectLookup.Antoine.x + 400 end, 1)
				},
			},
			Wait(1),
			Do(function()
				scene:changeScene{map="ironlock4", fadeOutSpeed=0.5, fadeInSpeed=0.5}
			end)
		}
	end
	
	showTitle()
	return PlayAudio("music", "ironlock", 1.0, true, true)
end
