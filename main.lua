-- Compatibility
unpack = unpack or table.unpack
pack = table.pack or function(...) return {...} end

require "util/class"
require "util/trim"
require "util/split"
require "util/clone"
require "util/count"
require "util/wordwrap"

FontCache = {
	ConsolasLarge = love.graphics.newFont("art/fonts/consola.ttf", 36),
	Consolas = love.graphics.newFont("art/fonts/consola.ttf", 24),
	ConsolasSmall = love.graphics.newFont("art/fonts/consola.ttf", 14),
	Outline = love.graphics.newFont("art/fonts/outline.ttf", 36),
	Stonebangs = love.graphics.newFont("art/fonts/stonebangs.ttf", 42),
	TechnoSmall = love.graphics.newFont("art/fonts/techno.ttf", 24),
	TechnoMed = love.graphics.newFont("art/fonts/techno.ttf", 42),
	Techno = love.graphics.newFont("art/fonts/techno.ttf", 72),
}

CursorSprite = love.graphics.newImage("art/sprites/cursor.png")
CursorSprite:setFilter("nearest", "nearest")

ScreenShader = love.graphics.newShader([[
	extern vec4 multColor;

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
	{
		vec4 texturecolor = Texel(texture, texture_coords);
		return texturecolor * color * multColor;
	}
]])

GameState = (require "object/GameState")()

local sceneMgr = (require "scene/SceneManager")()
local fullScreen = false

function love.load()
    love.profiler = require "lib/profile"
    love.profiler.hookall("Lua")
	collectgarbage("stop")

	love.graphics.setShader(ScreenShader)
	
	math.randomseed(os.time())
	
	sceneMgr:pushScene {class = "SageSplashScene"}
end

function love.update(dt)
	-- Stay on top of your garbage lua!!
	collectgarbage("step")

    if love.keyboard.isDown("f") then
        dt = dt * 10
	elseif love.keyboard.isDown("s") then
        dt = dt / 4
    end

    sceneMgr:update(dt)
end

function love.draw()
    sceneMgr:draw()
end

local isDown = love.keyboard.isDown

love.keyboard.isDown = function(key)
	local dpadMapping = {
		up = function()
			return isDown("up") or (sceneMgr.gamepad and sceneMgr.gamepad:getAxis(2) < 0)
		end,

		down = function()
			return isDown("down") or (sceneMgr.gamepad and sceneMgr.gamepad:getAxis(2) > 0)
		end,

		left = function()
			return isDown("left") or (sceneMgr.gamepad and sceneMgr.gamepad:getAxis(1) < 0)
		end,

		right = function()
			return isDown("right") or (sceneMgr.gamepad and sceneMgr.gamepad:getAxis(1) > 0)
		end,

		lshift = function()
			return isDown("lshift") or (sceneMgr.gamepad and sceneMgr.gamepad:isDown(3))
		end
	}

	local fun = dpadMapping[key]
	if fun then
		return fun()
	else
		return isDown(key)
	end
end

function love.joystickadded(joystick)
	sceneMgr:joystickadded(joystick)
end

function love.joystickaxis(joystick, axis, value)
	-- Gamepad mapping
	-- x, y = self.sceneMgr.gamepad:getAxes()
	-- -1 = up
	-- 1 = down
	-- -1 = left
	-- 1 = right
	local dpadMapping = {
		["1"] = {["1"] = "right", ["-1"] = "left"},
		["2"] = {["1"] = "down",  ["-1"] = "up"},
	}

	if dpadMapping[tostring(axis)] then
		local val = dpadMapping[tostring(axis)][tostring(value)]
		sceneMgr:keypressed(val, val)
	end
	
	-- Hack: Map axis of l/r triggers to flat buttons (c)
	if (axis == 3 or axis == 6) then
		if value == 1 then
			love.joystickpressed(joystick, 5)
		else
			love.joystickreleased(joystick, 5)
		end
	end
end

function love.joystickpressed(joystick, button)
	-- 1 = "x"
	-- 2 = "a"
	-- 3 = "b"
	-- 4 = "y"
	-- 5 = "L"
	-- 6 = "R"
	-- 9 = "select"
	-- 10 = "start"
	local buttonMap = {
		[1] = "z",
		[2] = "x",
		--[3] = "lshift",
		[4] = "z",
		[5] = "c",
		[6] = "c"
	}

	local val = buttonMap[button]
    sceneMgr:keypressed(val, val)
end

function love.joystickreleased(joystick, button)
    local buttonMap = {
		[1] = "z",
		[2] = "x",
		--[3] = "lshift",
		[4] = "z",
		[5] = "c",
		[6] = "c"
	}

	local val = buttonMap[button]
    sceneMgr:keyreleased(val, val)
end

function love.keypressed(key, uni)
	if key == "tab" then
		if not fullScreen then
			love.window.setFullscreen(true, "exclusive")
		else
			love.window.setFullscreen(false, "desktop")
		end
		fullScreen = not fullScreen
	end

    sceneMgr:keypressed(key, uni)
end

function love.keyreleased(key, uni)
    sceneMgr:keyreleased(key, uni)
end

function love.mousepressed(x, y, button)
    sceneMgr:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    sceneMgr:mousereleased(x, y, button)
end
