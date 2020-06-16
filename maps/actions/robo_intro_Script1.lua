local Do = require "actions/Do"

return function(scene)
	return Do(function()
		local swatbot = scene.objectLookup.Swatbot3
		swatbot.followStack = {"Waypoint8"}
		swatbot:postInit()
		swatbot.action:add(scene, Do(function() swatbot:remove() end))
	end)
end
