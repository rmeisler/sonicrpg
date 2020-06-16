local Task = class(require "actions/Action")

Task.idCounter = 1

function Task.SpawnThreads()
	-- Attempt to spin off n-threads where n is the number of physical cores
	for i=1,love.system.getProcessorCount()/2 do
		love.thread.newThread("util/resourcethread.lua"):start()
	end
end

function love.threaderror(thread, errormsg)
	print("error on thread "..errormsg)
end

function Task:construct(message)
	self.message = message
	self.message.id = Task.idCounter
	Task.idCounter = Task.idCounter + 1
	self.type = "Task"
end

function Task:setScene(scene)
	self.scene = scene
end

function Task:update(dt)
	if not self.sent then
		love.thread.getChannel("threadin"):push(self.message)
		self.sent = true
	end

	-- Listen for messages from resource threads notifying us
	-- that they finished loading an asset, and trigger the
	-- appropriate callback function on main thread
	local channel = love.thread.getChannel("threadout") 
	local res = channel:peek()
	if res and res.id == self.message.id then
		channel:pop()
		self[res.type.."_callback"](self, res)
		self.done = true
	end
end

function Task:image_callback(res)
	local img = love.graphics.newImage(res.object)
	img:setFilter("nearest", "nearest")

	-- Index in two ways. As unique basename and asset_folder/basename
	local name = res.file:match("/([%w_]+)%.")
	local namespacedName = res.file:match("/([%w_]+/[%w_]+)%.")
	
	self.scene.images[name] = img
	self.scene.images[namespacedName] = img

	-- If there's lua metadata related to this image, load it and cache it
	local metadata = love.filesystem.load(res.file:gsub("%..*", ".lua"))
	if metadata then
		local ref = metadata()
		self.scene.animations[name] = ref
		self.scene.animations[namespacedName] = ref
	end
end

function Task:sound_callback(res)
	res.object:setLooping(res.looping or false)
	res.object:setVolume(res.volume or 1.0)
	self.scene.audio:registerAs(res.category, res.file:match("/(%w+)%."), res.object)
end

function Task:gradient_callback(res)
	local gradient = love.graphics.newImage(res.object)
	gradient:setFilter('linear', 'linear')
	self.scene.images[res.name] = gradient
end

function Task:isDone()
	return self.done
end

function Task:reset()
	self.done = false
	self.sent = false
end


return Task
