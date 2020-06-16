local image = require "love.image"
local audio = require "love.audio"
local sound = require "love.sound"

local gradient = require "util/Gradient"

local input = love.thread.getChannel("threadin")
local output = love.thread.getChannel("threadout")

while true do
	local message = input:demand()
	local retValue = {}
	for k,v in pairs(message) do
		retValue[k] = v
	end
	
	if message.type == "sound" then
		retValue.object = audio.newSource(message.file, "static")
	elseif message.type == "image" then
		local img = image.newImageData(message.file)
		if message.processor then
			local args = {}
			for k,v in pairs(message) do
				if type(k) == "number" then
					args[k] = v
				end
			end
			img:mapPixel(loadstring(message.processor)(unpack(args)))
		end
		retValue.object = img
	elseif message.type == "gradient" then
		retValue.object = gradient(loadstring(message.args)())
	end
	
	output:push(retValue)
end
