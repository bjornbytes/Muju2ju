function love.conf(t)
	t.title = 'Muju Juju'
	t.console = false
  if arg[2] == 'server' then
    t.window = nil
  else
    t.window.width = 600
    t.window.height = 450
    t.window.resizable = true
    if arg[2] ~= 'local' then
      t.window.fullscreen = true
    end
    t.window.vsync = false
  end
end
