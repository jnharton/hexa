function love.conf(cfg)
	cfg.version = "0.10.2"
	cfg.console = false
    cfg.identity = 'hexa'
    
    -- window settings
	cfg.window.title = 'Global Game Jam 2017 -- Hexa'
    cfg.window.icon = nil
    
    cfg.window.width = 1300
    cfg.window.height = 680
    cfg.window.resizable = false
    
    -- disable unneeded modules
    cfg.modules.joystick = false
    cfg.modules.touch = false
    
    cfg.modules.physics = false
end