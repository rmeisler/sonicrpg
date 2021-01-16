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
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Data Center",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"3F",
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

	-- Find all the lasers
	local lasers = {
		Laser1_1 = scene.objectLookup.Laser1_1,
		Laser1_2 = scene.objectLookup.Laser1_2,
		Laser1_3 = scene.objectLookup.Laser1_3,
		Laser1_4 = scene.objectLookup.Laser1_4,
		Laser1_5 = scene.objectLookup.Laser1_5,
		Laser1_6 = scene.objectLookup.Laser1_6,
		
		Laser2_1 = scene.objectLookup.Laser2_1,
		Laser2_2 = scene.objectLookup.Laser2_2,
		Laser2_3 = scene.objectLookup.Laser2_3,
		Laser2_4 = scene.objectLookup.Laser2_4,
		Laser2_5 = scene.objectLookup.Laser2_5,
		Laser2_6 = scene.objectLookup.Laser2_6,
		
		Laser3_1 = scene.objectLookup.Laser3_1,
		Laser3_2 = scene.objectLookup.Laser3_2,
		Laser3_3 = scene.objectLookup.Laser3_3,
		Laser3_4 = scene.objectLookup.Laser3_4,
		Laser3_5 = scene.objectLookup.Laser3_5,
		Laser3_6 = scene.objectLookup.Laser3_6,
	}
	
	scene.laserPositions = {}
	for curName, laser in pairs(lasers) do
		if laser then
			scene.laserPositions[laser.name] = {x=laser.x, y=laser.y}
			laser.laserName = laser.name
		end
	end
	
	scene:addHandler("keytriggered", function(key)
		if key == "y" then
			local lasers = {
				Laser1_1 = scene.objectLookup.Laser1_1,
				Laser1_2 = scene.objectLookup.Laser1_2,
				Laser1_3 = scene.objectLookup.Laser1_3,
				Laser1_4 = scene.objectLookup.Laser1_4,
				Laser1_5 = scene.objectLookup.Laser1_5,
				Laser1_6 = scene.objectLookup.Laser1_6,
				
				Laser2_1 = scene.objectLookup.Laser2_1,
				Laser2_2 = scene.objectLookup.Laser2_2,
				Laser2_3 = scene.objectLookup.Laser2_3,
				Laser2_4 = scene.objectLookup.Laser2_4,
				Laser2_5 = scene.objectLookup.Laser2_5,
				Laser2_6 = scene.objectLookup.Laser2_6,
				
				Laser3_1 = scene.objectLookup.Laser3_1,
				Laser3_2 = scene.objectLookup.Laser3_2,
				Laser3_3 = scene.objectLookup.Laser3_3,
				Laser3_4 = scene.objectLookup.Laser3_4,
				Laser3_5 = scene.objectLookup.Laser3_5,
				Laser3_6 = scene.objectLookup.Laser3_6,
			}
			for loc, laser in pairs(lasers) do
				if laser then
					print("loc = "..loc..", laser = "..laser.laserName)
				end
			end
		end
	end)
	
	return Action()
end
