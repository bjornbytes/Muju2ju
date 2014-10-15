function love.conf(t)
  local function has(t, x)
    for _, v in pairs(t) do
      if v == x then return true end
    end
  end

	t.title = 'Muju Juju'
	t.console = false

  t.window.width = 800
  t.window.height = 600
  t.window.resizable = true
  t.window.vsync = false

  if has(arg, 'server') then
    t.modules.audio = nil
    t.modules.window = nil
    t.modules.graphics = nil
    t.window = nil
  end
end
