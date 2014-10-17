function love.run()
	if love.math then love.math.setRandomSeed(os.time(), os.time() % 19) end
	love.math.random() love.math.random()

	tickRate = .04
	tickDelta = 0
  interp = .1
	
	love.load(arg)

	delta = 0

	while true do
		love.timer.step()
		delta = love.timer.getDelta()
    if table.has(arg, 'fast') then delta = delta * 2 end

		tickDelta = tickDelta + delta
		while tickDelta >= tickRate do
			tickDelta = tickDelta - tickRate

			love.event.pump()
			for e, a, b, c, d in love.event.poll() do
				if e == 'quit' then
          f.exe(love.quit)
          if love.audio then love.audio.stop() end
          return
				else
          love.handlers[e](a, b, c, d)
        end
			end

			love.update()
		end

    if love.window and love.window.isCreated() then
      love.graphics.clear()
      love.draw()
      love.graphics.present()
    end

    love.timer.sleep(.001)
	end
end

function love.errhand(msg)
  msg = tostring(msg)

  print((debug.traceback('Error: ' .. tostring(msg), 1 + 2):gsub('\n[^\n]+$', '')))

  if not love.window or not love.graphics or not love.event then return end

  if not love.graphics.isCreated() or not love.window.isCreated() then
    if not pcall(love.window.setMode, 800, 600) then return end
  end

  -- Reset state.
  if love.mouse then
    love.mouse.setVisible(true)
    love.mouse.setGrabbed(false)
  end
  if love.joystick then
    for i,v in ipairs(love.joystick.getJoysticks()) do
      v:setVibration() -- Stop all joystick vibrations.
    end
  end
  if love.audio then love.audio.stop() end
  love.graphics.reset()
  love.graphics.setBackgroundColor(35, 35, 35)
  local font = love.graphics.setNewFont('media/fonts/pixel.ttf', 8)

  love.graphics.setColor(255, 255, 255, 255)

  local trace = debug.traceback()

  love.graphics.clear()
  love.graphics.origin()

  local err = {}

  for l in string.gmatch(trace, '(.-)\n') do
    if not string.match(l, 'boot.lua') then
      l = string.gsub(l, 'stack traceback:', 'stack trace:\n')
      table.insert(err, l)
    end
  end

  local p = table.concat(err, '\n')

  p = string.gsub(p, '\t', '')
  p = string.gsub(p, '%[string "(.-)"%]', '%1')

  local _, lines = font:getWrap(msg, love.graphics.getWidth() - 140)

  local function draw()
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.print('Muju Juju crashed =[\n\nhere\'s why:', 64, 64)
    love.graphics.setColor(192, 0, 0, 255)
    love.graphics.printf(msg, 64, 64 + font:getHeight() * 4, love.graphics.getWidth() - 64)
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.printf(p, 64, 64 + font:getHeight() * (5 + lines), love.graphics.getWidth() - 64)
    love.graphics.present()
  end

  while true do
    love.event.pump()

    for e, a, b, c in love.event.poll() do
      if e == 'quit' then return end
      if e == 'keypressed' and a == 'escape' then return end
    end

    draw()

    if love.timer then love.timer.sleep(0.1) end
  end
end
