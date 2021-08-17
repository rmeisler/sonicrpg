return function(scene)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local BlockPlayer = require "actions/BlockPlayer"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	if GameState:isFlagSet("deathegg_first") then
		return Action()
	end
	
	GameState:setFlag("deathegg_first")
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"DEATH EGG",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"1F",
		100
	)
	
	-- Find elevator layer
	local elevatorLayer
	for _,layer in pairs(scene.map.layers) do
		if layer.name == "elevator" then
			elevatorLayer = layer
			break
		end
	end

	scene.player.state = "idledown"
	return BlockPlayer {
		Spawn(Serial {
			PlayAudio("music", "mission2", 1.0, true, true),
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
		}),

		Wait(2),
		Parallel {
			Ease(elevatorLayer, "offsety", 0, 0.2, "linear"),
			Ease(scene.player, "y", 608 - scene.player.sprite.h*2, 0.2, "linear"),
			Do(function()
				-- Update drop shadow position
                scene.player.dropShadow.x = scene.player.x - 22
				scene.player.dropShadow.y = scene.player.dropShadowOverrideY or scene.player.y + scene.player.sprite.h - 15
			end)
		},
		
		Do(function()
			GameState:addToParty("b", 1, true)
			scene.player.x = scene.player.x - 50
			local walkout, walkin, sprites = scene.player:split {
				GameState.party.sonic,
				GameState.party.bunny,
				GameState.party.b,
				GameState.party.sally
			}
			scene:run {
				walkout,
				Wait(1),
				Animate(sprites.b.sprite, "seriousdown"),
				MessageBox{message="B: This is as far as I can take you. {p60}The rest is up to you."},
				MessageBox{message="Sally: Thank you, B."},
				MessageBox{message="B: Good luck, Freedom Fighters."},
				Animate(sprites.b.sprite, "crouchdown"),
				Wait(0.5),
				Animate(sprites.b.sprite, "leapdown"),
				Ease(sprites.b, "y", function() return sprites.b.y - 100 end, 4, "linear"),
				Ease(sprites.b, "y", function() return sprites.b.y + 900 end, 4, "quad"),
				walkin,
				Do(function()
					GameState:removeFromParty("b")
					GameState.leader = "sonic"
					scene.player.x = scene.player.x + 100
					scene.player.y = scene.player.y + 50
				end)
			}
		end)
	}
	
end
