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

	scene.audio:playMusic("doittoit", 0.5)
	
	scene:addHandler(
		"update",
		function(dt)
			local px = scene.player.x
			local py = scene.player.y + scene.player.height
			
			-- Bottom left
			local a = {x=95, y=575}
			local b = {x=308, y=680}
			
			if py > a.y and py < b.y and px > a.x and px < b.x then
				local a_to_p = {x = px - a.x, y = py - a.y}
				local a_to_b = {x = b.x - a.x, y = b.y - a.y}
				local atb_sq = a_to_b.x * a_to_b.x + a_to_b.y * a_to_b.y
				local atp_dot_atb = a_to_p.x * a_to_b.x + a_to_p.y * a_to_b.y
				local t = atp_dot_atb / atb_sq
			
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

	return Action()
end
