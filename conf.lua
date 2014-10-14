function love.conf(t)
	t.title = 'Muju Juju'
	t.console = false
  if arg[2] == 'server' then
    t.modules.audio = nil
    t.modules.window = nil
    t.modules.graphics = nil
    t.window = nil
  else
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    if false and arg[2] ~= 'local' then
      t.window.fullscreen = true
    end
    t.window.vsync = false
  end
end
