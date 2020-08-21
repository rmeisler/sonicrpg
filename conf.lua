
function love.conf(t)
    t.identity = "sonicrpg"
    t.version = "0.10.2"
    t.console = false
    t.debug = false

    t.window.title = "Sonic RPG"
    t.window.icon = nil
    t.window.width = 800
    t.window.height = 600
    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = false
	t.window.centered = true
    t.window.vsync = true
    t.window.fsaa = 0
    t.window.display = 1
    t.window.highdpi = false
    t.window.srgb = false

    t.modules.physics = true
end