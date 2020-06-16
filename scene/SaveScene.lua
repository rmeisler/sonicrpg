local Scene = require "scene/Scene"

local SplashScene = class(Scene)

function SplashScene:onEnter()
    --[[self.bgm = love.audio.newSource("audio/music/Musicbox.mp3", "static")
    self.bgm:setLooping(true)
    love.audio.play(self.bgm)--]]
end

function SplashScene:draw()
    love.graphics.print("Choose your file.", love.graphics.getWidth()/2 - 20, love.graphics.getHeight()/2)
end

function SplashScene:keytriggered(key, uni)
    if key == "return" then
        self.sceneMgr:switchScene{class="TestScene"}
    elseif key == "escape" then
        love.event.quit()
    end
end


return SplashScene