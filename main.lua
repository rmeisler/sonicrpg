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
	--love.filesystem.setIdentity('screenshot');

	love.graphics.setShader(ScreenShader)
	
	
	sceneMgr:pushScene {class = "SageSplashScene"}
	
	
end

function love.update(dt)
	love.frame = 1--(love.frame or 0) + 1
    if love.frame % 100 == 0 then
        print(tostring(love.profiler.report('time', 20)))
        love.profiler.reset()
    end

    --[[if love.keyboard.isDown("f") then
        dt = dt * 10
	elseif love.keyboard.isDown("s") then
        dt = dt / 4
    end]]

    sceneMgr:update(dt)
end

function love.draw()
    sceneMgr:draw()
end

function love.keypressed(key, uni)
	
	

	if key == "]" then
     local screenshot = love.graphics.newScreenshot();
		screenshot:encode('png', os.time() .. '.png');
   end

	
	
   if key == "'" then
      local state = not love.mouse.isVisible()   -- the opposite of whatever it currently is
      love.mouse.setVisible(state)
   end

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
