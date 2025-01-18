-- Bread-first search, assumes grid is two-dimensional array
local hashspace = function(space)
	return bit.bor(space[1], bit.lshift(space[2], 16))
end

local neighbors = {{0,-1},{1,-1},{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1}}

local bfs = function(grid, sx, sy, ex, ey)
	local start = {sx,sy}
	local goal = {ex,ey}
	local queue = {}
	table.insert(queue, 1, start)

	local path = {}
	while queue[1] ~= nil do
		local space = table.remove(queue)
		local cx = space[1]
		local cy = space[2]
		if cx == goal[1] and cy == goal[2] then
			break
		end

		for _,v in ipairs(neighbors) do
			local dx = v[1]
			local dy = v[2]
			local nextspace = {cx + dx, cy + dy}
			if path[hashspace(nextspace)] == nil and
			   grid[nextspace[2]] and
			   not grid[nextspace[2]][nextspace[1]]
			then
				print ("path nextspace x=" .. tostring(nextspace[1]) .. ", y=" .. tostring(nextspace[1]))
				path[hashspace(nextspace)] = space
				table.insert(queue, 1, nextspace)
			end
		end
	end
	print ("found path!!")

	-- Return path in reverse order because that's what we specifically want
	local finalPath = {}
	local current = goal
	while current ~= start do
		table.insert(finalPath, current)
		current = path[hashspace(current)]
	end
	return finalPath
end

return bfs